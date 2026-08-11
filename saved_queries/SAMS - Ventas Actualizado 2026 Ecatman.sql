-- ============================================================
-- Ventas_e_Inventarios_SAMS_v1.sql
-- Canal   : Sam's Club MX — Todos los Clubs (176)
-- Área    : E-Catman
-- Versión : 1.5 | Junio 2026  — Fix duplicados venta física y venta .com
--   · cte_ventas_com : eliminados JOINs fan-out con VISIT y STORE_TRANSACTION
--                       (STORE_TRANSACTION tiene N filas/visita → cada SCAN × N)
--   · cte_ventas      : ITEM_DESC deduplicada con QUALIFY (multi-proveedor)
--   · cte_inventarios : ídem dedup ITEM_DESC
--
-- TABLAS CONFIRMADAS:
--   wmt-edw-prod.MX_WC_VM.SKU_DLY_POS             → ventas físicas diarias
--   wmt-edw-prod.MX_WC_MB_VM.SCAN                 → ventas .com (tabla exclusiva ecommerce)
--   wmt-edw-prod.MX_WC_MB_VM.VISIT                → visitas online (ORDER_ID siempre presente)
--   wmt-edw-prod.MX_WC_MB_VM.STORE_TRANSACTION    → transacciones completadas
--   wmt-edw-prod.MX_WC_VM.MDSE_INVENTORY          → inventario por club
--   wmt-edw-prod.MX_WC_VM.ITEM_DESC               → catálogo de ítems
--   wmt-edw-prod.MX_WM_VM.CALENDAR_DAY            → calendario fiscal (compartido WM/SAMS)
--   wmt-edw-sandbox.Black_Bird.Catalogo_Clubes          → dim. clubs
--   wmt-edw-sandbox.Black_Bird.Catalogo_Cat_Subcat      → dim. categorías
--
-- NOTA .com: MX_WC_MB_VM es exclusivamente ecommerce (sin ventas presenciales).
--   No requiere filtro por "trait" — se excluyen ghost records (ITEM_NBR IS NULL)
--   y devoluciones (UNIT_QTY <= 0). Confirmado vía exploración BQ jun-2026.
--
-- NOTA Catalogo_Cat_Subcat: cargada sin headers. Mapeo inferido:
--   string_field_0 = Cat_Nbr  | string_field_1 = Cat_Nombre
--   string_field_4 = Subcat_Nbr | string_field_5 = Subcat_Nombre
-- ============================================================

WITH

-- ------------------------------------------------------------
-- CTE 1: POS físico diario — piezas y pesos ponderados por día
--   Usa los multiplicadores de CALENDAR_DAY para asignar las
--   ventas semanales al mes calendario correcto.
--   SAT_SALES_AMT…FRI_SALES_AMT son el importe real por día.
-- ------------------------------------------------------------
cte_pos_diario AS (
  SELECT
    a.STORE_NBR,
    a.ITEM_NBR,
    d.gregorian_date,
    ( a.SAT_QTY * d.sat_mult + a.SUN_QTY * d.sun_mult
    + a.MON_QTY * d.mon_mult + a.TUE_QTY * d.tue_mult
    + a.WED_QTY * d.wed_mult + a.THU_QTY * d.thu_mult
    + a.FRI_QTY * d.fri_mult )                       AS piezas_dia,
    ( a.SAT_SALES_AMT * d.sat_mult + a.SUN_SALES_AMT * d.sun_mult
    + a.MON_SALES_AMT * d.mon_mult + a.TUE_SALES_AMT * d.tue_mult
    + a.WED_SALES_AMT * d.wed_mult + a.THU_SALES_AMT * d.thu_mult
    + a.FRI_SALES_AMT * d.fri_mult )                 AS pesos_dia
  FROM `wmt-edw-prod.MX_WC_VM.SKU_DLY_POS`        AS a
  INNER JOIN `wmt-edw-prod.MX_WM_VM.CALENDAR_DAY`  AS d ON a.WM_YR_WK = d.wm_yr_wk
  WHERE EXTRACT(YEAR FROM d.gregorian_date) IN (
    EXTRACT(YEAR FROM CURRENT_DATE),
    EXTRACT(YEAR FROM CURRENT_DATE) - 1
  )
),

