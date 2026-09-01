-- =============================================================================
-- ADYACENCIAS DE CANASTA (Market Basket / Apriori) — Abarrotes, Impulso,
-- Perecederos, Fresh y Salud y Bienestar (EXCLUYE Mercancías Generales)
-- =============================================================================
-- Modelo: Apriori clásico de 2 niveles.
--   Nivel 1 (itemsets frecuentes): se descartan items con soporte bajo ANTES
--            de generar pares -> evita la explosión combinatoria de cruzar
--            TODOS los items contra TODOS dentro de cada canasta (por eso es
--            "Apriori" y no un self-join ingenuo: solo generamos candidatos
--            de 2-itemsets a partir de 1-itemsets que ya probaron ser frecuentes).
--   Nivel 2 (pares): self-join de canastas SOLO entre items frecuentes ->
--            soporte, confianza (en ambas direcciones) y lift por par.
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
--  CAVEAT IMPORTANTE (validado en exploración previa):
--   El cruce Sams_Ventas.sales_order_detail_item_id = CAST(SAMS_CONTENIDO_
--   CATALOGO.ITEM_ID AS STRING) solo matchea ~65% del revenue (35% de items
--   vendidos no tienen fila vigente en el snapshot actual del catálogo -> SKUs
--   descontinuados, probablemente). Esos items simplemente NO entran al
--   análisis (ni cuentan para el tamaño de canasta ni generan pares). No es
--   un error, es la cobertura real de la única fuente que tiene estos 5
--   buckets con esta granularidad. Si se necesita mejor cobertura, el
--   siguiente paso sería agregar un fallback vía
--   `Black_Bird.Catalogo_Cat_Compradores` (campo DIRECCION, solo 4 buckets)
--   para los items sin match -- no incluido aquí por ahora (YAGNI hasta que
--   se confirme que el gap de cobertura afecta materialmente los resultados).
--
-- VENTANA DE FECHAS: por default últimos 90 días (afinidad de canasta
-- reciente es más accionable para adyacencias de anaquel/promos que mezclar
-- 2+ años de histórico con estacionalidades distintas). Ajustable abajo.
-- =============================================================================

DECLARE fecha_inicio      DATE    DEFAULT DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY);
DECLARE fecha_fin         DATE    DEFAULT CURRENT_DATE();
DECLARE min_items_canasta INT64   DEFAULT 4;      -- canasta calificada: >= 4 items distintos
DECLARE min_support       FLOAT64 DEFAULT 0.001;  -- 0.1% de las canastas -> poda Apriori nivel 1
DECLARE min_confidence    FLOAT64 DEFAULT 0.05;   -- 5% mínimo en al menos una dirección
DECLARE min_lift          FLOAT64 DEFAULT 1.2;    -- solo afinidad real (lift > 1 = compran juntos más de lo esperado por azar)
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
-- 2) Líneas calificadas: solo ventas válidas, en la ventana, de items de los
--    5 buckets (INNER JOIN ya excluye Mercancías Generales y sin clasificar)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE lineas_calificadas AS
SELECT DISTINCT
  v.sales_order_detail_order_nbr   AS order_nbr,
  v.sales_order_detail_item_id     AS item_id,
  v.sales_order_detail_item_short_desc AS item_desc,
  cb.bucket_negocio
FROM `wmt-mx-dl-controlledmgzn-prod.ecom.Sams_Ventas` v
INNER JOIN catalogo_bucket cb
  ON v.sales_order_detail_item_id = cb.item_id
WHERE v.Estatus = 'VENTA'
  AND v.sales_order_detail_order_created_date BETWEEN fecha_inicio AND fecha_fin
  AND v.sales_order_detail_order_nbr IS NOT NULL;

-- -----------------------------------------------------------------------------
-- 3) Canastas calificadas: order_nbr con >= min_items_canasta items distintos
--    (solo cuentan items de los 5 buckets, por diseño del paso anterior)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE canastas_calificadas AS
SELECT order_nbr
FROM lineas_calificadas
GROUP BY order_nbr
HAVING COUNT(DISTINCT item_id) >= min_items_canasta;

