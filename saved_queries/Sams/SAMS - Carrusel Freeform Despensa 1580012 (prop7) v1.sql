-- ============================================================
-- SAMS - Carrusel Freeform Despensa 1580012 (prop7) v1.sql
-- Estado  : DRAFT / NO EJECUTADO -- pedir luz verde explicita de
--           Alberto antes de correr, y validar 1 dia antes de
--           comprometer el rango MTD completo (ver seccion COSTO).
-- Fecha   : 08-sep-2026
-- Objetivo: replicar el reporte nativo de Adobe Analytics Workspace
--           "Freeform table - carouselName (prop7)" exportado por
--           Alberto (C:\Users\a0f07dn\Downloads\Freeform table -
--           carouselName (prop7).csv), rango original Aug 7 - Sep 5
--           2026, 427 items -- esta version corre a PERIODO MTD
--           (fecha_inicio ajustable abajo).
--
--           Contexto fijo del reporte: Content Page
--           /content/despensa/1580012. Dimension de fila:
--           carouselName (prop7). Metricas del CSV original:
--             Visits (por canal: Social Paid, SEM, Direct, SEO, CRM)
--             %Add to Cart (Web Only {Official}, App {Android+iOS})
--             Occurrences
--             Add to Cart Location (eVar5) Instances
--             Checkout Conversion Rate {Official}
--             Bounce Rate (%) - Engagement (Official)
--             Unique Visitors
--             Revenue
-- ============================================================
-- TABLA FUENTE:
--   wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event
--   -> VIEW sobre TABLA EXTERNA (ORC) particionada por `ds` (DATE).
--   -> op_cmpny_cd = 'SAMS-MX' es el filtro de banner.
-- ============================================================
-- MAPEO CONFIRMADO CON DATOS REALES (exploracion 08-sep-2026,
-- via bigquery-explorer, ds='2026-09-07', ~620 GB gastados HOY
-- solo en exploracion -- ver caveat de costo de cust_dim abajo):
--
-- | Necesidad                          | Columna/Key real                          | Confianza |
-- |-------------------------------------|--------------------------------------------|-----------|
-- | carouselName (prop7)                | cust_dim key 'prop7'/'post_prop7'           | ALTA      |
-- |   formato: origen|tipoPagina|tipoCarrusel:Nombre                                        |
-- | Pagina fija /content/despensa/1580012| page_url_txt LIKE '.../content/despensa/1580012%' | ALTA (cuidado: NO usar LIKE '%1580012%' generico, ese ID tambien aparece en URLs /browse/ de categoria) |
-- | Canal de marketing (5 buckets)      | cust_dim key 'va_closer_detail' (formato canal|medio|campana|...) | BAJA -- NO es el bucket oficial de Adobe Marketing Channel Manager, es una RECONSTRUCCION con CASE WHEN (ver caveat) |
-- | Plataforma Web/App                  | cust_dim key 'prop38'/'post_prop38' (formato "x|WEB|WEB" o "x|APP|ANDROID") | MEDIA -- no se confirmo el valor exacto de iOS en la muestra |
-- | Add to Cart Location (eVar5)        | cust_dim key 'evar5'/'post_evar5'           | BAJA -- en la muestra de 300 filas NO se vio ningun valor de eVar5 con "itemcarousel", solo "search|searchresults" y "cart|NA". Puede que este eVar NO se popule desde carruseles en esta implementacion |
-- | Checkout Conversion Rate {Official} | Orders/Product Views (mismo patron que v3) | BAJA -- Adobe no expone el denominador real de la Calculated Metric |
-- | Bounce Rate (%) - Engagement       | visita de 1 solo hit, atribuida al hit de entrada | MEDIA -- mismo patron/limitante que v2/v3 |
--
-- CAVEAT CRITICO -- Canal de Marketing (Social Paid/SEM/Direct/SEO/CRM):
--   NO existe en cust_dim ningun key ya clasificado en estos 5
--   buckets (se busco explicitamente 'chnl'/'channel'/'mktg' y
--   NO existe, confirmado con 0 resultados). Adobe genera estos
--   buckets con un "Marketing Channel Manager" (reglas de negocio
--   configuradas en el UI de Adobe, no en los datos crudos). Esta
--   v1 RECONSTRUYE una aproximacion con CASE WHEN sobre
--   'va_closer_detail' (canal|medio|campana). Es una heuristica,
--   NO el bucket oficial -- los numeros de "Visits por canal" de
--   este query NO deben tomarse como equivalentes 1:1 al CSV de
--   Adobe hasta validar contra un dia real exportado del UI.
--
-- CAVEAT CRITICO -- eVar5 / Add to Cart Location (eVar5) Instances:
--   No se confirmo que este eVar traiga valores de tipo carrusel
--   en la muestra explorada. Es posible que esta metrica salga en
--   ceros o muy baja comparada con el CSV nativo. NO INVENTAR el
--   desglose si sale en cero -- reportarlo como limitante conocida,
--   igual que se hizo con Cart Additions por item en v3.
--
-- CAVEAT -- Checkout Conversion Rate / Bounce Rate:
--   Mismas definiciones ASUMIDAS que en v2/v3 (ver ese archivo para
--   el razonamiento completo). Pueden NO coincidir con el numero
--   nativo de Adobe Workspace.
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
    -- canal de marketing: RECONSTRUCCION heuristica, NO oficial (ver caveat arriba)
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
)

