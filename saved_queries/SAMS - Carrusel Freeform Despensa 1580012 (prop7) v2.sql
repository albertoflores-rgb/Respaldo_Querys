-- ============================================================
-- SAMS - Carrusel Freeform Despensa 1580012 (prop7) v2.sql
-- Estado  : DRAFT / NO EJECUTADO -- pedir luz verde explicita de
--           Alberto antes de correr, y validar 1 dia antes de
--           comprometer el rango MTD completo (ver seccion COSTO,
--           esta v2 es MAS CARA que v1).
-- Fecha   : 08-sep-2026
-- Objetivo: EXTIENDE "SAMS - Carrusel Freeform Despensa 1580012
--           (prop7) v1.sql" agregando las 2 metricas que v1 dejo
--           fuera a proposito por costo:
--             - Bounce Rate (%) - Engagement (Official)
--             - %Add to Cart (Web Only {Official}, App {Android+iOS})
--           Todo lo demas (Visits por canal, Occurrences, eVar5
--           Instances, Checkout Conversion Rate, Unique Visitors,
--           Revenue) es IDENTICO a v1 -- ver ese archivo para el
--           razonamiento completo de esas columnas.
-- ============================================================
-- TABLA FUENTE:
--   wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event
--   -> VIEW sobre TABLA EXTERNA (ORC) particionada por `ds` (DATE).
--   -> op_cmpny_cd = 'SAMS-MX' es el filtro de banner.
-- ============================================================
-- MAPEO CONFIRMADO CON DATOS REALES (igual que v1, ver ese archivo;
-- filas nuevas de esta v2 abajo):
--
-- | Necesidad                          | Columna/Key real                          | Confianza |
-- |-------------------------------------|--------------------------------------------|-----------|
-- | Bounce Rate (%) - Engagement       | visita (cust_visid_id,visit_nbr) con MAX(visit_page_nbr)=1 EN TODA LA TABLA (no solo esta pagina), atribuida a las visitas que tocaron un carrusel de esta pagina | MEDIA -- mismo patron/limitante ya usado en "Adobe Impresiones Item v3" |
-- | %Add to Cart (Web/App)             | cust_dim key IN ('evar85','post_evar85') = 'addToCart', buscado en TODA la visita (no solo el hit del carrusel), platforma tomada del hit del carrusel (prop38) | BAJA -- MISMA limitante documentada en v3 de "Adobe Impresiones Item": el hit de addToCart es link tracking y NO prueba que el ATC salio DESDE el carrusel especifico, solo que la MISMA VISITA que toco el carrusel tambien hizo ATC en algun momento de la sesion |
--
-- CAVEATS de v1 (Canal de Marketing reconstruido, eVar5 posiblemente
-- vacio, Checkout Conversion Rate asumido) siguen aplicando IGUAL
-- en esta v2 -- ver el archivo v1 para el detalle completo.
-- ============================================================

DECLARE fecha_inicio DATE DEFAULT '2026-09-06';           -- PRUEBA DE 1 SOLO DIA (dia ya cerrado; NO usar 09-07 = hoy, viene incompleto)
DECLARE fecha_fin    DATE DEFAULT '2026-09-06';            -- mismo dia que fecha_inicio para la prueba de 1 dia
DECLARE pagina_prefix STRING DEFAULT 'www.sams.com.mx/content/despensa/1580012';
-- BUG CONFIRMADO 08-sep-2026 (bigquery-explorer, ds=2026-09-06, costo real ~1.8 GB):
--   page_url_txt viene en DOS formatos mezclados en los datos reales:
--   unas filas SIN protocolo ('www.sams.com.mx/...') y otras CON
--   'https://' de prefijo. El filtro original (anclado al inicio con
--   LIKE pagina_prefix||'%') solo matcheaba el primer formato y
--   EXCLUIA SILENCIOSAMENTE ~5% de las visitas (2,413 de 45,550 filas
--   ese dia). Fix: agregar '%' TAMBIEN al inicio del LIKE (ver abajo).
--   PENDIENTE DE CONFIRMAR (requiere tocar cust_dim, ~205 GB/dia,
--   necesita luz verde explicita antes de correr): si el filtro de
--   prop7_raw ('%itemcarousel:%' / '%sponsoredproductcarousel:%')
--   sigue devolviendo 0 filas incluso con el fix de page_url_txt, el
--   problema esta ahi (posible mayuscula/minuscula distinta o nombre
--   de carrusel distinto al esperado) -- validar antes de asumir que
--   ya quedo arreglado del todo.

