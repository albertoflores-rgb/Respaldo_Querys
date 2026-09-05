-- ============================================================
-- SAMS - Adobe Impresiones Item (Investigacion) v3.sql
-- Estado  : DRAFT / NO EJECUTADO -- NO correr contra BQ sin antes
--           hacer dry_run y pedir luz verde explicita de Alberto
--           (costo esperado MUCHO mayor que v2, ver seccion de
--           COSTO al final -- v2 solo tocaba prod_lst_txt en 2
--           chnl_txt; esta version toca casi toda la tabla,
--           incluyendo `cust_dim` que es RECORD REPEATED pesado).
-- Fecha   : 05-sep-2026
-- Objetivo: replicar, a nivel ITEM (Product ID / eVar168), las
--           columnas del reporte nativo de Adobe Analytics
--           Workspace exportado por Alberto:
--           "Item Nutrioli - Product ID (evar168).csv"
--           (Report suite: MX - Sams Club | Rango: Sep 1-3, 2026 |
--            Segmento: "Abarrotes Sam's Alberto" | 13,962 items)
--
--           Columnas del CSV a replicar:
--             Product Views, Search Results - Item Impressions
--             (Hit level) [Total / In Stock / Out of Stock],
--             Units, Cart Additions, ATC Rate, Bounce Rate (%),
--             Orders, Revenue, Revenue/Order, Conversion Rate,
--             OOS Product Views (ev62), In Stock Product Views (ev63)
--
-- BASE: construye sobre el patron YA VALIDADO en
--       "SAMS - Adobe Impresiones Item (Investigacion) v2.sql"
--       (misma tabla fuente, mismo parsing de prod_lst_txt/eVar168).
--       v2 solo cubria "Ocurrencias" (impresiones search+browse).
--       Esta v3 EXTIENDE ese patron a todo el resto del funnel.
-- ============================================================
-- TABLA FUENTE (igual que v1/v2):
--   wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event
--   -> VIEW sobre TABLA EXTERNA (ORC) particionada por `ds` (DATE).
--   -> op_cmpny_cd = 'SAMS-MX' es el filtro de banner.
-- ============================================================
-- MAPEO CONFIRMADO CON DATOS REALES (exploracion 05-sep-2026,
-- via bigquery-explorer, SIEMPRE con ds='2026-09-02' + LIMIT bajo):
--
-- | Metrica CSV                    | Fuente BQ confirmada                                          | Confianza |
-- |---------------------------------|----------------------------------------------------------------|-----------|
-- | Search Impressions (ev492)      | chnl_txt IN ('searchResults','browseResults'), eVar168 en      | ALTA (=v2)|
-- |   Total / In Stock / Out Stock  | prod_lst_txt, split por eVar97 ("In Stock"/"Out of Stock")     |           |
-- | Product Views                   | chnl_txt='productPage' AND page_nm='productPage:productPage', | ALTA      |
-- |                                  | 1 producto por hit, eVar168 confirmado presente                |           |
-- | OOS/In Stock Product Views      | Mismo hit de Product Views, split por eVar97                    | ALTA      |
-- |   (ev62 / ev63)                 | (eVar97 real; el codigo literal ev62/ev63 NO existe en          |           |
-- |                                  | event_id_lst_txt -- es nomenclatura de la capa Adobe UI)       |           |
-- | Units / Revenue / Orders        | chnl_txt='checkout' AND page_nm='checkout:thankYou',            | ALTA      |
-- |                                  | prod_lst_txt: campo[1]=Item_Nbr, [2]=qty, [3]=revenue_linea;   |           |
-- |                                  | Orders = COUNT(DISTINCT prch_id) por item                      |           |
-- | Cart Additions                  | cust_dim: key IN ('evar85','post_evar85') AND value='addToCart' | MEDIA -- SOLO TOTAL SITIO/DIA, NO CONFIABLE POR ITEM (ver nota) |
-- | ATC Rate                        | Cart Additions / Product Views                                  | HEREDA la limitante de arriba |
-- | Bounce Rate                     | visita (cust_visid_id,visit_nbr) con MAX(visit_page_nbr)=1,     | MEDIA -- bounce por ITEM asume que el item de la visita es el visto en el hit visit_page_nbr=1 |
-- |                                  | atribuida al item visto en el hit de entrada (visit_page_nbr=1) |           |
-- | Conversion Rate                 | Orders / Product Views (definicion ASUMIDA, ver caveat)         | BAJA -- Adobe no expone el denominador real de esta metrica calculada en los datos crudos |
--
-- CAVEAT CRITICO -- Cart Additions / ATC Rate por ITEM:
--   El hit de "addToCart" (post_evar85='addToCart') es un hit de
--   LINK TRACKING (chnl_txt/page_nm vienen NULL). En la muestra
--   explorada, 4 de 5 hits de este tipo traen `prod_lst_txt` VACIO
--   -- es decir, Adobe NO adjunta el eVar168 del producto agregado
--   en la mayoria de estos hits. Se encontro un candidato
--   (`prop27`/`post_prop27` con formato de SKU) en 2 de esas 4
--   filas, pero SIN validar contra catalogo ni contra mas muestras.
--   POR ESO esta v3 reporta Cart Additions SOLO como TOTAL DEL
--   SITIO (no por item) hasta que se confirme `prop27` o se
--   consiga el diccionario oficial de eventos Adobe con el equipo
--   de Analytics. NO INVENTAR el desglose por item.
--
-- CAVEAT -- Conversion Rate:
--   No se pudo confirmar con los datos crudos si el reporte nativo
--   de Adobe usa Orders/Visits u Orders/Product Views como
--   denominador (es una Calculated Metric configurada en Adobe
--   Workspace, no algo que viva en la tabla). Esta v3 usa
--   Orders/Product Views por ser calculable 100% desde BQ, pero
--   puede NO coincidir exactamente con el numero del CSV nativo.
--   Si se necesita exactitud, pedir al equipo Adobe la formula
--   real de la Calculated Metric.
-- ============================================================

