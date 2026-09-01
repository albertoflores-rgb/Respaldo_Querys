-- =============================================================================
-- ADYACENCIAS DE CANASTA (Market Basket / Apriori) — Abarrotes, Impulso,
-- Perecederos, Fresh y Salud y Bienestar (EXCLUYE Mercancías Generales)
-- COMPARATIVO: Últimos 90 días (TY) vs mismo mes calendario completo, año
-- pasado (LY) -- para distinguir adyacencias EMERGENTES, ESTACIONALES o
-- CONSISTENTES en el tiempo.
-- =============================================================================
-- Modelo: Apriori clásico de 2 niveles, corrido EN PARALELO para 2 periodos:
--   Nivel 1 (itemsets frecuentes): se descartan items con soporte bajo ANTES
--            de generar pares -> evita la explosión combinatoria de cruzar
--            TODOS los items contra TODOS dentro de cada canasta. La poda de
--            soporte se hace POR PERIODO (un item puede ser frecuente en TY
--            y no en LY, o viceversa -- ej. un item nuevo que no existía
--            hace un año).
--   Nivel 2 (pares): self-join de canastas SOLO entre items frecuentes del
--            MISMO periodo (nunca se cruzan canastas de TY con LY).
--   Comparación: FULL OUTER JOIN de los resultados de TY y LY por
--            (item_a_id, item_b_id) -> un par puede salir fuerte en ambos
--            periodos, solo en uno, o en ninguno (se descarta si no es
--            fuerte en ninguno).
--
-- Fuentes:
--   ecom.Sams_Ventas                          -> líneas de venta (canasta = order_nbr)
--   SAMS_AD_HOC_COM.SAMS_CONTENIDO_CATALOGO   -> campo SQUAD -> bucket de negocio
--
-- MAPEO DE BUCKET (campo SQUAD real -> bucket de negocio pedido):
--   GROCERIES                            -> ABARROTES
--   IMPULSO                              -> IMPULSO
--   REFRIGERADOS, CONGELADOS Y BEBIDAS   -> PERECEDEROS
--   PRODUCE AND MEAT                     -> FRESH
--   SALUD Y BIENESTAR                    -> SALUD Y BIENESTAR
--   APPAREL / SEASONAL / TECHNOLOGY      -> (EXCLUIDO, es Mercancías Generales)
--
--  CAVEAT (heredado, sigue aplicando a ambos periodos): el cruce
--   sales_order_detail_item_id = CAST(ITEM_ID AS STRING) contra el
--   snapshot VIGENTE del catálogo solo matchea ~65% del revenue reciente.
--   Para LY el gap puede ser mayor si hubo items descontinuados hace más de
--   un año que ya no aparecen en el catálogo actual -- se documenta, no se
--   corrige aquí (ver Black_Bird.Catalogo_Cat_Compradores como fallback
--   futuro si el gap resulta material).
--
-- PERIODOS:
--   TY_90D          = últimos 90 días rodantes (hoy - 90 hasta hoy).
--   LY_MES_ANTERIOR = mes calendario ACTUAL, completo, pero del año pasado
--                     (ej. si hoy es 2-sep-2026, LY = 1 al 30-sep-2025
--                     completo, sin importar que septiembre 2026 apenas va
--                     a la mitad -- son referencias independientes, no se
--                     comparan volúmenes absolutos entre sí, solo fuerza de
--                     adyacencia dentro de cada uno).
--
-- CANASTA MÍNIMA DINÁMICA: ya no es un "4" fijo. Se calcula como el promedio
-- real de piezas (unidades) por transacción, sobre el universo calificado
-- (los 5 buckets, ventas válidas, TY+LY combinados) -> refleja el tamaño de
-- canasta real del negocio en vez de un número arbitrario. Se aplica EL
-- MISMO umbral a ambos periodos para que la comparación sea consistente
-- (si cada periodo tuviera su propio umbral, "fuerte en TY" y "fuerte en LY"
-- no serían comparables entre sí). Piso de seguridad: mínimo 2 items
-- (necesario para que exista un par).
-- =============================================================================

