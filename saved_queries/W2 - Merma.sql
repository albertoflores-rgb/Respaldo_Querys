SELECT
EXTRACT (YEAR FROM c.gregorian_date) AS A,
EXTRACT (MONTH FROM c.gregorian_date) AS M,
itd.ORDER_DEPT_NBR AS Dept_Nbr,
itd.vendor_nbr AS Vendor_Nbr,
itd.vendor_name AS Vendor_Name,
CAST(CAST(ITD.fineline AS INT64)/ 100 AS INT64) AS Category_Nbr,
itd.Old_nbr,
itd.UPC,
itd.primary_desc,
CASE
    WHEN t.trait_nbr IN (297) THEN 'Walmart'
    WHEN t.trait_nbr IN (11) THEN 'Superama'
    WHEN t.trait_nbr IN (9) THEN 'Bodega'
    WHEN t.trait_nbr IN (1312) THEN 'Mi Bodega'
    WHEN t.trait_nbr IN (969) THEN 'BAE'
END AS Formato,
MUMD.Event_ID,
CASE
    WHEN event_id IN (1001) THEN 'MD HO BASE PRICE CHG' 
    WHEN event_id IN (1002) THEN 'MD HO COMP PRICING'   
    WHEN event_id IN (1003) THEN 'MD HO INIT CLEARANCE' 
    WHEN event_id IN (1004) THEN 'MD SAVE EVEN MORE-SC' 
    WHEN event_id IN (1100) THEN 'MD HO FOLLOW-UP CLR.' 
    WHEN event_id IN (1101) THEN 'MD HO/STORE CLEANUP'  
    WHEN event_id IN (1201) THEN 'MD ST INIT CLEARANC'  
    WHEN event_id IN (1202) THEN 'MD FOLLOW-UP CLEARNC' 
    WHEN event_id IN (1300) THEN 'MD HOME OFFICE TAB'   
    WHEN event_id IN (1305) THEN 'MD LINKSAVE'  
    WHEN event_id IN (1401) THEN 'MD COMPETITIVE'   
    WHEN event_id IN (1402) THEN 'MD WMDC ASSORTMENT'   
    WHEN event_id IN (1500) THEN 'MD PRICE OVERRIDES'   
    WHEN event_id IN (1505) THEN 'MD $3 OFF SCAN ERRS'  
    WHEN event_id IN (1515) THEN 'MD POS COMP ADS'  
    WHEN event_id IN (1516) THEN 'MD POS CSC'   
    WHEN event_id IN (1517) THEN 'MD POS WARRANTY ADJ.' 
    WHEN event_id IN (1518) THEN 'MD POS MISCELLANEOUS' 
    WHEN event_id IN (1519) THEN 'MD POS OTHER' 
    WHEN event_id IN (1521) THEN 'Tienda' 
    WHEN event_id IN (1600) THEN 'MD DAMAGED M/D TO 0'  
    WHEN event_id IN (1700) THEN 'MD TEMP PRICE ACTION' 
    WHEN event_id IN (1804) THEN 'MD LAYAWAY CANCELS'   
    WHEN event_id IN (1805) THEN 'MD NOF & SCAN ERRS'   
    WHEN event_id IN (1814) THEN 'THROWAWAY-SC' 
    WHEN event_id IN (1815) THEN 'REDUCTION-SC' 
    WHEN event_id IN (1816) THEN 'MD H.O. ROLLBACK' 
    WHEN event_id IN (1821) THEN 'MD CHARITABLE CNTRIB'
    WHEN event_id IN (5001) THEN 'MU HO BASE PRICE CHG'
    WHEN event_id IN (5002) THEN 'MU HO COMP PRICING'
    WHEN event_id IN (5003) THEN 'MU HO INIT CLEARANCE'
    WHEN event_id IN (5004) THEN 'MU SAVE EVEN MORE-SC'
    WHEN event_id IN (5100) THEN 'MU HO FOLLOW-UP CLR.'
    WHEN event_id IN (5101) THEN 'MU HO/STORE CLEANUP'
    WHEN event_id IN (5201) THEN 'MU ST INIT CLEARANC'
    WHEN event_id IN (5202) THEN 'MU FOLLOW-UP CLEARNC'
    WHEN event_id IN (5300) THEN 'MU HOME OFFICE TAB'
    WHEN event_id IN (5305) THEN 'MU LINKSAVE'
    WHEN event_id IN (5401) THEN 'MU COMPETITIVE'
    WHEN event_id IN (5402) THEN 'MU WMDC ASSORTMENT'
    WHEN event_id IN (5500) THEN 'MU PRICE OVERRIDES'
    WHEN event_id IN (5505) THEN 'MU $3 OFF SCAN ERRS'
    WHEN event_id IN (5515) THEN 'MU POS COMP ADS'
    WHEN event_id IN (5516) THEN 'MU POS CSC'
    WHEN event_id IN (5518) THEN 'MU POS MISCELLANEOUS'
    WHEN event_id IN (5519) THEN 'MU POS OTHER'
    WHEN event_id IN (5600) THEN 'MU DAMAGED M/D TO 0'
    WHEN event_id IN (5700) THEN 'MU TEMP PRICE ACTION'
    WHEN event_id IN (5804) THEN 'MU LAYAWAY CANCELS'
    WHEN event_id IN (5805) THEN 'MU NOF & SCAN ERRS'
    WHEN event_id IN (5816) THEN 'MU H.O. ROLLBACK'
    WHEN event_id IN (5705) THEN 'MU STORE PRICE ACTIVATION'
    WHEN event_id IN (5811) THEN 'MU COMPETITIVE TO AD'
   
END AS Event_Description,

    SUM(sat_ITEM_QTY * sat_mult +
        sun_ITEM_QTY * sun_mult +
        mon_ITEM_QTY  * mon_mult +
        tue_ITEM_QTY * tue_mult +
        wed_ITEM_QTY * wed_mult +
        thu_ITEM_QTY * thu_mult +
        fri_ITEM_QTY * fri_mult)
    AS SI_MUMD_Qty,
    
    (SUM(sat_pre_tot_retl * sat_mult +
        sun_pre_tot_retl * sun_mult +
        mon_pre_tot_retl  * mon_mult +
        tue_pre_tot_retl * tue_mult +
        wed_pre_tot_retl * wed_mult +
        thu_pre_tot_retl * thu_mult +
        fri_pre_tot_retl * fri_mult))
        - 
    (SUM(sat_cur_tot_retl * sat_mult +
        sun_cur_tot_retl * sun_mult +
        mon_cur_tot_retl  * mon_mult +
        tue_cur_tot_retl * tue_mult +
        wed_cur_tot_retl * wed_mult +
        thu_cur_tot_retl * thu_mult +
        fri_cur_tot_retl * fri_mult)) 
    AS SI_Total_MUMD
    
FROM
    wmt-edw-prod.MX_WM_VM.SKU_TY_DLY_MUMD mumd,
    wmt-edw-prod.MX_WM_VM.CALENDAR_DAY c,
    wmt-edw-prod.MX_WM_VM.ITEM_DESC itd,
    wmt-edw-prod.MX_WM_VM.TRAIT_STORE t

WHERE
    mumd.wm_yr_wk = c.wm_yr_wk
    AND mumd.item_nbr = itd.item_nbr
    AND t.store_nbr = mumd.store_nbr
    AND t.trait_nbr IN (297,11,9,1312,969)  
    AND c.gregorian_date BETWEEN DATE '2024-07-01' AND DATE '2024-07-28' 
    --AND itd.Old_nbr IN ()

GROUP BY
    1,2,3,4,5,6,7,8,9,10,11,12