-- ------------------------------------------------------------
-- 1. BASE -- filtra primero por columnas escalares baratas
--    (ds, op_cmpny_cd, page_url_txt) ANTES de tocar cust_dim.
--    OJO: cust_dim es RECORD REPEATED -- BQ cobra por el TAMANO
--    COMPLETO de esa columna en el dia+particion escaneada, sin
--    importar cuantas filas sobrevivan el filtro de page_url_txt
--    (confirmado en la exploracion: ~205 GB/dia solo por tocar
--    cust_dim, sea cual sea el filtro adicional). Por eso esta
--    query extrae TODOS los keys que necesita (prop7, evar5,
--    prop38, va_closer_detail) en UN SOLO paso por cust_dim,
--    no en 4 pasadas separadas.
-- ------------------------------------------------------------
WITH base AS (
  SELECT
    ds,
    cust_visid_id,
    visit_nbr,
    visit_page_nbr,
    chnl_txt,
    page_nm,
    prch_id,
    prod_lst_txt,
    (SELECT value FROM UNNEST(cust_dim) WHERE key IN ('prop7','post_prop7') LIMIT 1)          AS prop7_raw,
    (SELECT value FROM UNNEST(cust_dim) WHERE key IN ('evar5','post_evar5') LIMIT 1)          AS evar5_raw,
    (SELECT value FROM UNNEST(cust_dim) WHERE key IN ('prop38','post_prop38') LIMIT 1)        AS prop38_raw,
    (SELECT value FROM UNNEST(cust_dim) WHERE key = 'va_closer_detail' LIMIT 1)               AS va_closer_detail_raw
  FROM `wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event`
  WHERE op_cmpny_cd = 'SAMS-MX'
    AND ds BETWEEN fecha_inicio AND fecha_fin
    AND page_url_txt LIKE '%' || pagina_prefix || '%'   -- FIX 08-sep-2026: '%' al inicio tambien, cubre URLs con y sin 'https://' de prefijo
),

-- ------------------------------------------------------------
-- 2. CARROUSEL HITS -- solo hits que traen un prop7 de tipo
--    carrusel (itemcarousel / sponsoredproductcarousel)
-- ------------------------------------------------------------
carousel_hits AS (
  SELECT
    *,
    REGEXP_EXTRACT(prop7_raw, r'^[^:]*:(.*)$') AS carousel_name,
    -- plataforma: heuristica sobre prop38 (formato "x|WEB|WEB" / "x|APP|ANDROID")
    CASE
      WHEN prop38_raw LIKE '%|APP|%' THEN 'App'
      WHEN prop38_raw LIKE '%|WEB|%' THEN 'Web'
      ELSE 'Sin_Clasificar'
    END AS plataforma,
    -- canal de marketing: RECONSTRUCCION heuristica, NO oficial (ver caveat en v1)
    CASE
      WHEN va_closer_detail_raw IS NULL OR SPLIT(va_closer_detail_raw,'|')[SAFE_OFFSET(0)] IN ('', 'NA') THEN 'Direct'
      WHEN SPLIT(va_closer_detail_raw,'|')[SAFE_OFFSET(0)] = 'crm' THEN 'CRM'
      WHEN SPLIT(va_closer_detail_raw,'|')[SAFE_OFFSET(1)] = 'Organic Search' THEN 'SEO'
      WHEN SPLIT(va_closer_detail_raw,'|')[SAFE_OFFSET(0)] = 'google' AND SPLIT(va_closer_detail_raw,'|')[SAFE_OFFSET(1)] = 'cpc' THEN 'SEM'
      WHEN SPLIT(va_closer_detail_raw,'|')[SAFE_OFFSET(1)] IN ('display','cpc') THEN 'Social Paid'
      ELSE 'Otro_Sin_Clasificar'
    END AS canal_marketing
  FROM base
  WHERE prop7_raw IS NOT NULL
    AND (prop7_raw LIKE '%itemcarousel:%' OR prop7_raw LIKE '%sponsoredproductcarousel:%')
),

