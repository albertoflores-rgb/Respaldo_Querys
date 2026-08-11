SELECT
b.category_nbr,
b.VENDOR_NBR,
b.VENDOR_NAME,
b.old_nbr,
b.PRIMARY_DESC,
a.club_nbr,
a.WM_yr_WK,
SUM(a.onsite_onhand_qty) AS OH,
SUM(a.offsite_onhand_qty) AS COH,
SUM(a.on_order_qty) AS OO,
--SUM(a.onsite_onhand_qty * a.unit_cost) AS OH_cost,
--SUM(a.offsite_onhand_qty * a.unit_cost) AS COH_cost,
--SUM(a.on_order_qty * a.unit_cost) AS OO_cost


FROM
wmt-edw-prod.MX_WC_VM.MDSE_INVENTORY_FRI a,
wmt-edw-prod.MX_WC_VM.ITEM_DESC b

WHERE
a.item_nbr = b.item_nbr AND
--b.old_nbr IN ()
a.wm_yr_wk BETWEEN (12249) AND (12316) AND
a.club_nbr IN (6233)

GROUP BY 1,2,3,4,5,6,7