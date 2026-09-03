-- =============================================================================
-- ADYACENCIAS DE CANASTA (Market Basket / Apriori) ANCLADAS A UN ÍTEM ESPECÍFICO
-- Ítem objetivo: 981022806 ("FRUTAS ENCHILADAS", categoría 43 - Frutas y
-- Vegetales Enlatados/Deshidratados)
-- Universo de análisis: SOLO categorías 41 (Abarrotes Secos), 43 (Frutas y
-- Vegetales Enlatados), 46 (Aceites, Granos & Aderezos), 49 (Pastas y
-- Condimentos), 68 (Gourmet) -- filtro pedido explícitamente por el usuario,
-- vía sales_order_detail_category_id / Black_Bird.Catalogo_CatID.cat_id
-- (confirmado con catálogo: 41=ABARROTES SECOS, 43=FRUTAS Y VEGETALES
-- ENLATADOS, 46=ACEITES GRANOS & ADEREZOS, 49=PASTAS Y CONDIMENTOS,
-- 68=GOURMET -- las 5 caen dentro del fineline Abarrotes/Frutas y Verduras).
--
-- NOTA METODOLÓGICA (por qué difiere del query maestro
-- `query_adyacencias_canasta_apriori.sql`):
--   1) Filtro por CATEGORÍA (cat_id, viene directo en Sams_Ventas) y NO por
--      bucket de negocio (SQUAD) -> NO se necesita join contra
--      SAMS_AD_HOC_COM.SAMS_CONTENIDO_CATALOGO, por lo tanto NO aplica aquí
--      el caveat de cobertura ~65% del catálogo de proveedor (cobertura
--      completa, cat_id viene en la línea de venta).
--   2) Análisis ANCLADO a un solo ítem (981022806), no Apriori genérico
--      sobre todos los pares. El self-join de Nivel 2 se hace directo
--      contra las canastas que ya contienen el ítem objetivo -> barato
--      computacionalmente sin necesitar la poda combinatoria del estudio
--      general (1,001 ítems frecuentes x 1,001).
--   3) El ítem objetivo se conserva SIEMPRE en el análisis (aunque su
--      soporte esté al límite del umbral general, ver hallazgo abajo); la
--      poda min_support (Nivel 1 Apriori) sólo se aplica a los ÍTEMS
--      COMPAÑEROS candidatos (B), para no reportar ruido de ítems rarísimos.
--   4) Reescrito como SELECT puro con CTEs (sin DECLARE/SET/CREATE TEMP
--      TABLE) porque en esta sesión el CLI `bq` no tenía credenciales
--      vigentes (reauth requerida) -- se ejecuta vía bigquery_execute_query.
--      Si se corre por `bq query` más adelante, es funcionalmente
--      equivalente a la versión con DECLARE/TEMP TABLE.
--
-- HALLAZGO DE DIAGNÓSTICO (corrido ANTES de fijar cualquier umbral, tal como
-- exige el protocolo -- ver bigquery_results/diag-top20-ty-*.csv):
--   - Soporte del ítem objetivo dentro del universo de las 5 categorías:
--       TY_90D:   1,194 canastas / 1,042,376 totales = 0.1146% (pasa 0.1%)
--       LY (mes):   274 canastas /   277,960 totales = 0.0986% (NO pasa el
--                   0.1% general -- queda justo por debajo/al límite). Se
--                   documenta y se conserva el ítem por ser el objetivo
--                   explícito del análisis; es señal de volumen marginal
--                   en LY.
--   - Distribución de CONFIANZA (ambas direcciones, ítem objetivo <->
--     compañero, ya con la poda min_support=0.1% aplicada a los
--     compañeros -- este es el diagnóstico FORMAL, el mismo pipeline que
--     produce el resultado final; ver RESULTADO 2 al final del archivo y
--     bigquery_results/diagnostico-confianza-item-981022806-*.csv):
--         TY_90D (373 pares candidatos):
--           >=30%: 0 | >=20%: 0 | >=10%: 1 | >=5%: 19 | >=2%: 77 | máx observado: 11.27%
--         LY_MES_ANTERIOR (259 pares candidatos):
--           >=30%: 0 | >=20%: 0 | >=10%: 4 | >=5%: 11 | >=2%: 62 | máx observado: 14.55%
--     El umbral estándar de "venta cruzada real" (30%, validado en el
--     estudio general de 5 buckets de negocio) NO APLICA a este ítem: no
--     existe NINGÚN compañero que se compre junto con "Frutas Enchiladas"
--     en 30%, 20% ni siquiera 10% de sus canastas (salvo 1 caso límite en
--     TY y 4 en LY apenas sobre el 10%).
--     CONCLUSIÓN: este ítem NO tiene un compañero dominante de venta
--     cruzada concentrada -- su patrón de co-compra es de "cola larga":
--     se combina con MUCHOS ítems distintos (frutas deshidratadas, cereal,
--     café, leche, snacks saludables), cada uno en proporción baja (máximo
--     observado ~11-15%). Por eso el umbral de "fuerte" para ESTE análisis
--     se recalibra a partir de la distribución real (min_confidence = 2%),
--     documentado explícitamente -- NO es un umbral fijado a ojo: es el
--     punto que deja variedad real de candidatos (77/62 pares) sin
--     diluirse en ruido total (el salto de 5% a 2% ya es de 19->77 y
--     11->62, la cola es muy larga y plana).
-- =============================================================================