-- ------------------------------------------------------------
-- CTE 2: Ventas físicas mensuales TY + LY — pivot por club / ítem
-- ------------------------------------------------------------
cte_ventas AS (
  SELECT
    v.STORE_NBR                                     AS CLUB_NBR,
    f.CLUB_NAME, f.DISTRITO, f.REGION, f.ESTADO,
    b.CATEGORY_NBR                                  AS CAT_NBR,
    cat.Categoria                              AS CAT_NOMBRE,
    b.SUB_CATEGORY_NBR                              AS SUBCAT_NBR,
    cat.Sub_Categoria                              AS SUBCAT_NOMBRE,
    b.Old_NBR                                       AS ITEM_NBR,
    b.PRIMARY_DESC                                  AS ITEM_DESC_1,
    b.SECONDARY_DESC                                AS ITEM_DESC_2,
    b.TYPE_CODE                                     AS TYPE_ITEM,
    b.VENDOR_NAME,
    CAST(b.VENDOR_NBR AS NUMERIC) * 1000
      + CAST(b.VENDOR_NBR_DEPT AS NUMERIC) * 10
      + CAST(b.VENDOR_NBR_SEQ  AS NUMERIC)         AS VENDOR_NBR,

    -- Ventas Año Actual — Piezas
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 1  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.piezas_dia END), 0) AS Venta_Pzas_M01,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 2  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.piezas_dia END), 0) AS Venta_Pzas_M02,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 3  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.piezas_dia END), 0) AS Venta_Pzas_M03,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 4  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.piezas_dia END), 0) AS Venta_Pzas_M04,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 5  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.piezas_dia END), 0) AS Venta_Pzas_M05,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 6  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.piezas_dia END), 0) AS Venta_Pzas_M06,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 7  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.piezas_dia END), 0) AS Venta_Pzas_M07,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 8  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.piezas_dia END), 0) AS Venta_Pzas_M08,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 9  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.piezas_dia END), 0) AS Venta_Pzas_M09,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 10 AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.piezas_dia END), 0) AS Venta_Pzas_M10,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 11 AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.piezas_dia END), 0) AS Venta_Pzas_M11,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 12 AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.piezas_dia END), 0) AS Venta_Pzas_M12,
    -- Ventas Año Pasado — Piezas
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 1  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.piezas_dia END), 0) AS Venta_Pzas_M01LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 2  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.piezas_dia END), 0) AS Venta_Pzas_M02LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 3  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.piezas_dia END), 0) AS Venta_Pzas_M03LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 4  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.piezas_dia END), 0) AS Venta_Pzas_M04LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 5  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.piezas_dia END), 0) AS Venta_Pzas_M05LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 6  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.piezas_dia END), 0) AS Venta_Pzas_M06LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 7  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.piezas_dia END), 0) AS Venta_Pzas_M07LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 8  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.piezas_dia END), 0) AS Venta_Pzas_M08LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 9  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.piezas_dia END), 0) AS Venta_Pzas_M09LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 10 AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.piezas_dia END), 0) AS Venta_Pzas_M10LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 11 AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.piezas_dia END), 0) AS Venta_Pzas_M11LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 12 AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.piezas_dia END), 0) AS Venta_Pzas_M12LY,
    -- Ventas Año Actual — Pesos
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 1  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.pesos_dia END), 0) AS VENTA_PESOS_M01,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 2  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.pesos_dia END), 0) AS VENTA_PESOS_M02,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 3  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.pesos_dia END), 0) AS VENTA_PESOS_M03,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 4  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.pesos_dia END), 0) AS VENTA_PESOS_M04,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 5  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.pesos_dia END), 0) AS VENTA_PESOS_M05,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 6  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.pesos_dia END), 0) AS VENTA_PESOS_M06,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 7  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.pesos_dia END), 0) AS VENTA_PESOS_M07,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 8  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.pesos_dia END), 0) AS VENTA_PESOS_M08,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 9  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.pesos_dia END), 0) AS VENTA_PESOS_M09,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 10 AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.pesos_dia END), 0) AS VENTA_PESOS_M10,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 11 AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.pesos_dia END), 0) AS VENTA_PESOS_M11,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 12 AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.pesos_dia END), 0) AS VENTA_PESOS_M12,
    -- Ventas Año Pasado — Pesos
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 1  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.pesos_dia END), 0) AS VENTA_PESOS_M01LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 2  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.pesos_dia END), 0) AS VENTA_PESOS_M02LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 3  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.pesos_dia END), 0) AS VENTA_PESOS_M03LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 4  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.pesos_dia END), 0) AS VENTA_PESOS_M04LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 5  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.pesos_dia END), 0) AS VENTA_PESOS_M05LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 6  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.pesos_dia END), 0) AS VENTA_PESOS_M06LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 7  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.pesos_dia END), 0) AS VENTA_PESOS_M07LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 8  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.pesos_dia END), 0) AS VENTA_PESOS_M08LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 9  AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.pesos_dia END), 0) AS VENTA_PESOS_M09LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 10 AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.pesos_dia END), 0) AS VENTA_PESOS_M10LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 11 AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.pesos_dia END), 0) AS VENTA_PESOS_M11LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM v.gregorian_date) = 12 AND EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN v.pesos_dia END), 0) AS VENTA_PESOS_M12LY

  FROM cte_pos_diario v
  -- FIX v1.5: ITEM_DESC puede tener N filas por ITEM_NBR (ítems multi-proveedor
  --   o reasignaciones). Sin dedup, el JOIN producía fan-out y ventas infladas.
  --   QUALIFY garantiza exactamente 1 fila por ITEM_NBR.
  INNER JOIN (
    SELECT
      ITEM_NBR, Old_NBR, PRIMARY_DESC, SECONDARY_DESC, TYPE_CODE,
      CATEGORY_NBR, SUB_CATEGORY_NBR,
      VENDOR_NAME, VENDOR_NBR, VENDOR_NBR_DEPT, VENDOR_NBR_SEQ
    FROM `wmt-edw-prod.MX_WC_VM.ITEM_DESC`
    QUALIFY ROW_NUMBER() OVER (PARTITION BY ITEM_NBR ORDER BY VENDOR_NBR ASC NULLS LAST) = 1
  )                                                AS b ON v.ITEM_NBR = b.ITEM_NBR
  LEFT JOIN  `wmt-edw-sandbox.Black_Bird.Catalogo_Clubes` f ON v.STORE_NBR = f.CLUB_NBR
  LEFT JOIN  `wmt-edw-sandbox.Black_Bird.Catalogo_Cat_Subcat` cat
    ON  SAFE_CAST(cat.Categoria_NBR AS INT64) = b.CATEGORY_NBR
    AND SAFE_CAST(cat.Sub_Categoria_Code AS INT64) = b.SUB_CATEGORY_NBR
  GROUP BY
    v.STORE_NBR, f.CLUB_NAME, f.DISTRITO, f.REGION, f.ESTADO,
    b.CATEGORY_NBR, cat.Categoria, b.SUB_CATEGORY_NBR, cat.Sub_Categoria,
    b.Old_NBR, b.PRIMARY_DESC, b.SECONDARY_DESC, b.TYPE_CODE,
    b.VENDOR_NAME, b.VENDOR_NBR, b.VENDOR_NBR_DEPT, b.VENDOR_NBR_SEQ
),

