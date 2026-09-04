-- =============================================================================
-- PILOTO: Venta cruzada ANCLADA a 4 SKUs (uno por bucket de negocio),
-- buscando complementos en TODO EL UNIVERSO de los 5 buckets (no solo
-- intra-bucket) -- se reporta el bucket real de cada complemento encontrado.
--
-- ANCLAS:
--   Fresh:              981029562 - AGUACATE HASS
--   Abarrotes:          000094422 - 1 KG NUTELLA CREMA   (SKU corregido:
--                        981009432 es "500GR PASTA FUSILLI", NO Nutella --
--                        dato mal mapeado en la lista fuente original)
--   Impulso:            981003552 - 24/600 ML GATORADE
--   Salud y Bienestar:  000146120 - 6/100ML COLGATE MFP  (LPAD a 9 digitos,
--                        el campo nativo en Sams_Ventas es '000146120')
--
-- =============================================================================
-- *** HALLAZGO CRÍTICO NUEVO (corrige un supuesto documentado previamente) ***
-- El caveat histórico decía "el join item_id = CAST(ITEM_ID AS STRING) solo
-- matchea ~65% del revenue, probablemente SKUs descontinuados". Se validó
-- ESO hoy con un diagnóstico de longitud de ITEM_ID en el catálogo:
--   LEN=3: 781 | LEN=4: 3,409 | LEN=5: 128,285 | LEN=6: 336,954 | LEN=9: 3,016,812
-- Es decir, ~469K items (13.5% del catálogo) tienen MENOS de 9 dígitos.
-- `sales_order_detail_item_id` en Sams_Ventas SIEMPRE viene con 9 dígitos
-- (padded con ceros a la izquierda, validado: 12,002,499 filas de TY_90D,
-- el 100% con LENGTH=9). CAST(ITEM_ID AS STRING) en el catálogo NO conserva
-- los ceros a la izquierda (94422 -> '94422', no '000094422') -> el join
-- viejo NUNCA matchea ningún SKU de <9 dígitos, aunque sí esté vigente en
-- catálogo. Prueba con datos reales (TY_90D, monto total $4,503.8M):
--   Join viejo (sin LPAD):        $2,820.6M matcheado = 62.6%
--   Join corregido (con LPAD 9):  $4,495.3M matcheado = 99.8%
-- CONCLUSIÓN: el "35% sin match" NO era mayormente SKUs descontinuados --
-- era un bug de formato de string. La cobertura REAL del catálogo (una vez
-- corregido el join) es ~99.8% del revenue, no ~65%. Este script usa el
-- JOIN CORREGIDO (LPAD a 9 dígitos en ambos lados). Se recomienda aplicar
-- el mismo fix a `query_adyacencias_canasta_apriori.sql` (pendiente,
-- reportado en el resumen ejecutivo de esta corrida).
-- =============================================================================
--
-- METODOLOGÍA (extiende el patrón de
-- query_adyacencias_item_981022806_cat_41_43_46_49_68.sql a 4 anclas y al
-- UNIVERSO COMPLETO de negocio en vez de restringir a categorías):
--   1) Universo = los 5 buckets de negocio (via SQUAD, catálogo), ventas
--      VENTA reales, TY_90D + LY_MES_ANTERIOR.
--   2) Umbral de canasta calificada: dinámico, GREATEST(2, AVG(piezas)/2),
--      MISMO valor para ambos periodos (igual que el query maestro).
--   3) Nivel 1 Apriori (poda min_support=0.1%) se aplica a TODOS los items
--      del universo (los complementos candidatos deben ser frecuentes) --
--      pero las 4 ANCLAS se CONSERVAN SIEMPRE aunque no pasen la poda (igual
--      criterio que el analisis de item unico anterior).
--   4) Nivel 2: self-join de canastas restringido a pares donde UN lado es
--      una de las 4 anclas (no se generan pares entre no-anclas, evita la
--      explosión combinatoria general) y el otro lado es cualquier item
--      frecuente de CUALQUIER bucket (busqueda cross-bucket real).
--   5) Comparativo TY vs LY + clasificación CONSISTENTE/EMERGENTE/ESTACIONAL
--      igual que el query maestro.
--   6) Venta cruzada real: para cada ancla, valida el umbral de confianza
--      con COUNTIF a 70/50/40/30/20/10% (diagnostico, SELECT 1) ANTES de
--      fijar el umbral final (ver decision documentada mas abajo tras correr
--      el diagnostico).
-- =============================================================================

