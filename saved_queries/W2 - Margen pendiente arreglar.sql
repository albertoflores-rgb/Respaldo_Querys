-- ============================================================
-- W2 - Margen Inicial y Sostenido — SAM'S CLUB MX (v2, migrado)
-- ------------------------------------------------------------
-- ORIGEN: este query era una copia casi literal de
-- "W2 - MArgen inicial y Sostenido.sql" (Walmart Autoservicios,
-- dataset wmt-edw-prod.MX_WM_VM) — por eso NO corría en Sam's:
-- las tablas SKU_DLY_POS/ITEM/ITEM_DESC/TRAIT_STORE/CATALOGUE_*
-- de Walmart no existen (o no significan lo mismo) en el dataset
-- de Sam's (wmt-edw-prod.MX_WC_VM). El original quedó "pendiente
-- arreglar" por eso. Este archivo lo reescribe para Sam's,
-- tomando como base los patrones de JOIN de
-- "SAMS - Venta e Inventarios Ecatman - Diario TY vs LY.sql"
-- (Old_NBR bridge, MDSE_INVENTORY/ITEM_DESC, TYPE_CODE IN
-- ('22','20'), Black_Bird.Catalogo_Cat_Subcat).
--
-- DECISIONES DE MIGRACIÓN (con luz verde de Alberto, 08-sep-2026):
--
-- 1) ESTRUCTURA: el original repetía el MISMO bloque de ~11
--    tablas TMP (ventas, netships, MUMD, MD, MU) UNA VEZ POR
--    CADA PERIODO (MTD actual + Enero + Febrero, con fechas
--    quemadas a mano) usando DROP/CREATE TABLE — 33 tablas
--    temporales, puro copy-paste, viola DRY feo. Aquí se
--    reescribe PARAMETRIZADO: un solo rango `date_ini`/`date_fin`
--    (default = YTD del año en curso) y GROUP BY YEAR_MONTH hace
--    el desglose mensual solo, sin repetir código. Ajusta el
--    rango de fechas abajo según lo que necesites (un solo mes,
--    últimos N días, año completo, etc.).
--
-- 2) GRANO: el original agrupaba a nivel Departamento-Categoría-
--    Fineline (jerarquía "Autoservicios" de Walmart, con FORMATO
--    Bodega/Supercenter/Express y TRIBU/SQUAD). Sam's Club no
--    tiene múltiples formatos de tienda (todos los clubs son el
--    mismo formato) y este repo ya usa consistentemente el
--    catálogo Categoría-Subcategoría de
--    `Black_Bird.Catalogo_Cat_Subcat` para Sam's (sin Fineline).
--    Por eso aquí el grano final es CATEGORÍA-SUBCATEGORÍA, y se
--    eliminan las columnas FORMATO/TRIBU/SQUAD/FINELINE.
--
-- 3) MARGEN SOSTENIDO (MUMD) → 1:1, sin drama: Sam's SÍ tiene
--    tabla gemela exacta `MX_WC_VM.SKU_TY_DLY_MUMD` con las
--    mismas columnas que la de Walmart. Confirmado con
--    bigquery-explorer (get_table_schema), no es un supuesto.
--
-- 4) MARGEN INICIAL (NETSHIPS) →  SIN equivalente exacto.
--    `MX_WM_VM.SKU_DLY_SHIP` (item+tienda+semana con SHIP_COST Y
--    RETAIL_AMT explícitos) NO tiene gemela en MX_WC_VM. El
--    candidato más parecido es `MX_WC_VM.WEEKLY_STORE_SHIPS`,
--    pero usa `SELL_PRICE` (precio unitario) en vez de
--    `RETAIL_AMT`. Se usa aquí como mejor esfuerzo, con luz verde
--    de Alberto (08-sep-2026) — PERO el Margen Inicial resultante
--    queda PENDIENTE DE VALIDAR con negocio antes de confiar en
--    él para decisiones. Si el equipo de Merch confirma que
--    SELL_PRICE no es equivalente semántico a RETAIL_AMT, hay que
--    buscar otra fuente.
--
-- TABLAS USADAS (todas confirmadas por bigquery-explorer):
--   wmt-edw-prod.MX_WC_VM.SKU_DLY_POS         → ventas físicas diarias
--   wmt-edw-prod.MX_WC_VM.WEEKLY_STORE_SHIPS  → netships (Margen Inicial, best-effort)
--   wmt-edw-prod.MX_WC_VM.SKU_TY_DLY_MUMD     → markup/markdown (Margen Sostenido)
--   wmt-edw-prod.MX_WC_VM.ITEM_DESC           → catálogo de ítems (Categoria/Subcategoria/TYPE_CODE)
--   wmt-edw-prod.MX_WM_VM.CALENDAR_DAY        → calendario fiscal (compartido Walmart/Sam's)
--   wmt-mx-dl-controlledmgzn-prod.Black_Bird.Catalogo_Cat_Subcat → nombres de Categoria/Subcategoria
-- ============================================================

DECLARE date_ini DATE DEFAULT DATE(EXTRACT(YEAR FROM CURRENT_DATE('America/Mexico_City')), 1, 1);
DECLARE date_fin DATE DEFAULT DATE_SUB(CURRENT_DATE('America/Mexico_City'), INTERVAL 1 DAY);
-- ↑ Default = YTD (1-ene del año en curso al día de ayer), que ya
--   incluye el mes en curso (MTD) como el último renglón del
--   GROUP BY YEAR_MONTH. Para un solo mes cerrado, usa DATE
--   literales tipo DATE '2026-01-01' / DATE '2026-01-31'.

DECLARE md_event_ids ARRAY<INT64> DEFAULT [
  1001,1002,1003,1004,1100,1101,1201,1202,1300,1305,1401,1402,1500,
  1505,1515,1516,1517,1518,1519,1521,1600,1700,1804,1805,1814
];  -- eventos de REBAJA (markdown) en SKU_TY_DLY_MUMD

DECLARE mu_event_ids ARRAY<INT64> DEFAULT [
  1815,1816,1821,5001,5002,5003,5004,5100,5101,5201,5202,5300,5305,
  5401,5402,5500,5505,5515,5516,5518,5519,5600,5700,5804,5805,5816,
  5705,5811
];  -- eventos de ALZA (markup) en SKU_TY_DLY_MUMD

WITH

-- ------------------------------------------------------------
-- Catálogo Categoría/Subcategoría (solo para nombres, no se usa
-- para filtrar filas — igual que en el archivo Diario TY vs LY).
-- ------------------------------------------------------------
cte_catalogo AS (
  SELECT DISTINCT
    b.CATEGORY_NBR      AS CAT_NBR,
    cat.Categoria        AS CAT_NOMBRE,
    b.SUB_CATEGORY_NBR   AS SUBCAT_NBR,
    cat.Sub_Categoria     AS SUBCAT_NOMBRE
  FROM `wmt-edw-prod.MX_WC_VM.ITEM_DESC` b
  LEFT JOIN `wmt-mx-dl-controlledmgzn-prod.Black_Bird.Catalogo_Cat_Subcat` cat
    ON  SAFE_CAST(cat.Categoria_NBR AS INT64) = b.CATEGORY_NBR
    AND SAFE_CAST(cat.Sub_Categoria_Code AS INT64) = b.SUB_CATEGORY_NBR
  WHERE b.TYPE_CODE IN ('22', '20')  -- activo | inactivo (dominio Sam's)
),

-- ------------------------------------------------------------
-- VENTAS (piezas + pesos), TY y LY en un solo scan pivotado.
--   LY se homologa al mes de TY sumándole 1 año a su fecha ANTES
--   de sacar el YEAR_MONTH, así Ene-2026 (TY) cae en la misma
--   fila que Ene-2025 (LY).
-- ------------------------------------------------------------
cte_ventas_rows AS (
  SELECT
    'TY' AS PERIOD,
    b.CATEGORY_NBR AS CAT_NBR,
    b.SUB_CATEGORY_NBR AS SUBCAT_NBR,
    FORMAT_DATE('%Y-%m', h.gregorian_date) AS YEAR_MONTH,
    (a.SAT_QTY * h.sat_mult + a.SUN_QTY * h.sun_mult + a.MON_QTY * h.mon_mult
     + a.TUE_QTY * h.tue_mult + a.WED_QTY * h.wed_mult + a.THU_QTY * h.thu_mult
     + a.FRI_QTY * h.fri_mult) AS piezas,
    (a.SAT_SALES_AMT * h.sat_mult + a.SUN_SALES_AMT * h.sun_mult + a.MON_SALES_AMT * h.mon_mult
     + a.TUE_SALES_AMT * h.tue_mult + a.WED_SALES_AMT * h.wed_mult + a.THU_SALES_AMT * h.thu_mult
     + a.FRI_SALES_AMT * h.fri_mult) AS pesos
  FROM `wmt-edw-prod.MX_WC_VM.SKU_DLY_POS` a
  INNER JOIN `wmt-edw-prod.MX_WC_VM.ITEM_DESC` b ON a.ITEM_NBR = b.ITEM_NBR
  INNER JOIN `wmt-edw-prod.MX_WM_VM.CALENDAR_DAY` h ON a.WM_YR_WK = h.wm_yr_wk
  WHERE h.gregorian_date BETWEEN date_ini AND date_fin
    AND b.TYPE_CODE IN ('22', '20')

  UNION ALL

  SELECT
    'LY' AS PERIOD,
    b.CATEGORY_NBR,
    b.SUB_CATEGORY_NBR,
    FORMAT_DATE('%Y-%m', DATE_ADD(h.gregorian_date, INTERVAL 1 YEAR)) AS YEAR_MONTH,
    (a.SAT_QTY * h.sat_mult + a.SUN_QTY * h.sun_mult + a.MON_QTY * h.mon_mult
     + a.TUE_QTY * h.tue_mult + a.WED_QTY * h.wed_mult + a.THU_QTY * h.thu_mult
     + a.FRI_QTY * h.fri_mult) AS piezas,
    (a.SAT_SALES_AMT * h.sat_mult + a.SUN_SALES_AMT * h.sun_mult + a.MON_SALES_AMT * h.mon_mult
     + a.TUE_SALES_AMT * h.tue_mult + a.WED_SALES_AMT * h.wed_mult + a.THU_SALES_AMT * h.thu_mult
     + a.FRI_SALES_AMT * h.fri_mult) AS pesos
  FROM `wmt-edw-prod.MX_WC_VM.SKU_DLY_POS` a
  INNER JOIN `wmt-edw-prod.MX_WC_VM.ITEM_DESC` b ON a.ITEM_NBR = b.ITEM_NBR
  INNER JOIN `wmt-edw-prod.MX_WM_VM.CALENDAR_DAY` h ON a.WM_YR_WK = h.wm_yr_wk
  WHERE h.gregorian_date BETWEEN DATE_SUB(date_ini, INTERVAL 1 YEAR) AND DATE_SUB(date_fin, INTERVAL 1 YEAR)
    AND b.TYPE_CODE IN ('22', '20')
),
cte_ventas AS (
  SELECT
    CAT_NBR, SUBCAT_NBR, YEAR_MONTH,
    SUM(IF(PERIOD = 'TY', piezas, 0)) AS VENTA_PIEZAS_TY,
    SUM(IF(PERIOD = 'TY', pesos, 0))  AS VENTA_PESOS_TY,
    SUM(IF(PERIOD = 'LY', piezas, 0)) AS VENTA_PIEZAS_LY,
    SUM(IF(PERIOD = 'LY', pesos, 0))  AS VENTA_PESOS_LY
  FROM cte_ventas_rows
  GROUP BY 1, 2, 3
),

-- ------------------------------------------------------------
-- NETSHIPS (Margen Inicial) — best-effort vía WEEKLY_STORE_SHIPS.
--   Ver nota de cabecera: SELL_PRICE aquí sustituye a RETAIL_AMT
--   de Walmart, pendiente de validar con negocio.
-- ------------------------------------------------------------
cte_netships_rows AS (
  SELECT
    'TY' AS PERIOD,
    b.CATEGORY_NBR AS CAT_NBR,
    b.SUB_CATEGORY_NBR AS SUBCAT_NBR,
    FORMAT_DATE('%Y-%m', h.gregorian_date) AS YEAR_MONTH,
    (a.SAT_QTY * h.sat_mult + a.SUN_QTY * h.sun_mult + a.MON_QTY * h.mon_mult
     + a.TUE_QTY * h.tue_mult + a.WED_QTY * h.wed_mult + a.THU_QTY * h.thu_mult
     + a.FRI_QTY * h.fri_mult) AS qty_wk,
    (a.SAT_QTY * h.sat_mult + a.SUN_QTY * h.sun_mult + a.MON_QTY * h.mon_mult
     + a.TUE_QTY * h.tue_mult + a.WED_QTY * h.wed_mult + a.THU_QTY * h.thu_mult
     + a.FRI_QTY * h.fri_mult) * a.SHIP_COST AS cost_wk,
    (a.SAT_QTY * h.sat_mult + a.SUN_QTY * h.sun_mult + a.MON_QTY * h.mon_mult
     + a.TUE_QTY * h.tue_mult + a.WED_QTY * h.wed_mult + a.THU_QTY * h.thu_mult
     + a.FRI_QTY * h.fri_mult) * a.SELL_PRICE AS rtl_wk
  FROM `wmt-edw-prod.MX_WC_VM.WEEKLY_STORE_SHIPS` a
  INNER JOIN `wmt-edw-prod.MX_WC_VM.ITEM_DESC` b ON a.ITEM_NBR = b.ITEM_NBR
  INNER JOIN `wmt-edw-prod.MX_WM_VM.CALENDAR_DAY` h ON a.WM_YR_WK = h.wm_yr_wk
  WHERE h.gregorian_date BETWEEN date_ini AND date_fin
    AND b.TYPE_CODE IN ('22', '20')

  UNION ALL

  SELECT
    'LY' AS PERIOD,
    b.CATEGORY_NBR,
    b.SUB_CATEGORY_NBR,
    FORMAT_DATE('%Y-%m', DATE_ADD(h.gregorian_date, INTERVAL 1 YEAR)) AS YEAR_MONTH,
    (a.SAT_QTY * h.sat_mult + a.SUN_QTY * h.sun_mult + a.MON_QTY * h.mon_mult
     + a.TUE_QTY * h.tue_mult + a.WED_QTY * h.wed_mult + a.THU_QTY * h.thu_mult
     + a.FRI_QTY * h.fri_mult) AS qty_wk,
    (a.SAT_QTY * h.sat_mult + a.SUN_QTY * h.sun_mult + a.MON_QTY * h.mon_mult
     + a.TUE_QTY * h.tue_mult + a.WED_QTY * h.wed_mult + a.THU_QTY * h.thu_mult
     + a.FRI_QTY * h.fri_mult) * a.SHIP_COST AS cost_wk,
    (a.SAT_QTY * h.sat_mult + a.SUN_QTY * h.sun_mult + a.MON_QTY * h.mon_mult
     + a.TUE_QTY * h.tue_mult + a.WED_QTY * h.wed_mult + a.THU_QTY * h.thu_mult
     + a.FRI_QTY * h.fri_mult) * a.SELL_PRICE AS rtl_wk
  FROM `wmt-edw-prod.MX_WC_VM.WEEKLY_STORE_SHIPS` a
  INNER JOIN `wmt-edw-prod.MX_WC_VM.ITEM_DESC` b ON a.ITEM_NBR = b.ITEM_NBR
  INNER JOIN `wmt-edw-prod.MX_WM_VM.CALENDAR_DAY` h ON a.WM_YR_WK = h.wm_yr_wk
  WHERE h.gregorian_date BETWEEN DATE_SUB(date_ini, INTERVAL 1 YEAR) AND DATE_SUB(date_fin, INTERVAL 1 YEAR)
    AND b.TYPE_CODE IN ('22', '20')
),
cte_netships AS (
  SELECT
    CAT_NBR, SUBCAT_NBR, YEAR_MONTH,
    SUM(IF(PERIOD = 'TY', cost_wk, 0)) AS NETSHIPS_COST_TY,
    SUM(IF(PERIOD = 'TY', rtl_wk, 0))  AS NETSHIPS_RTL_TY,
    SUM(IF(PERIOD = 'TY', qty_wk, 0))  AS NETSHIPS_QTY_TY,
    SUM(IF(PERIOD = 'LY', cost_wk, 0)) AS NETSHIPS_COST_LY,
    SUM(IF(PERIOD = 'LY', rtl_wk, 0))  AS NETSHIPS_RTL_LY,
    SUM(IF(PERIOD = 'LY', qty_wk, 0))  AS NETSHIPS_QTY_LY
  FROM cte_netships_rows
  GROUP BY 1, 2, 3
),

-- ------------------------------------------------------------
-- MUMD (Margen Sostenido) — retail antes/después de cada evento
-- de cambio de precio. MD = solo rebajas, MU = solo alzas. Un
-- solo scan de la tabla con SUM(IF(...)) en vez de 3 tablas
-- separadas como hacía el original (mismo resultado, 1/3 del
-- costo de BQ).
-- ------------------------------------------------------------
cte_mumd_rows AS (
  SELECT
    'TY' AS PERIOD,
    b.CATEGORY_NBR AS CAT_NBR,
    b.SUB_CATEGORY_NBR AS SUBCAT_NBR,
    FORMAT_DATE('%Y-%m', h.gregorian_date) AS YEAR_MONTH,
    a.EVENT_ID,
    (a.SAT_ITEM_QTY * h.sat_mult + a.SUN_ITEM_QTY * h.sun_mult + a.MON_ITEM_QTY * h.mon_mult
     + a.TUE_ITEM_QTY * h.tue_mult + a.WED_ITEM_QTY * h.wed_mult + a.THU_ITEM_QTY * h.thu_mult
     + a.FRI_ITEM_QTY * h.fri_mult) AS qty_wk,
    (a.SAT_PRE_TOT_RETL * h.sat_mult + a.SUN_PRE_TOT_RETL * h.sun_mult + a.MON_PRE_TOT_RETL * h.mon_mult
     + a.TUE_PRE_TOT_RETL * h.tue_mult + a.WED_PRE_TOT_RETL * h.wed_mult + a.THU_PRE_TOT_RETL * h.thu_mult
     + a.FRI_PRE_TOT_RETL * h.fri_mult)
    -
    (a.SAT_CUR_TOT_RETL * h.sat_mult + a.SUN_CUR_TOT_RETL * h.sun_mult + a.MON_CUR_TOT_RETL * h.mon_mult
     + a.TUE_CUR_TOT_RETL * h.tue_mult + a.WED_CUR_TOT_RETL * h.wed_mult + a.THU_CUR_TOT_RETL * h.thu_mult
     + a.FRI_CUR_TOT_RETL * h.fri_mult) AS retl_delta_wk
  FROM `wmt-edw-prod.MX_WC_VM.SKU_TY_DLY_MUMD` a
  INNER JOIN `wmt-edw-prod.MX_WC_VM.ITEM_DESC` b ON a.ITEM_NBR = b.ITEM_NBR
  INNER JOIN `wmt-edw-prod.MX_WM_VM.CALENDAR_DAY` h ON a.WM_YR_WK = h.wm_yr_wk
  WHERE h.gregorian_date BETWEEN date_ini AND date_fin
    AND b.TYPE_CODE IN ('22', '20')

  UNION ALL

  SELECT
    'LY' AS PERIOD,
    b.CATEGORY_NBR,
    b.SUB_CATEGORY_NBR,
    FORMAT_DATE('%Y-%m', DATE_ADD(h.gregorian_date, INTERVAL 1 YEAR)) AS YEAR_MONTH,
    a.EVENT_ID,
    (a.SAT_ITEM_QTY * h.sat_mult + a.SUN_ITEM_QTY * h.sun_mult + a.MON_ITEM_QTY * h.mon_mult
     + a.TUE_ITEM_QTY * h.tue_mult + a.WED_ITEM_QTY * h.wed_mult + a.THU_ITEM_QTY * h.thu_mult
     + a.FRI_ITEM_QTY * h.fri_mult) AS qty_wk,
    (a.SAT_PRE_TOT_RETL * h.sat_mult + a.SUN_PRE_TOT_RETL * h.sun_mult + a.MON_PRE_TOT_RETL * h.mon_mult
     + a.TUE_PRE_TOT_RETL * h.tue_mult + a.WED_PRE_TOT_RETL * h.wed_mult + a.THU_PRE_TOT_RETL * h.thu_mult
     + a.FRI_PRE_TOT_RETL * h.fri_mult)
    -
    (a.SAT_CUR_TOT_RETL * h.sat_mult + a.SUN_CUR_TOT_RETL * h.sun_mult + a.MON_CUR_TOT_RETL * h.mon_mult
     + a.TUE_CUR_TOT_RETL * h.tue_mult + a.WED_CUR_TOT_RETL * h.wed_mult + a.THU_CUR_TOT_RETL * h.thu_mult
     + a.FRI_CUR_TOT_RETL * h.fri_mult) AS retl_delta_wk
  FROM `wmt-edw-prod.MX_WC_VM.SKU_TY_DLY_MUMD` a
  INNER JOIN `wmt-edw-prod.MX_WC_VM.ITEM_DESC` b ON a.ITEM_NBR = b.ITEM_NBR
  INNER JOIN `wmt-edw-prod.MX_WM_VM.CALENDAR_DAY` h ON a.WM_YR_WK = h.wm_yr_wk
  WHERE h.gregorian_date BETWEEN DATE_SUB(date_ini, INTERVAL 1 YEAR) AND DATE_SUB(date_fin, INTERVAL 1 YEAR)
    AND b.TYPE_CODE IN ('22', '20')
),
cte_mumd AS (
  SELECT
    CAT_NBR, SUBCAT_NBR, YEAR_MONTH,
    SUM(IF(PERIOD = 'TY', qty_wk, 0))        AS MUMD_QTY_TY,
    SUM(IF(PERIOD = 'TY', retl_delta_wk, 0)) AS MUMD_RTL_TY,
    SUM(IF(PERIOD = 'TY' AND EVENT_ID IN UNNEST(md_event_ids), retl_delta_wk, 0)) AS MD_RTL_TY,
    SUM(IF(PERIOD = 'TY' AND EVENT_ID IN UNNEST(mu_event_ids), retl_delta_wk, 0)) AS MU_RTL_TY,
    SUM(IF(PERIOD = 'LY', qty_wk, 0))        AS MUMD_QTY_LY,
    SUM(IF(PERIOD = 'LY', retl_delta_wk, 0)) AS MUMD_RTL_LY,
    SUM(IF(PERIOD = 'LY' AND EVENT_ID IN UNNEST(md_event_ids), retl_delta_wk, 0)) AS MD_RTL_LY,
    SUM(IF(PERIOD = 'LY' AND EVENT_ID IN UNNEST(mu_event_ids), retl_delta_wk, 0)) AS MU_RTL_LY
  FROM cte_mumd_rows
  GROUP BY 1, 2, 3
),

-- ------------------------------------------------------------
-- Universo de (Categoría, Subcategoría, Mes) que aparecieron en
-- CUALQUIERA de las 3 fuentes — reemplaza al "TMP1 catálogo
-- maestro" del original como tabla base para los LEFT JOIN.
-- ------------------------------------------------------------
cte_base AS (
  SELECT CAT_NBR, SUBCAT_NBR, YEAR_MONTH FROM cte_ventas
  UNION DISTINCT
  SELECT CAT_NBR, SUBCAT_NBR, YEAR_MONTH FROM cte_netships
  UNION DISTINCT
  SELECT CAT_NBR, SUBCAT_NBR, YEAR_MONTH FROM cte_mumd
)

-- ============================================================
-- SELECT FINAL: Categoría/Subcategoría/Mes + Ventas + Netships
-- (Margen Inicial) + MUMD (Margen Sostenido), TY y LY lado a
-- lado.
-- ============================================================
SELECT
  base.YEAR_MONTH,
  base.CAT_NBR, cat.CAT_NOMBRE,
  base.SUBCAT_NBR, cat.SUBCAT_NOMBRE,

  v.VENTA_PIEZAS_TY, v.VENTA_PESOS_TY,
  v.VENTA_PIEZAS_LY, v.VENTA_PESOS_LY,

  n.NETSHIPS_COST_TY, n.NETSHIPS_RTL_TY, n.NETSHIPS_QTY_TY,
  n.NETSHIPS_COST_LY, n.NETSHIPS_RTL_LY, n.NETSHIPS_QTY_LY,

  m.MUMD_QTY_TY, m.MUMD_RTL_TY,
  m.MUMD_QTY_LY, m.MUMD_RTL_LY,
  m.MD_RTL_TY, m.MD_RTL_LY,
  m.MU_RTL_TY, m.MU_RTL_LY

FROM cte_base base
LEFT JOIN cte_catalogo cat
  ON base.CAT_NBR = cat.CAT_NBR AND base.SUBCAT_NBR = cat.SUBCAT_NBR
LEFT JOIN cte_ventas v
  ON base.CAT_NBR = v.CAT_NBR AND base.SUBCAT_NBR = v.SUBCAT_NBR AND base.YEAR_MONTH = v.YEAR_MONTH
LEFT JOIN cte_netships n
  ON base.CAT_NBR = n.CAT_NBR AND base.SUBCAT_NBR = n.SUBCAT_NBR AND base.YEAR_MONTH = n.YEAR_MONTH
LEFT JOIN cte_mumd m
  ON base.CAT_NBR = m.CAT_NBR AND base.SUBCAT_NBR = m.SUBCAT_NBR AND base.YEAR_MONTH = m.YEAR_MONTH

-- ── Filtros opcionales ────────────────────────────────────
-- WHERE base.CAT_NBR IN (41, 43, 46, 49, 53, 68)

ORDER BY base.YEAR_MONTH, base.CAT_NBR, base.SUBCAT_NBR