-- ------------------------------------------------------------
-- 3. OCCURRENCES + UNIQUE VISITORS -- a nivel HIT (occurrences)
--    y a nivel visitante unico, por carrusel
-- ------------------------------------------------------------
occurrences_agg AS (
  SELECT
    carousel_name,
    COUNT(*)                          AS Occurrences,
    COUNT(DISTINCT cust_visid_id)     AS Unique_Visitors,
    -- eVar5 Instances: cuenta hits de este carrusel que TAMBIEN traen
    -- un valor de eVar5 no nulo (ver caveat: puede no reflejar ATC real)
    COUNTIF(evar5_raw IS NOT NULL)    AS Add_to_Cart_Location_eVar5_Instances
  FROM carousel_hits
  GROUP BY carousel_name
),

-- ------------------------------------------------------------
-- 4. VISITS por canal de marketing -- a nivel visita
--    (cust_visid_id, visit_nbr), usando el canal reconstruido
-- ------------------------------------------------------------
visitas_por_carrusel AS (
  SELECT DISTINCT
    carousel_name,
    cust_visid_id,
    visit_nbr,
    canal_marketing,
    plataforma
  FROM carousel_hits
),
visits_agg AS (
  SELECT
    carousel_name,
    COUNTIF(canal_marketing = 'Social Paid') AS Visits_Social_Paid,
    COUNTIF(canal_marketing = 'SEM')         AS Visits_SEM,
    COUNTIF(canal_marketing = 'Direct')      AS Visits_Direct,
    COUNTIF(canal_marketing = 'SEO')         AS Visits_SEO,
    COUNTIF(canal_marketing = 'CRM')         AS Visits_CRM,
    COUNT(*)                                 AS Visits_Total
  FROM visitas_por_carrusel
  GROUP BY carousel_name
),

-- ------------------------------------------------------------
-- 5. REVENUE -- checkout:thankYou de las MISMAS visitas que
--    tocaron un carrusel de esta pagina (join por cust_visid_id+visit_nbr)
-- ------------------------------------------------------------
visitas_relevantes AS (
  SELECT DISTINCT cust_visid_id, visit_nbr, carousel_name FROM visitas_por_carrusel
),
checkout_hits AS (
  SELECT
    cust_visid_id, visit_nbr, prch_id,
    SPLIT(prod_lst_txt, ',') AS items
  FROM `wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event`
  WHERE op_cmpny_cd = 'SAMS-MX'
    AND ds BETWEEN fecha_inicio AND fecha_fin
    AND chnl_txt = 'checkout'
    AND page_nm = 'checkout:thankYou'
),
checkout_por_visita AS (
  SELECT
    cust_visid_id, visit_nbr, prch_id,
    SAFE_CAST(SPLIT(item, ';')[SAFE_OFFSET(2)] AS FLOAT64) AS revenue_linea
  FROM checkout_hits, UNNEST(items) AS item
),
revenue_agg AS (
  SELECT
    vr.carousel_name,
    COUNT(DISTINCT cp.prch_id) AS Orders,
    SUM(cp.revenue_linea)      AS Revenue
  FROM visitas_relevantes vr
  JOIN checkout_por_visita cp
    ON vr.cust_visid_id = cp.cust_visid_id AND vr.visit_nbr = cp.visit_nbr
  GROUP BY vr.carousel_name
),

