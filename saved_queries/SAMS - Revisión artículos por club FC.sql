Select 
b.Old_NBR, 
b.PRIMARY_DESC,
B.SECONDARY_DESC,
b.CATEGORY_NBR,
b.SUB_CATEGORY_NBR,
b.TYPE_CODE,
Cast(b.VENDOR_NBR as Numeric) * 1000 + Cast(b.VENDOR_NBR_DEPT as Numeric) * 10 + Cast(b.VENDOR_NBR_SEQ as Numeric) as Vnd_nbr,
b.VENDOR_NAME,
COUNTIF(a.club_nbr = 5885) AS club_5885,
COUNTIF(a.club_nbr = 5885) AS club_4879,
COUNTIF(a.club_nbr = 5885) AS club_4977,
COUNTIF(a.club_nbr = 5885) AS club_6246,
COUNTIF(a.club_nbr = 5885) AS club_6397,
COUNTIF(a.club_nbr = 5885) AS club_6534,
COUNTIF(a.club_nbr = 5885) AS club_6290,
COUNTIF(a.club_nbr = 5885) AS club_6497,
COUNTIF(a.club_nbr = 5885) AS club_6283,
COUNTIF(a.club_nbr = 5885) AS club_6205,
COUNTIF(a.club_nbr = 5885) AS club_6211,

--a.CLUB_NBR,
--(a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY) AS OH, 
--(a.ONSITE_ONHAND_QTY + a.OFFSITE_ONHAND_QTY * a.UNIT_COST) AS OH_COST,
--a.ON_ORDER_QTY AS OO, 
--a.UNIT_COST, 
--a.UNIT_SELL, 
--a.ITEM_ON_SHELF_DATE AS Fecha_Inic,
--a.ITEM_OFF_SHELF_DT AS Fecha_Fin,
--a.STATUS
FROM wmt-edw-prod.MX_WC_VM.MDSE_INVENTORY a,
         wmt-edw-prod.MX_WC_VM.ITEM_DESC b
WHERE a.ITEM_NBR = b.ITEM_NBR
AND a.CLUB_NBR IN (5885,4879,4977,6246,6397,6534,6290,6497,6283,6205,6211)

Group BY 1,2,3,4,5,6,7,8

Order By 1 asc