WITH parametros AS (
  SELECT
    '981022806' AS item_objetivo,
    DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY) AS ty_inicio,
    CURRENT_DATE() AS ty_fin,
    DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 1 YEAR) AS ly_inicio,
    LAST_DAY(DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 1 YEAR)) AS ly_fin,
    0.001 AS min_support,      -- 0.1% -- poda Nivel 1 SOLO para ítems compañeros (B)
    0.02  AS min_confidence,   -- 2% -- recalibrado para ESTE ítem, ver hallazgo arriba
    1.2   AS min_lift
),
lineas_categoria AS (
  SELECT
    CASE
      WHEN v.sales_order_detail_order_created_date BETWEEN p.ty_inicio AND p.ty_fin THEN 'TY_90D'
      WHEN v.sales_order_detail_order_created_date BETWEEN p.ly_inicio AND p.ly_fin THEN 'LY_MES_ANTERIOR'
    END AS periodo,
    v.sales_order_detail_order_nbr       AS order_nbr,
    v.sales_order_detail_item_id         AS item_id,
    v.sales_order_detail_item_short_desc AS item_desc,
    v.sales_order_detail_category_id     AS category_id,
    v.sales_order_detail_commercial_sale_qty_base AS piezas
  FROM `wmt-mx-dl-controlledmgzn-prod.ecom.Sams_Ventas` v
  CROSS JOIN parametros p
  WHERE v.Estatus = 'VENTA'
    AND v.sales_order_detail_category_id IN (41, 43, 46, 49, 68)
    AND v.sales_order_detail_order_nbr IS NOT NULL
    AND (
      v.sales_order_detail_order_created_date BETWEEN p.ty_inicio AND p.ty_fin
      OR v.sales_order_detail_order_created_date BETWEEN p.ly_inicio AND p.ly_fin
    )
),
resumen_orden AS (
  SELECT periodo, order_nbr, SUM(piezas) AS piezas_totales
  FROM lineas_categoria
  GROUP BY periodo, order_nbr
),
umbral_canasta AS (
  SELECT GREATEST(2, CAST(ROUND(AVG(piezas_totales) / 2) AS INT64)) AS min_items_canasta
  FROM resumen_orden
),
lineas_calificadas AS (
  SELECT DISTINCT periodo, order_nbr, item_id, item_desc, category_id
  FROM lineas_categoria
),
canastas_calificadas AS (
  SELECT periodo, order_nbr
  FROM lineas_calificadas
  GROUP BY periodo, order_nbr
  HAVING COUNT(DISTINCT item_id) >= (SELECT min_items_canasta FROM umbral_canasta)
),
canasta_items AS (
  SELECT lc.*
  FROM lineas_calificadas lc
  INNER JOIN canastas_calificadas cc USING (periodo, order_nbr)
),
total_canastas AS (
  SELECT periodo, COUNT(DISTINCT order_nbr) AS n
  FROM canasta_items
  GROUP BY periodo
),
items_soporte AS (
  SELECT
    ci.periodo,
    ci.item_id,
    ANY_VALUE(ci.item_desc)   AS item_desc,
    ANY_VALUE(ci.category_id) AS category_id,
    COUNT(DISTINCT ci.order_nbr) AS canastas_item,
    SAFE_DIVIDE(COUNT(DISTINCT ci.order_nbr), ANY_VALUE(tc.n)) AS support_item
  FROM canasta_items ci
  INNER JOIN total_canastas tc ON tc.periodo = ci.periodo
  GROUP BY ci.periodo, ci.item_id
),
items_frecuentes_companeros AS (
  SELECT s.*
  FROM items_soporte s
  CROSS JOIN parametros p
  WHERE s.support_item >= p.min_support
    AND s.item_id != p.item_objetivo
),
canastas_objetivo AS (
  SELECT ci.periodo, ci.order_nbr
  FROM canasta_items ci
  CROSS JOIN parametros p
  WHERE ci.item_id = p.item_objetivo
),
pares_ancla AS (
  SELECT
    co.periodo,
    ci.item_id AS companero_id,
    COUNT(DISTINCT co.order_nbr) AS canastas_con_ambos
  FROM canastas_objetivo co
  INNER JOIN canasta_items ci
    ON ci.periodo = co.periodo AND ci.order_nbr = co.order_nbr
  INNER JOIN items_frecuentes_companeros fc
    ON fc.periodo = ci.periodo AND fc.item_id = ci.item_id
  CROSS JOIN parametros p
  WHERE ci.item_id != p.item_objetivo
  GROUP BY co.periodo, companero_id
),
resultado_periodo AS (
  SELECT
    p.periodo,
    par.item_objetivo             AS item_a_id,
    obj.item_desc                 AS item_a_desc,
    p.companero_id                AS item_b_id,
    fc.item_desc                  AS item_b_desc,
    fc.category_id                AS item_b_category_id,
    p.canastas_con_ambos,
    obj.canastas_item             AS canastas_con_a,
    fc.canastas_item              AS canastas_con_b,
    SAFE_DIVIDE(p.canastas_con_ambos, tc.n)              AS support_par,
    SAFE_DIVIDE(p.canastas_con_ambos, obj.canastas_item) AS confianza_a_b,  -- P(B | compra objetivo)
    SAFE_DIVIDE(p.canastas_con_ambos, fc.canastas_item)  AS confianza_b_a,  -- P(objetivo | compra B)
    SAFE_DIVIDE(SAFE_DIVIDE(p.canastas_con_ambos, tc.n), obj.support_item * fc.support_item) AS lift
  FROM pares_ancla p
  CROSS JOIN parametros par
  INNER JOIN items_frecuentes_companeros fc ON fc.periodo = p.periodo AND fc.item_id = p.companero_id
  INNER JOIN items_soporte obj ON obj.periodo = p.periodo AND obj.item_id = par.item_objetivo
  INNER JOIN total_canastas tc ON tc.periodo = p.periodo
),
resultado_periodo_flag AS (
  SELECT rp.*,
    (rp.lift >= par.min_lift AND GREATEST(rp.confianza_a_b, rp.confianza_b_a) >= par.min_confidence) AS es_fuerte
  FROM resultado_periodo rp
  CROSS JOIN parametros par
),
resultado_ty AS (
  SELECT item_a_id, item_a_desc, item_b_id, item_b_desc, item_b_category_id,
    canastas_con_ambos AS canastas_con_ambos_ty, support_par AS support_ty,
    confianza_a_b AS confianza_ty_a_b, confianza_b_a AS confianza_ty_b_a,
    lift AS lift_ty, es_fuerte AS fuerte_ty
  FROM resultado_periodo_flag WHERE periodo = 'TY_90D'
),
resultado_ly AS (
  SELECT item_a_id, item_a_desc, item_b_id, item_b_desc, item_b_category_id,
    canastas_con_ambos AS canastas_con_ambos_ly, support_par AS support_ly,
    confianza_a_b AS confianza_ly_a_b, confianza_b_a AS confianza_ly_b_a,
    lift AS lift_ly, es_fuerte AS fuerte_ly
  FROM resultado_periodo_flag WHERE periodo = 'LY_MES_ANTERIOR'
)
-- =============================================================================
-- RESULTADO 1: comparativo TY (últimos 90 días) vs LY (mismo mes calendario,
-- año pasado) de adyacencias del ítem 981022806 dentro de categorías
-- 41/43/46/49/68. tipo_adyacencia clasifica CONSISTENTE / EMERGENTE /
-- ESTACIONAL-HISTÓRICA / DÉBIL igual que el query maestro.
-- =============================================================================
SELECT
  (SELECT min_items_canasta FROM umbral_canasta) AS umbral_canasta_usado,
  (SELECT min_confidence FROM parametros)        AS umbral_confianza_fuerte_usado,  -- 2%, recalibrado (ver nota)
  COALESCE(t.item_a_id, l.item_a_id)         AS item_objetivo_id,
  COALESCE(t.item_a_desc, l.item_a_desc)     AS item_objetivo_desc,
  COALESCE(t.item_b_id, l.item_b_id)         AS item_companero_id,
  COALESCE(t.item_b_desc, l.item_b_desc)     AS item_companero_desc,
  COALESCE(t.item_b_category_id, l.item_b_category_id) AS item_companero_category_id,
  t.canastas_con_ambos_ty, t.support_ty, t.confianza_ty_a_b, t.confianza_ty_b_a, t.lift_ty,
  IFNULL(t.fuerte_ty, FALSE) AS fuerte_ty,
  l.canastas_con_ambos_ly, l.support_ly, l.confianza_ly_a_b, l.confianza_ly_b_a, l.lift_ly,
  IFNULL(l.fuerte_ly, FALSE) AS fuerte_ly,
  CASE
    WHEN IFNULL(t.fuerte_ty, FALSE) AND IFNULL(l.fuerte_ly, FALSE) THEN 'CONSISTENTE (ambos periodos)'
    WHEN IFNULL(t.fuerte_ty, FALSE) AND NOT IFNULL(l.fuerte_ly, FALSE) THEN 'EMERGENTE (solo ultimos 90 dias)'
    WHEN NOT IFNULL(t.fuerte_ty, FALSE) AND IFNULL(l.fuerte_ly, FALSE) THEN 'ESTACIONAL/HISTORICA (solo mismo mes ano pasado)'
    ELSE 'DEBIL'
  END AS tipo_adyacencia