-- ------------------------------------------------------------
-- 6. BOUNCE RATE -- NUEVO en v2. Requiere MAX(visit_page_nbr) de
--    LA VISITA COMPLETA (todas las paginas que toco, no solo esta),
--    por eso escanea la tabla SIN el filtro de page_url_txt. Mismo
--    patron ya validado en "Adobe Impresiones Item v3". Es
--    probablemente el CTE mas caro de esta query (ver COSTO abajo).
-- ------------------------------------------------------------
visitas_hits_totales AS (
  SELECT
    cust_visid_id,
    visit_nbr,
    MAX(visit_page_nbr) AS max_hit
  FROM `wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event`
  WHERE op_cmpny_cd = 'SAMS-MX'
    AND ds BETWEEN fecha_inicio AND fecha_fin
  GROUP BY cust_visid_id, visit_nbr
),
bounce_agg AS (
  SELECT
    vr.carousel_name,
    COUNTIF(vht.max_hit = 1) AS Visitas_Bounce,
    COUNT(*)                 AS Visitas_Base_Bounce
  FROM visitas_relevantes vr
  JOIN visitas_hits_totales vht
    ON vr.cust_visid_id = vht.cust_visid_id AND vr.visit_nbr = vht.visit_nbr
  GROUP BY vr.carousel_name
),

-- ------------------------------------------------------------
-- 7. %ADD TO CART (Web / App) -- NUEVO en v2. Busca hits de tipo
--    addToCart (cust_dim evar85/post_evar85='addToCart') dentro de
--    LA MISMA VISITA que toco el carrusel (no necesariamente en el
--    mismo hit del carrusel -- ver caveat MEDIA/BAJA arriba).
--    Toca cust_dim OTRA VEZ sin el filtro de pagina -> caro, ver COSTO.
-- ------------------------------------------------------------
atc_hits AS (
  SELECT DISTINCT cust_visid_id, visit_nbr
  FROM `wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event`,
    UNNEST(cust_dim) AS cd
  WHERE op_cmpny_cd = 'SAMS-MX'
    AND ds BETWEEN fecha_inicio AND fecha_fin
    AND cd.key IN ('evar85', 'post_evar85')
    AND cd.value = 'addToCart'
),
atc_por_plataforma AS (
  SELECT
    vpc.carousel_name,
    vpc.plataforma,
    COUNT(DISTINCT IF(ah.cust_visid_id IS NOT NULL,
                       CONCAT(vpc.cust_visid_id, '|', CAST(vpc.visit_nbr AS STRING)),
                       NULL))                                              AS Visitas_Con_ATC,
    COUNT(DISTINCT CONCAT(vpc.cust_visid_id, '|', CAST(vpc.visit_nbr AS STRING))) AS Visitas_Totales
  FROM visitas_por_carrusel vpc
  LEFT JOIN atc_hits ah
    ON vpc.cust_visid_id = ah.cust_visid_id AND vpc.visit_nbr = ah.visit_nbr
  GROUP BY vpc.carousel_name, vpc.plataforma
),
atc_agg AS (
  SELECT
    carousel_name,
    SAFE_DIVIDE(SUM(IF(plataforma = 'Web', Visitas_Con_ATC, 0)),
                SUM(IF(plataforma = 'Web', Visitas_Totales, 0)))  AS Pct_Add_to_Cart_Web,
    SAFE_DIVIDE(SUM(IF(plataforma = 'App', Visitas_Con_ATC, 0)),
                SUM(IF(plataforma = 'App', Visitas_Totales, 0)))  AS Pct_Add_to_Cart_App
  FROM atc_por_plataforma
  GROUP BY carousel_name
)

-- ------------------------------------------------------------
-- 8. SELECT FINAL
-- ------------------------------------------------------------
SELECT
  COALESCE(o.carousel_name, v.carousel_name, r.carousel_name, bo.carousel_name, a.carousel_name) AS carouselName,

  v.Visits_Social_Paid,
  v.Visits_SEM,
  v.Visits_Direct,
  v.Visits_SEO,
  v.Visits_CRM,

  a.Pct_Add_to_Cart_Web,
  a.Pct_Add_to_Cart_App,

  o.Occurrences,
  o.Unique_Visitors,
  o.Add_to_Cart_Location_eVar5_Instances,

  r.Orders,
  r.Revenue,
  SAFE_DIVIDE(r.Orders, v.Visits_Total) AS Checkout_Conversion_Rate_Asumida,  -- ver caveat en v1: definicion NO confirmada contra Adobe

  SAFE_DIVIDE(bo.Visitas_Bounce, bo.Visitas_Base_Bounce) AS Bounce_Rate_Asumida  -- ver caveat arriba: bounce de LA VISITA COMPLETA, no solo esta pagina

