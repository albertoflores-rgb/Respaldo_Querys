Select
Item_ID AS Item,
Item_Primary_Description AS Descripcion,
Item_Secondary_Desciption AS Descripcion_2,
Tribe_Description AS Tribu,
Squad_Description AS Division,
Category_ID AS Categoria,
Category_Description AS Cat_Desc,
SubCategory_ID AS Subcategory,
Item_Status_Code AS Status,
Item_Type_Code AS Tipo,
Vendor_ID AS Vendor,
Vendor_Name AS Vendor_Desc,
Channel_Description AS Canal,
Inventory_Date AS Date,
Total_Inventory_Unit_Quantity as total_Units,
Total_Inventory_Cost_Amount aS Total_Cost,
Inventory_Available_Unit_Quantity AS Disponible_Units,
Inventory_Available_Cost_Amount AS Disponible_cost,
Inventory_Returned_Unit_Quantity AS Devoluciones_Units,
Inventory_Returned_Cost_Amount AS Devoluciones_Cost,
Inventory_Awaiting_Unit_Quantity AS On_Hold_Units,
Inventory_Awaiting_Cost_Amount AS On_Hold_Cost,
Inventory_Pending_Unit_Quantity AS Pendiente_Units,
Inventory_Pending_Cost_Amount AS Pendiente_Cost

FROM wmt-mx-dl-controlledmgzn-prod.WM_AD_HOC_MX.AD_HOC_ECOMM_WC_INVT_FC_DLY
Where 
PARSE_DATE('%d.%m.%Y',Inventory_Date) IN (CURRENT_DATE()) --Inventario del dia
--Inventory_Date BETWEEN ("2023-11-08") AND CURRENT_DATE --Historico
--AND Category_ID IN () -- revisar por cateogoria
--AND Squad_Description () -- revisar por division
--AND Item_ID IN () --revisar por id 
--AND Vendor_id IN ('12641630')
--AND Item_Status_Code () --Status Item
--Item_Type_Code () --revisar por articulos resurtibles y no resurtibles

Order By
Inventory_Date Desc
