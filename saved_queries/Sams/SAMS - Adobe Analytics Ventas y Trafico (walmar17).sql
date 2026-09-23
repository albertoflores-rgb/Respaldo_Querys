-- ============================================================================
-- SAMS - Adobe Analytics Ventas y Tráfico (Report Suite: walmar17)
-- ============================================================================
-- Objetivo: replicar en BigQuery las métricas estándar de un workspace de
-- Adobe Analytics Workspace (Visits, Orders, Units, Revenue, Conversion Rate,
-- AOV) desglosadas por fecha y por categoría de producto.
--
-- Fuente:  wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event
-- Tenant:  SAMS_MX   |   Report Suite Adobe: walmar17 (Sam's Club México)
--
--  CÓMO SE CONSTRUYÓ ESTE QUERY (léelo antes de usarlo en producción):
-- El link original del workspace de Adobe
--   https://experience.adobe.com/#/@walmartmexico/so:walmar17/analytics/spa/
--   #/workspace/edit/6a3e84979e2159550f26622f
-- requiere login SSO corporativo, así que no pudo inspeccionarse el contenido
-- real del proyecto (métricas/dimensiones/segmentos exactos que tú ves en
-- pantalla). Este query se armó 100% a partir de documentación de Confluence
-- (esquema CSD/AIP + diccionario de eVars/props de Sam's) replicando el
-- patrón MÁS COMÚN de un reporte de e-commerce (tráfico + ventas).
--
-- Si tu workspace en realidad muestra otra cosa (ej: impresiones pagadas vs
-- orgánicas, flujo de membresías, búsqueda interna, etc.), dímelo y ajusto
-- las CTEs de abajo — la estructura de "sesión" y "compra" no cambia, solo
-- qué extraes de cust_dim / prod_lst_txt.
--
-- Fuentes Confluence usadas:
--   - Use case of hive table mx_csd_secured_dl_tables (OIT)
--   - Daily Sales Aggregated View: LLD (OIT)
--   - Omni Analytics Adobe Data Dictionary (SABMI) — diccionario Sam's
--   - Migrations Adobe to ET-360 (OIT) — mapeo de impresiones Sam's
-- ============================================================================

DECLARE start_date DATE DEFAULT DATE_SUB(CURRENT_DATE('America/Mexico_City'), INTERVAL 30 DAY);
DECLARE end_date   DATE DEFAULT CURRENT_DATE('America/Mexico_City');

WITH base AS (
  SELECT
    ds,
    -- Sesión = visit_hi_id + visit_low_id + visit_nbr, con fallback a
    -- post_visid_hi_id/low_id cuando el identificador de visita viene nulo/0
    -- (patrón documentado en el LLD de wmt_mx_csd_adobe_event_ea).
    COALESCE(
      NULLIF(CONCAT(CAST(visit_hi_id AS STRING), '-', CAST(visit_low_id AS STRING), '-', CAST(visit_nbr AS STRING)), '--'),
      CONCAT(CAST(post_visid_hi_id AS STRING), '-', CAST(post_visid_low_id AS STRING))
    ) AS session_id,
    prch_id,
    dup_prch_ind,
    event_id_lst_txt,
    prod_lst_txt
  FROM `wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event`
  WHERE ds BETWEEN start_date AND end_date
),

visits AS (
  -- Métrica Visits: sesiones únicas por día
  SELECT ds, COUNT(DISTINCT session_id) AS visits
  FROM base
  GROUP BY ds
),

purchases AS (
  -- Métrica Orders: purchase_id únicos donde ocurrió el evento Adobe "1"
  -- (=compra), excluyendo compras duplicadas (dup_prch_ind = 0).
  SELECT ds, COUNT(DISTINCT prch_id) AS orders
  FROM base
  WHERE dup_prch_ind = 0
    AND '1' IN UNNEST(SPLIT(event_id_lst_txt, ','))
    AND prch_id IS NOT NULL
  GROUP BY ds
),

product_rows AS (
  -- prod_lst_txt viene como lista de productos separados por coma, cada uno
  -- con formato "category;UPC;quantity;revenue;evars...". Se desagrega con
  -- UNNEST y se extraen unidades/revenue por producto.
  SELECT
    ds,
    prch_id,
    SPLIT(product_item, ';')[SAFE_OFFSET(0)] AS category,
    SAFE_CAST(SPLIT(product_item, ';')[SAFE_OFFSET(2)] AS FLOAT64) AS units,
    SAFE_CAST(SPLIT(product_item, ';')[SAFE_OFFSET(3)] AS FLOAT64) AS revenue
  FROM base,
  UNNEST(SPLIT(prod_lst_txt, ',')) AS product_item
  WHERE dup_prch_ind = 0
    AND '1' IN UNNEST(SPLIT(event_id_lst_txt, ','))
    AND prod_lst_txt IS NOT NULL
),

sales_by_day AS (
  SELECT ds, SUM(units) AS units, SUM(revenue) AS revenue
  FROM product_rows
  GROUP BY ds
)

-- ============================================================================
-- QUERY 1: KPIs diarios (usar esto para la vista "resumen" del workspace)
-- ============================================================================
SELECT
  v.ds AS fecha,
  v.visits,
  COALESCE(p.orders, 0) AS orders,
  COALESCE(s.units, 0)  AS units,
  ROUND(COALESCE(s.revenue, 0), 2) AS revenue,
  ROUND(SAFE_DIVIDE(p.orders, v.visits) * 100, 2) AS conversion_rate_pct,
  ROUND(SAFE_DIVIDE(s.revenue, p.orders), 2) AS aov
FROM visits v
LEFT JOIN purchases p USING (ds)
LEFT JOIN sales_by_day s USING (ds)
ORDER BY fecha;

-- ============================================================================
-- QUERY 2: Desglose por categoría (comentar el bloque de arriba y correr
-- este si lo que necesitas es la tabla "por categoría" del workspace)
-- ============================================================================
-- SELECT
--   ds AS fecha,
--   category,
--   COUNT(DISTINCT prch_id) AS orders,
--   SUM(units)   AS units,
--   ROUND(SUM(revenue), 2) AS revenue
-- FROM product_rows
-- GROUP BY ds, category
-- ORDER BY fecha, revenue DESC;