-- ------------------------------------------------------------
-- CTE 3: Ventas .com mensuales TY + LY  (OD + Click & Collect)
--   Fuente: MX_WC_MB_VM — tabla EXCLUSIVAMENTE ecommerce Sam's.
--   No requiere filtro por trait; se excluyen:
--     · Ghost records : ITEM_NBR IS NULL (SCAN_ID sin producto)
--     · Devoluciones  : UNIT_QTY <= 0
--   VISIT_DATE disponible directamente → no necesita CALENDAR_DAY.
-- ------------------------------------------------------------
cte_ventas_com AS (
  SELECT
    s.STORE_NBR                                     AS CLUB_NBR,
    i.Old_NBR                                       AS ITEM_NBR,

    -- .com Año Actual — Piezas
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 1  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.UNIT_QTY END), 0) AS COM_Pzas_M01,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 2  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.UNIT_QTY END), 0) AS COM_Pzas_M02,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 3  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.UNIT_QTY END), 0) AS COM_Pzas_M03,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 4  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.UNIT_QTY END), 0) AS COM_Pzas_M04,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 5  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.UNIT_QTY END), 0) AS COM_Pzas_M05,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 6  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.UNIT_QTY END), 0) AS COM_Pzas_M06,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 7  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.UNIT_QTY END), 0) AS COM_Pzas_M07,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 8  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.UNIT_QTY END), 0) AS COM_Pzas_M08,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 9  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.UNIT_QTY END), 0) AS COM_Pzas_M09,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 10 AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.UNIT_QTY END), 0) AS COM_Pzas_M10,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 11 AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.UNIT_QTY END), 0) AS COM_Pzas_M11,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 12 AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.UNIT_QTY END), 0) AS COM_Pzas_M12,
    -- .com Año Pasado — Piezas
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 1  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.UNIT_QTY END), 0) AS COM_Pzas_M01LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 2  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.UNIT_QTY END), 0) AS COM_Pzas_M02LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 3  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.UNIT_QTY END), 0) AS COM_Pzas_M03LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 4  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.UNIT_QTY END), 0) AS COM_Pzas_M04LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 5  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.UNIT_QTY END), 0) AS COM_Pzas_M05LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 6  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.UNIT_QTY END), 0) AS COM_Pzas_M06LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 7  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.UNIT_QTY END), 0) AS COM_Pzas_M07LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 8  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.UNIT_QTY END), 0) AS COM_Pzas_M08LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 9  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.UNIT_QTY END), 0) AS COM_Pzas_M09LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 10 AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.UNIT_QTY END), 0) AS COM_Pzas_M10LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 11 AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.UNIT_QTY END), 0) AS COM_Pzas_M11LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 12 AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.UNIT_QTY END), 0) AS COM_Pzas_M12LY,
    -- .com Año Actual — Pesos
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 1  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M01,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 2  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M02,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 3  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M03,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 4  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M04,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 5  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M05,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 6  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M06,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 7  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M07,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 8  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M08,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 9  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M09,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 10 AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M10,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 11 AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M11,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 12 AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M12,
    -- .com Año Pasado — Pesos
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 1  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M01LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 2  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M02LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 3  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M03LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 4  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M04LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 5  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M05LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 6  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M06LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 7  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M07LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 8  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M08LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 9  AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M09LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 10 AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M10LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 11 AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M11LY,
    COALESCE(SUM(CASE WHEN EXTRACT(MONTH FROM s.VISIT_DATE) = 12 AND EXTRACT(YEAR FROM s.VISIT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN s.RETAIL_PRICE END), 0) AS COM_Pesos_M12LY

  -- FIX v1.5: Se eliminan los JOINs con VISIT y STORE_TRANSACTION.
  --   Causa de duplicación confirmada: STORE_TRANSACTION puede tener N filas
  --   por visita (estados de pago, reintentos, autorizaciones parciales, etc.)
  --   → cada línea de SCAN se multiplicaba por N.
  --   VISIT tampoco aporta columnas al SELECT ni al WHERE → también innecesario.
  --   Los filtros UNIT_QTY > 0 + ITEM_NBR IS NOT NULL son suficientes para
  --   garantizar transacciones reales sin devoluciones ni ghost records.
  -- FIX v1.5: ITEM_DESC puede tener múltiples filas por Old_NBR (renumeración).
  --   QUALIFY garantiza 1:1 antes del JOIN.
  FROM `wmt-edw-prod.MX_WC_MB_VM.SCAN`            AS s
  INNER JOIN (
    SELECT Old_NBR
    FROM `wmt-edw-prod.MX_WC_VM.ITEM_DESC`
    QUALIFY ROW_NUMBER() OVER (PARTITION BY Old_NBR ORDER BY ITEM_NBR ASC) = 1
  )                                                AS i
    ON  s.ITEM_NBR   = i.Old_NBR   -- SCAN guarda Old_NBR en ITEM_NBR (no el ID interno)
  WHERE
    EXTRACT(YEAR FROM s.VISIT_DATE) IN (
      EXTRACT(YEAR FROM CURRENT_DATE),
      EXTRACT(YEAR FROM CURRENT_DATE) - 1
    )
    AND s.UNIT_QTY  > 0          -- excluir devoluciones / reversos
    AND s.ITEM_NBR IS NOT NULL   -- excluir ghost records (traits de canal)
  GROUP BY
    s.STORE_NBR, i.Old_NBR
),

