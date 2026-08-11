Select 
DATE_TRUNC(EXTRACT (DATE FROM Order_Created_Date),YEAR) AS Fecha_Ano,
DATE_TRUNC(EXTRACT (DATE FROM Order_Created_Date),Month) AS Fecha_Mes,
DATE_TRUNC(EXTRACT (DATE FROM Order_Created_Date),Day) AS Fecha_Dia,
Sum(Sales_Qty_dot_com) AS Omnicanal,
Sum(Sales_dot_com)

FROM
wmt-edw-sandbox.WM_AD_HOC_MX.AD_HOC_VENTA_RECONFIG_HIST_CALC

--WHERE
--Item_ID IN (981011033)
--AND Tribe in (MG)
--AND Club_Nbr in (5854)
--AND  EXTRACT (DATE FROM Order_Created_Date) between ('2022-01-01') and ('2023-09-12')
--AND Category_ID IN (5)

Group By 1,2,3
Order By 1 DESC, 2 DESC, 3 DESC