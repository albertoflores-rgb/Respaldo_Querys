-- Safety ganador clubes victor

SELECT 
inventario.Cat
,inventario.Vnd_nbr
,inventario.Vnd_Name
,inventario.Item_Nbr
--,inventario.item
,inventario.Item_Desc
,inventario.Item_Desc2
,inventario.Club_nbr
,inventario.Club_name
,inventario.Status_club
,inventario.VnPk
--,inventario.OH_qty
--,inventario.Unit_cost
--,FCST_WEEK_0
--,FCST_WEEK_1
--,FCST_WEEK_2
--,FCST_WEEK_3
--,ZEROIFNULL((FCST_WEEK_0*.18+FCST_WEEK_0*.16+FCST_WEEK_0*.12+FCST_WEEK_0*.12+FCST_WEEK_0*.12+FCST_WEEK_0*.13+FCST_WEEK_0*.17+FCST_WEEK_1*.18+FCST_WEEK_1*.16+FCST_WEEK_1*.12+FCST_WEEK_1*.12+FCST_WEEK_1*.12+FCST_WEEK_1*.13+FCST_WEEK_1*.17+FCST_WEEK_2*.18+FCST_WEEK_2*.16+FCST_WEEK_2*.12+FCST_WEEK_2*.12+FCST_WEEK_2*.12+FCST_WEEK_2*.13+FCST_WEEK_2*.17+FCST_WEEK_3*.18+FCST_WEEK_3*.16+FCST_WEEK_3*.12+FCST_WEEK_3*.12+FCST_WEEK_3*.12+FCST_WEEK_3*.13+FCST_WEEK_3*.17)/28) AS FCST_prom_diario
--,ventas. wk_1	
--,ventas. wk_2
--,ventas. wk_3
--,ventas. wk_4
--,ventas. wk_5
--,ventas. wk_6
--,ventas. wk_7
--,ventas. wk_8
--,ZEROIFNULL((ventas. wk_1	+ventas.wk_2+ventas.wk_3+ventas.wk_4+ventas. wk_5	+ventas.wk_6+ventas.wk_7+ventas.wk_8)*1.00/56) AS promvta8sem_diario
,ifnull(e.SScov,0) AS SScov
--,e.sscov* promvta8sem_diario AS SSCOV_piezas
--,ZEROIFNULL(ss_cov*FCST_prom_diario) AS SSCOV_piezas
,IFNULL(press_qty,0) AS SSpres
,IFNULL(e.Minss,0) AS MinSS
,IFNULL(e.Maxss,0) AS MaxSS
,IFNULL(win.SAFETY_EACH_QTY,0) AS Safety_Ganador
/* CASE WHEN (press>sscov_piezas AND press>e.minss AND press<e.maxss) THEN Press ELSE 0 END AS safety_ganador
	CASE WHEN sscov_piezas>press AND sscov_piezas>e.minss AND sscov_piezas>e.maxss THEN sscov_piezas ELSE
	CASE WHEN e.minss>press AND e.minss>sscov_piezas AND e.minss>e.maxss THEN e.minss ELSE
	CASE WHEN e.maxss>press AND e.maxss>sscov_piezas AND e.maxss>e.minss THEN e.maxss END END END END AS safety_ganador
*/
--,CASE WHEN inventario.Status_GRS =2 THEN safety_ganador+inventario.VnPk ELSE 0 END AS Optimal_Fcst_Sales
--,Optimal_Fcst_Sales*inventario.Unit_cost AS Optimal_Cost_Fcst_Sales
--, inventario.OH_cost
--,Optimal_Cost_Fcst_Sales*1.20 AS Optimal_20

--,CASE WHEN inventario.Status_GRS =1 THEN 0 ELSE 
-- CASE WHEN inventario.Status_GRS =0 THEN 0 ELSE 
-- CASE WHEN ( inventario.Status_GRS =2 AND Optimal_20<inventario.OH_cost) THEN Optimal_20-inventario.OH_cost ELSE 0  END END END AS IMPACTO_120

--,Optimal_Cost_Fcst_Sales*.80 AS OPTIMAL_MENOS20

--,CASE WHEN inventario.Status_GRS =1 THEN 0 ELSE 
-- CASE WHEN inventario.Status_GRS =0 THEN 0 ELSE 
-- CASE WHEN ( inventario.Status_GRS =2 AND OPTIMAL_MENOS20>inventario.OH_cost) THEN OPTIMAL_MENOS20-inventario.OH_cost ELSE 0  END END END AS IMPACTO_80

,inventario.Status_GRS
--ALLOC_18161212121317*/