DECLARE fecha_inicio DATE DEFAULT '2026-09-01';
DECLARE fecha_fin    DATE DEFAULT '2026-09-03';   -- mismo rango que el CSV de Alberto

-- ------------------------------------------------------------
-- 1. IMPRESIONES (search + browse) -- patron v2, + split stock
-- ------------------------------------------------------------
WITH impresiones_base AS (
  SELECT ds, prod_lst_txt
  FROM `wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event`
  WHERE op_cmpny_cd = 'SAMS-MX'
    AND ds BETWEEN fecha_inicio AND fecha_fin
    AND chnl_txt IN ('searchResults', 'browseResults')
    AND prod_lst_txt IS NOT NULL
),
impresiones_segmentos AS (
  SELECT
    REGEXP_EXTRACT(segment, r'eVar168=([^|;,]+)') AS Item_Nbr,
    (SELECT SPLIT(kv, '=')[SAFE_OFFSET(1)]
       FROM UNNEST(SPLIT(segment, '|')) kv
       WHERE STARTS_WITH(kv, 'eVar97=')) AS stock_status
  FROM impresiones_base, UNNEST(SPLIT(prod_lst_txt, ',')) AS segment
  WHERE segment != ''
),
impresiones_agg AS (
  SELECT
    Item_Nbr,
    COUNT(*) AS Impresiones_Total,
    COUNTIF(stock_status = 'In Stock')     AS Impresiones_InStock,
    COUNTIF(stock_status = 'Out of Stock') AS Impresiones_OOS
  FROM impresiones_segmentos
  WHERE Item_Nbr IS NOT NULL
  GROUP BY Item_Nbr
),

