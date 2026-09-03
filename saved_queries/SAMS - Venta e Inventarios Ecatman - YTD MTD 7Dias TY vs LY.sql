-- ============================================================
-- Ventas_e_Inventarios_SAMS_v3.sql
-- Canal   : Sam's Club MX — Todos los Clubs (176)
-- Área    : E-Catman
-- Versión : 3.2 | Sep 2026 — 4 MOMENTOS comparativos TY vs LY
--           (parte de la versión "Mensual TY vs LY" v1.4, NO del
--           grano de la versión "Diario TY vs LY")
--           v3.1: se agrego Crecimiento_Piso_* y Crecimiento_Com_*
--           (piezas y pesos) por separado, ademas del Crecimiento_*
--           Total que ya existía.
--           v3.2: se agrego MOMENTO L1D (venta de ayer, un solo dia)
--           TY vs LY, mismo patron que YTD/MTD/L7D.
--
-- QUÉ HACE ESTA VERSIÓN (distinto a Mensual y a Diario):
--   En vez de pivotear por mes calendario (M01..M12) o dejar grano
--   diario, esta versión agrega TODO a nivel Club x Ítem con 3
--   "momentos" de negocio, cada uno con su Año Actual (TY) y su
--   comparable Año Pasado (LY) para poder sacar % de crecimiento:
--
--     1) YTD  = Year To Date   : 1-ene-AñoActual  -> AYER
--        YTD LY comparable    : 1-ene-AñoPasado   -> (AYER - 1 año)
--     2) MTD  = Month To Date  : día 1 del mes actual -> AYER
--        MTD LY comparable    : día 1 del mismo mes LY -> (AYER - 1 año)
--     3) L7D  = Últimos 7 días : (AYER - 6 días) -> AYER
--        L7D LY comparable    : MISMAS FECHAS, UN AÑO ATRÁS
--        (confirmado explícitamente: NO es alineación de calendario
--         fiscal 4-5-4, es resta directa de 1 año en la fecha)
--     4) L1D  = Último día (ayer)  : AYER -> AYER
--        L1D LY comparable    : MISMO DÍA CALENDARIO, UN AÑO ATRÁS
--
--   "AYER" se usa como corte (no HOY) porque el día en curso casi
--   siempre trae ventas parciales/incompletas en las fuentes.
--
-- MÉTRICAS por cada momento (TY y LY), separadas Piso vs .com
-- (pedido explícito: "valida que tengamos venta en piezas, pesos
-- para piso y .com"):
--   - Piso_Pzas / Piso_Pesos        (físico, SKU_DLY_POS)
--   - Com_Pzas  / Com_Pesos         (.com, Sams_Ventas)
--   - Ordenes_Com                   (pedidos únicos .com)
--   - Numero_Socios                 (membresías únicas .com)
--   - Total_Pzas / Total_Pesos      (Piso + .com, calculado)
--   - Crecimiento_Pzas / _Pesos %   (TY vs LY, calculado)
--
-- CONFIRMADO CON ALBERTO: Ordenes_Com y Numero_Socios aplican a
--   los 3 momentos (YTD, MTD, L7D), no solo a "Últimos 7 días".
--
-- TABLAS (mismas que v1.4 / v2.0):
--   wmt-edw-prod.MX_WC_VM.SKU_DLY_POS             → ventas físicas diarias
--   wmt-mx-dl-controlledmgzn-prod.ecom.Sams_Ventas → ventas .com
--   wmt-edw-prod.MX_WC_VM.MDSE_INVENTORY          → inventario por club
--   wmt-edw-prod.MX_WC_VM.ITEM_DESC               → catálogo de ítems
--   wmt-edw-prod.MX_WM_VM.CALENDAR_DAY            → calendario fiscal
--   wmt-intl-cons-mx-users.adhoc_users.SAMS_MERCH_MX_CLUBES_INFO → dim. clubs
--   wmt-mx-dl-controlledmgzn-prod.Black_Bird.Catalogo_Cat_Subcat → dim. categorías
--
-- NOTA Socios: se usa sales_order_detail_membership_nbr de Sams_Ventas
--   como identificador de membresía. COUNT(DISTINCT ...) por
--   Club/Ítem/momento — cuenta membresías únicas que compraron ESE
--   ítem en ESE club durante la ventana, no el total de socios del club.
--
-- NOTA campo pendiente (dejado COMENTADO a propósito, sin activar):
--   sales_order_detail_order_promotion_discount_desc — Alberto pidió
--   dejarlo listo como columna Y como filtro opcional, pero SIN mover
--   la data todavía. Buscar los dos "-- PROMO:" abajo cuando se quiera
--   activar el desglose por promoción.
-- ============================================================

DECLARE fecha_ayer  DATE   DEFAULT DATE_SUB(CURRENT_DATE('America/Mexico_City'), INTERVAL 1 DAY);
DECLARE anio_actual INT64  DEFAULT EXTRACT(YEAR FROM fecha_ayer);
DECLARE anio_pasado INT64  DEFAULT anio_actual - 1;

-- ---- Momento 1: YTD (1-ene -> ayer) ----
DECLARE ytd_ty_ini DATE DEFAULT DATE(anio_actual, 1, 1);
DECLARE ytd_ty_fin DATE DEFAULT fecha_ayer;
DECLARE ytd_ly_ini DATE DEFAULT DATE(anio_pasado, 1, 1);
DECLARE ytd_ly_fin DATE DEFAULT DATE_SUB(fecha_ayer, INTERVAL 1 YEAR);

-- ---- Momento 2: MTD (día 1 del mes -> ayer) ----
DECLARE mtd_ty_ini DATE DEFAULT DATE_TRUNC(fecha_ayer, MONTH);
DECLARE mtd_ty_fin DATE DEFAULT fecha_ayer;
DECLARE mtd_ly_ini DATE DEFAULT DATE_SUB(DATE_TRUNC(fecha_ayer, MONTH), INTERVAL 1 YEAR);
DECLARE mtd_ly_fin DATE DEFAULT DATE_SUB(fecha_ayer, INTERVAL 1 YEAR);

-- ---- Momento 3: Últimos 7 días (ayer-6 -> ayer) ----
DECLARE l7d_ty_ini DATE DEFAULT DATE_SUB(fecha_ayer, INTERVAL 6 DAY);
DECLARE l7d_ty_fin DATE DEFAULT fecha_ayer;
-- LY = mismas fechas, un año atrás (confirmado, sin alineación fiscal)
DECLARE l7d_ly_ini DATE DEFAULT DATE_SUB(l7d_ty_ini, INTERVAL 1 YEAR);
DECLARE l7d_ly_fin DATE DEFAULT DATE_SUB(l7d_ty_fin, INTERVAL 1 YEAR);

-- ---- Momento 4: Último día (ayer) ----
DECLARE l1d_ty_ini DATE DEFAULT fecha_ayer;
DECLARE l1d_ty_fin DATE DEFAULT fecha_ayer;
-- LY = mismo dia calendario, un año atrás (mismo criterio que YTD/MTD/L7D)
DECLARE l1d_ly_ini DATE DEFAULT DATE_SUB(fecha_ayer, INTERVAL 1 YEAR);
DECLARE l1d_ly_fin DATE DEFAULT DATE_SUB(fecha_ayer, INTERVAL 1 YEAR);

-- Rango global: cubre los 8 sub-rangos de arriba en una sola pasada
-- por las tablas fuente (evita escanear SKU_DLY_POS / Sams_Ventas 6 veces).
DECLARE date_ini DATE DEFAULT ytd_ly_ini;
DECLARE date_fin DATE DEFAULT fecha_ayer;

WITH

-- ------------------------------------------------------------
-- CTE 1: POS físico diario — piezas y pesos ponderados por día
--   (idéntico a v1.4/v2.0, solo acotado al rango global de arriba)
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
-- CTE 2: Ventas FÍSICAS agregadas por Club/Ítem en los 3 momentos
--   (TY + LY cada uno), vía SUM condicional — mismo patrón que el
--   pivot de la versión "Mensual TY vs LY", pero por ventana de
--   fecha en vez de mes.
-- ------------------------------------------------------------
cte_ventas_fisico AS (
  SELECT
    v.STORE_NBR AS CLUB_NBR,
    b.Old_NBR   AS ITEM_NBR,

    -- YTD
    COALESCE(SUM(CASE WHEN v.gregorian_date BETWEEN ytd_ty_ini AND ytd_ty_fin THEN v.piezas_dia END), 0) AS Piso_Pzas_YTD,
    COALESCE(SUM(CASE WHEN v.gregorian_date BETWEEN ytd_ty_ini AND ytd_ty_fin THEN v.pesos_dia  END), 0) AS Piso_Pesos_YTD,
    COALESCE(SUM(CASE WHEN v.gregorian_date BETWEEN ytd_ly_ini AND ytd_ly_fin THEN v.piezas_dia END), 0) AS Piso_Pzas_YTDLY,
    COALESCE(SUM(CASE WHEN v.gregorian_date BETWEEN ytd_ly_ini AND ytd_ly_fin THEN v.pesos_dia  END), 0) AS Piso_Pesos_YTDLY,

    -- MTD
    COALESCE(SUM(CASE WHEN v.gregorian_date BETWEEN mtd_ty_ini AND mtd_ty_fin THEN v.piezas_dia END), 0) AS Piso_Pzas_MTD,
    COALESCE(SUM(CASE WHEN v.gregorian_date BETWEEN mtd_ty_ini AND mtd_ty_fin THEN v.pesos_dia  END), 0) AS Piso_Pesos_MTD,
    COALESCE(SUM(CASE WHEN v.gregorian_date BETWEEN mtd_ly_ini AND mtd_ly_fin THEN v.piezas_dia END), 0) AS Piso_Pzas_MTDLY,
    COALESCE(SUM(CASE WHEN v.gregorian_date BETWEEN mtd_ly_ini AND mtd_ly_fin THEN v.pesos_dia  END), 0) AS Piso_Pesos_MTDLY,

    -- Últimos 7 días
    COALESCE(SUM(CASE WHEN v.gregorian_date BETWEEN l7d_ty_ini AND l7d_ty_fin THEN v.piezas_dia END), 0) AS Piso_Pzas_L7D,
    COALESCE(SUM(CASE WHEN v.gregorian_date BETWEEN l7d_ty_ini AND l7d_ty_fin THEN v.pesos_dia  END), 0) AS Piso_Pesos_L7D,
    COALESCE(SUM(CASE WHEN v.gregorian_date BETWEEN l7d_ly_ini AND l7d_ly_fin THEN v.piezas_dia END), 0) AS Piso_Pzas_L7DLY,
    COALESCE(SUM(CASE WHEN v.gregorian_date BETWEEN l7d_ly_ini AND l7d_ly_fin THEN v.pesos_dia  END), 0) AS Piso_Pesos_L7DLY,

    -- Último día (ayer)
    COALESCE(SUM(CASE WHEN v.gregorian_date BETWEEN l1d_ty_ini AND l1d_ty_fin THEN v.piezas_dia END), 0) AS Piso_Pzas_L1D,
    COALESCE(SUM(CASE WHEN v.gregorian_date BETWEEN l1d_ty_ini AND l1d_ty_fin THEN v.pesos_dia  END), 0) AS Piso_Pesos_L1D,
    COALESCE(SUM(CASE WHEN v.gregorian_date BETWEEN l1d_ly_ini AND l1d_ly_fin THEN v.piezas_dia END), 0) AS Piso_Pzas_L1DLY,
    COALESCE(SUM(CASE WHEN v.gregorian_date BETWEEN l1d_ly_ini AND l1d_ly_fin THEN v.pesos_dia  END), 0) AS Piso_Pesos_L1DLY

  FROM cte_pos_diario v
  INNER JOIN `wmt-edw-prod.MX_WC_VM.ITEM_DESC` b ON v.ITEM_NBR = b.ITEM_NBR
  GROUP BY v.STORE_NBR, b.Old_NBR
),

-- ------------------------------------------------------------
-- CTE 3: .com — filas base acotadas al rango global, SIN agregar
--   todavía. Necesario mantener grano de orden/membresía aquí
--   (no pre-sumar por día) para que los COUNT(DISTINCT) del
--   siguiente CTE sean correctos por ventana de fecha, no por día.
-- ------------------------------------------------------------
cte_com_raw AS (
  SELECT
    DATE(s.sales_order_detail_order_created_date)              AS Fecha,
    SAFE_CAST(s.sales_order_detail_assigned_store_nbr AS INT64) AS CLUB_NBR,
    SAFE_CAST(s.sales_order_detail_item_id_short AS INT64)      AS ITEM_NBR,
    s.sales_order_detail_commercial_sale_qty_base               AS Piezas,
    s.sales_order_detail_net_paid_orders_wo_shipping_amount_1   AS Pesos,
    s.sales_order_detail_order_nbr                              AS Orden_Nbr,
    s.sales_order_detail_membership_nbr                         AS Membresia_Nbr
    -- PROMO: campo pedido por Alberto, dejado listo pero SIN activar.
    -- , s.sales_order_detail_order_promotion_discount_desc AS Promocion_Desc
  FROM `wmt-mx-dl-controlledmgzn-prod.ecom.Sams_Ventas` AS s
  WHERE
    DATE(s.sales_order_detail_order_created_date) BETWEEN date_ini AND date_fin
    AND s.sales_order_detail_commercial_sale_qty_base > 0        -- excluir devoluciones / reversos
    AND s.sales_order_detail_item_id_short IS NOT NULL           -- excluir ghost records
    -- PROMO: filtro opcional futuro, SIN activar todavía.
    -- AND s.sales_order_detail_order_promotion_discount_desc = 'NOMBRE_PROMO'
),

-- ------------------------------------------------------------
-- CTE 4: .com agregado por Club/Ítem en los 3 momentos (TY+LY):
--   piezas, pesos, pedidos únicos (Ordenes_Com) y membresías
--   únicas (Numero_Socios). COUNT(DISTINCT CASE WHEN...) es
--   seguro aquí porque NULL (fuera de rango) no cuenta.
-- ------------------------------------------------------------
cte_ventas_com AS (
  SELECT
    CLUB_NBR,
    ITEM_NBR,

    -- YTD
    COALESCE(SUM(CASE WHEN Fecha BETWEEN ytd_ty_ini AND ytd_ty_fin THEN Piezas END), 0)              AS Com_Pzas_YTD,
    COALESCE(SUM(CASE WHEN Fecha BETWEEN ytd_ty_ini AND ytd_ty_fin THEN Pesos  END), 0)              AS Com_Pesos_YTD,
    COUNT(DISTINCT CASE WHEN Fecha BETWEEN ytd_ty_ini AND ytd_ty_fin THEN Orden_Nbr END)             AS Ordenes_Com_YTD,
    COUNT(DISTINCT CASE WHEN Fecha BETWEEN ytd_ty_ini AND ytd_ty_fin THEN Membresia_Nbr END)         AS Numero_Socios_YTD,
    COALESCE(SUM(CASE WHEN Fecha BETWEEN ytd_ly_ini AND ytd_ly_fin THEN Piezas END), 0)              AS Com_Pzas_YTDLY,
    COALESCE(SUM(CASE WHEN Fecha BETWEEN ytd_ly_ini AND ytd_ly_fin THEN Pesos  END), 0)              AS Com_Pesos_YTDLY,
    COUNT(DISTINCT CASE WHEN Fecha BETWEEN ytd_ly_ini AND ytd_ly_fin THEN Orden_Nbr END)             AS Ordenes_Com_YTDLY,
    COUNT(DISTINCT CASE WHEN Fecha BETWEEN ytd_ly_ini AND ytd_ly_fin THEN Membresia_Nbr END)         AS Numero_Socios_YTDLY,

    -- MTD
    COALESCE(SUM(CASE WHEN Fecha BETWEEN mtd_ty_ini AND mtd_ty_fin THEN Piezas END), 0)              AS Com_Pzas_MTD,
    COALESCE(SUM(CASE WHEN Fecha BETWEEN mtd_ty_ini AND mtd_ty_fin THEN Pesos  END), 0)              AS Com_Pesos_MTD,
    COUNT(DISTINCT CASE WHEN Fecha BETWEEN mtd_ty_ini AND mtd_ty_fin THEN Orden_Nbr END)             AS Ordenes_Com_MTD,
    COUNT(DISTINCT CASE WHEN Fecha BETWEEN mtd_ty_ini AND mtd_ty_fin THEN Membresia_Nbr END)         AS Numero_Socios_MTD,
    COALESCE(SUM(CASE WHEN Fecha BETWEEN mtd_ly_ini AND mtd_ly_fin THEN Piezas END), 0)              AS Com_Pzas_MTDLY,
    COALESCE(SUM(CASE WHEN Fecha BETWEEN mtd_ly_ini AND mtd_ly_fin THEN Pesos  END), 0)              AS Com_Pesos_MTDLY,
    COUNT(DISTINCT CASE WHEN Fecha BETWEEN mtd_ly_ini AND mtd_ly_fin THEN Orden_Nbr END)             AS Ordenes_Com_MTDLY,
    COUNT(DISTINCT CASE WHEN Fecha BETWEEN mtd_ly_ini AND mtd_ly_fin THEN Membresia_Nbr END)         AS Numero_Socios_MTDLY,

    -- Últimos 7 días
    COALESCE(SUM(CASE WHEN Fecha BETWEEN l7d_ty_ini AND l7d_ty_fin THEN Piezas END), 0)              AS Com_Pzas_L7D,
    COALESCE(SUM(CASE WHEN Fecha BETWEEN l7d_ty_ini AND l7d_ty_fin THEN Pesos  END), 0)              AS Com_Pesos_L7D,
    COUNT(DISTINCT CASE WHEN Fecha BETWEEN l7d_ty_ini AND l7d_ty_fin THEN Orden_Nbr END)             AS Ordenes_Com_L7D,
    COUNT(DISTINCT CASE WHEN Fecha BETWEEN l7d_ty_ini AND l7d_ty_fin THEN Membresia_Nbr END)         AS Numero_Socios_L7D,
    COALESCE(SUM(CASE WHEN Fecha BETWEEN l7d_ly_ini AND l7d_ly_fin THEN Piezas END), 0)              AS Com_Pzas_L7DLY,
    COALESCE(SUM(CASE WHEN Fecha BETWEEN l7d_ly_ini AND l7d_ly_fin THEN Pesos  END), 0)              AS Com_Pesos_L7DLY,
    COUNT(DISTINCT CASE WHEN Fecha BETWEEN l7d_ly_ini AND l7d_ly_fin THEN Orden_Nbr END)             AS Ordenes_Com_L7DLY,
    COUNT(DISTINCT CASE WHEN Fecha BETWEEN l7d_ly_ini AND l7d_ly_fin THEN Membresia_Nbr END)         AS Numero_Socios_L7DLY,

    -- Último día (ayer)
    COALESCE(SUM(CASE WHEN Fecha BETWEEN l1d_ty_ini AND l1d_ty_fin THEN Piezas END), 0)              AS Com_Pzas_L1D,
    COALESCE(SUM(CASE WHEN Fecha BETWEEN l1d_ty_ini AND l1d_ty_fin THEN Pesos  END), 0)              AS Com_Pesos_L1D,
    COUNT(DISTINCT CASE WHEN Fecha BETWEEN l1d_ty_ini AND l1d_ty_fin THEN Orden_Nbr END)             AS Ordenes_Com_L1D,
    COUNT(DISTINCT CASE WHEN Fecha BETWEEN l1d_ty_ini AND l1d_ty_fin THEN Membresia_Nbr END)         AS Numero_Socios_L1D,
    COALESCE(SUM(CASE WHEN Fecha BETWEEN l1d_ly_ini AND l1d_ly_fin THEN Piezas END), 0)              AS Com_Pzas_L1DLY,
    COALESCE(SUM(CASE WHEN Fecha BETWEEN l1d_ly_ini AND l1d_ly_fin THEN Pesos  END), 0)              AS Com_Pesos_L1DLY,
    COUNT(DISTINCT CASE WHEN Fecha BETWEEN l1d_ly_ini AND l1d_ly_fin THEN Orden_Nbr END)             AS Ordenes_Com_L1DLY,
    COUNT(DISTINCT CASE WHEN Fecha BETWEEN l1d_ly_ini AND l1d_ly_fin THEN Membresia_Nbr END)         AS Numero_Socios_L1DLY

  FROM cte_com_raw
  GROUP BY CLUB_NBR, ITEM_NBR
),

-- ------------------------------------------------------------
-- CTE 5: Inventario actual por Club — snapshot puntual, sin fecha.
--   (idéntico a las versiones "Mensual TY vs LY" / "Diario TY vs LY";
--   sigue siendo la tabla más completa en dimensiones Club/Categoría/Ítem)
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
-- Consulta final: Inventario + Venta Física + Venta .com, con
-- los 4 momentos (YTD/MTD/L7D/L1D) TY+LY y % de crecimiento.
--   T2 (inventario) es la base → RIGHT JOIN con T1 (físico)
--   T3 (.com) se agrega con LEFT JOIN sobre la misma clave
-- ============================================================
SELECT
  -- ── Identificadores ──────────────────────────────────────
  -- (T2 = cte_inventarios es la tabla BASE del RIGHT JOIN, nunca es NULL
  --  aquí, por eso las dims salen directo de T2 sin necesidad de COALESCE)
  T2.CLUB_NBR, T2.CLUB_NAME, T2.DISTRITO, T2.REGION, T2.ESTADO,
  T2.CAT_NBR, T2.CAT_NOMBRE, T2.SUBCAT_NBR, T2.SUBCAT_NOMBRE,
  T2.ITEM_NBR,
  T2.ITEM_DESC_1, T2.ITEM_DESC_2,
  T2.TYPE_ITEM, T2.VENDOR_NAME, T2.VENDOR_NBR,

  -- ── Inventario (snapshot actual) ─────────────────────────
  T2.OH_Piso, T2.OH_Trastienda, T2.OH_Total, T2.OO_En_Orden,
  T2.Costo_Unit, T2.Precio_Venta,
  T2.OH_Costo_MXN, T2.OH_Retail_MXN, T2.OO_Retail_MXN,
  T2.Fecha_Inicio, T2.Fecha_Fin, T2.Fecha_Corte,
  T2.Semaforo_OH, T2.Flag_OOS_Activo, T2.NUM_CLUBS,

  -- ══ MOMENTO 1: YTD (1-ene -> ayer) ═══════════════════════
  COALESCE(T1.Piso_Pzas_YTD, 0)         AS Piso_Pzas_YTD,
  COALESCE(T1.Piso_Pesos_YTD, 0)        AS Piso_Pesos_YTD,
  COALESCE(T3.Com_Pzas_YTD, 0)          AS Com_Pzas_YTD,
  COALESCE(T3.Com_Pesos_YTD, 0)         AS Com_Pesos_YTD,
  COALESCE(T3.Ordenes_Com_YTD, 0)       AS Ordenes_Com_YTD,
  COALESCE(T3.Numero_Socios_YTD, 0)     AS Numero_Socios_YTD,
  (COALESCE(T1.Piso_Pzas_YTD,0)  + COALESCE(T3.Com_Pzas_YTD,0))   AS Total_Pzas_YTD,
  (COALESCE(T1.Piso_Pesos_YTD,0) + COALESCE(T3.Com_Pesos_YTD,0))  AS Total_Pesos_YTD,

  COALESCE(T1.Piso_Pzas_YTDLY, 0)       AS Piso_Pzas_YTDLY,
  COALESCE(T1.Piso_Pesos_YTDLY, 0)      AS Piso_Pesos_YTDLY,
  COALESCE(T3.Com_Pzas_YTDLY, 0)        AS Com_Pzas_YTDLY,
  COALESCE(T3.Com_Pesos_YTDLY, 0)       AS Com_Pesos_YTDLY,
  COALESCE(T3.Ordenes_Com_YTDLY, 0)     AS Ordenes_Com_YTDLY,
  COALESCE(T3.Numero_Socios_YTDLY, 0)   AS Numero_Socios_YTDLY,
  (COALESCE(T1.Piso_Pzas_YTDLY,0)  + COALESCE(T3.Com_Pzas_YTDLY,0))  AS Total_Pzas_YTDLY,
  (COALESCE(T1.Piso_Pesos_YTDLY,0) + COALESCE(T3.Com_Pesos_YTDLY,0)) AS Total_Pesos_YTDLY,

  -- Crecimiento por bloque (Piso solo, .com solo) ademas del Total:
  SAFE_DIVIDE(
    COALESCE(T1.Piso_Pzas_YTD,0) - COALESCE(T1.Piso_Pzas_YTDLY,0),
    NULLIF(COALESCE(T1.Piso_Pzas_YTDLY,0), 0)
  ) AS Crecimiento_Piso_Pzas_YTD,
  SAFE_DIVIDE(
    COALESCE(T1.Piso_Pesos_YTD,0) - COALESCE(T1.Piso_Pesos_YTDLY,0),
    NULLIF(COALESCE(T1.Piso_Pesos_YTDLY,0), 0)
  ) AS Crecimiento_Piso_Pesos_YTD,
  SAFE_DIVIDE(
    COALESCE(T3.Com_Pzas_YTD,0) - COALESCE(T3.Com_Pzas_YTDLY,0),
    NULLIF(COALESCE(T3.Com_Pzas_YTDLY,0), 0)
  ) AS Crecimiento_Com_Pzas_YTD,
  SAFE_DIVIDE(
    COALESCE(T3.Com_Pesos_YTD,0) - COALESCE(T3.Com_Pesos_YTDLY,0),
    NULLIF(COALESCE(T3.Com_Pesos_YTDLY,0), 0)
  ) AS Crecimiento_Com_Pesos_YTD,
  SAFE_DIVIDE(
    (COALESCE(T1.Piso_Pzas_YTD,0) + COALESCE(T3.Com_Pzas_YTD,0)) - (COALESCE(T1.Piso_Pzas_YTDLY,0) + COALESCE(T3.Com_Pzas_YTDLY,0)),
    NULLIF(COALESCE(T1.Piso_Pzas_YTDLY,0) + COALESCE(T3.Com_Pzas_YTDLY,0), 0)
  ) AS Crecimiento_Pzas_YTD,
  SAFE_DIVIDE(
    (COALESCE(T1.Piso_Pesos_YTD,0) + COALESCE(T3.Com_Pesos_YTD,0)) - (COALESCE(T1.Piso_Pesos_YTDLY,0) + COALESCE(T3.Com_Pesos_YTDLY,0)),
    NULLIF(COALESCE(T1.Piso_Pesos_YTDLY,0) + COALESCE(T3.Com_Pesos_YTDLY,0), 0)
  ) AS Crecimiento_Pesos_YTD,

  -- ══ MOMENTO 2: MTD (día 1 del mes -> ayer) ═══════════════
  COALESCE(T1.Piso_Pzas_MTD, 0)         AS Piso_Pzas_MTD,
  COALESCE(T1.Piso_Pesos_MTD, 0)        AS Piso_Pesos_MTD,
  COALESCE(T3.Com_Pzas_MTD, 0)          AS Com_Pzas_MTD,
  COALESCE(T3.Com_Pesos_MTD, 0)         AS Com_Pesos_MTD,
  COALESCE(T3.Ordenes_Com_MTD, 0)       AS Ordenes_Com_MTD,
  COALESCE(T3.Numero_Socios_MTD, 0)     AS Numero_Socios_MTD,
  (COALESCE(T1.Piso_Pzas_MTD,0)  + COALESCE(T3.Com_Pzas_MTD,0))   AS Total_Pzas_MTD,
  (COALESCE(T1.Piso_Pesos_MTD,0) + COALESCE(T3.Com_Pesos_MTD,0))  AS Total_Pesos_MTD,

  COALESCE(T1.Piso_Pzas_MTDLY, 0)       AS Piso_Pzas_MTDLY,
  COALESCE(T1.Piso_Pesos_MTDLY, 0)      AS Piso_Pesos_MTDLY,
  COALESCE(T3.Com_Pzas_MTDLY, 0)        AS Com_Pzas_MTDLY,
  COALESCE(T3.Com_Pesos_MTDLY, 0)       AS Com_Pesos_MTDLY,
  COALESCE(T3.Ordenes_Com_MTDLY, 0)     AS Ordenes_Com_MTDLY,
  COALESCE(T3.Numero_Socios_MTDLY, 0)   AS Numero_Socios_MTDLY,
  (COALESCE(T1.Piso_Pzas_MTDLY,0)  + COALESCE(T3.Com_Pzas_MTDLY,0))  AS Total_Pzas_MTDLY,
  (COALESCE(T1.Piso_Pesos_MTDLY,0) + COALESCE(T3.Com_Pesos_MTDLY,0)) AS Total_Pesos_MTDLY,

  -- Crecimiento por bloque (Piso solo, .com solo) ademas del Total:
  SAFE_DIVIDE(
    COALESCE(T1.Piso_Pzas_MTD,0) - COALESCE(T1.Piso_Pzas_MTDLY,0),
    NULLIF(COALESCE(T1.Piso_Pzas_MTDLY,0), 0)
  ) AS Crecimiento_Piso_Pzas_MTD,
  SAFE_DIVIDE(
    COALESCE(T1.Piso_Pesos_MTD,0) - COALESCE(T1.Piso_Pesos_MTDLY,0),
    NULLIF(COALESCE(T1.Piso_Pesos_MTDLY,0), 0)
  ) AS Crecimiento_Piso_Pesos_MTD,
  SAFE_DIVIDE(
    COALESCE(T3.Com_Pzas_MTD,0) - COALESCE(T3.Com_Pzas_MTDLY,0),
    NULLIF(COALESCE(T3.Com_Pzas_MTDLY,0), 0)
  ) AS Crecimiento_Com_Pzas_MTD,
  SAFE_DIVIDE(
    COALESCE(T3.Com_Pesos_MTD,0) - COALESCE(T3.Com_Pesos_MTDLY,0),
    NULLIF(COALESCE(T3.Com_Pesos_MTDLY,0), 0)
  ) AS Crecimiento_Com_Pesos_MTD,
  SAFE_DIVIDE(
    (COALESCE(T1.Piso_Pzas_MTD,0) + COALESCE(T3.Com_Pzas_MTD,0)) - (COALESCE(T1.Piso_Pzas_MTDLY,0) + COALESCE(T3.Com_Pzas_MTDLY,0)),
    NULLIF(COALESCE(T1.Piso_Pzas_MTDLY,0) + COALESCE(T3.Com_Pzas_MTDLY,0), 0)
  ) AS Crecimiento_Pzas_MTD,
  SAFE_DIVIDE(
    (COALESCE(T1.Piso_Pesos_MTD,0) + COALESCE(T3.Com_Pesos_MTD,0)) - (COALESCE(T1.Piso_Pesos_MTDLY,0) + COALESCE(T3.Com_Pesos_MTDLY,0)),
    NULLIF(COALESCE(T1.Piso_Pesos_MTDLY,0) + COALESCE(T3.Com_Pesos_MTDLY,0), 0)
  ) AS Crecimiento_Pesos_MTD,

  -- ══ MOMENTO 3: Últimos 7 días (ayer-6 -> ayer) ═══════════
  COALESCE(T1.Piso_Pzas_L7D, 0)         AS Piso_Pzas_L7D,
  COALESCE(T1.Piso_Pesos_L7D, 0)        AS Piso_Pesos_L7D,
  COALESCE(T3.Com_Pzas_L7D, 0)          AS Com_Pzas_L7D,
  COALESCE(T3.Com_Pesos_L7D, 0)         AS Com_Pesos_L7D,
  COALESCE(T3.Ordenes_Com_L7D, 0)       AS Ordenes_Com_L7D,
  COALESCE(T3.Numero_Socios_L7D, 0)     AS Numero_Socios_L7D,
  (COALESCE(T1.Piso_Pzas_L7D,0)  + COALESCE(T3.Com_Pzas_L7D,0))   AS Total_Pzas_L7D,
  (COALESCE(T1.Piso_Pesos_L7D,0) + COALESCE(T3.Com_Pesos_L7D,0))  AS Total_Pesos_L7D,

  COALESCE(T1.Piso_Pzas_L7DLY, 0)       AS Piso_Pzas_L7DLY,
  COALESCE(T1.Piso_Pesos_L7DLY, 0)      AS Piso_Pesos_L7DLY,
  COALESCE(T3.Com_Pzas_L7DLY, 0)        AS Com_Pzas_L7DLY,
  COALESCE(T3.Com_Pesos_L7DLY, 0)       AS Com_Pesos_L7DLY,
  COALESCE(T3.Ordenes_Com_L7DLY, 0)     AS Ordenes_Com_L7DLY,
  COALESCE(T3.Numero_Socios_L7DLY, 0)   AS Numero_Socios_L7DLY,
  (COALESCE(T1.Piso_Pzas_L7DLY,0)  + COALESCE(T3.Com_Pzas_L7DLY,0))  AS Total_Pzas_L7DLY,
  (COALESCE(T1.Piso_Pesos_L7DLY,0) + COALESCE(T3.Com_Pesos_L7DLY,0)) AS Total_Pesos_L7DLY,

  -- Crecimiento por bloque (Piso solo, .com solo) ademas del Total:
  SAFE_DIVIDE(
    COALESCE(T1.Piso_Pzas_L7D,0) - COALESCE(T1.Piso_Pzas_L7DLY,0),
    NULLIF(COALESCE(T1.Piso_Pzas_L7DLY,0), 0)
  ) AS Crecimiento_Piso_Pzas_L7D,
  SAFE_DIVIDE(
    COALESCE(T1.Piso_Pesos_L7D,0) - COALESCE(T1.Piso_Pesos_L7DLY,0),
    NULLIF(COALESCE(T1.Piso_Pesos_L7DLY,0), 0)
  ) AS Crecimiento_Piso_Pesos_L7D,
  SAFE_DIVIDE(
    COALESCE(T3.Com_Pzas_L7D,0) - COALESCE(T3.Com_Pzas_L7DLY,0),
    NULLIF(COALESCE(T3.Com_Pzas_L7DLY,0), 0)
  ) AS Crecimiento_Com_Pzas_L7D,
  SAFE_DIVIDE(
    COALESCE(T3.Com_Pesos_L7D,0) - COALESCE(T3.Com_Pesos_L7DLY,0),
    NULLIF(COALESCE(T3.Com_Pesos_L7DLY,0), 0)
  ) AS Crecimiento_Com_Pesos_L7D,
  SAFE_DIVIDE(
    (COALESCE(T1.Piso_Pzas_L7D,0) + COALESCE(T3.Com_Pzas_L7D,0)) - (COALESCE(T1.Piso_Pzas_L7DLY,0) + COALESCE(T3.Com_Pzas_L7DLY,0)),
    NULLIF(COALESCE(T1.Piso_Pzas_L7DLY,0) + COALESCE(T3.Com_Pzas_L7DLY,0), 0)
  ) AS Crecimiento_Pzas_L7D,
  SAFE_DIVIDE(
    (COALESCE(T1.Piso_Pesos_L7D,0) + COALESCE(T3.Com_Pesos_L7D,0)) - (COALESCE(T1.Piso_Pesos_L7DLY,0) + COALESCE(T3.Com_Pesos_L7DLY,0)),
    NULLIF(COALESCE(T1.Piso_Pesos_L7DLY,0) + COALESCE(T3.Com_Pesos_L7DLY,0), 0)
  ) AS Crecimiento_Pesos_L7D,

  -- ══ MOMENTO 4: Último día (ayer) ═════════════════════════
  COALESCE(T1.Piso_Pzas_L1D, 0)         AS Piso_Pzas_L1D,
  COALESCE(T1.Piso_Pesos_L1D, 0)        AS Piso_Pesos_L1D,
  COALESCE(T3.Com_Pzas_L1D, 0)          AS Com_Pzas_L1D,
  COALESCE(T3.Com_Pesos_L1D, 0)         AS Com_Pesos_L1D,
  COALESCE(T3.Ordenes_Com_L1D, 0)       AS Ordenes_Com_L1D,
  COALESCE(T3.Numero_Socios_L1D, 0)     AS Numero_Socios_L1D,
  (COALESCE(T1.Piso_Pzas_L1D,0)  + COALESCE(T3.Com_Pzas_L1D,0))   AS Total_Pzas_L1D,
  (COALESCE(T1.Piso_Pesos_L1D,0) + COALESCE(T3.Com_Pesos_L1D,0))  AS Total_Pesos_L1D,

  COALESCE(T1.Piso_Pzas_L1DLY, 0)       AS Piso_Pzas_L1DLY,
  COALESCE(T1.Piso_Pesos_L1DLY, 0)      AS Piso_Pesos_L1DLY,
  COALESCE(T3.Com_Pzas_L1DLY, 0)        AS Com_Pzas_L1DLY,
  COALESCE(T3.Com_Pesos_L1DLY, 0)       AS Com_Pesos_L1DLY,
  COALESCE(T3.Ordenes_Com_L1DLY, 0)     AS Ordenes_Com_L1DLY,
  COALESCE(T3.Numero_Socios_L1DLY, 0)   AS Numero_Socios_L1DLY,
  (COALESCE(T1.Piso_Pzas_L1DLY,0)  + COALESCE(T3.Com_Pzas_L1DLY,0))  AS Total_Pzas_L1DLY,
  (COALESCE(T1.Piso_Pesos_L1DLY,0) + COALESCE(T3.Com_Pesos_L1DLY,0)) AS Total_Pesos_L1DLY,

  -- Crecimiento por bloque (Piso solo, .com solo) ademas del Total:
  SAFE_DIVIDE(
    COALESCE(T1.Piso_Pzas_L1D,0) - COALESCE(T1.Piso_Pzas_L1DLY,0),
    NULLIF(COALESCE(T1.Piso_Pzas_L1DLY,0), 0)
  ) AS Crecimiento_Piso_Pzas_L1D,
  SAFE_DIVIDE(
    COALESCE(T1.Piso_Pesos_L1D,0) - COALESCE(T1.Piso_Pesos_L1DLY,0),
    NULLIF(COALESCE(T1.Piso_Pesos_L1DLY,0), 0)
  ) AS Crecimiento_Piso_Pesos_L1D,
  SAFE_DIVIDE(
    COALESCE(T3.Com_Pzas_L1D,0) - COALESCE(T3.Com_Pzas_L1DLY,0),
    NULLIF(COALESCE(T3.Com_Pzas_L1DLY,0), 0)
  ) AS Crecimiento_Com_Pzas_L1D,
  SAFE_DIVIDE(
    COALESCE(T3.Com_Pesos_L1D,0) - COALESCE(T3.Com_Pesos_L1DLY,0),
    NULLIF(COALESCE(T3.Com_Pesos_L1DLY,0), 0)
  ) AS Crecimiento_Com_Pesos_L1D,
  SAFE_DIVIDE(
    (COALESCE(T1.Piso_Pzas_L1D,0) + COALESCE(T3.Com_Pzas_L1D,0)) - (COALESCE(T1.Piso_Pzas_L1DLY,0) + COALESCE(T3.Com_Pzas_L1DLY,0)),
    NULLIF(COALESCE(T1.Piso_Pzas_L1DLY,0) + COALESCE(T3.Com_Pzas_L1DLY,0), 0)
  ) AS Crecimiento_Pzas_L1D,
  SAFE_DIVIDE(
    (COALESCE(T1.Piso_Pesos_L1D,0) + COALESCE(T3.Com_Pesos_L1D,0)) - (COALESCE(T1.Piso_Pesos_L1DLY,0) + COALESCE(T3.Com_Pesos_L1DLY,0)),
    NULLIF(COALESCE(T1.Piso_Pesos_L1DLY,0) + COALESCE(T3.Com_Pesos_L1DLY,0), 0)
  ) AS Crecimiento_Pesos_L1D

FROM cte_ventas_fisico AS T1
RIGHT JOIN cte_inventarios AS T2
  ON  T1.CLUB_NBR = T2.CLUB_NBR
  AND T1.ITEM_NBR = T2.ITEM_NBR
LEFT JOIN cte_ventas_com AS T3
  ON  T2.CLUB_NBR = T3.CLUB_NBR
  AND T2.ITEM_NBR = T3.ITEM_NBR

-- ── Filtros opcionales ────────────────────────────────────
--WHERE T2.CAT_NBR IN (41, 43, 46, 49, 53, 68)
-- AND T2.CLUB_NBR IN (6206, 6242, 6213)
-- AND T2.REGION = 1
-- AND T2.Flag_OOS_Activo = 'OOS_ACTIVO'
-- AND T2.VENDOR_NAME = 'PROVEEDOR X'