FROM occurrences_agg o
FULL OUTER JOIN visits_agg v  ON o.carousel_name = v.carousel_name
FULL OUTER JOIN revenue_agg r ON COALESCE(o.carousel_name, v.carousel_name) = r.carousel_name
FULL OUTER JOIN bounce_agg bo ON COALESCE(o.carousel_name, v.carousel_name, r.carousel_name) = bo.carousel_name
FULL OUTER JOIN atc_agg a     ON COALESCE(o.carousel_name, v.carousel_name, r.carousel_name, bo.carousel_name) = a.carousel_name
ORDER BY o.Occurrences DESC;

-- ============================================================
-- COSTO -- NO SE HA CORRIDO ESTA QUERY TODAVIA
-- ============================================================
-- v1 (sin bounce ni %ATC) ya estimaba ~205 GB/dia solo por tocar
-- cust_dim UNA vez en el CTE `base` (con filtro de page_url_txt).
-- Esta v2 agrega DOS escaneos NUEVOS, ambos SIN el filtro de
-- page_url_txt (porque necesitan ver TODA la visita, no solo los
-- hits de esta pagina):
--
--   1. `visitas_hits_totales` (Bounce Rate): escanea TODA la tabla
--      del rango (cust_visid_id, visit_nbr, visit_page_nbr,
--      chnl_txt/op_cmpny_cd) sin filtrar por pagina. NO toca
--      cust_dim, asi que es mas barato que el punto 2, pero sigue
--      siendo un GROUP BY sobre la tabla completa x N dias -- en
--      "Adobe Impresiones Item v3" esto se identifico como
--      "probablemente el CTE mas caro de la query completa".
--
--   2. `atc_hits` (%Add to Cart): UNNEST(cust_dim) SIN filtro de
--      pagina -- misma limitante ya confirmada: tocar cust_dim
--      cuesta ~205 GB/dia POR SI SOLO, sin importar el filtro.
--      Como aqui NO se filtra por pagina, se paga el cust_dim
--      COMPLETO del dia (no solo el de esta pagina, que ya se
--      pagaba en el CTE `base` de v1) -- es decir, esta v2
--      PRACTICAMENTE DUPLICA el costo de cust_dim de v1.
--
-- ESTIMADO CONSERVADOR para el rango MTD completo (7 dias):
--   v1 ya costaba ~1.4 TB (cust_dim de la pagina) + checkout aparte.
--   v2 SUMA: ~1.4 TB adicionales (cust_dim completo, sin filtro de
--   pagina, para ATC) + el escaneo completo de la tabla para bounce
--   (variable, pero del mismo orden que v1 de "Impresiones Item").
--   TOTAL ESTIMADO v2: ~3 TB o mas para el rango MTD completo.
--
-- ANTES DE CORRER EL RANGO MTD COMPLETO:
--   1. Correr esta v2 con fecha_inicio = fecha_fin = 1 SOLO DIA
--      (ej. '2026-09-07') y confirmar el costo real de CADA CTE
--      nuevo por separado (dry_run de bounce_agg y atc_agg antes
--      de correr el SELECT final completo).
--   2. Comparar Bounce Rate y %Add to Cart resultantes contra el
--      CSV nativo de Alberto para el mismo dia, documentar el
--      grado de coincidencia (o discrepancia) ANTES de confiar en
--      el numero para el rango completo.
--   3. Reportar el costo real y los hallazgos a Alberto ANTES de
--      correr el rango completo -- misma disciplina que se siguio
--      con v1 y con "Adobe Impresiones Item v3".
-- ============================================================