FROM 
(
	SELECT 
									b.category_nbr AS Cat,
									--,b.sub_category_nbr AS Subcat
									Cast(b.VENDOR_NBR as Numeric) * 1000 + Cast(b.VENDOR_NBR_DEPT as Numeric) * 10 + Cast(b.VENDOR_NBR_SEQ as Numeric) as Vnd_nbr
									,b.vendor_name AS Vnd_Name
									--,c.REPL_GROUP_NBR AS CID
									,b.item_nbr AS item
									 ,b.old_nbr AS item_Nbr
									,b.primary_desc AS Item_Desc
									,b.secondary_desc AS Item_Desc2
									,a.club_nbr AS Club_nbr
									,d.store_name AS Club_name
									,a.status AS Status_club
									,b.vnpk_qty AS VnPk
									,a.onsite_onhand_qty AS OH_qty
									,a.vendor_pack_cost AS VnPk_cost
									,a.unit_cost  AS Unit_cost
									,b.item_nbr AS Item_key										
									,a.onsite_onhand_qty*a.unit_cost AS OH_cost
									,V.JDA_VNDR_STAT_CD AS Status_GRS
								--	,a.on_order_qty AS OO_qty
								--,a.on_order_qty*a.unit_cost AS OO_cost
								--	,b.majority_status_cd AS Status_corp
								--,c.item_type_code AS Tipo
									
									
									
									
		FROM
	
			 wmt-edw-prod.MX_WC_VM.MDSE_INVENTORY a, -- inventario club item
			 wmt-edw-prod.MX_WC_VM.ITEM_DESC b, -- catalogo articulos
			 wmt-edw-prod.MX_WC_VM.ITEM c, -- CID
			 wmt-edw-prod.MX_WC_VM.STORE_INFO d,  -- catalogo clubs
			
			(
						SELECT
			VENDOR_NBR*1000+DEPT_NBR*10+	VENDOR_SEQ_NBR*1 AS Vendor,
			JDA_VNDR_STAT_CD
			FROM
			 wmt-edw-prod.MX_WC_REPL_VM.GRS_VENDOR_AGREEMENT
			) V

			
  		--	MX_WC_VM.calendar_day x -- catalogo fechas
	
WHERE
						
			 a.item_nbr = b.item_nbr
		AND a.item_nbr=c.item_nbr
		AND a.club_nbr = d.store_nbr
		AND  b.item_nbr = c.item_nbr
		AND (Cast(b.VENDOR_NBR as Numeric) * 1000 + Cast(b.VENDOR_NBR_DEPT as Numeric) * 10 + Cast(b.VENDOR_NBR_SEQ as Numeric)) = V.Vendor

--		AND a.club_nbr NOT IN (6250, 6550, 6245, 6238, 8105, 7504, 6549, 4995, 6548, 6239, 4971, 7502, 6388, 4850, 4952, 4996, 4964, 7505, 7501)
AND a.club_nbr IN (6523,
4728,
4982,
4983,
6396)
--		AND category_nbr NOT IN (	81,80,97,18,66,63,57,24,73,77,79,91,76,20,30,35,37,65,74,87,88,89,90,94,95,96	) ---> CAMBIAR CATEGORIA
		--AND category_nbr IN (41,
		---AND a.status IN ('A','O','S') 
		AND c.	item_type_code IN (20,22)
		AND a.ITEM_ON_SHELF_DATE <=CURRENT_DATE
		--AND V.JDA_VNDR_STAT_CD  IN (0,1)
  --	AND V.JDA_VNDR_STAT_CD  IN (2)
    
--AND b.old_nbr IN (980019408,



		GROUP BY
				1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
				
) AS inventario	

LEFT JOIN
(
SELECT
STORE_NBR,
ITEM_NBR,
SAFETY_EACH_QTY

FROM

  wmt-edw-prod.MX_WC_REPL_VM.GRS_FCST_DEMAND
 
 WHERE
 FCST_DATE=CURRENT_DATE		
) AS win

ON (inventario. Item_key=win.item_nbr AND inventario.Club_nbr=win.store_nbr)
LEFT JOIN

(SELECT
			Dest_store_nbr AS store_nbr,
			item_nbr AS item_nbr,
			presentation_qty AS press_qty,
			SS_PRESN_SOURCE_NAME
			FROM

      wmt-edw-prod.MX_WC_REPL_VM.GRS_PRESENTATION_PARM
						WHERE
			SS_PRESN_SOURCE_NAME LIKE ('%Default Ovrd%')
			
			GROUP BY 1,2,3,4
	) AS pressqty
	
 ON (inventario. Item_key=pressqty.item_nbr AND inventario.Club_nbr=pressqty.store_nbr)

LEFT JOIN
(SELECT
STORE_NBR AS store_nbr,
ITEM_NBR AS item_nbr,
MIN_SS_QTY AS Minss,
MIN_SS_SUPPLY_DAY_QTY AS SScov,
MAX_SS_QTY AS Maxss

FROM
 
 wmt-edw-prod.MX_WC_REPL_VM.GRS_FULFILLMENT_PARM

) AS e

ON (inventario.Item_key=e.item_nbr AND inventario.Club_nbr=e.store_nbr)


	LEFT JOIN
	
	(

	SELECT 
			T1.item_nbr AS item_key2,
			T2.store_nbr AS store_key2,			
			52.00 AS semanas,

SUM(CASE WHEN (T3.GREGORIAN_DATE= CURRENT_DATE AND T2.WM_YR_WK= T3.WM_YR_WK)     THEN  T2.WKLY_QTY ELSE 0    END) AS   wk_Act	,
SUM(CASE WHEN (T3.GREGORIAN_DATE= CURRENT_DATE-7  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_1	,
SUM(CASE WHEN (T3.GREGORIAN_DATE= CURRENT_DATE-14 AND T2.WM_YR_WK= T3.WM_YR_WK )    THEN  T2.WKLY_QTY ELSE 0    END) AS wk_2	,
SUM(CASE WHEN (T3.GREGORIAN_DATE= CURRENT_DATE-21 AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_3	,
SUM(CASE WHEN (T3.GREGORIAN_DATE= CURRENT_DATE-28 AND T2.WM_YR_WK= T3.WM_YR_WK )    THEN  T2.WKLY_QTY ELSE 0    END) AS wk_4	,
SUM(CASE WHEN (T3.GREGORIAN_DATE= CURRENT_DATE-35 AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_5	,
SUM(CASE WHEN (T3.GREGORIAN_DATE= CURRENT_DATE-42  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_6	,
SUM(CASE WHEN (T3.GREGORIAN_DATE= CURRENT_DATE-49  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_7	,
SUM(CASE WHEN (T3.GREGORIAN_DATE= CURRENT_DATE-56  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_8	
/*SUM(CASE WHEN (T3.GREGORIAN_DATE =DATE -63  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_9	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -70  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_10	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -77  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_11	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -84  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_12	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -91  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_13	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -98  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_14	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -105  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_15	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -112  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_16	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -119  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_17	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -126  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_18	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -133  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_19	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -140  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_20	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -147  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_21	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -154  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_22	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -161  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_23	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -168  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_24	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -175  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_25	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -182  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_26	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -189  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_27	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -196  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_28	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -203  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_29	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -210  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_30	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -217  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_31	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -224  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_32	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -231  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_33	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -238  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_34	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -245  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_35	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -252  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_36	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -259  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_37	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -266  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_38	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -273  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_39	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -280  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_40	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -287  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_41	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -294  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_42	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -301  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_43	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -308  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_44	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -315  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_45	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -322  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_46	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -329  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_47	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -336  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_48	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -343  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_49	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -350  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_50	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -357  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_51	,
SUM(CASE WHEN (T3.GREGORIAN_DATE=DATE -364  AND T2.WM_YR_WK= T3.WM_YR_WK )     THEN  T2.WKLY_QTY ELSE 0    END) AS wk_52	*/

FROM

 wmt-edw-prod.MX_WC_VM.ITEM_DESC T1,
 wmt-edw-prod.MX_WC_VM.SKU_DLY_POS  T2,
 wmt-edw-prod.MX_WC_VM.CALENDAR_DAY T3



WHERE 

T2.WM_YR_WK= T3.WM_YR_WK AND
T1.ITEM_NBR=T2.item_NBR

GROUP BY 
1,2,3

					
						) AS ventas

						
				ON (inventario.item_key = ventas.item_key2 AND
								inventario.club_nbr = ventas.store_key2 )			
		
					
					LEFT JOIN
			
	(			
				SELECT 

								 e.item_nbr AS item_key3,
								 e.store_nbr AS store_key3,
                COALESCE(SUM(CASE WHEN (f.GREGORIAN_DATE = CURRENT_DATE AND f.WM_YR_WK = e.WM_YR_WK) THEN SALES_FCST_EACH_QTY ELSE 0 END),0) AS FCST_WK_0,
							  COALESCE(SUM(CASE WHEN (f.GREGORIAN_DATE= CURRENT_DATE+7 AND f.WM_YR_WK = e.WM_YR_WK) THEN SALES_FCST_EACH_QTY ELSE 0 END),0) AS FCST_WEEK_1,
								 COALESCE(SUM(CASE WHEN (f.GREGORIAN_DATE= CURRENT_DATE+14 AND f.WM_YR_WK = e.WM_YR_WK) THEN SALES_FCST_EACH_QTY ELSE 0 END),0) AS FCST_WEEK_2,
								  COALESCE(SUM(CASE WHEN (f.GREGORIAN_DATE= CURRENT_DATE+21 AND f.WM_YR_WK = e.WM_YR_WK) THEN SALES_FCST_EACH_QTY ELSE 0 END),0) AS FCST_WEEK_3
/*									 SUM(CASE WHEN (f.GREGORIAN_DATE=DATE+28 AND f.WM_YR_WK = e.WM_YR_WK) THEN SALES_FCST_EACH_QTY ELSE 0 END) (NAMED "FCST_WEEK_4"),
								 SUM(CASE WHEN (f.GREGORIAN_DATE=DATE+35 AND f.WM_YR_WK = e.WM_YR_WK) THEN SALES_FCST_EACH_QTY ELSE 0 END) (NAMED "FCST_WEEK_5"),
								 SUM(CASE WHEN (f.GREGORIAN_DATE=DATE+42 AND f.WM_YR_WK = e.WM_YR_WK) THEN SALES_FCST_EACH_QTY ELSE 0 END) (NAMED "FCST_WEEK_6"),
								 SUM(CASE WHEN (f.GREGORIAN_DATE=DATE+49 AND f.WM_YR_WK = e.WM_YR_WK) THEN SALES_FCST_EACH_QTY ELSE 0 END) (NAMED "FCST_WEEK_7"),
								 SUM(CASE WHEN (f.GREGORIAN_DATE=DATE+56 AND f.WM_YR_WK = e.WM_YR_WK) THEN SALES_FCST_EACH_QTY ELSE 0 END) (NAMED "FCST_WEEK_8"),
								 SUM(CASE WHEN (f.GREGORIAN_DATE=DATE+63 AND f.WM_YR_WK = e.WM_YR_WK) THEN SALES_FCST_EACH_QTY ELSE 0 END) (NAMED "FCST_WEEK_9"),
								 SUM(CASE WHEN (f.GREGORIAN_DATE=DATE+70 AND f.WM_YR_WK = e.WM_YR_WK) THEN SALES_FCST_EACH_QTY ELSE 0 END) (NAMED "FCST_WEEK_10"),
								 SUM(CASE WHEN (f.GREGORIAN_DATE=DATE+77 AND f.WM_YR_WK = e.WM_YR_WK) THEN SALES_FCST_EACH_QTY ELSE 0 END) (NAMED "FCST_WEEK_11"),
								 SUM(CASE WHEN (f.GREGORIAN_DATE=DATE+84 AND f.WM_YR_WK = e.WM_YR_WK) THEN SALES_FCST_EACH_QTY ELSE 0 END) (NAMED "FCST_WEEK_12"),
  						 		SUM(CASE WHEN (f.GREGORIAN_DATE=DATE+91 AND f.WM_YR_WK = e.WM_YR_WK) THEN SALES_FCST_EACH_QTY ELSE 0 END) (NAMED "FCST_WEEK_13"),
 									SUM(CASE WHEN (f.GREGORIAN_DATE=DATE+98 AND f.WM_YR_WK = e.WM_YR_WK) THEN SALES_FCST_EACH_QTY ELSE 0 END) (NAMED "FCST_WEEK_14"),
 									SUM(CASE WHEN (f.GREGORIAN_DATE=DATE+105 AND f.WM_YR_WK = e.WM_YR_WK) THEN SALES_FCST_EACH_QTY ELSE 0 END) (NAMED "FCST_WEEK_15"),
 									SUM(CASE WHEN (f.GREGORIAN_DATE=DATE+112 AND f.WM_YR_WK = e.WM_YR_WK) THEN SALES_FCST_EACH_QTY ELSE 0 END) (NAMED "FCST_WEEK_16")*/

				FROM
							 
               wmt-edw-prod.MX_WC_VM.STORE_ITEM_FCST_WK_CONV e,
							 wmt-edw-prod.MX_WC_VM.CALENDAR_DAY f,

						(
					SELECT
					WM_YR_WK
					FROM
					wmt-edw-prod.MX_WC_VM.CALENDAR_DAY
					WHERE
					GREGORIAN_DATE=CURRENT_DATE
					)	AS Semana

				WHERE
 								f.GREGORIAN_DATE>=CURRENT_DATE AND
 								f.GREGORIAN_DATE<=CURRENT_DATE +(112) AND
								f.WM_YR_WK = e.FCST_WM_YR_WK
				GROUP BY 1,2
				
   ) AS forecast			
													

				ON (inventario.item_key= forecast.item_key3 AND
									inventario.club_nbr = forecast.store_key3 )			
		

		ORDER BY

		inventario.Cat,
		inventario.Item_nbr,
		inventario.club_nbr
	--	ventas.VentaPresupuesto