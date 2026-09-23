-- ============================================================
-- Ventas_e_Inventarios_SAMS_v2.sql
-- Canal   : Sam's Club MX — Todos los Clubs (176)
-- Área    : E-Catman
-- Versión : 2.0 | Ago 2026 — Grano DIARIO (antes mensual) +
--           Inventario anexado AL FINAL desde Ventas (antes era
--           al revés: inventario era la tabla base).
--
-- QUÉ CAMBIÓ vs la versión "Mensual TY vs LY" (mantenida como respaldo):
--   1) Ya NO se pivotea a columnas M01..M12 / M01LY..M12LY. Cada fila
--      es un (Fecha, Club, Ítem) con su venta física + .com de ESE día.
--   2) El JOIN final ahora parte de VENTAS (cte_ventas_diaria) y le
--      pega el inventario (snapshot actual, sin fecha) con LEFT JOIN.
--      El inventario es un corte puntual — se repite igual en cada
--      fila de venta del mismo club/ítem, no varía por día.
--   3) Rango de fechas parametrizado con DECLARE (ver abajo) para no
--      tronar BQ jalando 2 años completos a grano diario x 176 clubs
--      x miles de ítems (eso sí sería una tabla gigante). Ajusta
--      date_ini/date_fin según necesites.
--
-- TABLAS CONFIRMADAS (mismas que v1.4):
--   wmt-edw-prod.MX_WC_VM.SKU_DLY_POS             → ventas físicas diarias
--   wmt-mx-dl-controlledmgzn-prod.ecom.Sams_Ventas → ventas .com
--   wmt-edw-prod.MX_WC_VM.MDSE_INVENTORY          → inventario por club
--   wmt-edw-prod.MX_WC_VM.ITEM_DESC               → catálogo de ítems
--   wmt-edw-prod.MX_WM_VM.CALENDAR_DAY            → calendario fiscal
--   wmt-intl-cons-mx-users.adhoc_users.SAMS_MERCH_MX_CLUBES_INFO → dim. clubs
--   wmt-mx-dl-controlledmgzn-prod.Black_Bird.Catalogo_Cat_Subcat → dim. categorías
--
-- NOTA dims (Club/Categoría/Ítem): se toman del inventario (cte_inventarios),
--   que es la tabla más completa en dimensiones (176 clubs, catálogo activo
--   + inactivo). Si una fila de venta no encuentra match en inventario,
--   los campos de dimensión salen NULL — validado antes que esto pasa con
--   los 3 clubs CEDIS (6238, 6388, 6548), que son centros de distribución,
--   no tiendas, y no viven en SAMS_MERCH_MX_CLUBES_INFO.
-- ============================================================

DECLARE date_ini DATE DEFAULT DATE_SUB(CURRENT_DATE('America/Mexico_City'), INTERVAL 30 DAY);
DECLARE date_fin DATE DEFAULT CURRENT_DATE('America/Mexico_City');
-- ↑ PRUEBA: últimos 30 días. Para historia completa, amplía el rango
--   (ej. INTERVAL 400 DAY para año actual + año pasado) sabiendo que
--   el resultado crece rápido en grano diario.

WITH

-- ------------------------------------------------------------
-- CTE 1: POS físico diario — piezas y pesos ponderados por día
--   (sin cambios de lógica vs v1.4, solo se filtra por rango de
--   fechas en vez de por año completo)
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
  WHERE d.gregorian_date BETWEEN date_ini AND date_fin
),