DECLARE ty_inicio DATE DEFAULT DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY);
DECLARE ty_fin    DATE DEFAULT CURRENT_DATE();
DECLARE ly_inicio DATE DEFAULT DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 1 YEAR);
DECLARE ly_fin    DATE DEFAULT LAST_DAY(ly_inicio);

DECLARE min_items_canasta INT64;
DECLARE min_support    FLOAT64 DEFAULT 0.001;  -- poda Nivel 1, aplica a companeros (no a anclas)
DECLARE min_confidence FLOAT64 DEFAULT 0.05;   -- umbral "fuerte" general (igual que query maestro)
DECLARE min_lift       FLOAT64 DEFAULT 1.2;
DECLARE top_n_por_ancla INT64  DEFAULT 10;
DECLARE min_confidence_venta_cruzada FLOAT64 DEFAULT 0.30;  -- default heredado del estudio general; se re-valida con diagnostico (SELECT 1) antes de usarse en el resumen ejecutivo (SELECT 4)

CREATE TEMP TABLE anchors AS
SELECT * FROM UNNEST([
  STRUCT('981029562' AS item_id, 'FRESH' AS bucket_ancla, 'AGUACATE HASS' AS desc_ancla),
  STRUCT('000094422' AS item_id, 'ABARROTES' AS bucket_ancla, '1 KG NUTELLA CREMA' AS desc_ancla),
  STRUCT('981003552' AS item_id, 'IMPULSO' AS bucket_ancla, '24/600 ML GATORADE' AS desc_ancla),
  STRUCT('000146120' AS item_id, 'SALUD Y BIENESTAR' AS bucket_ancla, 'COLGATE MFP' AS desc_ancla)
]);

-- -----------------------------------------------------------------------------
-- 1) Item -> bucket de negocio (dedup + JOIN CORREGIDO con LPAD a 9 digitos)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE catalogo_bucket AS
SELECT * FROM (
  SELECT
    LPAD(CAST(ITEM_ID AS STRING), 9, '0') AS item_id,  -- FIX: preserva match con Sams_Ventas (9 digitos siempre)
    CASE
      WHEN SQUAD = 'GROCERIES' THEN 'ABARROTES'
      WHEN SQUAD = 'IMPULSO' THEN 'IMPULSO'
      WHEN SQUAD = 'REFRIGERADOS, CONGELADOS Y BEBIDAS' THEN 'PERECEDEROS'
      WHEN SQUAD = 'PRODUCE AND MEAT' THEN 'FRESH'
      WHEN SQUAD = 'SALUD Y BIENESTAR' THEN 'SALUD Y BIENESTAR'
      ELSE NULL
    END AS bucket_negocio,
    ROW_NUMBER() OVER (PARTITION BY ITEM_ID ORDER BY FECHA_INTEGRACION DESC) AS rn
  FROM `wmt-mx-dl-controlledmgzn-prod.SAMS_AD_HOC_COM.SAMS_CONTENIDO_CATALOGO`
  WHERE ITEM_ID IS NOT NULL
)
WHERE rn = 1 AND bucket_negocio IS NOT NULL;

-- -----------------------------------------------------------------------------
-- 2) Lineas crudas, universo completo (5 buckets), ambos periodos
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE lineas_crudas AS
SELECT
  CASE
    WHEN v.sales_order_detail_order_created_date BETWEEN ty_inicio AND ty_fin THEN 'TY_90D'
    WHEN v.sales_order_detail_order_created_date BETWEEN ly_inicio AND ly_fin THEN 'LY_MES_ANTERIOR'
  END AS periodo,
  v.sales_order_detail_order_nbr       AS order_nbr,
  v.sales_order_detail_item_id         AS item_id,
  v.sales_order_detail_item_short_desc AS item_desc,
  v.sales_order_detail_commercial_sale_qty_base AS piezas,
  v.sales_order_detail_net_paid_orders_wo_shipping_amount_1 AS monto,
  cb.bucket_negocio