FROM resultado_ty t
FULL OUTER JOIN resultado_ly l
  ON t.item_b_id = l.item_b_id
WHERE IFNULL(t.fuerte_ty, FALSE) OR IFNULL(l.fuerte_ly, FALSE)
QUALIFY ROW_NUMBER() OVER (
  ORDER BY GREATEST(IFNULL(t.lift_ty, 0), IFNULL(l.lift_ly, 0)) DESC,
           GREATEST(IFNULL(t.confianza_ty_a_b,0), IFNULL(l.confianza_ly_a_b,0)) DESC
) <= 100
ORDER BY GREATEST(IFNULL(t.lift_ty, 0), IFNULL(l.lift_ly, 0)) DESC;

-- =============================================================================
-- RESULTADO 2: diagnóstico FORMAL de distribución de confianza (mismo
-- pipeline de poda que el RESULTADO 1) -- documenta por qué NO se usa el
-- umbral estándar de 30% de venta cruzada para este ítem específico.
-- Nota: requiere volver a declarar las CTEs (BigQuery no permite reusar un
-- WITH de un statement anterior en otro statement dentro del mismo archivo
-- sin CREATE TEMP TABLE) -- ejecutar como query independiente.
-- =============================================================================
WITH parametros AS (
  SELECT
    '981022806' AS item_objetivo,
    DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY) AS ty_inicio,
    CURRENT_DATE() AS ty_fin,
    DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 1 YEAR) AS ly_inicio,
    LAST_DAY(DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 1 YEAR)) AS ly_fin,
    0.001 AS min_support
),
lineas_categoria AS (
  SELECT
    CASE
      WHEN v.sales_order_detail_order_created_date BETWEEN p.ty_inicio AND p.ty_fin THEN 'TY_90D'
      WHEN v.sales_order_detail_order_created_date BETWEEN p.ly_inicio AND p.ly_fin THEN 'LY_MES_ANTERIOR'
    END AS periodo,
    v.sales_order_detail_order_nbr       AS order_nbr,
    v.sales_order_detail_item_id         AS item_id,
    v.sales_order_detail_item_short_desc AS item_desc,
    v.sales_order_detail_category_id     AS category_id,
    v.sales_order_detail_commercial_sale_qty_base AS piezas
  FROM `wmt-mx-dl-controlledmgzn-prod.ecom.Sams_Ventas` v
  CROSS JOIN parametros p
  WHERE v.Estatus = 'VENTA'
    AND v.sales_order_detail_category_id IN (41, 43, 46, 49, 68)
    AND v.sales_order_detail_order_nbr IS NOT NULL
    AND (
      v.sales_order_detail_order_created_date BETWEEN p.ty_inicio AND p.ty_fin
      OR v.sales_order_detail_order_created_date BETWEEN p.ly_inicio AND p.ly_fin
    )
),
resumen_orden AS (
  SELECT periodo, order_nbr, SUM(piezas) AS piezas_totales
  FROM lineas_categoria GROUP BY periodo, order_nbr
),
umbral_canasta AS (
  SELECT GREATEST(2, CAST(ROUND(AVG(piezas_totales) / 2) AS INT64)) AS min_items_canasta
  FROM resumen_orden
),
lineas_calificadas AS (
  SELECT DISTINCT periodo, order_nbr, item_id, item_desc, category_id FROM lineas_categoria
),
canastas_calificadas AS (
  SELECT periodo, order_nbr FROM lineas_calificadas
  GROUP BY periodo, order_nbr
  HAVING COUNT(DISTINCT item_id) >= (SELECT min_items_canasta FROM umbral_canasta)
),
canasta_items AS (
  SELECT lc.* FROM lineas_calificadas lc
  INNER JOIN canastas_calificadas cc USING (periodo, order_nbr)
),
total_canastas AS (
  SELECT periodo, COUNT(DISTINCT order_nbr) AS n FROM canasta_items GROUP BY periodo
),
items_soporte AS (
  SELECT ci.periodo, ci.item_id, ANY_VALUE(ci.item_desc) AS item_desc,
    COUNT(DISTINCT ci.order_nbr) AS canastas_item,
    SAFE_DIVIDE(COUNT(DISTINCT ci.order_nbr), ANY_VALUE(tc.n)) AS support_item
  FROM canasta_items ci INNER JOIN total_canastas tc ON tc.periodo = ci.periodo
  GROUP BY ci.periodo, ci.item_id
),
items_frecuentes_companeros AS (
  SELECT s.* FROM items_soporte s CROSS JOIN parametros p
  WHERE s.support_item >= p.min_support AND s.item_id != p.item_objetivo
),
canastas_objetivo AS (
  SELECT ci.periodo, ci.order_nbr FROM canasta_items ci CROSS JOIN parametros p
  WHERE ci.item_id = p.item_objetivo
),
pares_ancla AS (
  SELECT co.periodo, ci.item_id AS companero_id, COUNT(DISTINCT co.order_nbr) AS canastas_con_ambos
  FROM canastas_objetivo co
  INNER JOIN canasta_items ci ON ci.periodo = co.periodo AND ci.order_nbr = co.order_nbr
  INNER JOIN items_frecuentes_companeros fc ON fc.periodo = ci.periodo AND fc.item_id = ci.item_id
  CROSS JOIN parametros p
  WHERE ci.item_id != p.item_objetivo
  GROUP BY co.periodo, companero_id
),
metricas AS (
  SELECT p.periodo,
    SAFE_DIVIDE(p.canastas_con_ambos, obj.canastas_item) AS confianza_a_b,
    SAFE_DIVIDE(p.canastas_con_ambos, fc.canastas_item)  AS confianza_b_a
  FROM pares_ancla p
  CROSS JOIN parametros par
  INNER JOIN items_frecuentes_companeros fc ON fc.periodo = p.periodo AND fc.item_id = p.companero_id
  INNER JOIN items_soporte obj ON obj.periodo = p.periodo AND obj.item_id = par.item_objetivo
)
SELECT
  periodo,
  COUNT(*) AS pares_candidatos_totales,
  COUNTIF(GREATEST(confianza_a_b, confianza_b_a) >= 0.30) AS pares_conf_ge_30pct,
  COUNTIF(GREATEST(confianza_a_b, confianza_b_a) >= 0.20) AS pares_conf_ge_20pct,
  COUNTIF(GREATEST(confianza_a_b, confianza_b_a) >= 0.10) AS pares_conf_ge_10pct,
  COUNTIF(GREATEST(confianza_a_b, confianza_b_a) >= 0.05) AS pares_conf_ge_05pct,
  COUNTIF(GREATEST(confianza_a_b, confianza_b_a) >= 0.02) AS pares_conf_ge_02pct,
  ROUND(MAX(GREATEST(confianza_a_b, confianza_b_a)) * 100, 2) AS confianza_maxima_pct
FROM metricas
GROUP BY periodo;
