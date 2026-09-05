--DROP TABLE IF EXISTS `wmt-mx-dl-controlledmgzn-prod.WM_AD_HOC_MX.REPORTE_INSTOCK_SAMS_W2`;

--CREATE TABLE `wmt-mx-dl-controlledmgzn-prod.Black_Bird.REPORTE_INSTOCK_SAMS_W2` AS

SELECT
  -- ── Geografía ──────────────────────────────────────────────────────────────
  a.REGION,
  a.DISTRITO,
  a.CLUB,
  a.ESTADO,

  -- ── Jerarquía Producto ─────────────────────────────────────────────────────
  a.NUMDEPTO,
  a.DEPARTAMENTO,
  a.NUMFL,
  a.FINELINE,
  a.UPC,
  a.ITEM_NBR,
  a.ITEM_DESC1,
  a.ITEM_DESC2,
  a.SIGNING_DESC,

  -- ── Trait ──────────────────────────────────────────────────────────────────
  a.TRAIT,

  -- ── Métricas Instock ───────────────────────────────────────────────────────
  SUM(a.COMBINACIONES)   AS COMBINACIONES,
  SUM(a.FALTANTES_OH)    AS FALTANTES_OH,    -- sin stock piso hoy
  SUM(a.FALTANTES_BACK)  AS FALTANTES_BACK,  -- sin stock piso+backroom en 3 días
  SUM(a.FALTANTES_IO)    AS FALTANTES_IO,    -- sin stock piso+back+pedido en 7 días

  -- ── Inventario detalle ─────────────────────────────────────────────────────
  SUM(a.OH_PISO_QTY)    AS OH_PISO_QTY,    -- ONSITE (piso de ventas)
  SUM(a.BACKROOM_QTY)   AS BACKROOM_QTY,   -- OFFSITE (bodega/backroom)
  SUM(a.OH_TOTAL_QTY)   AS OH_TOTAL_QTY,   -- ONSITE + OFFSITE
  SUM(a.IO_QTY)         AS IO_QTY,         -- ON_ORDER (en pedido)

  -- ── POs ────────────────────────────────────────────────────────────────────
  SUM(a.PACKS_ORD) AS PACKS_ORD,
  SUM(a.PACKS_REC) AS PACKS_REC