FROM `wmt-mx-dl-controlledmgzn-prod.ecom.Sams_Ventas` v
INNER JOIN catalogo_bucket cb ON v.sales_order_detail_item_id = cb.item_id
WHERE v.Estatus = 'VENTA'
  AND v.sales_order_detail_order_nbr IS NOT NULL
  AND (
    v.sales_order_detail_order_created_date BETWEEN ty_inicio AND ty_fin
    OR v.sales_order_detail_order_created_date BETWEEN ly_inicio AND ly_fin
  );

-- -----------------------------------------------------------------------------
-- 3) Resumen por orden + umbral dinamico de canasta calificada
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE resumen_orden AS
SELECT periodo, order_nbr, SUM(piezas) AS piezas_totales, SUM(monto) AS monto_total
FROM lineas_crudas
GROUP BY periodo, order_nbr;

SET min_items_canasta = (
  SELECT GREATEST(2, CAST(ROUND(AVG(piezas_totales) / 2) AS INT64))
  FROM resumen_orden
);

CREATE TEMP TABLE lineas_calificadas AS
SELECT DISTINCT periodo, order_nbr, item_id, item_desc, bucket_negocio FROM lineas_crudas;

CREATE TEMP TABLE canastas_calificadas AS
SELECT periodo, order_nbr FROM lineas_calificadas
GROUP BY periodo, order_nbr
HAVING COUNT(DISTINCT item_id) >= min_items_canasta;

CREATE TEMP TABLE canasta_items AS
SELECT lc.* FROM lineas_calificadas lc
INNER JOIN canastas_calificadas cc USING (periodo, order_nbr);

CREATE TEMP TABLE total_canastas AS
SELECT periodo, COUNT(DISTINCT order_nbr) AS n FROM canasta_items GROUP BY periodo;

-- -----------------------------------------------------------------------------
-- 4) Nivel 1 Apriori: soporte de TODOS los items del universo, por periodo
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE items_soporte AS
SELECT
  ci.periodo, ci.item_id,
  ANY_VALUE(ci.item_desc)      AS item_desc,
  ANY_VALUE(ci.bucket_negocio) AS bucket_negocio,
  COUNT(DISTINCT ci.order_nbr) AS canastas_item,
  SAFE_DIVIDE(COUNT(DISTINCT ci.order_nbr), ANY_VALUE(tc.n)) AS support_item
FROM canasta_items ci
INNER JOIN total_canastas tc ON tc.periodo = ci.periodo
GROUP BY ci.periodo, ci.item_id;

CREATE TEMP TABLE items_frecuentes AS
SELECT * FROM items_soporte WHERE support_item >= min_support;

-- Anclas: se conservan SIEMPRE (aunque no pasen min_support), igual criterio
-- que el analisis de item unico previo (981022806)
CREATE TEMP TABLE anchors_soporte AS
SELECT s.*, a.bucket_ancla, a.desc_ancla
FROM items_soporte s
INNER JOIN anchors a ON a.item_id = s.item_id;

-- -----------------------------------------------------------------------------
-- 5) Nivel 2: self-join SOLO ancla <-> item frecuente (cualquier bucket)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE pares_ancla_canasta AS
SELECT
  ca.periodo,
  ca.item_id AS anchor_id,
  cb2.item_id AS companion_id,
  COUNT(DISTINCT ca.order_nbr) AS canastas_con_ambos
FROM canasta_items ca
INNER JOIN anchors an ON an.item_id = ca.item_id
INNER JOIN canasta_items cb2
  ON cb2.periodo = ca.periodo AND cb2.order_nbr = ca.order_nbr AND cb2.item_id != ca.item_id
INNER JOIN items_frecuentes fc ON fc.periodo = cb2.periodo AND fc.item_id = cb2.item_id
GROUP BY ca.periodo, anchor_id, companion_id;