-- ------------------------------------------------------------
-- 6. SELECT FINAL
-- ------------------------------------------------------------
SELECT
  COALESCE(o.carousel_name, v.carousel_name, r.carousel_name) AS carouselName,

  v.Visits_Social_Paid,
  v.Visits_SEM,
  v.Visits_Direct,
  v.Visits_SEO,
  v.Visits_CRM,

  o.Occurrences,
  o.Unique_Visitors,
  o.Add_to_Cart_Location_eVar5_Instances,

  r.Orders,
  r.Revenue,
  SAFE_DIVIDE(r.Orders, v.Visits_Total) AS Checkout_Conversion_Rate_Asumida  -- ver caveat: definicion NO confirmada contra Adobe

FROM occurrences_agg o
FULL OUTER JOIN visits_agg v  ON o.carousel_name = v.carousel_name
FULL OUTER JOIN revenue_agg r ON COALESCE(o.carousel_name, v.carousel_name) = r.carousel_name
ORDER BY o.Occurrences DESC;

-- Bounce Rate (%) - Engagement (Official) y %Add to Cart (Web/App)
-- se dejan FUERA de este v1 a proposito: requieren CTEs adicionales
-- (visitas de 1 solo hit para bounce; hits de addToCart reales para
-- %ATC, que en v3 se documento como NO confiables por item/contexto)
-- y cada una agrega otro barrido caro sobre cust_dim o sobre toda la
-- tabla. Se agregan en v2 de este query SOLO si Alberto confirma que
-- quiere pagar el costo adicional despues de validar v1 con 1 dia.

-- ============================================================
-- COSTO -- NO SE HA CORRIDO ESTA QUERY TODAVIA
-- ============================================================
-- Hallazgo confirmado en exploracion 08-sep-2026: tocar cust_dim
-- (UNNEST, aunque sea con WHERE key='x' LIMIT chico) cuesta
-- ~205 GB POR DIA de la particion `ds`, prácticamente sin importar
-- cuantos filtros escalares se agreguen (columnar: se paga por la
-- columna completa del dia, no por las filas que sobreviven el
-- WHERE). Esta query toca cust_dim UNA sola vez en el CTE `base`
-- (4 keys en la misma pasada), asi que el costo esperado es:
--   ~205 GB/dia x (fecha_fin - fecha_inicio + 1) dias
--   + costo aparte de `checkout_hits` (tabla completa, sin cust_dim,
--     mas barato, similar a v3 ~pocas decenas de GB/dia)
--
-- Para el rango MTD completo (ej. 1-7 sep = 7 dias):
--   ESTIMADO: ~1.4 TB solo por cust_dim, + checkout aparte.
--   Esto es MAS CARO que la corrida real de v3 (205 GB / 3 dias)
--   porque ahi cust_dim NO se tocaba para nada (v3 no necesitaba
--   prop7/evar5/canal/plataforma).
--
-- ANTES DE CORRER EL RANGO MTD COMPLETO:
--   1. Correr esta query con fecha_inicio = fecha_fin = 1 SOLO DIA
--      (ej. '2026-09-07') y confirmar: (a) que el costo real ronda
--      los 205-230 GB esperados, (b) que los numeros de Occurrences
--      /Unique Visitors por carrusel tienen un orden de magnitud
--      razonable comparado con el CSV de Alberto (proporcionalmente
--      al numero de dias).
--   2. Reportar el costo real y los hallazgos a Alberto ANTES de
--      correr el rango completo.
--   3. Si Alberto aprueba, ampliar fecha_fin al ultimo dia completo
--      de septiembre disponible.
-- ============================================================