-- ------------------------------------------------------------
-- CTE 2: Ventas físicas DIARIAS por club/ítem (sin pivot a mes)
-- ------------------------------------------------------------
cte_ventas_fisico_diario AS (
  SELECT
    v.gregorian_date  AS Fecha,
    v.STORE_NBR       AS CLUB_NBR,
    b.Old_NBR         AS ITEM_NBR,   -- traduce ITEM_NBR crudo -> Old_NBR
                                      -- (el mismo dominio que usa inventario;
                                      -- sin este puente el JOIN final con
                                      -- cte_inventarios casi nunca pega)
    SUM(v.piezas_dia) AS Venta_Pzas_Fisico,
    SUM(v.pesos_dia)  AS Venta_Pesos_Fisico
  FROM cte_pos_diario v
  INNER JOIN `wmt-edw-prod.MX_WC_VM.ITEM_DESC` b ON v.ITEM_NBR = b.ITEM_NBR
  GROUP BY v.gregorian_date, v.STORE_NBR, b.Old_NBR
  -- Solo días con venta real; SKU_DLY_POS trae el calendario completo
  -- de la semana (7 días x fila), la mayoría en 0 para un item/día dado.
  HAVING SUM(v.piezas_dia) <> 0 OR SUM(v.pesos_dia) <> 0
),

-- ------------------------------------------------------------
-- CTE 3: Ventas .com DIARIAS por club/ítem (sin pivot a mes)
--   Piezas   = sales_order_detail_commercial_sale_qty_base
--   Venta $  = sales_order_detail_net_paid_orders_wo_shipping_amount_1
--   Fecha    = sales_order_detail_order_created_date
--   Tienda   = sales_order_detail_assigned_store_nbr (join -> CLUB_NBR)
--   Item     = sales_order_detail_item_id_short (join -> ITEM_NBR)
--   Ordenes  = COUNT(DISTINCT sales_order_detail_order_nbr) -- ordenes
--             unicas (una orden puede traer varias piezas del mismo
--             item, o el mismo item en mas de una linea de la orden)
-- ------------------------------------------------------------
cte_ventas_com_diario AS (
  SELECT
    DATE(s.sales_order_detail_order_created_date)                  AS Fecha,
    SAFE_CAST(s.sales_order_detail_assigned_store_nbr AS INT64)     AS CLUB_NBR,
    SAFE_CAST(s.sales_order_detail_item_id_short AS INT64)          AS ITEM_NBR,
    SUM(s.sales_order_detail_commercial_sale_qty_base)                 AS Venta_Pzas_Com,
    SUM(s.sales_order_detail_net_paid_orders_wo_shipping_amount_1)     AS Venta_Pesos_Com,
    COUNT(DISTINCT s.sales_order_detail_order_nbr)                     AS Ordenes_Com
  FROM `wmt-mx-dl-controlledmgzn-prod.ecom.Sams_Ventas` AS s
  WHERE
    DATE(s.sales_order_detail_order_created_date) BETWEEN date_ini AND date_fin
    AND s.sales_order_detail_commercial_sale_qty_base > 0        -- excluir devoluciones / reversos
    AND s.sales_order_detail_item_id_short IS NOT NULL           -- excluir ghost records
  GROUP BY
    DATE(s.sales_order_detail_order_created_date),
    SAFE_CAST(s.sales_order_detail_assigned_store_nbr AS INT64),
    SAFE_CAST(s.sales_order_detail_item_id_short AS INT64)
),

-- ------------------------------------------------------------
-- CTE 4: Ventas DIARIAS combinadas (físico + .com) — un solo grano
--   Fecha / Club / Ítem. FULL OUTER porque un ítem puede vender
--   solo en tienda, solo en .com, o en ambos ese día.
-- ------------------------------------------------------------
cte_ventas_diaria AS (
  SELECT
    COALESCE(f.Fecha, c.Fecha)         AS Fecha,
    COALESCE(f.CLUB_NBR, c.CLUB_NBR)   AS CLUB_NBR,
    COALESCE(f.ITEM_NBR, c.ITEM_NBR)   AS ITEM_NBR,
    COALESCE(f.Venta_Pzas_Fisico, 0)   AS Venta_Pzas_Fisico,
    COALESCE(f.Venta_Pesos_Fisico, 0)  AS Venta_Pesos_Fisico,
    COALESCE(c.Venta_Pzas_Com, 0)      AS Venta_Pzas_Com,
    COALESCE(c.Venta_Pesos_Com, 0)     AS Venta_Pesos_Com,
    COALESCE(c.Ordenes_Com, 0)         AS Ordenes_Com
  FROM cte_ventas_fisico_diario f
  FULL OUTER JOIN cte_ventas_com_diario c
    ON  f.Fecha    = c.Fecha
    AND f.CLUB_NBR = c.CLUB_NBR
    AND f.ITEM_NBR = c.ITEM_NBR
),