-- -----------------------------------------------------------------------------
-- 6) Metricas por par (ancla, companero) y periodo
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE resultado_periodo AS
SELECT
  p.periodo,
  p.anchor_id, aso.desc_ancla AS anchor_desc, aso.bucket_ancla AS anchor_bucket,
  p.companion_id, fc.item_desc AS companion_desc, fc.bucket_negocio AS companion_bucket,
  p.canastas_con_ambos,
  aso.canastas_item AS canastas_con_anchor,
  fc.canastas_item  AS canastas_con_companion,
  SAFE_DIVIDE(p.canastas_con_ambos, tc.n) AS support_par,
  SAFE_DIVIDE(p.canastas_con_ambos, aso.canastas_item) AS conf_ancla_a_comp,   -- P(comprar companero | compro ancla)
  SAFE_DIVIDE(p.canastas_con_ambos, fc.canastas_item)  AS conf_comp_a_ancla,   -- P(comprar ancla | compro companero)
  SAFE_DIVIDE(SAFE_DIVIDE(p.canastas_con_ambos, tc.n), aso.support_item * fc.support_item) AS lift
FROM pares_ancla_canasta p
INNER JOIN anchors_soporte aso ON aso.periodo = p.periodo AND aso.item_id = p.anchor_id
INNER JOIN items_frecuentes fc ON fc.periodo = p.periodo AND fc.item_id = p.companion_id
INNER JOIN total_canastas tc   ON tc.periodo = p.periodo;

CREATE TEMP TABLE resultado_periodo_flag AS
SELECT *,
  (lift >= min_lift AND GREATEST(conf_ancla_a_comp, conf_comp_a_ancla) >= min_confidence) AS es_fuerte
FROM resultado_periodo;

CREATE TEMP TABLE resultado_ty AS
SELECT anchor_id, anchor_desc, anchor_bucket, companion_id, companion_desc, companion_bucket,
  canastas_con_ambos AS canastas_ambos_ty, support_par AS support_ty,
  conf_ancla_a_comp AS conf_ty_ancla_a_comp, conf_comp_a_ancla AS conf_ty_comp_a_ancla,
  lift AS lift_ty, es_fuerte AS fuerte_ty
FROM resultado_periodo_flag WHERE periodo = 'TY_90D';

CREATE TEMP TABLE resultado_ly AS
SELECT anchor_id, anchor_desc, anchor_bucket, companion_id, companion_desc, companion_bucket,
  canastas_con_ambos AS canastas_ambos_ly, support_par AS support_ly,
  conf_ancla_a_comp AS conf_ly_ancla_a_comp, conf_comp_a_ancla AS conf_ly_comp_a_ancla,
  lift AS lift_ly, es_fuerte AS fuerte_ly
FROM resultado_periodo_flag WHERE periodo = 'LY_MES_ANTERIOR';

CREATE TEMP TABLE comparativo AS
SELECT
  COALESCE(t.anchor_id, l.anchor_id)         AS anchor_id,
  COALESCE(t.anchor_desc, l.anchor_desc)     AS anchor_desc,
  COALESCE(t.anchor_bucket, l.anchor_bucket) AS anchor_bucket,
  COALESCE(t.companion_id, l.companion_id)         AS companion_id,
  COALESCE(t.companion_desc, l.companion_desc)     AS companion_desc,
  COALESCE(t.companion_bucket, l.companion_bucket) AS companion_bucket,
  t.canastas_ambos_ty, t.support_ty, t.conf_ty_ancla_a_comp, t.conf_ty_comp_a_ancla, t.lift_ty,
  IFNULL(t.fuerte_ty, FALSE) AS fuerte_ty,
  l.canastas_ambos_ly, l.support_ly, l.conf_ly_ancla_a_comp, l.conf_ly_comp_a_ancla, l.lift_ly,
  IFNULL(l.fuerte_ly, FALSE) AS fuerte_ly,
  CASE
    WHEN IFNULL(t.fuerte_ty, FALSE) AND IFNULL(l.fuerte_ly, FALSE) THEN 'CONSISTENTE (ambos periodos)'
    WHEN IFNULL(t.fuerte_ty, FALSE) AND NOT IFNULL(l.fuerte_ly, FALSE) THEN 'EMERGENTE (solo ultimos 90 dias)'
    WHEN NOT IFNULL(t.fuerte_ty, FALSE) AND IFNULL(l.fuerte_ly, FALSE) THEN 'ESTACIONAL/HISTORICA (solo mismo mes ano pasado)'
    ELSE 'DEBIL'
  END AS tipo_adyacencia
