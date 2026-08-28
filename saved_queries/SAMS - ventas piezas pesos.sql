SELECT *
FROM 
(
                SELECT 
                                                                                                                              b.old_nbr AS Item_Nbr
                                                                                                                                             ,b.primary_desc AS Item_Desc
                                                                                                                                             ,b.category_nbr AS Cat
                                                                                                                                             ,b.sub_category_nbr AS Subcat
                                                                                                                                             ,b.vendor_nbr_dept AS Vendor_Dept
                                                                                                                                             ,b.vendor_nbr AS Vendor_Nbr
                                                                                                                                             ,b.vendor_nbr_seq AS Vendor_Seq
                                                                                                                                             ,b.vendor_name AS Vendor_Name
                                                                                                                                             ,a.vendor_pack_cost AS VnPk_cost
                                                                                                                                             ,b.vnpk_qty AS VnPk
                                                                                                                                             ,a.club_nbr AS Club_nbr
                                                                                                                                             ,d.store_name AS Club_name
--                                                                                                                                          ,b.majority_status_cd AS Status_corp
                                                                                                                                             ,a.onsite_onhand_qty AS OH_qty
                                                                                                                                             ,a.onsite_onhand_qty*a.unit_cost AS OH_cost
                                                                                                                                             ,a.on_order_qty AS OO_qty
                                                                                                                                             ,a.on_order_qty*a.unit_cost AS OO_cost
                                                                                                                                             ,a.status AS Status_club
                                                                                                                                             ,b.item_nbr AS Item_key
                                                                                                                             
                                                                                                                                             
  FROM
 wmt-edw-prod.MX_WC_VM.MDSE_INVENTORY a, -- inventario club item
wmt-edw-prod.MX_WC_VM.ITEM_DESC b, -- catalogo articulos
wmt-edw-prod.MX_WC_VM.STORE_INFO d -- catalogo clubs
--mx_wc_vm.calendar_day x -- catalogo fechas
                
WHERE
                                                                                              
a.item_nbr=b.item_nbr
 AND a.club_nbr=d.store_nbr
 --AND a.club_nbr  IN (4832,4841,4935,4951,4972,4987,6227,6286,6576,6578)
 --- AND
--AND--a.status IN ('A','S','O') 

--AND Division NOT IN ('7','8','desconocido')
--AND b.category_nbr IN  (3,5,6,15,29,31,32,60,70,71,80,81,98)
---AND  b.vendor_nbr IN(224431)
--AND b.old_nbr IN(980032333)
AND a.club_nbr IN  (4727,
4728,
4746,
4790,
4791,
4792,
4801,
4805,
4827,
4832,
4841,
4862,
4877,
4878,
4879,
4901,
4910,
4911,
4913,
4934,
4935,
4936,
4937,
4938,
4939,
4944,
4945,
4946,
4947,
4948,
4949,
4950,
4951,
4954,
4955,
4957,
4958,
4960,
4961,
4968,
4969,
4970,
4972,
4973,
4975,
4977,
4978,
4979,
4981,
4982,
4983,
4984,
4985,
4986,
4987,
4988,
4991,
4992,
4999,
6204,
6205,
6206,
6207,
6208,
6209,
6210,
6211,
6212,
6213,
6215,
6217,
6218,
6219,
6221,
6222,
6223,
6224,
6225,
6226,
6227,
6232,
6233,
6234,
6236,
6237,
6240,
6241,
6242,
6244,
6248,
6249,
6251,
6252,
6254,
6258,
6260,
6261,
6263,
6264,
6274,
6275,
6279,
6285,
6288,
6294,
6390,
6391,
6392,
6393,
6394,
6395,
6396,
6397,
6398,
6467,
6468,
6469,
6470,
6497,
6513,
6523,
6534,
6557,
6563,
6574,
6576,
6577,
6578,
6583,
6584,
6585,
6586,
8118,
8121,
8122,
8124,
8127,
8240,
6282,
6298,
6287,
6300,
6297,
6289,
6277,
6247,
6305,
6265,
4989,
6229,
6293,
6286,
6296,
6309,
6246,
6308,
4941,
6290,
6307,
6243,
6295,
6283,
6313,
6314,
6317,
5854,
6315,
6320,
4914,
6312)
                               
 GROUP BY
 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
                                                               
) AS inventario                                      


      LEFT JOIN 
      
 (
  
 SELECT 
    c.item_nbr AS item_key2
,store_nbr                              
                               
                                               
-- Actual 

,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12249)THEN c.wkly_qty END ),0) ASqty_wk22_49
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12250)THEN c.wkly_qty END ),0) ASqty_wk22_50
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12251)THEN c.wkly_qty END ),0) ASqty_wk22_51
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12252)THEN c.wkly_qty END ),0) ASqty_wk22_52
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12301)THEN c.wkly_qty END ),0) ASqty_wk23_01
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12302)THEN c.wkly_qty END ),0) ASqty_wk23_02
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12303)THEN c.wkly_qty END ),0) ASqty_wk23_03
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12304)THEN c.wkly_qty END ),0) ASqty_wk23_04

,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12149)THEN c.wkly_qty END ),0) ASqty_wk21_49
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12150)THEN c.wkly_qty END ),0) ASqty_wk21_50
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12151)THEN c.wkly_qty END ),0) ASqty_wk21_51
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12152)THEN c.wkly_qty END ),0) ASqty_wk21_52
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12201)THEN c.wkly_qty END ),0) ASqty_wk22_01
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12202)THEN c.wkly_qty END ),0) ASqty_wk22_02
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12203)THEN c.wkly_qty END ),0) ASqty_wk22_03
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12204)THEN c.wkly_qty END ),0) ASqty_wk22_04

,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12249)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_49
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12250)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_50
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12251)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_51
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12252)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_52
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12301)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk23_01
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12302)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk23_02
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12303)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk23_03
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12304)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk23_04

,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12149)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk21_49
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12150)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk21_50
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12151)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk21_51
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12152)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk21_52
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12201)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_01
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12202)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_02
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12203)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_03
,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12204)THEN c.wkly_qty*a.unit_cost END ),0) ASC_wk22_04



                
                
                
                --FECHAS 10+1
                                                                                                                                          

--,COALESCE(SUM(CASE WHEN(c.wm_yr_wk =12212)THEN c.wkly_qty END ),0) ASqty_wk22_12



                                                                                                                                                                     
 FROM 
  wmt-edw-prod.MX_WC_VM.SKU_DLY_POS c, -- ventas
  wmt-edw-prod.MX_WC_VM.MDSE_INVENTORY a

  where a.club_nbr=c.store_nbr
  AND c.ITEM_NBR = a.ITEM_NBR

 GROUP BY 1,2)
       AS ventas
                ON (inventario.item_key = ventas.item_key2 AND
                               inventario.club_nbr = ventas.store_nbr )


                               ORDER BY

                               inventario.Vendor_nbr,
                               inventario.Item_nbr