-- ------------------------------------------------------------
-- CTE 4: Inventario actual por Club — 176 clubs, sin filtro cat.
-- ------------------------------------------------------------
cte_inventarios AS (
  SELECT
    a.CLUB_NBR,
    f.CLUB_NAME, f.DISTRITO, f.REGION, f.ESTADO,
    b.CATEGORY_NBR                                          AS CAT_NBR,
    cat.Categoria                                      AS CAT_NOMBRE,
    b.SUB_CATEGORY_NBR                                      AS SUBCAT_NBR,
    cat.Sub_Categoria                                      AS SUBCAT_NOMBRE,
    b.Old_NBR                                               AS ITEM_NBR,
    b.PRIMARY_DESC                                          AS ITEM_DESC_1,
    b.SECONDARY_DESC                                        AS ITEM_DESC_2,
    b.TYPE_CODE                                             AS TYPE_ITEM,
    b.VENDOR_NAME,
    CAST(b.VENDOR_NBR AS NUMERIC) * 1000
      + CAST(b.VENDOR_NBR_DEPT AS NUMERIC) * 10
      + CAST(b.VENDOR_NBR_SEQ  AS NUMERIC)                 AS VENDOR_NBR,
    SUM(a.ONSITE_ONHAND_QTY)                                AS OH_Piso,
    SUM(a.OFFSITE_ONHAND_QTY)                               AS OH_Trastienda,
    SUM(a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY)        AS OH_Total,
    SUM(a.ON_ORDER_QTY)                                     AS OO_En_Orden,
    AVG(a.UNIT_COST)                                        AS Costo_Unit,
    AVG(a.UNIT_SELL)                                        AS Precio_Venta,
    SUM(ROUND((a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY) * a.UNIT_COST, 2)) AS OH_Costo_MXN,
    SUM(ROUND((a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY) * a.UNIT_SELL, 2)) AS OH_Retail_MXN,
    SUM(ROUND(a.ON_ORDER_QTY * a.UNIT_SELL, 2))            AS OO_Retail_MXN,
    MAX(a.ITEM_ON_SHELF_DATE)                               AS Fecha_Inicio,
    MAX(a.ITEM_OFF_SHELF_DT)                                AS Fecha_Fin,
    CURRENT_DATE('America/Mexico_City')                     AS Fecha_Corte,
    CASE
      WHEN SUM(a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY) = 0   THEN 'OOS'
      WHEN SUM(a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY) <= 5  THEN 'Crítico (<6)'
      WHEN SUM(a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY) <= 20 THEN 'Bajo (6-20)'
      ELSE                                                              'OK'
    END                                                     AS Semaforo_OH,
    CASE
      WHEN b.TYPE_CODE = '22'   -- '22' = ítem activo en Sam's
       AND SUM(a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY) = 0
       AND SUM(a.ON_ORDER_QTY) = 0                         THEN 'OOS_ACTIVO'
      ELSE NULL
    END                                                     AS Flag_OOS_Activo,
    COUNT(DISTINCT a.CLUB_NBR)                              AS NUM_CLUBS
  FROM `wmt-edw-prod.MX_WC_VM.MDSE_INVENTORY`           AS a
  -- FIX v1.5: ídem dedup ITEM_DESC para inventario (misma razón que cte_ventas).
  JOIN  (
    SELECT
      ITEM_NBR, Old_NBR, PRIMARY_DESC, SECONDARY_DESC, TYPE_CODE,
      CATEGORY_NBR, SUB_CATEGORY_NBR,
      VENDOR_NAME, VENDOR_NBR, VENDOR_NBR_DEPT, VENDOR_NBR_SEQ
    FROM `wmt-edw-prod.MX_WC_VM.ITEM_DESC`
    QUALIFY ROW_NUMBER() OVER (PARTITION BY ITEM_NBR ORDER BY VENDOR_NBR ASC NULLS LAST) = 1
  )                                                       AS b  ON a.ITEM_NBR = b.ITEM_NBR
  LEFT JOIN `wmt-edw-sandbox.Black_Bird.Catalogo_Clubes`  AS f  ON a.CLUB_NBR = f.CLUB_NBR
  LEFT JOIN `wmt-edw-sandbox.Black_Bird.Catalogo_Cat_Subcat` AS cat
    ON  SAFE_CAST(cat.Categoria_NBR AS INT64) = b.CATEGORY_NBR
    AND SAFE_CAST(cat.Sub_Categoria_Code AS INT64) = b.SUB_CATEGORY_NBR
  -- Sam's TYPE_CODE: '22' = activo | '20' = inactivo (distinto a WM que usa 'A'/'I')
  WHERE b.TYPE_CODE IN ('22', '20')
  -- AND b.CATEGORY_NBR IN (41, 43, 46, 49, 53, 68)  -- filtro opcional por cat
  GROUP BY
    a.CLUB_NBR, f.CLUB_NAME, f.DISTRITO, f.REGION, f.ESTADO,
    b.CATEGORY_NBR, cat.Categoria, b.SUB_CATEGORY_NBR, cat.Sub_Categoria,
    b.Old_NBR, b.PRIMARY_DESC, b.SECONDARY_DESC, b.TYPE_CODE,
    b.VENDOR_NAME, b.VENDOR_NBR, b.VENDOR_NBR_DEPT, b.VENDOR_NBR_SEQ
)