-- ------------------------------------------------------------
-- 2. PRODUCT VIEWS (PDP real) + split In Stock / OOS
--    (proxy de ev62/ev63 -- ver caveat arriba)
-- ------------------------------------------------------------
product_views_base AS (
  SELECT
    prod_lst_txt,
    (SELECT SPLIT(kv, '=')[SAFE_OFFSET(1)]
       FROM UNNEST(SPLIT(prod_lst_txt, ';')) kv
       WHERE STARTS_WITH(kv, 'eVar168=')) AS Item_Nbr_raw
  FROM `wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event`
  WHERE op_cmpny_cd = 'SAMS-MX'
    AND ds BETWEEN fecha_inicio AND fecha_fin
    AND chnl_txt = 'productPage'
    AND page_nm = 'productPage:productPage'
    AND prod_lst_txt IS NOT NULL
),
product_views_parsed AS (
  SELECT
    REGEXP_EXTRACT(prod_lst_txt, r'eVar168=([^|;,]+)') AS Item_Nbr,
    (SELECT SPLIT(kv, '=')[SAFE_OFFSET(1)]
       FROM UNNEST(SPLIT(prod_lst_txt, '|')) kv
       WHERE STARTS_WITH(kv, 'eVar97=')) AS stock_status
  FROM product_views_base
),
product_views_agg AS (
  SELECT
    Item_Nbr,
    COUNT(*) AS Product_Views,
    COUNTIF(stock_status = 'Out of Stock') AS OOS_Product_Views,
    COUNTIF(stock_status = 'In Stock')     AS InStock_Product_Views
  FROM product_views_parsed
  WHERE Item_Nbr IS NOT NULL
  GROUP BY Item_Nbr
),

-- ------------------------------------------------------------
-- 3. ORDERS / UNITS / REVENUE -- checkout:thankYou
-- ------------------------------------------------------------
orders_base AS (
  SELECT
    prch_id,
    SPLIT(prod_item, ';') AS f
  FROM `wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event`,
    UNNEST(SPLIT(prod_lst_txt, ',')) AS prod_item
  WHERE op_cmpny_cd = 'SAMS-MX'
    AND ds BETWEEN fecha_inicio AND fecha_fin
    AND chnl_txt = 'checkout'
    AND page_nm = 'checkout:thankYou'
    AND prod_lst_txt IS NOT NULL
),
orders_parsed AS (
  SELECT
    prch_id,
    f[SAFE_OFFSET(1)] AS Item_Nbr,
    SAFE_CAST(f[SAFE_OFFSET(2)] AS FLOAT64) AS qty,
    SAFE_CAST(f[SAFE_OFFSET(3)] AS FLOAT64) AS revenue_linea
  FROM orders_base
),
orders_agg AS (
  SELECT
    Item_Nbr,
    COUNT(DISTINCT prch_id)  AS Orders,
    SUM(qty)                 AS Units,
    SUM(revenue_linea)       AS Revenue
  FROM orders_parsed
  WHERE Item_Nbr IS NOT NULL
  GROUP BY Item_Nbr
),

-- ------------------------------------------------------------
-- 4. CART ADDITIONS -- SOLO TOTAL SITIO (ver caveat), no por item
-- ------------------------------------------------------------
cart_additions_total AS (
  SELECT COUNT(*) AS Cart_Additions_Total_Sitio
  FROM `wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event`,
    UNNEST(cust_dim) AS cd
  WHERE op_cmpny_cd = 'SAMS-MX'
    AND ds BETWEEN fecha_inicio AND fecha_fin
    AND cd.key IN ('evar85', 'post_evar85')
    AND cd.value = 'addToCart'
),

-- ------------------------------------------------------------
-- 5. BOUNCE RATE -- visitas de 1 solo hit, atribuidas al item
--    visto en el hit de entrada (visit_page_nbr = 1)
-- ------------------------------------------------------------
visitas AS (
  SELECT
    cust_visid_id,
    visit_nbr,
    MAX(visit_page_nbr) = 1 AS es_bounce,
    -- item visto en el hit de entrada (si el hit 1 fue un productPage)
    ARRAY_AGG(
      IF(visit_page_nbr = 1 AND chnl_txt = 'productPage',
         REGEXP_EXTRACT(prod_lst_txt, r'eVar168=([^|;,]+)'), NULL)
      IGNORE NULLS ORDER BY visit_page_nbr LIMIT 1
    )[SAFE_OFFSET(0)] AS Item_Nbr_entrada
  FROM `wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event`
  WHERE op_cmpny_cd = 'SAMS-MX'
    AND ds BETWEEN fecha_inicio AND fecha_fin
  GROUP BY cust_visid_id, visit_nbr
),
bounce_agg AS (
  SELECT
    Item_Nbr_entrada AS Item_Nbr,
    COUNTIF(es_bounce) AS Visitas_Bounce,
    COUNT(*)           AS Visitas_Entrada_Item
  FROM visitas
  WHERE Item_Nbr_entrada IS NOT NULL
  GROUP BY Item_Nbr_entrada
)

