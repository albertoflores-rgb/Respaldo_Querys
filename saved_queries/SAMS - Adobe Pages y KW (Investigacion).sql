-- ============================================================================
-- Adobe Pages + KW (keyword) — investigación reproducible
-- Tablero: Sam's Club MX / report suite walmar17
--
-- IMPORTANTE:
--   * Siempre filtrar ds con literal/parametro para podar particion.
--   * @fecha_reporte debe ser DATE.
--   * Este query NO pretende inventar una dimension KW: primero mide cobertura
--     y devuelve candidatos para validacion con Adobe Admin.
-- Fuente:
--   wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event
-- ============================================================================

-- 1) Cobertura de Pages y candidatos de KW por canal.
SELECT
  chnl_txt,
  COUNT(*) AS hits,
  COUNTIF(NULLIF(TRIM(page_nm), '') IS NOT NULL) AS page_nm_nonblank,
  COUNTIF(NULLIF(TRIM(page_url_txt), '') IS NOT NULL) AS page_url_nonblank,
  COUNTIF(NULLIF(TRIM(page_type_nm), '') IS NOT NULL) AS page_type_nonblank,
  COUNTIF(NULLIF(TRIM(page_event_var1), '') IS NOT NULL) AS page_event_var1_nonblank,
  COUNTIF(NULLIF(TRIM(page_event_var2), '') IS NOT NULL) AS page_event_var2_nonblank,
  COUNTIF(NULLIF(TRIM(hier1), '') IS NOT NULL) AS hier1_nonblank,
  COUNTIF(NULLIF(TRIM(hier2), '') IS NOT NULL) AS hier2_nonblank,
  COUNTIF(NULLIF(TRIM(hier3), '') IS NOT NULL) AS hier3_nonblank,
  COUNTIF(NULLIF(TRIM(hier4), '') IS NOT NULL) AS hier4_nonblank,
  COUNTIF(NULLIF(TRIM(hier5), '') IS NOT NULL) AS hier5_nonblank,
  COUNTIF(NULLIF(TRIM(post_kws_txt), '') IS NOT NULL) AS post_kws_nonblank,
  COUNTIF(NULLIF(TRIM(merch_evar_nm), '') IS NOT NULL) AS merch_evar_nonblank,
  COUNTIF(NULLIF(TRIM(post_merch_evar_nm), '') IS NOT NULL) AS post_merch_evar_nonblank
FROM `wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event`
WHERE op_cmpny_cd = 'SAMS-MX'
  AND ds = @fecha_reporte
  AND chnl_txt IN ('searchResults', 'browseResults')
GROUP BY chnl_txt
ORDER BY chnl_txt;

-- 2) Pages utilizables para el tablero.
SELECT
  page_nm,
  page_event_var1,
  page_event_var2,
  chnl_txt,
  COUNT(*) AS hits
FROM `wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event`
WHERE op_cmpny_cd = 'SAMS-MX'
  AND ds = @fecha_reporte
  AND chnl_txt IN ('searchResults', 'browseResults')
GROUP BY page_nm, page_event_var1, page_event_var2, chnl_txt
ORDER BY hits DESC
LIMIT 500;

-- 3) KW: candidatos directos. No tratar post_kws_txt como keyword oficial
-- hasta confirmar el mapeo de Adobe; en la exploracion 2026-09-11 solo hubo
-- dos filas no vacias ("Logged In" y "4954").
SELECT
  post_kws_txt,
  merch_evar_nm,
  post_merch_evar_nm,
  ref_nm,
  visit_ref_txt,
  page_nm,
  page_event_var1,
  page_event_var2,
  COUNT(*) AS hits
FROM `wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event`
WHERE op_cmpny_cd = 'SAMS-MX'
  AND ds = @fecha_reporte
  AND chnl_txt = 'searchResults'
  AND (
    NULLIF(TRIM(post_kws_txt), '') IS NOT NULL
    OR NULLIF(TRIM(merch_evar_nm), '') IS NOT NULL
    OR NULLIF(TRIM(post_merch_evar_nm), '') IS NOT NULL
    OR NULLIF(TRIM(ref_nm), '') IS NOT NULL
    OR NULLIF(TRIM(visit_ref_txt), '') IS NOT NULL
  )
GROUP BY
  post_kws_txt, merch_evar_nm, post_merch_evar_nm, ref_nm, visit_ref_txt,
  page_nm, page_event_var1, page_event_var2
ORDER BY hits DESC
LIMIT 500;

-- 4) Descubrimiento de eVars dentro de los productos listados. Esto sirve
-- para auditar posicion, sponsored status y otros atributos, pero no prueba
-- que alguno sea el termino buscado por el usuario.
SELECT
  REGEXP_EXTRACT(segment, r'eVar168=([^|;,]+)') AS item_nbr,
  REGEXP_EXTRACT(segment, r'eVar96=([^|;,]*)') AS position,
  REGEXP_EXTRACT(segment, r'eVar109=([^|;,]*)') AS normalized_position,
  REGEXP_EXTRACT(segment, r'eVar124=([^|;,]*)') AS sponsored_status,
  COUNT(*) AS occurrences
FROM `wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event`,
UNNEST(SPLIT(prod_lst_txt, ',')) AS segment
WHERE op_cmpny_cd = 'SAMS-MX'
  AND ds = @fecha_reporte
  AND chnl_txt IN ('searchResults', 'browseResults')
  AND prod_lst_txt IS NOT NULL
  AND segment != ''
GROUP BY item_nbr, position, normalized_position, sponsored_status
HAVING item_nbr IS NOT NULL
ORDER BY occurrences DESC
LIMIT 500;