-- ============================================================
-- Consulta final: Inventario + Ventas Físicas + Ventas .com
--   T2 (inventario) es la base → RIGHT JOIN con T1 (físico)
--   T3 (.com) se agrega con LEFT JOIN sobre la misma clave
-- ============================================================
SELECT
  -- ── Identificadores ──────────────────────────────────────
  COALESCE(T1.CLUB_NBR,      T2.CLUB_NBR)      AS CLUB_NBR,
  COALESCE(T1.CLUB_NAME,     T2.CLUB_NAME)     AS CLUB_NAME,
  COALESCE(T1.DISTRITO,      T2.DISTRITO)      AS DISTRITO,
  COALESCE(T1.REGION,        T2.REGION)        AS REGION,
  COALESCE(T1.ESTADO,        T2.ESTADO)        AS ESTADO,
  COALESCE(T1.CAT_NBR,       T2.CAT_NBR)       AS CAT_NBR,
  COALESCE(T1.CAT_NOMBRE,    T2.CAT_NOMBRE)    AS CAT_NOMBRE,
  COALESCE(T1.SUBCAT_NBR,    T2.SUBCAT_NBR)    AS SUBCAT_NBR,
  COALESCE(T1.SUBCAT_NOMBRE, T2.SUBCAT_NOMBRE) AS SUBCAT_NOMBRE,
  COALESCE(T1.ITEM_NBR,      T2.ITEM_NBR)      AS ITEM_NBR,
  T2.ITEM_DESC_1, T2.ITEM_DESC_2,
  T2.TYPE_ITEM, T2.VENDOR_NAME, T2.VENDOR_NBR,

  -- ── Inventario ────────────────────────────────────────────
  T2.OH_Piso, T2.OH_Trastienda, T2.OH_Total, T2.OO_En_Orden,
  T2.Costo_Unit, T2.Precio_Venta,
  T2.OH_Costo_MXN, T2.OH_Retail_MXN, T2.OO_Retail_MXN,
  T2.Fecha_Inicio, T2.Fecha_Fin, T2.Fecha_Corte,
  T2.Semaforo_OH, T2.Flag_OOS_Activo, T2.NUM_CLUBS,

  -- ── Ventas Físicas TY — Piezas ───────────────────────────
  T1.Venta_Pzas_M01, T1.Venta_Pzas_M02, T1.Venta_Pzas_M03,
  T1.Venta_Pzas_M04, T1.Venta_Pzas_M05, T1.Venta_Pzas_M06,
  T1.Venta_Pzas_M07, T1.Venta_Pzas_M08, T1.Venta_Pzas_M09,
  T1.Venta_Pzas_M10, T1.Venta_Pzas_M11, T1.Venta_Pzas_M12,
  -- ── Ventas Físicas TY — Pesos ────────────────────────────
  T1.VENTA_PESOS_M01, T1.VENTA_PESOS_M02, T1.VENTA_PESOS_M03,
  T1.VENTA_PESOS_M04, T1.VENTA_PESOS_M05, T1.VENTA_PESOS_M06,
  T1.VENTA_PESOS_M07, T1.VENTA_PESOS_M08, T1.VENTA_PESOS_M09,
  T1.VENTA_PESOS_M10, T1.VENTA_PESOS_M11, T1.VENTA_PESOS_M12,
  -- ── Ventas Físicas LY — Piezas ───────────────────────────
  T1.Venta_Pzas_M01LY, T1.Venta_Pzas_M02LY, T1.Venta_Pzas_M03LY,
  T1.Venta_Pzas_M04LY, T1.Venta_Pzas_M05LY, T1.Venta_Pzas_M06LY,
  T1.Venta_Pzas_M07LY, T1.Venta_Pzas_M08LY, T1.Venta_Pzas_M09LY,
  T1.Venta_Pzas_M10LY, T1.Venta_Pzas_M11LY, T1.Venta_Pzas_M12LY,
  -- ── Ventas Físicas LY — Pesos ────────────────────────────
  T1.VENTA_PESOS_M01LY, T1.VENTA_PESOS_M02LY, T1.VENTA_PESOS_M03LY,
  T1.VENTA_PESOS_M04LY, T1.VENTA_PESOS_M05LY, T1.VENTA_PESOS_M06LY,
  T1.VENTA_PESOS_M07LY, T1.VENTA_PESOS_M08LY, T1.VENTA_PESOS_M09LY,
  T1.VENTA_PESOS_M10LY, T1.VENTA_PESOS_M11LY, T1.VENTA_PESOS_M12LY,

  -- ── Ventas .com TY — Piezas ──────────────────────────────
  COALESCE(T3.COM_Pzas_M01, 0) AS COM_Pzas_M01,
  COALESCE(T3.COM_Pzas_M02, 0) AS COM_Pzas_M02,
  COALESCE(T3.COM_Pzas_M03, 0) AS COM_Pzas_M03,
  COALESCE(T3.COM_Pzas_M04, 0) AS COM_Pzas_M04,
  COALESCE(T3.COM_Pzas_M05, 0) AS COM_Pzas_M05,
  COALESCE(T3.COM_Pzas_M06, 0) AS COM_Pzas_M06,
  COALESCE(T3.COM_Pzas_M07, 0) AS COM_Pzas_M07,
  COALESCE(T3.COM_Pzas_M08, 0) AS COM_Pzas_M08,
  COALESCE(T3.COM_Pzas_M09, 0) AS COM_Pzas_M09,
  COALESCE(T3.COM_Pzas_M10, 0) AS COM_Pzas_M10,
  COALESCE(T3.COM_Pzas_M11, 0) AS COM_Pzas_M11,
  COALESCE(T3.COM_Pzas_M12, 0) AS COM_Pzas_M12,
  -- ── Ventas .com TY — Pesos ───────────────────────────────
  COALESCE(T3.COM_Pesos_M01, 0) AS COM_Pesos_M01,
  COALESCE(T3.COM_Pesos_M02, 0) AS COM_Pesos_M02,
  COALESCE(T3.COM_Pesos_M03, 0) AS COM_Pesos_M03,
  COALESCE(T3.COM_Pesos_M04, 0) AS COM_Pesos_M04,
  COALESCE(T3.COM_Pesos_M05, 0) AS COM_Pesos_M05,
  COALESCE(T3.COM_Pesos_M06, 0) AS COM_Pesos_M06,
  COALESCE(T3.COM_Pesos_M07, 0) AS COM_Pesos_M07,
  COALESCE(T3.COM_Pesos_M08, 0) AS COM_Pesos_M08,
  COALESCE(T3.COM_Pesos_M09, 0) AS COM_Pesos_M09,
  COALESCE(T3.COM_Pesos_M10, 0) AS COM_Pesos_M10,
  COALESCE(T3.COM_Pesos_M11, 0) AS COM_Pesos_M11,
  COALESCE(T3.COM_Pesos_M12, 0) AS COM_Pesos_M12,
  -- ── Ventas .com LY — Piezas ──────────────────────────────
  COALESCE(T3.COM_Pzas_M01LY, 0) AS COM_Pzas_M01LY,
  COALESCE(T3.COM_Pzas_M02LY, 0) AS COM_Pzas_M02LY,
  COALESCE(T3.COM_Pzas_M03LY, 0) AS COM_Pzas_M03LY,
  COALESCE(T3.COM_Pzas_M04LY, 0) AS COM_Pzas_M04LY,
  COALESCE(T3.COM_Pzas_M05LY, 0) AS COM_Pzas_M05LY,
  COALESCE(T3.COM_Pzas_M06LY, 0) AS COM_Pzas_M06LY,
  COALESCE(T3.COM_Pzas_M07LY, 0) AS COM_Pzas_M07LY,
  COALESCE(T3.COM_Pzas_M08LY, 0) AS COM_Pzas_M08LY,
  COALESCE(T3.COM_Pzas_M09LY, 0) AS COM_Pzas_M09LY,
  COALESCE(T3.COM_Pzas_M10LY, 0) AS COM_Pzas_M10LY,
  COALESCE(T3.COM_Pzas_M11LY, 0) AS COM_Pzas_M11LY,
  COALESCE(T3.COM_Pzas_M12LY, 0) AS COM_Pzas_M12LY,
  -- ── Ventas .com LY — Pesos ───────────────────────────────
  COALESCE(T3.COM_Pesos_M01LY, 0) AS COM_Pesos_M01LY,
  COALESCE(T3.COM_Pesos_M02LY, 0) AS COM_Pesos_M02LY,
  COALESCE(T3.COM_Pesos_M03LY, 0) AS COM_Pesos_M03LY,
  COALESCE(T3.COM_Pesos_M04LY, 0) AS COM_Pesos_M04LY,
  COALESCE(T3.COM_Pesos_M05LY, 0) AS COM_Pesos_M05LY,
  COALESCE(T3.COM_Pesos_M06LY, 0) AS COM_Pesos_M06LY,
  COALESCE(T3.COM_Pesos_M07LY, 0) AS COM_Pesos_M07LY,
  COALESCE(T3.COM_Pesos_M08LY, 0) AS COM_Pesos_M08LY,
  COALESCE(T3.COM_Pesos_M09LY, 0) AS COM_Pesos_M09LY,
  COALESCE(T3.COM_Pesos_M10LY, 0) AS COM_Pesos_M10LY,
  COALESCE(T3.COM_Pesos_M11LY, 0) AS COM_Pesos_M11LY,
  COALESCE(T3.COM_Pesos_M12LY, 0) AS COM_Pesos_M12LY

FROM cte_ventas AS T1
RIGHT JOIN cte_inventarios AS T2
  ON  T1.CLUB_NBR = T2.CLUB_NBR
  AND T1.ITEM_NBR = T2.ITEM_NBR
-- LEFT JOIN: agrega .com cuando existe; 0 si el ítem no tuvo ventas online
LEFT JOIN cte_ventas_com AS T3
  ON  T2.CLUB_NBR = T3.CLUB_NBR
  AND T2.ITEM_NBR = T3.ITEM_NBR

-- ── Filtros opcionales ────────────────────────────────────
WHERE T2.CAT_NBR IN (41, 43, 46, 49, 53, 68)
-- AND T2.CLUB_NBR IN (6206, 6242, 6213)
-- AND T2.REGION = 1
-- AND T2.Flag_OOS_Activo = 'OOS_ACTIVO'
-- AND T2.VENDOR_NAME = 'PROVEEDOR X'