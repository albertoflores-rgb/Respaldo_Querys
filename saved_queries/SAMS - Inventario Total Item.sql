-- ============================================================
-- SAM'S CLUB MX — Inventarios por Club
-- Área    : E-Catman
-- Schema  : wmt-edw-prod.MX_WC_VM  (Sam's Club MX)
-- ============================================================

-- ── PARÁMETROS: ajusta aquí sin tocar el resto ──────────────
--DECLARE _CATS     ARRAY<INT64>   DEFAULT [41, 43, 46, 49, 53, 68];
--DECLARE _STATUS   ARRAY<STRING>  DEFAULT ['A','O','S','I','D'];
--DECLARE _CLUBS ARRAY<INT64>  DEFAULT [5885, 5886]; -- filtro club específico (opcional)
--DECLARE _ITEMS ARRAY<INT64>  DEFAULT [];            -- filtro ítem específico  (opcional)

-- ════════════════════════════════════════════════════════════
-- QUERY PRINCIPAL — Detalle Item Total
-- ════════════════════════════════════════════════════════════
SELECT

  -- ── Ítem ────────────────────────────────────────────────
  b.Old_NBR                                               AS Item_Nbr,
  b.PRIMARY_DESC                                          AS Item_Desc_1,
  b.SECONDARY_DESC                                        AS Item_Desc_2,
  e.DIRECCION                                             AS Direccion,
  e.DIVISION                                              AS Departamento,
  b.CATEGORY_NBR                                          AS Cat_Nbr,
  e.CATDESC                                               AS Cat_Desc,
  b.SUB_CATEGORY_NBR                                      AS Sub_Cat_Nbr,
  f.Sub_Categoria                                         AS Sub_Cat_Desc,
  f.Cat_SubCat                                            AS Cat_Sub_Cat,
  b.TYPE_CODE                                             AS Tipo,
  b.Status_Code											  AS Status,
  b.VENDOR_NAME                                           AS Proveedor,
  CAST(b.VENDOR_NBR AS NUMERIC) * 1000
    + CAST(b.VENDOR_NBR_DEPT AS NUMERIC) * 10
    + CAST(b.VENDOR_NBR_SEQ  AS NUMERIC)                 AS Vendor_Nbr,

  -- ── Resurtido ────────────────────────────────────────────────
  e.COMPRADOR                                             AS Comrpador,
  e.GERENTE                                               AS Gerente_Resurtido,
  e.RESURTIDOR                                            AS Resurtidor,
  b.EFFECTIVE_DATE                                        AS IED,

  -- ── Club ────────────────────────────────────────────────

  --a.CLUB_NBR                                              AS Club_Nbr,
  --d.store_NAME                                             AS Club_Name,
  --g.Tipo_Tienda                                           AS Tipo_Det,
  -- ── Inventario ──────────────────────────────────────────
  --sum (a.ONSITE_ONHAND_QTY)                                     AS OH_Piso,
  --sum (a.OFFSITE_ONHAND_QTY)                                    AS OH_Trastienda,
  --sum ((a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY))           AS OH_Total,
  --sum (a.ON_ORDER_QTY)                                          AS OO_En_Orden,
  COALESCE(SUM(CASE WHEN(g.Tipo_Tienda = "Club") THEN (a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY) END) , 0 ) AS OHQty_Clubes,
  COALESCE(SUM(CASE WHEN(g.Tipo_Tienda = "FC MX") THEN (a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY) END) , 0) AS OHQty_FC_MX,
  COALESCE(SUM(CASE WHEN(g.Tipo_Tienda = "FC MTY") THEN (a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY) END) , 0) AS OHQty_FC_MTY,
  COALESCE(COUNT((CASE WHEN(g.tipo_tienda = "Club") THEN a.club_nbr END)), 0) AS Club_con_Inventario,    
  COALESCE(COUNT((CASE WHEN(g.tipo_tienda = "Club" and a.ONSITE_ONHAND_QTY > 0) THEN a.club_nbr END)), 0) AS Club_con_Inventario,
  
  -- ── Fechas de vigencia ──────────────────────────────────
  a.ITEM_ON_SHELF_DATE                                    AS Fecha_Inicio,
  a.ITEM_OFF_SHELF_DT                                     AS Fecha_Fin,
  CURRENT_DATE('America/Mexico_City')                     AS Fecha_Corte,

  -- ── Valuación ───────────────────────────────────────────
  avg(a.UNIT_COST)                                             AS Costo_Unit,
  avg(a.UNIT_SELL)                                             AS Precio_Venta,
  --sum((a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY)
        --* a.UNIT_COST)                                AS OH_Costo_MXN,
  --sum((a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY)
        --* a.UNIT_SELL)                                 AS OH_Retail_MXN,
  --sum(a.ON_ORDER_QTY * a.UNIT_SELL)                 AS OO_Retail_MXN,

  COALESCE(SUM(CASE WHEN(g.Tipo_Tienda = "Club") THEN ((a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY) * a.UNIT_SELL) END) , 0 ) AS OHQty_Clubes_MXN,
  COALESCE(SUM(CASE WHEN(g.Tipo_Tienda = "FC MX") THEN ((a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY) * a.UNIT_SELL) END) , 0) AS OHMXN_FC_MX,
  COALESCE(SUM(CASE WHEN(g.Tipo_Tienda = "FC MTY") THEN ((a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY) * a.UNIT_SELL) END) , 0) AS OHMXN_FC_MTY,



  -- ── Semáforo OH ─────────────────────────────────────────
  CASE
    WHEN sum((a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY)) = 0
                                                THEN '🔴 OOS'
    WHEN sum((a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY)) BETWEEN 1  AND 5
                                                THEN '🟡 Crítico  (<6)'
    WHEN sum((a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY)) BETWEEN 6  AND 20
                                                THEN '🟠 Bajo    (6-20)'
    ELSE                                             '🟢 OK'
  END                                                     AS Semaforo_OH,

  -- Informacion Compras y Resurtido
  

FROM `wmt-edw-prod.MX_WC_VM.MDSE_INVENTORY`  AS a
Left JOIN `wmt-edw-prod.MX_WC_VM.ITEM_DESC`       AS b ON  (a.ITEM_NBR = b.ITEM_NBR)
Left JOIN `wmt-mx-dl-controlledmgzn-prod.Black_Bird.Catalogo_CatID` AS c ON (b.CATEGORY_NBR = c.cat_id)
LEFT JOIN wmt-edw-prod.MX_WC_VM.STORE_INFO AS d ON (a.CLUB_NBR = d.store_NBR)
LEFT JOIN `wmt-mx-dl-controlledmgzn-prod.Black_Bird.Catalogo_Cat_Compradores` AS e ON (b.CATEGORY_NBR = e.DEPT_NBR)
LEFT JOIN `wmt-mx-dl-controlledmgzn-prod.Black_Bird.Catalogo_Cat_Subcat` AS f ON (CONCAT (CAST(b.CATEGORY_NBR AS STRING),"-",CAST(b.Sub_CATEGORY_NBR AS STRING)) = f.Cat_SubCat)
LEFT JOIN `wmt-mx-dl-controlledmgzn-prod.Black_Bird.Catalogo_Clubes` AS g on (a.club_nbr = g.club_nbr)

WHERE a.club_nbr not in (5808 , 6269, 6389,7101,7573,7475,8103,8691)
AND g.tipo_tienda not in("Staff","Ex CA","Cedis Devoluciones","Transpo","WMG","Medimart","Import","Prueba")
  -- Categorías Abarrotes e Impulso (comentar línea para ver todo)
  --b.CATEGORY_NBR IN UNNEST(_CATS)

  -- Status ítem
  --AND b.TYPE_CODE IN UNNEST(_STATUS)

  -- Filtros opcionales (descomentar según necesidad)

  -- AND a.CLUB_NBR IN UNNEST(_CLUBS)
  -- AND b.Old_NBR  IN UNNEST(_ITEMS)

Group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,24,25

ORDER BY OHQTY_Clubes DESC 