-- ------------------------------------------------------------
-- 6. SELECT FINAL -- une todo por Item_Nbr
-- ------------------------------------------------------------
SELECT
  COALESCE(pv.Item_Nbr, imp.Item_Nbr, ob.Item_Nbr, ba.Item_Nbr) AS Item_Nbr,

  pv.Product_Views,
  imp.Impresiones_Total     AS Search_Results_Item_Impressions_Total,
  imp.Impresiones_InStock   AS Search_Results_Item_Impressions_InStock,
  imp.Impresiones_OOS       AS Search_Results_Item_Impressions_OOS,

  ob.Units,
  -- Cart Additions por item: NO DISPONIBLE de forma confiable (ver caveat) -> NULL a proposito
  CAST(NULL AS INT64) AS Cart_Additions_Por_Item,
  SAFE_DIVIDE(NULL, pv.Product_Views) AS ATC_Rate,  -- bloqueado hasta resolver Cart Additions por item

  SAFE_DIVIDE(ba.Visitas_Bounce, ba.Visitas_Entrada_Item) AS Bounce_Rate,

  ob.Orders,
  ob.Revenue,
  SAFE_DIVIDE(ob.Revenue, ob.Orders) AS Revenue_Por_Orden,
  SAFE_DIVIDE(ob.Orders, pv.Product_Views) AS Conversion_Rate,  -- ASUMIDO Orders/Product Views, ver caveat

  pv.OOS_Product_Views,
  pv.InStock_Product_Views

FROM product_views_agg pv
FULL OUTER JOIN impresiones_agg imp ON pv.Item_Nbr = imp.Item_Nbr
FULL OUTER JOIN orders_agg ob       ON COALESCE(pv.Item_Nbr, imp.Item_Nbr) = ob.Item_Nbr
FULL OUTER JOIN bounce_agg ba       ON COALESCE(pv.Item_Nbr, imp.Item_Nbr, ob.Item_Nbr) = ba.Item_Nbr
ORDER BY pv.Product_Views DESC;

-- Cart_Additions_Total_Sitio (de la CTE cart_additions_total) se
-- reporta APARTE (una sola fila, todo el sitio) -- correr como
-- query independiente si se quiere el numero de contexto, no
-- forma parte del JOIN de arriba porque no tiene Item_Nbr confiable.

-- ============================================================
-- COSTO -- NO SE HA CORRIDO ESTA QUERY TODAVIA
-- ============================================================
-- v2 (solo impresiones, 1 dia, 2 valores de chnl_txt) costo
-- ~11-15 GB/dia. Esta v3 agrega:
--   - chnl_txt='productPage' (tabla completa mas grande: 2.9M
--     hits/dia vs 2.4M de searchResults)
--   - chnl_txt='checkout' (mas chico, 178K hits/dia)
--   - UNNEST(cust_dim) para Cart Additions -- cust_dim es RECORD
--     REPEATED; en la exploracion previa, UNA sola query de
--     exploracion sobre cust_dim proceso ~200 GB en un solo dia.
--   - Un GROUP BY a nivel (cust_visid_id, visit_nbr) sobre TODA
--     la tabla del rango (sin filtro de chnl_txt) para Bounce Rate
--     -- este es probablemente el mas caro de todos, escanea la
--     tabla completa x 3 dias.
--
-- ESTIMADO CONSERVADOR: varias decenas de GB a >100 GB POR DIA,
-- x 3 dias del rango = posiblemente varios cientos de GB a >1 TB.
-- ANTES DE CORRER: hacer `bq query --dry_run` (o el equivalente en
-- bigquery-explorer) sobre CADA CTE por separado (empezando por
-- bounce_agg, que es la sospechosa de ser mas cara) y reportar el
-- numero real a Alberto ANTES de ejecutar. Igual que se hizo con
-- Total Departamentos V1 (~3.8 TB, requirio luz verde explicita).
-- ============================================================