DECLARE ty_inicio DATE DEFAULT DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY);
DECLARE ty_fin    DATE DEFAULT CURRENT_DATE();
DECLARE ly_inicio DATE DEFAULT DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 1 YEAR);
DECLARE ly_fin    DATE DEFAULT LAST_DAY(ly_inicio);

DECLARE min_items_canasta INT64;                  -- dinámico, se calcula mas abajo (ya no hardcodeado)
DECLARE min_support       FLOAT64 DEFAULT 0.001;  -- 0.1% de las canastas -> poda Apriori nivel 1 (por periodo)
DECLARE min_confidence    FLOAT64 DEFAULT 0.05;   -- 5% mínimo en al menos una dirección
DECLARE min_lift          FLOAT64 DEFAULT 1.2;    -- lift > 1 = compran juntos más de lo esperado por azar
DECLARE top_n             INT64   DEFAULT 500;    -- aplicado via QUALIFY (LIMIT no acepta variables DECLARE en BigQuery)

-- -----------------------------------------------------------------------------
-- 1) Item -> bucket de negocio (dedup: snapshot de catálogo más reciente)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE catalogo_bucket AS
SELECT * FROM (
  SELECT
    CAST(ITEM_ID AS STRING) AS item_id,
    CASE
      WHEN SQUAD = 'GROCERIES' THEN 'ABARROTES'
      WHEN SQUAD = 'IMPULSO' THEN 'IMPULSO'
      WHEN SQUAD = 'REFRIGERADOS, CONGELADOS Y BEBIDAS' THEN 'PERECEDEROS'
      WHEN SQUAD = 'PRODUCE AND MEAT' THEN 'FRESH'
      WHEN SQUAD = 'SALUD Y BIENESTAR' THEN 'SALUD Y BIENESTAR'
      ELSE NULL  -- APPAREL/SEASONAL/TECHNOLOGY (Mercancias Generales) y cualquier otro -> fuera
    END AS bucket_negocio,
    ROW_NUMBER() OVER (PARTITION BY ITEM_ID ORDER BY FECHA_INTEGRACION DESC) AS rn
  FROM `wmt-mx-dl-controlledmgzn-prod.SAMS_AD_HOC_COM.SAMS_CONTENIDO_CATALOGO`
  WHERE ITEM_ID IS NOT NULL
)
WHERE rn = 1
  AND bucket_negocio IS NOT NULL;  -- excluye Mercancias Generales + sin clasificar

-- -----------------------------------------------------------------------------
-- 2) Líneas crudas (SIN dedup por item, se necesita la pieza real para el
--    umbral dinámico) de AMBOS periodos en un solo pase sobre Sams_Ventas,
--    etiquetadas con `periodo`
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
  cb.bucket_negocio
FROM `wmt-mx-dl-controlledmgzn-prod.ecom.Sams_Ventas` v
INNER JOIN catalogo_bucket cb
  ON v.sales_order_detail_item_id = cb.item_id
WHERE v.Estatus = 'VENTA'
  AND v.sales_order_detail_order_nbr IS NOT NULL
  AND (
    v.sales_order_detail_order_created_date BETWEEN ty_inicio AND ty_fin
    OR v.sales_order_detail_order_created_date BETWEEN ly_inicio AND ly_fin
  );

-- -----------------------------------------------------------------------------
-- 3) Umbral dinámico de canasta = promedio de piezas totales por transacción,
--    sobre el universo calificado (5 buckets, TY+LY combinados)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE piezas_por_orden AS
SELECT periodo, order_nbr, SUM(piezas) AS piezas_totales
FROM lineas_crudas
GROUP BY periodo, order_nbr;

SET min_items_canasta = (
  SELECT GREATEST(2, CAST(ROUND(AVG(piezas_totales)) AS INT64))
  FROM piezas_por_orden
);

-- -----------------------------------------------------------------------------
-- 4) Líneas calificadas: dedup por item dentro de cada canasta+periodo
--    (para Apriori nos importa presencia/ausencia del item, no su cantidad)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE lineas_calificadas AS
SELECT DISTINCT periodo, order_nbr, item_id, item_desc, bucket_negocio
FROM lineas_crudas;