CREATE TEMP TABLE canasta_items AS
SELECT lc.*
FROM lineas_calificadas lc
INNER JOIN canastas_calificadas cc USING (order_nbr);

-- Total de canastas calificadas (denominador de soporte)
CREATE TEMP TABLE total_canastas AS
SELECT COUNT(DISTINCT order_nbr) AS n FROM canasta_items;

-- -----------------------------------------------------------------------------
-- 4) NIVEL 1 (Apriori): itemsets de 1 item, poda por min_support
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE items_frecuentes AS
SELECT
  item_id,
  ANY_VALUE(item_desc)     AS item_desc,
  ANY_VALUE(bucket_negocio) AS bucket_negocio,
  COUNT(DISTINCT order_nbr) AS canastas_con_item,
  SAFE_DIVIDE(COUNT(DISTINCT order_nbr), (SELECT n FROM total_canastas)) AS support_item
FROM canasta_items
GROUP BY item_id
HAVING SAFE_DIVIDE(COUNT(DISTINCT order_nbr), (SELECT n FROM total_canastas)) >= min_support;

-- -----------------------------------------------------------------------------
-- 5) NIVEL 2 (Apriori): pares de items frecuentes, self-join por canasta
--    (a.item_id < b.item_id evita duplicar el par y el caso item consigo mismo)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE pares_canasta AS
SELECT
  a.item_id AS item_a_id,
  b.item_id AS item_b_id,
  COUNT(DISTINCT a.order_nbr) AS canastas_con_ambos
FROM canasta_items a
INNER JOIN canasta_items b
  ON a.order_nbr = b.order_nbr
  AND a.item_id < b.item_id
INNER JOIN items_frecuentes fa ON fa.item_id = a.item_id
INNER JOIN items_frecuentes fb ON fb.item_id = b.item_id
GROUP BY item_a_id, item_b_id;

-- =============================================================================
-- RESULTADO: soporte, confianza (ambas direcciones) y lift por par de items
-- =============================================================================
SELECT
  p.item_a_id,
  fa.item_desc                                   AS item_a_desc,
  fa.bucket_negocio                              AS item_a_bucket,
  p.item_b_id,
  fb.item_desc                                   AS item_b_desc,
  fb.bucket_negocio                              AS item_b_bucket,
  p.canastas_con_ambos,
  fa.canastas_con_item                           AS canastas_con_a,
  fb.canastas_con_item                           AS canastas_con_b,
  ROUND(SAFE_DIVIDE(p.canastas_con_ambos, (SELECT n FROM total_canastas)), 6) AS support_par,
  ROUND(SAFE_DIVIDE(p.canastas_con_ambos, fa.canastas_con_item), 4)  AS confianza_a_a_b,  -- P(B|A)
  ROUND(SAFE_DIVIDE(p.canastas_con_ambos, fb.canastas_con_item), 4)  AS confianza_b_a_b,  -- P(A|B)
  ROUND(
    SAFE_DIVIDE(
      SAFE_DIVIDE(p.canastas_con_ambos, (SELECT n FROM total_canastas)),
      fa.support_item * fb.support_item
    ), 2
  ) AS lift
FROM pares_canasta p
INNER JOIN items_frecuentes fa ON fa.item_id = p.item_a_id
INNER JOIN items_frecuentes fb ON fb.item_id = p.item_b_id
WHERE
  SAFE_DIVIDE(
    SAFE_DIVIDE(p.canastas_con_ambos, (SELECT n FROM total_canastas)),
    fa.support_item * fb.support_item
  ) >= min_lift
  AND GREATEST(
    SAFE_DIVIDE(p.canastas_con_ambos, fa.canastas_con_item),
    SAFE_DIVIDE(p.canastas_con_ambos, fb.canastas_con_item)
  ) >= min_confidence
QUALIFY ROW_NUMBER() OVER (ORDER BY lift DESC, support_par DESC) <= top_n
ORDER BY lift DESC, support_par DESC;