-- ------------------------------------------------------------
-- CTE 5: Inventario actual por Club — snapshot puntual, sin fecha.
--   (idéntico a v1.4; es la tabla que aporta las dimensiones
--   Club/Categoría/Ítem más completas)
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
  JOIN  `wmt-edw-prod.MX_WC_VM.ITEM_DESC`                AS b  ON a.ITEM_NBR = b.ITEM_NBR
  LEFT JOIN `wmt-intl-cons-mx-users.adhoc_users.SAMS_MERCH_MX_CLUBES_INFO`  AS f  ON a.CLUB_NBR = f.CLUB_NBR
  LEFT JOIN `wmt-mx-dl-controlledmgzn-prod.Black_Bird.Catalogo_Cat_Subcat` AS cat
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
-- Consulta final: Venta DIARIA (física + .com) con Inventario
-- anexado AL FINAL.
--   T1 (ventas diarias) es la base → LEFT JOIN con T2 (inventario)
--   El inventario es snapshot puntual: se repite igual en cada
--   fila de venta del mismo club/ítem, sin importar la fecha.
-- ============================================================
SELECT
  -- ── Fecha + Identificadores ────────────────────────
  T1.Fecha,
  CAST(T1.CLUB_NBR AS INT64) AS CLUB_NBR,
  T2.CLUB_NAME, T2.DISTRITO, T2.REGION, T2.ESTADO,
  T2.CAT_NBR, T2.CAT_NOMBRE, T2.SUBCAT_NBR, T2.SUBCAT_NOMBRE,
  T1.ITEM_NBR,
  T2.ITEM_DESC_1, T2.ITEM_DESC_2,
  T2.TYPE_ITEM, T2.VENDOR_NAME, T2.VENDOR_NBR,

  -- ── Venta del día (física + .com + total) ────────────────
  T1.Venta_Pzas_Fisico,
  T1.Venta_Pesos_Fisico,
  T1.Venta_Pzas_Com,
  T1.Venta_Pesos_Com,
  T1.Ordenes_Com,
  (T1.Venta_Pzas_Fisico  + T1.Venta_Pzas_Com)  AS Venta_Pzas_Total,
  (T1.Venta_Pesos_Fisico + T1.Venta_Pesos_Com) AS Venta_Pesos_Total,

  -- ── Inventario anexado AL FINAL (snapshot actual) ────────
  T2.OH_Piso, T2.OH_Trastienda, T2.OH_Total, T2.OO_En_Orden,
  T2.Costo_Unit, T2.Precio_Venta,
  T2.OH_Costo_MXN, T2.OH_Retail_MXN, T2.OO_Retail_MXN,
  T2.Fecha_Inicio, T2.Fecha_Fin, T2.Fecha_Corte,
  T2.Semaforo_OH, T2.Flag_OOS_Activo, T2.NUM_CLUBS

FROM cte_ventas_diaria AS T1
LEFT JOIN cte_inventarios AS T2
  ON  T1.CLUB_NBR = T2.CLUB_NBR
  AND T1.ITEM_NBR = T2.ITEM_NBR

-- ── Filtros opcionales ────────────────────────────────────
--WHERE T2.CAT_NBR IN (41, 43, 46, 49, 53, 68)
-- AND T1.CLUB_NBR IN (6206, 6242, 6213)
-- AND T2.REGION = 1
-- AND T2.Flag_OOS_Activo = 'OOS_ACTIVO'
-- AND T2.VENDOR_NAME = 'PROVEEDOR X'

ORDER BY T1.Fecha DESC, T1.CLUB_NBR, T1.ITEM_NBR