-- -----------------------------------------------------------------------------
-- 5) Canastas calificadas por periodo: >= min_items_canasta (dinámico) items
--    distintos -- MISMO umbral para TY y LY, para que sean comparables
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE canastas_calificadas AS
SELECT periodo, order_nbr
FROM lineas_calificadas
GROUP BY periodo, order_nbr
HAVING COUNT(DISTINCT item_id) >= min_items_canasta;

CREATE TEMP TABLE canasta_items AS
SELECT lc.*
FROM lineas_calificadas lc
INNER JOIN canastas_calificadas cc USING (periodo, order_nbr);

-- Total de canastas calificadas POR PERIODO (denominador de soporte)
CREATE TEMP TABLE total_canastas AS
SELECT periodo, COUNT(DISTINCT order_nbr) AS n
FROM canasta_items
GROUP BY periodo;

-- -----------------------------------------------------------------------------
-- 6) NIVEL 1 (Apriori): itemsets de 1 item, poda por min_support, POR PERIODO
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE items_frecuentes AS
SELECT
  ci.periodo,
  ci.item_id,
  ANY_VALUE(ci.item_desc)      AS item_desc,
  ANY_VALUE(ci.bucket_negocio) AS bucket_negocio,
  COUNT(DISTINCT ci.order_nbr) AS canastas_con_item,
  SAFE_DIVIDE(COUNT(DISTINCT ci.order_nbr), ANY_VALUE(tc.n)) AS support_item
FROM canasta_items ci
INNER JOIN total_canastas tc ON tc.periodo = ci.periodo
GROUP BY ci.periodo, ci.item_id
HAVING SAFE_DIVIDE(COUNT(DISTINCT ci.order_nbr), ANY_VALUE(tc.n)) >= min_support;

-- -----------------------------------------------------------------------------
-- 7) NIVEL 2 (Apriori): pares de items frecuentes, self-join por canasta
--    DENTRO del mismo periodo (nunca se cruza TY con LY)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE pares_canasta AS
SELECT
  a.periodo,
  a.item_id AS item_a_id,
  b.item_id AS item_b_id,
  COUNT(DISTINCT a.order_nbr) AS canastas_con_ambos
FROM canasta_items a
INNER JOIN canasta_items b
  ON a.periodo = b.periodo
  AND a.order_nbr = b.order_nbr
  AND a.item_id < b.item_id
INNER JOIN items_frecuentes fa ON fa.periodo = a.periodo AND fa.item_id = a.item_id
INNER JOIN items_frecuentes fb ON fb.periodo = b.periodo AND fb.item_id = b.item_id
GROUP BY a.periodo, item_a_id, item_b_id;

-- -----------------------------------------------------------------------------
-- 8) Métricas por par y periodo: soporte, confianza (2 direcciones), lift
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE resultado_periodo AS
SELECT
  p.periodo,
  p.item_a_id, fa.item_desc AS item_a_desc, fa.bucket_negocio AS item_a_bucket,
  p.item_b_id, fb.item_desc AS item_b_desc, fb.bucket_negocio AS item_b_bucket,
  p.canastas_con_ambos,
  fa.canastas_con_item AS canastas_con_a,
  fb.canastas_con_item AS canastas_con_b,
  SAFE_DIVIDE(p.canastas_con_ambos, tc.n)              AS support_par,
  SAFE_DIVIDE(p.canastas_con_ambos, fa.canastas_con_item) AS confianza_a_b,
  SAFE_DIVIDE(p.canastas_con_ambos, fb.canastas_con_item) AS confianza_b_a,
  SAFE_DIVIDE(SAFE_DIVIDE(p.canastas_con_ambos, tc.n), fa.support_item * fb.support_item) AS lift
FROM pares_canasta p
INNER JOIN items_frecuentes fa ON fa.periodo = p.periodo AND fa.item_id = p.item_a_id
INNER JOIN items_frecuentes fb ON fb.periodo = p.periodo AND fb.item_id = p.item_b_id
INNER JOIN total_canastas tc   ON tc.periodo = p.periodo;

-- Flag "es fuerte" (columnas ya materializadas -> se puede referenciar lift/confianza directo)
CREATE TEMP TABLE resultado_periodo_flag AS
SELECT *,
  (lift >= min_lift AND GREATEST(confianza_a_b, confianza_b_a) >= min_confidence) AS es_fuerte