FROM resultado_ty t
FULL OUTER JOIN resultado_ly l ON t.anchor_id = l.anchor_id AND t.companion_id = l.companion_id
WHERE IFNULL(t.fuerte_ty, FALSE) OR IFNULL(l.fuerte_ly, FALSE);

-- =============================================================================
-- SELECT 1: DIAGNOSTICO de distribucion de confianza por ancla (TY_90D),
-- sobre TODOS los pares candidatos (no solo los "fuertes") -- se corre ANTES
-- de fijar el umbral de venta cruzada, tal como exige el protocolo.
-- =============================================================================
SELECT
  anchor_desc, anchor_bucket,
  COUNT(*) AS pares_candidatos_ty,
  COUNTIF(GREATEST(conf_ty_ancla_a_comp, conf_ty_comp_a_ancla) >= 0.70) AS ge_70pct,
  COUNTIF(GREATEST(conf_ty_ancla_a_comp, conf_ty_comp_a_ancla) >= 0.50) AS ge_50pct,
  COUNTIF(GREATEST(conf_ty_ancla_a_comp, conf_ty_comp_a_ancla) >= 0.40) AS ge_40pct,
  COUNTIF(GREATEST(conf_ty_ancla_a_comp, conf_ty_comp_a_ancla) >= 0.30) AS ge_30pct,
  COUNTIF(GREATEST(conf_ty_ancla_a_comp, conf_ty_comp_a_ancla) >= 0.20) AS ge_20pct,
  COUNTIF(GREATEST(conf_ty_ancla_a_comp, conf_ty_comp_a_ancla) >= 0.10) AS ge_10pct,
  ROUND(MAX(GREATEST(conf_ty_ancla_a_comp, conf_ty_comp_a_ancla)) * 100, 2) AS conf_maxima_pct
FROM resultado_ty
GROUP BY anchor_desc, anchor_bucket
ORDER BY anchor_desc;

-- =============================================================================
-- SELECT 2: TOP N complementos por ancla (comparativo TY vs LY), buscando en
-- TODO el universo de 5 buckets (companion_bucket puede ser distinto de
-- anchor_bucket -- eso es precisamente lo pedido: cross-bucket).
-- =============================================================================
SELECT
  min_items_canasta AS umbral_canasta_usado,
  anchor_id, anchor_desc, anchor_bucket,
  companion_id, companion_desc, companion_bucket,
  canastas_ambos_ty, support_ty, conf_ty_ancla_a_comp, conf_ty_comp_a_ancla, lift_ty, fuerte_ty,
  canastas_ambos_ly, support_ly, conf_ly_ancla_a_comp, conf_ly_comp_a_ancla, lift_ly, fuerte_ly,
  tipo_adyacencia
FROM comparativo
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY anchor_id
  ORDER BY GREATEST(IFNULL(lift_ty,0), IFNULL(lift_ly,0)) DESC,
           GREATEST(IFNULL(support_ty,0), IFNULL(support_ly,0)) DESC
) <= top_n_por_ancla
ORDER BY anchor_desc, GREATEST(IFNULL(lift_ty,0), IFNULL(lift_ly,0)) DESC;

-- -----------------------------------------------------------------------------
-- 7) VENTA CRUZADA REAL por ancla: pares con confianza >= umbral validado
--    (30% default, ver SELECT 1 para confirmar si aplica a cada ancla), y
--    canastas/monto REALES capturados en TY_90D (basket completo, no solo
--    el par) -- 1 canasta se cuenta una sola vez aunque matchee mas de un
--    companero del mismo ancla (DISTINCT order_nbr).
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE pares_venta_cruzada_por_ancla AS
SELECT anchor_id, anchor_desc, anchor_bucket, companion_id, companion_desc, companion_bucket,
  conf_ty_ancla_a_comp, conf_ty_comp_a_ancla, lift_ty
FROM comparativo
WHERE GREATEST(IFNULL(conf_ty_ancla_a_comp,0), IFNULL(conf_ty_comp_a_ancla,0)) >= min_confidence_venta_cruzada;

