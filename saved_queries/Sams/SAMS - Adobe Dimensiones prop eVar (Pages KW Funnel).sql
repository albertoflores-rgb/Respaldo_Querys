-- ============================================================================
-- Dimensiones Adobe confirmadas en cust_dim
-- Parametro: @fecha_reporte (DATE)
-- Fuente particionada: sams_mx_csd_adobe_event
--
-- Adobe guarda prop/eVar como registros repetidos cust_dim.key/value; no son
-- columnas top-level. Este archivo valida KW (prop14/eVar2), Page Type
-- (prop1), login (prop59) y candidatos de canal.
-- ============================================================================

-- 1) Cobertura y ejemplos de dimensiones de la captura.
SELECT
  LOWER(cd.key) AS adobe_key,
  COUNT(*) AS rows_with_key,
  COUNTIF(NULLIF(TRIM(cd.value), '') IS NOT NULL) AS populated_rows,
  ARRAY_AGG(DISTINCT cd.value IGNORE NULLS LIMIT 20) AS examples
FROM `wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event` t,
UNNEST(t.cust_dim) AS cd
WHERE t.op_cmpny_cd = 'SAMS-MX'
  AND t.ds = @fecha_reporte
  AND LOWER(cd.key) IN (
    'prop1', 'post_prop1',
    'prop14', 'post_prop14',
    'evar2', 'post_evar2',
    'prop59', 'post_prop59',
    'evar147', 'post_evar147',
    'evar148', 'post_evar148',
    'evar149', 'post_evar149'
  )
GROUP BY adobe_key
ORDER BY adobe_key;

-- 2) KW comparable al panel Adobe: cada variante de variable.
WITH terms AS (
  SELECT
    LOWER(cd.key) AS adobe_key,
    LOWER(TRIM(cd.value)) AS term,
    CONCAT(CAST(t.visit_hi_id AS STRING), '-',
           CAST(t.visit_low_id AS STRING), '-',
           CAST(t.visit_nbr AS STRING)) AS visit_id
  FROM `wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event` t,
  UNNEST(t.cust_dim) AS cd
  WHERE t.op_cmpny_cd = 'SAMS-MX'
    AND t.ds = @fecha_reporte
    AND LOWER(cd.key) IN ('prop14', 'post_prop14', 'evar2', 'post_evar2')
    AND NULLIF(TRIM(cd.value), '') IS NOT NULL
)
SELECT
  adobe_key,
  term,
  COUNT(*) AS instances,
  COUNT(DISTINCT visit_id) AS visits
FROM terms
GROUP BY adobe_key, term
ORDER BY adobe_key, instances DESC
LIMIT 500;

-- 3) Page Type y señales de funnel. Los códigos de event_id_lst_txt deben
-- validarse contra el diccionario Adobe antes de fijar Cart Additions.
SELECT
  COALESCE(NULLIF(TRIM(page_nm), ''), '(blank)') AS page_name,
  COUNT(*) AS hits,
  COUNT(DISTINCT CONCAT(CAST(visit_hi_id AS STRING), '-',
                        CAST(visit_low_id AS STRING), '-',
                        CAST(visit_nbr AS STRING))) AS visits,
  COUNTIF(LOWER(page_nm) LIKE 'cart%') AS cart_page_hits,
  COUNTIF(LOWER(page_nm) LIKE 'checkout%') AS checkout_page_hits,
  COUNTIF(EXISTS (
    SELECT 1 FROM UNNEST(cust_dim) x
    WHERE LOWER(x.key) IN ('prop59', 'post_prop59')
      AND LOWER(x.value) = 'logged in'
  )) AS logged_in_hits
FROM `wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event`
WHERE op_cmpny_cd = 'SAMS-MX'
  AND ds = @fecha_reporte
GROUP BY page_name
ORDER BY hits DESC
LIMIT 500;