FROM resultado_periodo;

CREATE TEMP TABLE resultado_ty AS
SELECT
  item_a_id, item_a_desc, item_a_bucket, item_b_id, item_b_desc, item_b_bucket,
  canastas_con_ambos AS canastas_con_ambos_90d,
  support_par        AS support_90d,
  confianza_a_b       AS confianza_90d_a_b,
  confianza_b_a       AS confianza_90d_b_a,
  lift               AS lift_90d,
  es_fuerte          AS fuerte_90d
FROM resultado_periodo_flag
WHERE periodo = 'TY_90D';

CREATE TEMP TABLE resultado_ly AS
SELECT
  item_a_id, item_a_desc, item_a_bucket, item_b_id, item_b_desc, item_b_bucket,
  canastas_con_ambos AS canastas_con_ambos_ly,
  support_par        AS support_ly,
  confianza_a_b       AS confianza_ly_a_b,
  confianza_b_a       AS confianza_ly_b_a,
  lift               AS lift_ly,
  es_fuerte          AS fuerte_ly
FROM resultado_periodo_flag
WHERE periodo = 'LY_MES_ANTERIOR';

-- =============================================================================
-- RESULTADO FINAL: comparativo TY vs LY por par de items (FULL OUTER JOIN)
-- fuerte_90d / fuerte_ly / tipo_adyacencia son los campos que piden para
-- identificar si la adyacencia es fuerte en los ultimos 90 dias, en el mismo
-- mes del año pasado, en ambos (CONSISTENTE) o solo en uno (EMERGENTE /
-- ESTACIONAL-HISTORICA).
-- =============================================================================
SELECT
  min_items_canasta AS umbral_canasta_usado,  -- informativo: el umbral dinamico que se aplico
  COALESCE(t.item_a_id, l.item_a_id)         AS item_a_id,
  COALESCE(t.item_a_desc, l.item_a_desc)     AS item_a_desc,
  COALESCE(t.item_a_bucket, l.item_a_bucket) AS item_a_bucket,
  COALESCE(t.item_b_id, l.item_b_id)         AS item_b_id,
  COALESCE(t.item_b_desc, l.item_b_desc)     AS item_b_desc,
  COALESCE(t.item_b_bucket, l.item_b_bucket) AS item_b_bucket,
  t.canastas_con_ambos_90d, t.support_90d, t.confianza_90d_a_b, t.confianza_90d_b_a, t.lift_90d,
  IFNULL(t.fuerte_90d, FALSE) AS fuerte_90d,
  l.canastas_con_ambos_ly, l.support_ly, l.confianza_ly_a_b, l.confianza_ly_b_a, l.lift_ly,
  IFNULL(l.fuerte_ly, FALSE) AS fuerte_ly,
  CASE
    WHEN IFNULL(t.fuerte_90d, FALSE) AND IFNULL(l.fuerte_ly, FALSE) THEN 'CONSISTENTE (ambos periodos)'
    WHEN IFNULL(t.fuerte_90d, FALSE) AND NOT IFNULL(l.fuerte_ly, FALSE) THEN 'EMERGENTE (solo ultimos 90 dias)'
    WHEN NOT IFNULL(t.fuerte_90d, FALSE) AND IFNULL(l.fuerte_ly, FALSE) THEN 'ESTACIONAL/HISTORICA (solo mismo mes ano pasado)'
    ELSE 'DEBIL'
  END AS tipo_adyacencia
FROM resultado_ty t
FULL OUTER JOIN resultado_ly l
  ON t.item_a_id = l.item_a_id AND t.item_b_id = l.item_b_id
WHERE IFNULL(t.fuerte_90d, FALSE) OR IFNULL(l.fuerte_ly, FALSE)
QUALIFY ROW_NUMBER() OVER (
  ORDER BY GREATEST(IFNULL(t.lift_90d, 0), IFNULL(l.lift_ly, 0)) DESC,
           GREATEST(IFNULL(t.support_90d, 0), IFNULL(l.support_ly, 0)) DESC
) <= top_n
ORDER BY GREATEST(IFNULL(t.lift_90d, 0), IFNULL(l.lift_ly, 0)) DESC;