FROM (
  /*───────────────────────────────────────────────────────────────────────────
    NIVEL 2: Calcular flags de faltante con el FCST diario
  ───────────────────────────────────────────────────────────────────────────*/
  SELECT
    a.REGION,
    a.DISTRITO,
    a.CLUB,
    a.ESTADO,
    a.NUMDEPTO,
    a.DEPARTAMENTO,
    a.NUMFL,
    a.FINELINE,
    a.UPC,
    a.ITEM_NBR,
    a.ITEM_DESC1,
    a.ITEM_DESC2,
    a.SIGNING_DESC,
    a.TRAIT,
    a.COMBINACIONES,
    IFNULL(a.SALES_FCST, 0)                                         AS SALES_FCST,

    -- Flags instock
    IF(a.OH_TOTAL_QTY < IFNULL(a.SALES_FCST, 0),             1, 0) AS FALTANTES_OH,
    IF(a.OH_TOTAL_QTY < IFNULL(a.SALES_FCST, 0) * 3,         1, 0) AS FALTANTES_BACK,
    IF((a.OH_TOTAL_QTY + a.IO_QTY) < IFNULL(a.SALES_FCST, 0) * 7,
                                                              1, 0) AS FALTANTES_IO,
    a.OH_PISO_QTY,
    a.BACKROOM_QTY,
    a.OH_TOTAL_QTY,
    a.IO_QTY,
    a.PACKS_ORD,
    a.PACKS_REC

  FROM (
    /*───────────────────────────────────────────────────────────────────────
      NIVEL 1: Universo base ítem × club  +  LEFT JOINs de todas las fuentes
    ───────────────────────────────────────────────────────────────────────*/
    SELECT
      -- ── Geografía ──────────────────────────────────────────────────────
      si.REGION_NBR                                       AS REGION,
      si.DISTRICT_NBR                                     AS DISTRITO,
      CAST(fp.STORE_NBR AS INT64)                         AS CLUB,
      si.STATE                                            AS ESTADO,

      -- ── Producto ───────────────────────────────────────────────────────
      itm.DEPT_NBR                                        AS NUMDEPTO,
      dd.DEPT_DESC                                        AS DEPARTAMENTO,
      itm.FINELINE_NBR                                    AS NUMFL,
      itmd.FINELINE                                       AS FINELINE,
      CAST(itm.UPC_NBR AS STRING)                         AS UPC,
      itm.OLD_NBR                                         AS ITEM_NBR,
      itm.ITEM1_DESC                                      AS ITEM_DESC1,
      itm.ITEM2_DESC                                      AS ITEM_DESC2,
      itm.SIGNING_DESC                                    AS SIGNING_DESC,

      -- ── Trait ──────────────────────────────────────────────────────────
      -- ITEM_DESIGNATION_1: 'ALL'=todos clubs | 'C'=club-trait |
      --                     'A'=all | 'S'=especial | 'R'=restringido
      -- ⚠️  TRAIT_FLAG en ITEM_DESC es siempre NULL/blank en Sam's
      IFNULL(ides.ITEM_DESIGNATION_1, 'ALL')              AS TRAIT,

      -- ── Combinación ────────────────────────────────────────────────────
      1                                                   AS COMBINACIONES,

      -- ── Forecast semanal → diario ──────────────────────────────────────
      IF(fcst.SALES_FCST_EACH_QTY IS NULL, 0,
         fcst.SALES_FCST_EACH_QTY / 7)                   AS SALES_FCST,

      -- ── Inventario (MDSE_INVENTORY) ────────────────────────────────────
      -- ONSITE  = piso de ventas  ≈ OH_QTY en WM
      -- OFFSITE = backroom/bodega ≈ IW_QTY en WM
      -- ⚠️  Sam's NO tiene separación de IN_TRANSIT (IT) como WM
      IF(inv.ONSITE_ONHAND_QTY  IS NULL, 0,
         inv.ONSITE_ONHAND_QTY)                           AS OH_PISO_QTY,
      IF(inv.OFFSITE_ONHAND_QTY IS NULL, 0,
         inv.OFFSITE_ONHAND_QTY)                          AS BACKROOM_QTY,
      IF(inv.ONSITE_ONHAND_QTY  IS NULL, 0,
         inv.ONSITE_ONHAND_QTY)
      + IF(inv.OFFSITE_ONHAND_QTY IS NULL, 0,
           inv.OFFSITE_ONHAND_QTY)                        AS OH_TOTAL_QTY,
      IF(inv.ON_ORDER_QTY IS NULL, 0,
         inv.ON_ORDER_QTY)                                AS IO_QTY,

      -- ── Purchase Orders ────────────────────────────────────────────────
      IF(po.PACKS_ORD IS NULL, 0, po.PACKS_ORD)          AS PACKS_ORD,
      IF(po.PACKS_REC IS NULL, 0, po.PACKS_REC)          AS PACKS_REC

    FROM (
      /*─────────────────────────────────────────────────────────────────────
        UNIVERSO: ítems gestionados por GRS  =  equivalente INFOREM_MANAGED_SKU
        GRS_FULFILLMENT_PARM contiene las combinaciones club × ítem activas.
        Valores confirmados:
          STOP_REPL_IND:         '0'=activo | '2'=stop repl | '3'=otro
          FULFILLMENT_BLOCK_IND: '0'=sin bloqueo | '1'=bloqueado
      ─────────────────────────────────────────────────────────────────────*/
      SELECT DISTINCT
        STORE_NBR,
        ITEM_NBR,
        REPL_GROUP_NBR
      FROM `wmt-edw-prod.MX_WC_REPL_VM.GRS_FULFILLMENT_PARM`
      WHERE STOP_REPL_IND        = '0'
        AND FULFILLMENT_BLOCK_IND = '0'
    ) fp

    /*─────────────────────────────────────────────────────────────────────
      ITEM  (catálogo maestro Sam's)
    ─────────────────────────────────────────────────────────────────────*/
    INNER JOIN `wmt-edw-prod.MX_WC_VM.ITEM` itm
      ON  fp.ITEM_NBR = itm.ITEM_NBR
      AND itm.ITEM_STATUS_CODE = 'A'

    /*─────────────────────────────────────────────────────────────────────
      ITEM_DESC  (status, flags)
      ⚠️  ORDBK_FLAG no aplica en Sam's (siempre = 'N', diferente a WM)
    ─────────────────────────────────────────────────────────────────────*/
    INNER JOIN `wmt-edw-prod.MX_WC_VM.ITEM_DESC` itmd
      ON  itm.OLD_NBR  = itmd.OLD_NBR
      AND itm.ITEM_NBR = itmd.ITEM_NBR
      AND itmd.STATUS_CODE          = 'A'
      AND itmd.CANCEL_WHEN_OUT_FLAG = 'N'

    /*─────────────────────────────────────────────────────────────────────
      STORE_INFO  (geografía del club)
      OPEN_STATUS = '2' → clubs abiertos (200 clubs confirmados en prueba)
      Otros valores: '0'=45 clubs | '1'=8 | '6'=3 | '7'=7
    ─────────────────────────────────────────────────────────────────────*/
    INNER JOIN `wmt-edw-prod.MX_WC_VM.STORE_INFO` si
      ON  fp.STORE_NBR  = CAST(si.STORE_NBR AS INT64)
      AND si.OPEN_STATUS = '2'

    /*─────────────────────────────────────────────────────────────────────
      DEPT_DESC  (nombre del departamento)
    ─────────────────────────────────────────────────────────────────────*/
    LEFT JOIN `wmt-edw-prod.MX_WC_VM.DEPT_DESC` dd
      ON  itm.DEPT_NBR = dd.ORDER_DEPT_NBR

    /*─────────────────────────────────────────────────────────────────────
      TRAIT: ITEM → GRS_DMDUNIT → ITEM_DESIGNATION
      LEFT JOIN: ítems sin trait explícito no tienen registro en ITEM_DESIGNATION
    ─────────────────────────────────────────────────────────────────────*/
    LEFT JOIN `wmt-edw-prod.MX_WC_REPL_VM.GRS_DMDUNIT` gdu
      ON  CAST(fp.REPL_GROUP_NBR AS NUMERIC) = gdu.REPL_GROUP_NBR

    LEFT JOIN `wmt-edw-prod.MX_WC_VM.ITEM_DESIGNATION` ides
      ON  CAST(gdu.MDS_FAM_ID AS NUMERIC) = CAST(ides.MDS_FAM_ID AS NUMERIC)
      AND fp.STORE_NBR = CAST(ides.CLUB_NBR AS INT64)

    /*─────────────────────────────────────────────────────────────────────
      FORECAST SEMANAL (semana actual)
    ─────────────────────────────────────────────────────────────────────*/
    LEFT JOIN (
      SELECT
        f.STORE_NBR,
        f.ITEM_NBR,
        SUM(f.SALES_FCST_EACH_QTY) AS SALES_FCST_EACH_QTY
      FROM `wmt-edw-prod.MX_WC_VM.STORE_ITEM_FCST_WK_CONV` f
      WHERE f.WM_YR_WK = (
        SELECT DISTINCT WM_YR_WK
        FROM `wmt-edw-prod.MX_WC_VM.CALENDAR_DAY`
        WHERE GREGORIAN_DATE = CURRENT_DATE()
      )
        AND f.FCST_WM_YR_WK = (
        SELECT DISTINCT WM_YR_WK
        FROM `wmt-edw-prod.MX_WC_VM.CALENDAR_DAY`
        WHERE GREGORIAN_DATE = CURRENT_DATE()
      )
      GROUP BY 1, 2
    ) fcst
      ON  fp.STORE_NBR = fcst.STORE_NBR
      AND fp.ITEM_NBR  = fcst.ITEM_NBR

    /*─────────────────────────────────────────────────────────────────────
      INVENTARIO ACTUAL (MDSE_INVENTORY — snapshot vigente)
      PERIOD_END_DATE = '2500-01-01' identifica el registro activo
    ─────────────────────────────────────────────────────────────────────*/
    LEFT JOIN (
      SELECT
        ITEM_NBR,
        CAST(CLUB_NBR AS INT64)        AS CLUB_NBR,
        SUM(ONSITE_ONHAND_QTY)         AS ONSITE_ONHAND_QTY,
        SUM(OFFSITE_ONHAND_QTY)        AS OFFSITE_ONHAND_QTY,
        SUM(ON_ORDER_QTY)              AS ON_ORDER_QTY
      FROM `wmt-edw-prod.MX_WC_VM.MDSE_INVENTORY`
      WHERE PERIOD_END_DATE = '2500-01-01'
      GROUP BY 1, 2
    ) inv
      ON  fp.ITEM_NBR  = inv.ITEM_NBR
      AND fp.STORE_NBR = inv.CLUB_NBR

    /*─────────────────────────────────────────────────────────────────────
      PURCHASE ORDERS (últimas ~4 semanas, pedidos completados)
      En Sam's, PO_LINE_DISTRIBUTION ya contiene STORE_NBR e ITEM_NBR directo
      → no se necesita PO_LINE como tabla intermedia (diferente a WM)
    ─────────────────────────────────────────────────────────────────────*/
    LEFT JOIN (
      SELECT
        pold.STORE_NBR,
        pold.ITEM_NBR,
        SUM(pold.WHPK_ORDERED_QTY)  AS PACKS_ORD,
        SUM(pold.WHPK_RECEIVED_QTY) AS PACKS_REC
      FROM `wmt-edw-prod.MX_WC_VM.PURCHASE_ORDER` po
      INNER JOIN `wmt-edw-prod.MX_WC_VM.PO_LINE_DISTRIBUTION` pold
        ON  po.PO_NBR     = pold.PO_NBR
        AND po.ORDER_DATE = pold.ORDER_DATE
      WHERE po.CANCEL_DATE BETWEEN CURRENT_DATE() - 37 AND CURRENT_DATE() - 10
        AND po.PO_STATUS = 'C'
      GROUP BY 1, 2
    ) po
      ON  fp.STORE_NBR = po.STORE_NBR
      AND fp.ITEM_NBR  = po.ITEM_NBR

    GROUP BY
      1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22

  ) a

) a

GROUP BY
  1,2,3,4,5,6,7,8,9,10,11,12,13,14

ORDER BY
  REGION, DISTRITO, CLUB, NUMDEPTO, NUMFL, ITEM_NBR;