CREATE TEMP TABLE canastas_venta_cruzada_ancla AS
SELECT DISTINCT pvc.anchor_id, pvc.anchor_desc, pvc.anchor_bucket, ca.order_nbr
FROM canasta_items ca
INNER JOIN pares_venta_cruzada_por_ancla pvc ON pvc.anchor_id = ca.item_id AND ca.periodo = 'TY_90D'
INNER JOIN canasta_items cb2 ON cb2.periodo = 'TY_90D' AND cb2.order_nbr = ca.order_nbr AND cb2.item_id = pvc.companion_id;

-- =============================================================================
-- SELECT 3: monto/canastas capturado POR PAR (para anexar a cada complemento
-- del top-N de SELECT 2) -- basket completo (todos los items de la orden),
-- no solo el valor de los 2 items del par.
-- =============================================================================
CREATE TEMP TABLE ordenes_por_par_ty AS
SELECT DISTINCT ca.item_id AS anchor_id, cb2.item_id AS companion_id, ca.order_nbr
FROM canasta_items ca
INNER JOIN anchors an ON an.item_id = ca.item_id AND ca.periodo = 'TY_90D'
INNER JOIN canasta_items cb2 ON cb2.periodo = 'TY_90D' AND cb2.order_nbr = ca.order_nbr AND cb2.item_id != ca.item_id
INNER JOIN comparativo comp ON comp.anchor_id = ca.item_id AND comp.companion_id = cb2.item_id;

CREATE TEMP TABLE ordenes_por_par_ly AS
SELECT DISTINCT ca.item_id AS anchor_id, cb2.item_id AS companion_id, ca.order_nbr
FROM canasta_items ca
INNER JOIN anchors an ON an.item_id = ca.item_id AND ca.periodo = 'LY_MES_ANTERIOR'
INNER JOIN canasta_items cb2 ON cb2.periodo = 'LY_MES_ANTERIOR' AND cb2.order_nbr = ca.order_nbr AND cb2.item_id != ca.item_id
INNER JOIN comparativo comp ON comp.anchor_id = ca.item_id AND comp.companion_id = cb2.item_id;

SELECT
  o.anchor_id, o.companion_id,
  COUNT(DISTINCT o.order_nbr) AS canastas_capturadas_ty,
  ROUND(SUM(ro.monto_total), 2) AS monto_capturado_ty
FROM ordenes_por_par_ty o
INNER JOIN resumen_orden ro ON ro.periodo = 'TY_90D' AND ro.order_nbr = o.order_nbr
GROUP BY o.anchor_id, o.companion_id;

-- =============================================================================
-- SELECT 4: RESUMEN EJECUTIVO por ancla (venta cruzada real @ umbral
-- validado en SELECT 1) -- para decidir si se escala a los 79 SKUs.
-- =============================================================================
SELECT
  cvca.anchor_desc, cvca.anchor_bucket,
  (SELECT COUNT(*) FROM pares_venta_cruzada_por_ancla p WHERE p.anchor_id = cvca.anchor_id) AS pares_alta_confianza,
  COUNT(DISTINCT cvca.order_nbr) AS canastas_venta_cruzada_ty,
  (SELECT canastas_item FROM anchors_soporte WHERE item_id = cvca.anchor_id AND periodo = 'TY_90D') AS canastas_totales_ancla_ty,
  ROUND(SAFE_DIVIDE(
    COUNT(DISTINCT cvca.order_nbr),
    (SELECT canastas_item FROM anchors_soporte WHERE item_id = cvca.anchor_id AND periodo = 'TY_90D')
  ) * 100, 2) AS pct_canastas_ancla_con_cruce,
  (SELECT ROUND(SUM(ro.monto_total), 2)
   FROM (SELECT DISTINCT order_nbr FROM canastas_venta_cruzada_ancla c2 WHERE c2.anchor_id = cvca.anchor_id) d
   INNER JOIN resumen_orden ro ON ro.order_nbr = d.order_nbr AND ro.periodo = 'TY_90D') AS monto_capturado_ty
FROM canastas_venta_cruzada_ancla cvca
GROUP BY cvca.anchor_id, cvca.anchor_desc, cvca.anchor_bucket
ORDER BY monto_capturado_ty DESC;
