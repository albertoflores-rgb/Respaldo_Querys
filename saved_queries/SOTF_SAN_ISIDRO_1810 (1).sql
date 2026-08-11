DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP1;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP1 AS

SELECT 

    e.Formato AS FORMATO,
    g.Tribu AS TRIBU,
    g.MEGA_SQUAD AS MEGA_SQUAD,
    g.Squad AS SQUAD,
    b.Dept_nbr AS NUMDEPTO,
    f.NumDepartamento AS DEPARTAMENTO,
    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    g.NumCategoria AS CATEGORIA,
    b.Fineline_nbr AS NUMFL,
    i.NumFineline AS FINELINE,
    SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS,
    SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS_HIST a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e ON (a.store_nbr = e.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2023-01-01' AND  DATE '2026-01-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND e.Formato IN ('SUPERCENTER')
--AND e.Det IN (3845)
--AND e.Det IN (3858,3876,3847,3863,3846)
GROUP BY 1,2,3,4,5,6,7,8,9,10;


-- VENTAS

--ANTES

DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP2;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP2 AS

SELECT 

    e.Formato AS FORMATO,
    g.Tribu AS TRIBU,
    g.MEGA_SQUAD AS MEGA_SQUAD,
    g.Squad AS SQUAD,
    b.Dept_nbr AS NUMDEPTO,
    f.NumDepartamento AS DEPARTAMENTO,
    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    g.NumCategoria AS CATEGORIA,
    b.Fineline_nbr AS NUMFL,
    i.NumFineline AS FINELINE,
    SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_UNI_ANT_LY,
    SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_UNI_ANT_LY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS_HIST a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e ON (a.store_nbr = e.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2023-12-01' AND  DATE '2024-05-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND e.Formato IN ('SUPERCENTER')
--AND e.Det IN (3845)
--AND e.Det IN (3858,3876,3847,3863,3846)

--Las Torres
--AND e.Det IN (2034)
--AND e.Det IN (1139,2044,3114,3239)

--Lincoln
--AND e.Det IN (3720)
--AND e.Det IN (1027,1833,2676,3051,3800)

--San Isidro
AND e.Det  IN (1810)
--AND e.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND e.Det in (4547)
--AND e.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND e.Det in (1584)
--AND e.Det in (3847,1032,3504)

--Patio Santa Fe
--AND e.Det in (1770)
--AND e.Det in (1580,2466,2644)

--Lomas Toreo
--AND e.Det in (2344)
--AND e.Det in (2464,3005,3851)

--Interlomas
--AND e.Det in (2382)
--AND e-Det in (1834,3872,3877)


GROUP BY 1,2,3,4,5,6,7,8,9,10;


DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP3;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP3 AS

SELECT 

    e.Formato AS FORMATO,
    g.Tribu AS TRIBU,
    g.MEGA_SQUAD AS MEGA_SQUAD,
    g.Squad AS SQUAD,
    b.Dept_nbr AS NUMDEPTO,
    f.NumDepartamento AS DEPARTAMENTO,
    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    g.NumCategoria AS CATEGORIA,
    b.Fineline_nbr AS NUMFL,
    i.NumFineline AS FINELINE,
    SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_CON_ANT_LY,
    SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_CON_ANT_LY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS_HIST a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e ON (a.store_nbr = e.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2023-12-01' AND  DATE '2024-05-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND e.Formato IN ('SUPERCENTER')
--AND e.Det IN (3845)
--AND e.Det IN (3858,3876,3847,3863,3846)

--Las Torres
--AND e.Det IN (2034)
--AND e.Det IN (1139,2044,3114,3239)

--Lincoln
--AND e.Det IN (3720)
--AND e.Det IN (1027,1833,2676,3051,3800)

--San Isidro
--AND e.Det  IN (1810)
AND e.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND e.Det in (4547)
--AND e.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND e.Det in (1584)
--AND e.Det in (3847,1032,3504)

--Patio Santa Fe
--AND e.Det in (1770)
--AND e.Det in (1580,2466,2644)

--Lomas Toreo
--AND e.Det in (2344)
--AND e.Det in (2464,3005,3851)

--Interlomas
--AND e.Det in (2382)
--AND e-Det in (1834,3872,3877)



GROUP BY 1,2,3,4,5,6,7,8,9,10;


DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP4;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP4 AS

SELECT 

    e.Formato AS FORMATO,
    g.Tribu AS TRIBU,
    g.MEGA_SQUAD AS MEGA_SQUAD,
    g.Squad AS SQUAD,
    b.Dept_nbr AS NUMDEPTO,
    f.NumDepartamento AS DEPARTAMENTO,
    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    g.NumCategoria AS CATEGORIA,
    b.Fineline_nbr AS NUMFL,
    i.NumFineline AS FINELINE,
    SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_UNI_ANT_TY,
    SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_UNI_ANT_TY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS_HIST a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e ON (a.store_nbr = e.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2024-12-01' AND  DATE '2025-05-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND e.Formato IN ('SUPERCENTER')
--AND e.Det IN (3845)
--AND e.Det IN (3858,3876,3847,3863,3846)

--Las Torres
--AND e.Det IN (2034)
--AND e.Det IN (1139,2044,3114,3239)

--Lincoln
--AND e.Det IN (3720)
--AND e.Det IN (1027,1833,2676,3051,3800)

--San Isidro
AND e.Det  IN (1810)
--AND e.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND e.Det in (4547)
--AND e.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND e.Det in (1584)
--AND e.Det in (3847,1032,3504)

--Patio Santa Fe
--AND e.Det in (1770)
--AND e.Det in (1580,2466,2644)

--Lomas Toreo
--AND e.Det in (2344)
--AND e.Det in (2464,3005,3851)

--Interlomas
--AND e.Det in (2382)
--AND e-Det in (1834,3872,3877)

GROUP BY 1,2,3,4,5,6,7,8,9,10;


DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP5;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP5 AS

SELECT 

    e.Formato AS FORMATO,
    g.Tribu AS TRIBU,
    g.MEGA_SQUAD AS MEGA_SQUAD,
    g.Squad AS SQUAD,
    b.Dept_nbr AS NUMDEPTO,
    f.NumDepartamento AS DEPARTAMENTO,
    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    g.NumCategoria AS CATEGORIA,
    b.Fineline_nbr AS NUMFL,
    i.NumFineline AS FINELINE,
    SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_CON_ANT_TY,
    SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_CON_ANT_TY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS_HIST a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e ON (a.store_nbr = e.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2024-12-01' AND  DATE '2025-05-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND e.Formato IN ('SUPERCENTER')
--AND e.Det IN (3845)
--AND e.Det IN (3858,3876,3847,3863,3846)

--Las Torres
--AND e.Det IN (2034)
--AND e.Det IN (1139,2044,3114,3239)

--Lincoln
--AND e.Det IN (3720)
--AND e.Det IN (1027,1833,2676,3051,3800)

--San Isidro
--AND e.Det  IN (1810)
AND e.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND e.Det in (4547)
--AND e.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND e.Det in (1584)
--AND e.Det in (3847,1032,3504)

--Patio Santa Fe
--AND e.Det in (1770)
--AND e.Det in (1580,2466,2644)

--Lomas Toreo
--AND e.Det in (2344)
--AND e.Det in (2464,3005,3851)

--Interlomas
--AND e.Det in (2382)
--AND e-Det in (1834,3872,3877)

GROUP BY 1,2,3,4,5,6,7,8,9,10;


--DURANTE

DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP6;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP6 AS

SELECT 

    e.Formato AS FORMATO,
    g.Tribu AS TRIBU,
    g.MEGA_SQUAD AS MEGA_SQUAD,
    g.Squad AS SQUAD,
    b.Dept_nbr AS NUMDEPTO,
    f.NumDepartamento AS DEPARTAMENTO,
    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    g.NumCategoria AS CATEGORIA,
    b.Fineline_nbr AS NUMFL,
    i.NumFineline AS FINELINE,
    SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_UNI_DUR_LY,
    SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_UNI_DUR_LY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS_HIST a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e ON (a.store_nbr = e.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2024-06-01' AND  DATE '2024-07-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND e.Formato IN ('SUPERCENTER')
--AND e.Det IN (3845)
--AND e.Det IN (3858,3876,3847,3863,3846)

--Las Torres
--AND e.Det IN (2034)
--AND e.Det IN (1139,2044,3114,3239)

--Lincoln
--AND e.Det IN (3720)
--AND e.Det IN (1027,1833,2676,3051,3800)

--San Isidro
AND e.Det  IN (1810)
--AND e.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND e.Det in (4547)
--AND e.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND e.Det in (1584)
--AND e.Det in (3847,1032,3504)

--Patio Santa Fe
--AND e.Det in (1770)
--AND e.Det in (1580,2466,2644)

--Lomas Toreo
--AND e.Det in (2344)
--AND e.Det in (2464,3005,3851)

--Interlomas
--AND e.Det in (2382)
--AND e-Det in (1834,3872,3877)

GROUP BY 1,2,3,4,5,6,7,8,9,10;


DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP7;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP7 AS

SELECT 

    e.Formato AS FORMATO,
    g.Tribu AS TRIBU,
    g.MEGA_SQUAD AS MEGA_SQUAD,
    g.Squad AS SQUAD,
    b.Dept_nbr AS NUMDEPTO,
    f.NumDepartamento AS DEPARTAMENTO,
    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    g.NumCategoria AS CATEGORIA,
    b.Fineline_nbr AS NUMFL,
    i.NumFineline AS FINELINE,
    SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_CON_DUR_LY,
    SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_CON_DUR_LY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS_HIST a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e ON (a.store_nbr = e.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2024-06-01' AND  DATE '2024-07-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND e.Formato IN ('SUPERCENTER')
--AND e.Det IN (3845)
--AND e.Det IN (3858,3876,3847,3863,3846)

--Las Torres
--AND e.Det IN (2034)
--AND e.Det IN (1139,2044,3114,3239)

--Lincoln
--AND e.Det IN (3720)
--AND e.Det IN (1027,1833,2676,3051,3800)

--San Isidro
--AND e.Det  IN (1810)
AND e.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND e.Det in (4547)
--AND e.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND e.Det in (1584)
--AND e.Det in (3847,1032,3504)

--Patio Santa Fe
--AND e.Det in (1770)
--AND e.Det in (1580,2466,2644)

--Lomas Toreo
--AND e.Det in (2344)
--AND e.Det in (2464,3005,3851)

--Interlomas
--AND e.Det in (2382)
--AND e-Det in (1834,3872,3877)

GROUP BY 1,2,3,4,5,6,7,8,9,10;


DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP8;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP8 AS

SELECT 

    e.Formato AS FORMATO,
    g.Tribu AS TRIBU,
    g.MEGA_SQUAD AS MEGA_SQUAD,
    g.Squad AS SQUAD,
    b.Dept_nbr AS NUMDEPTO,
    f.NumDepartamento AS DEPARTAMENTO,
    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    g.NumCategoria AS CATEGORIA,
    b.Fineline_nbr AS NUMFL,
    i.NumFineline AS FINELINE,
    SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_UNI_DUR_TY,
    SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_UNI_DUR_TY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS_HIST a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e ON (a.store_nbr = e.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2025-06-01' AND  DATE '2025-07-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND e.Formato IN ('SUPERCENTER')
--AND e.Det IN (3845)
--AND e.Det IN (3858,3876,3847,3863,3846)

--Las Torres
--AND e.Det IN (2034)
--AND e.Det IN (1139,2044,3114,3239)

--Lincoln
--AND e.Det IN (3720)
--AND e.Det IN (1027,1833,2676,3051,3800)

--San Isidro
AND e.Det  IN (1810)
--AND e.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND e.Det in (4547)
--AND e.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND e.Det in (1584)
--AND e.Det in (3847,1032,3504)

--Patio Santa Fe
--AND e.Det in (1770)
--AND e.Det in (1580,2466,2644)

--Lomas Toreo
--AND e.Det in (2344)
--AND e.Det in (2464,3005,3851)

--Interlomas
--AND e.Det in (2382)
--AND e-Det in (1834,3872,3877)


GROUP BY 1,2,3,4,5,6,7,8,9,10;


DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP9;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP9 AS

SELECT 

    e.Formato AS FORMATO,
    g.Tribu AS TRIBU,
    g.MEGA_SQUAD AS MEGA_SQUAD,
    g.Squad AS SQUAD,
    b.Dept_nbr AS NUMDEPTO,
    f.NumDepartamento AS DEPARTAMENTO,
    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    g.NumCategoria AS CATEGORIA,
    b.Fineline_nbr AS NUMFL,
    i.NumFineline AS FINELINE,
    SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_CON_DUR_TY,
    SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_CON_DUR_TY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS_HIST a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e ON (a.store_nbr = e.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2025-06-01' AND  DATE '2025-07-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND e.Formato IN ('SUPERCENTER')
--AND e.Det IN (3845)
--AND e.Det IN (3858,3876,3847,3863,3846)
--Las Torres
--AND e.Det IN (2034)
--AND e.Det IN (1139,2044,3114,3239)

--Lincoln
--AND e.Det IN (3720)
--AND e.Det IN (1027,1833,2676,3051,3800)

--San Isidro
--AND e.Det  IN (1810)
AND e.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND e.Det in (4547)
--AND e.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND e.Det in (1584)
--AND e.Det in (3847,1032,3504)

--Patio Santa Fe
--AND e.Det in (1770)
--AND e.Det in (1580,2466,2644)

--Lomas Toreo
--AND e.Det in (2344)
--AND e.Det in (2464,3005,3851)

--Interlomas
--AND e.Det in (2382)
--AND e-Det in (1834,3872,3877)


GROUP BY 1,2,3,4,5,6,7,8,9,10;


--DESPUES

DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP10;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP10 AS

SELECT 

    e.Formato AS FORMATO,
    g.Tribu AS TRIBU,
    g.MEGA_SQUAD AS MEGA_SQUAD,
    g.Squad AS SQUAD,
    b.Dept_nbr AS NUMDEPTO,
    f.NumDepartamento AS DEPARTAMENTO,
    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    g.NumCategoria AS CATEGORIA,
    b.Fineline_nbr AS NUMFL,
    i.NumFineline AS FINELINE,
    SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_UNI_DES_LY,
    SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_UNI_DES_LY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS_HIST a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e ON (a.store_nbr = e.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2024-08-01' AND  DATE '2025-01-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND e.Formato IN ('SUPERCENTER')
--AND e.Det IN (3845)
--AND e.Det IN (3858,3876,3847,3863,3846)

--Las Torres
--AND e.Det IN (2034)
--AND e.Det IN (1139,2044,3114,3239)

--Lincoln
--AND e.Det IN (3720)
--AND e.Det IN (1027,1833,2676,3051,3800)

--San Isidro
AND e.Det  IN (1810)
--AND e.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND e.Det in (4547)
--AND e.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND e.Det in (1584)
--AND e.Det in (3847,1032,3504)

--Patio Santa Fe
--AND e.Det in (1770)
--AND e.Det in (1580,2466,2644)

--Lomas Toreo
--AND e.Det in (2344)
--AND e.Det in (2464,3005,3851)

--Interlomas
--AND e.Det in (2382)
--AND e-Det in (1834,3872,3877)

GROUP BY 1,2,3,4,5,6,7,8,9,10;


DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP11;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP11 AS

SELECT 

    e.Formato AS FORMATO,
    g.Tribu AS TRIBU,
    g.MEGA_SQUAD AS MEGA_SQUAD,
    g.Squad AS SQUAD,
    b.Dept_nbr AS NUMDEPTO,
    f.NumDepartamento AS DEPARTAMENTO,
    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    g.NumCategoria AS CATEGORIA,
    b.Fineline_nbr AS NUMFL,
    i.NumFineline AS FINELINE,
    SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_CON_DES_LY,
    SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_CON_DES_LY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS_HIST a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e ON (a.store_nbr = e.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2024-08-01' AND  DATE '2025-01-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND e.Formato IN ('SUPERCENTER')
--AND e.Det IN (3845)
--AND e.Det IN (3858,3876,3847,3863,3846)

--Las Torres
--AND e.Det IN (2034)
--AND e.Det IN (1139,2044,3114,3239)

--Lincoln
--AND e.Det IN (3720)
--AND e.Det IN (1027,1833,2676,3051,3800)

--San Isidro
--AND e.Det  IN (1810)
AND e.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND e.Det in (4547)
--AND e.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND e.Det in (1584)
--AND e.Det in (3847,1032,3504)

--Patio Santa Fe
--AND e.Det in (1770)
--AND e.Det in (1580,2466,2644)

--Lomas Toreo
--AND e.Det in (2344)
--AND e.Det in (2464,3005,3851)

--Interlomas
--AND e.Det in (2382)
--AND e-Det in (1834,3872,3877)

GROUP BY 1,2,3,4,5,6,7,8,9,10;


DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP12;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP12 AS

SELECT 

    e.Formato AS FORMATO,
    g.Tribu AS TRIBU,
    g.MEGA_SQUAD AS MEGA_SQUAD,
    g.Squad AS SQUAD,
    b.Dept_nbr AS NUMDEPTO,
    f.NumDepartamento AS DEPARTAMENTO,
    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    g.NumCategoria AS CATEGORIA,
    b.Fineline_nbr AS NUMFL,
    i.NumFineline AS FINELINE,
    SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_UNI_DES_TY,
    SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_UNI_DES_TY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS_HIST a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e ON (a.store_nbr = e.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2025-08-01' AND  DATE '2026-01-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND e.Formato IN ('SUPERCENTER')
--AND e.Det IN (3845)
--AND e.Det IN (3858,3876,3847,3863,3846)

--Las Torres
--AND e.Det IN (2034)
--AND e.Det IN (1139,2044,3114,3239)

--Lincoln
--AND e.Det IN (3720)
--AND e.Det IN (1027,1833,2676,3051,3800)

--San Isidro
AND e.Det  IN (1810)
--AND e.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND e.Det in (4547)
--AND e.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND e.Det in (1584)
--AND e.Det in (3847,1032,3504)

--Patio Santa Fe
--AND e.Det in (1770)
--AND e.Det in (1580,2466,2644)

--Lomas Toreo
--AND e.Det in (2344)
--AND e.Det in (2464,3005,3851)

--Interlomas
--AND e.Det in (2382)
--AND e-Det in (1834,3872,3877)

GROUP BY 1,2,3,4,5,6,7,8,9,10;


DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP13;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP13 AS

SELECT 

    e.Formato AS FORMATO,
    g.Tribu AS TRIBU,
    g.MEGA_SQUAD AS MEGA_SQUAD,
    g.Squad AS SQUAD,
    b.Dept_nbr AS NUMDEPTO,
    f.NumDepartamento AS DEPARTAMENTO,
    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    g.NumCategoria AS CATEGORIA,
    b.Fineline_nbr AS NUMFL,
    i.NumFineline AS FINELINE,
    SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_CON_DES_TY,
    SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_CON_DES_TY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS_HIST a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e ON (a.store_nbr = e.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2025-08-01' AND  DATE '2026-01-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND e.Formato IN ('SUPERCENTER')
--AND e.Det IN (3845)
--AND e.Det IN (3858,3876,3847,3863,3846)

--Las Torres
--AND e.Det IN (2034)
--AND e.Det IN (1139,2044,3114,3239)

--Lincoln
--AND e.Det IN (3720)
--AND e.Det IN (1027,1833,2676,3051,3800)

--San Isidro
--AND e.Det  IN (1810)
AND e.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND e.Det in (4547)
--AND e.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND e.Det in (1584)
--AND e.Det in (3847,1032,3504)

--Patio Santa Fe
--AND e.Det in (1770)
--AND e.Det in (1580,2466,2644)

--Lomas Toreo
--AND e.Det in (2344)
--AND e.Det in (2464,3005,3851)

--Interlomas
--AND e.Det in (2382)
--AND e-Det in (1834,3872,3877)


GROUP BY 1,2,3,4,5,6,7,8,9,10;


-- CLIENTES

-- ANTES

DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP14;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP14 AS

SELECT 
											
    g.Formato AS FORMATO,
    i.Tribu AS TRIBU,
    i.MEGA_SQUAD AS MEGA_SQUAD,
    i.Squad AS SQUAD,
    c.Dept_nbr AS NUMDEPTO,
    h.NumDepartamento AS DEPARTAMENTO,
    CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    i.NumCategoria AS CATEGORIA,
    c.Fineline_nbr AS NUMFL,
    j.NumFineline AS FINELINE,
    COUNT(DISTINCT a.store_nbr||''||a.visit_nbr)AS CLIENTES_UNI_ANT_LY

FROM wmt-edw-prod.MX_WM_MB_VM.SCAN a
INNER JOIN wmt-edw-prod.MX_WM_MB_VM.VISIT b ON (a.visit_nbr=b.visit_nbr AND a.store_nbr=b.store_nbr AND a.visit_date=b.visit_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM c ON (a.scan_id = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC d ON (c.old_nbr = d.old_nbr AND c.item_nbr = d.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY e ON (a.visit_date = e.gregorian_date AND b.visit_date = e.gregorian_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO f ON (a.store_nbr = f.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES g ON (a.store_nbr = g.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES h ON (c.dept_nbr = h.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES i ON (CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2))=i.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES j ON (c.Dept_nbr=j.NumDepto AND c.Fineline_nbr=j.NumFl)
WHERE e.gregorian_date BETWEEN DATE '2023-12-01' AND  DATE '2024-05-31'
AND d.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND g.Formato IN ('SUPERCENTER')
--AND g.Det IN (3845)
--AND g.DET IN (3858,3876,3847,3863,3846)

--Las Torres
--AND g.Det IN (2034)
--AND g.Det IN (1139,2044,3114,3239)

--Lincoln
--AND g.Det IN (3720)
--AND g.Det IN (1027,1833,2676,3051,3800)

--San Isidro
AND g.Det  IN (1810)
--AND g.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND g.Det in (4547)
--AND g.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND g.Det in (1584)
--AND g.Det in (3847,1032,3504)

--Patio Santa Fe
--AND g.Det in (1770)
--AND g.Det in (1580,2466,2644)

--Lomas Toreo
--AND g.Det in (2344)
--AND g.Det in (2464,3005,3851)

--Interlomas
--AND g.Det in (2382)
--AND g-Det in (1834,3872,3877)


GROUP BY 1,2,3,4,5,6,7,8,9,10;



DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP15;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP15 AS

SELECT 
											
    g.Formato AS FORMATO,
    i.Tribu AS TRIBU,
    i.MEGA_SQUAD AS MEGA_SQUAD,
    i.Squad AS SQUAD,
    c.Dept_nbr AS NUMDEPTO,
    h.NumDepartamento AS DEPARTAMENTO,
    CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    i.NumCategoria AS CATEGORIA,
    c.Fineline_nbr AS NUMFL,
    j.NumFineline AS FINELINE,
    COUNT(DISTINCT a.store_nbr||''||a.visit_nbr)AS CLIENTES_CON_ANT_LY

FROM wmt-edw-prod.MX_WM_MB_VM.SCAN a
INNER JOIN wmt-edw-prod.MX_WM_MB_VM.VISIT b ON (a.visit_nbr=b.visit_nbr AND a.store_nbr=b.store_nbr AND a.visit_date=b.visit_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM c ON (a.scan_id = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC d ON (c.old_nbr = d.old_nbr AND c.item_nbr = d.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY e ON (a.visit_date = e.gregorian_date AND b.visit_date = e.gregorian_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO f ON (a.store_nbr = f.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES g ON (a.store_nbr = g.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES h ON (c.dept_nbr = h.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES i ON (CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2))=i.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES j ON (c.Dept_nbr=j.NumDepto AND c.Fineline_nbr=j.NumFl)
WHERE e.gregorian_date BETWEEN DATE '2023-12-01' AND  DATE '2024-05-31'
AND d.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND g.Formato IN ('SUPERCENTER')
--AND e.Det IN (3845)
--AND g.DET IN (3858,3876,3847,3863,3846)

--Las Torres
--AND g.Det IN (2034)
--AND g.Det IN (1139,2044,3114,3239)

--Lincoln
--AND g.Det IN (3720)
--AND g.Det IN (1027,1833,2676,3051,3800)

--San Isidro
--AND g.Det  IN (1810)
AND g.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND g.Det in (4547)
--AND g.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND g.Det in (1584)
--AND g.Det in (3847,1032,3504)

--Patio Santa Fe
--AND g.Det in (1770)
--AND g.Det in (1580,2466,2644)

--Lomas Toreo
--AND g.Det in (2344)
--AND g.Det in (2464,3005,3851)

--Interlomas
--AND g.Det in (2382)
--AND g.Det in (1834,3872,3877)


GROUP BY 1,2,3,4,5,6,7,8,9,10;


DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP16;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP16 AS

SELECT 
											
    g.Formato AS FORMATO,
    i.Tribu AS TRIBU,
    i.MEGA_SQUAD AS MEGA_SQUAD,
    i.Squad AS SQUAD,
    c.Dept_nbr AS NUMDEPTO,
    h.NumDepartamento AS DEPARTAMENTO,
    CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    i.NumCategoria AS CATEGORIA,
    c.Fineline_nbr AS NUMFL,
    j.NumFineline AS FINELINE,
    COUNT(DISTINCT a.store_nbr||''||a.visit_nbr)AS CLIENTES_UNI_ANT_TY

FROM wmt-edw-prod.MX_WM_MB_VM.SCAN a
INNER JOIN wmt-edw-prod.MX_WM_MB_VM.VISIT b ON (a.visit_nbr=b.visit_nbr AND a.store_nbr=b.store_nbr AND a.visit_date=b.visit_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM c ON (a.scan_id = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC d ON (c.old_nbr = d.old_nbr AND c.item_nbr = d.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY e ON (a.visit_date = e.gregorian_date AND b.visit_date = e.gregorian_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO f ON (a.store_nbr = f.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES g ON (a.store_nbr = g.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES h ON (c.dept_nbr = h.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES i ON (CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2))=i.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES j ON (c.Dept_nbr=j.NumDepto AND c.Fineline_nbr=j.NumFl)
WHERE e.gregorian_date BETWEEN DATE '2024-12-01' AND  DATE '2025-05-31'
AND d.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND g.Formato IN ('SUPERCENTER')
--AND g.Det IN (3845)
--AND g.DET IN (3858,3876,3847,3863,3846)

--Las Torres
--AND g.Det IN (2034)
--AND g.Det IN (1139,2044,3114,3239)

--Lincoln
--AND g.Det IN (3720)
--AND g.Det IN (1027,1833,2676,3051,3800)

--San Isidro
AND g.Det  IN (1810)
--AND g.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND g.Det in (4547)
--AND g.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND g.Det in (1584)
--AND g.Det in (3847,1032,3504)

--Patio Santa Fe
--AND g.Det in (1770)
--AND g.Det in (1580,2466,2644)

--Lomas Toreo
--AND g.Det in (2344)
--AND g.Det in (2464,3005,3851)

--Interlomas
--AND g.Det in (2382)
--AND g-Det in (1834,3872,3877)


GROUP BY 1,2,3,4,5,6,7,8,9,10;


DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP17;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP17 AS

SELECT 
											
    g.Formato AS FORMATO,
    i.Tribu AS TRIBU,
    i.MEGA_SQUAD AS MEGA_SQUAD,
    i.Squad AS SQUAD,
    c.Dept_nbr AS NUMDEPTO,
    h.NumDepartamento AS DEPARTAMENTO,
    CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    i.NumCategoria AS CATEGORIA,
    c.Fineline_nbr AS NUMFL,
    j.NumFineline AS FINELINE,
    COUNT(DISTINCT a.store_nbr||''||a.visit_nbr)AS CLIENTES_CON_ANT_TY

FROM wmt-edw-prod.MX_WM_MB_VM.SCAN a
INNER JOIN wmt-edw-prod.MX_WM_MB_VM.VISIT b ON (a.visit_nbr=b.visit_nbr AND a.store_nbr=b.store_nbr AND a.visit_date=b.visit_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM c ON (a.scan_id = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC d ON (c.old_nbr = d.old_nbr AND c.item_nbr = d.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY e ON (a.visit_date = e.gregorian_date AND b.visit_date = e.gregorian_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO f ON (a.store_nbr = f.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES g ON (a.store_nbr = g.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES h ON (c.dept_nbr = h.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES i ON (CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2))=i.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES j ON (c.Dept_nbr=j.NumDepto AND c.Fineline_nbr=j.NumFl)
WHERE e.gregorian_date BETWEEN DATE '2024-12-01' AND  DATE '2025-05-31'
AND d.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND g.Formato IN ('SUPERCENTER')
--AND g.Det IN (3845)
--AND g.DET IN (3858,3876,3847,3863,3846)

--Las Torres
--AND g.Det IN (2034)
--AND g.Det IN (1139,2044,3114,3239)

--Lincoln
--AND g.Det IN (3720)
--AND g.Det IN (1027,1833,2676,3051,3800)

--San Isidro
--AND g.Det  IN (1810)
AND g.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND g.Det in (4547)
--AND g.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND g.Det in (1584)
--AND g.Det in (3847,1032,3504)

--Patio Santa Fe
--AND g.Det in (1770)
--AND g.Det in (1580,2466,2644)

--Lomas Toreo
--AND g.Det in (2344)
--AND g.Det in (2464,3005,3851)

--Interlomas
--AND g.Det in (2382)
--AND g-Det in (1834,3872,3877)


GROUP BY 1,2,3,4,5,6,7,8,9,10;


-- DURANTE

DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP18;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP18 AS

SELECT 
											
    g.Formato AS FORMATO,
    i.Tribu AS TRIBU,
    i.MEGA_SQUAD AS MEGA_SQUAD,
    i.Squad AS SQUAD,
    c.Dept_nbr AS NUMDEPTO,
    h.NumDepartamento AS DEPARTAMENTO,
    CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    i.NumCategoria AS CATEGORIA,
    c.Fineline_nbr AS NUMFL,
    j.NumFineline AS FINELINE,
    COUNT(DISTINCT a.store_nbr||''||a.visit_nbr)AS CLIENTES_UNI_DUR_LY

FROM wmt-edw-prod.MX_WM_MB_VM.SCAN a
INNER JOIN wmt-edw-prod.MX_WM_MB_VM.VISIT b ON (a.visit_nbr=b.visit_nbr AND a.store_nbr=b.store_nbr AND a.visit_date=b.visit_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM c ON (a.scan_id = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC d ON (c.old_nbr = d.old_nbr AND c.item_nbr = d.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY e ON (a.visit_date = e.gregorian_date AND b.visit_date = e.gregorian_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO f ON (a.store_nbr = f.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES g ON (a.store_nbr = g.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES h ON (c.dept_nbr = h.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES i ON (CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2))=i.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES j ON (c.Dept_nbr=j.NumDepto AND c.Fineline_nbr=j.NumFl)
WHERE e.gregorian_date BETWEEN DATE '2024-06-01' AND  DATE '2024-07-31'
AND d.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND g.Formato IN ('SUPERCENTER')
--AND g.Det IN (3845)
--AND g.DET IN (3858,3876,3847,3863,3846)

--Las Torres
--AND g.Det IN (2034)
--AND g.Det IN (1139,2044,3114,3239)

--Lincoln
--AND g.Det IN (3720)
--AND g.Det IN (1027,1833,2676,3051,3800)

--San Isidro
AND g.Det  IN (1810)
--AND g.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND g.Det in (4547)
--AND g.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND g.Det in (1584)
--AND g.Det in (3847,1032,3504)

--Patio Santa Fe
--AND g.Det in (1770)
--AND g.Det in (1580,2466,2644)

--Lomas Toreo
--AND g.Det in (2344)
--AND g.Det in (2464,3005,3851)

--Interlomas
--AND g.Det in (2382)
--AND g.Det in (1834,3872,3877)


GROUP BY 1,2,3,4,5,6,7,8,9,10;


DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP19;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP19 AS

SELECT 
											
    g.Formato AS FORMATO,
    i.Tribu AS TRIBU,
    i.MEGA_SQUAD AS MEGA_SQUAD,
    i.Squad AS SQUAD,
    c.Dept_nbr AS NUMDEPTO,
    h.NumDepartamento AS DEPARTAMENTO,
    CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    i.NumCategoria AS CATEGORIA,
    c.Fineline_nbr AS NUMFL,
    j.NumFineline AS FINELINE,
    COUNT(DISTINCT a.store_nbr||''||a.visit_nbr)AS CLIENTES_CON_DUR_LY

FROM wmt-edw-prod.MX_WM_MB_VM.SCAN a
INNER JOIN wmt-edw-prod.MX_WM_MB_VM.VISIT b ON (a.visit_nbr=b.visit_nbr AND a.store_nbr=b.store_nbr AND a.visit_date=b.visit_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM c ON (a.scan_id = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC d ON (c.old_nbr = d.old_nbr AND c.item_nbr = d.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY e ON (a.visit_date = e.gregorian_date AND b.visit_date = e.gregorian_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO f ON (a.store_nbr = f.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES g ON (a.store_nbr = g.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES h ON (c.dept_nbr = h.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES i ON (CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2))=i.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES j ON (c.Dept_nbr=j.NumDepto AND c.Fineline_nbr=j.NumFl)
WHERE e.gregorian_date BETWEEN DATE '2024-06-01' AND  DATE '2024-07-31'
AND d.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND g.Formato IN ('SUPERCENTER')
--AND g.Det IN (3845)
--AND g.DET IN (3858,3876,3847,3863,3846)

--Las Torres
--AND g.Det IN (2034)
--AND g.Det IN (1139,2044,3114,3239)

--Lincoln
--AND g.Det IN (3720)
--AND g.Det IN (1027,1833,2676,3051,3800)

--San Isidro
--AND g.Det  IN (1810)
AND g.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND g.Det in (4547)
--AND g.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND g.Det in (1584)
--AND g.Det in (3847,1032,3504)

--Patio Santa Fe
--AND g.Det in (1770)
--AND g.Det in (1580,2466,2644)

--Lomas Toreo
--AND g.Det in (2344)
--AND g.Det in (2464,3005,3851)

--Interlomas
--AND g.Det in (2382)
--AND g.Det in (1834,3872,3877)

GROUP BY 1,2,3,4,5,6,7,8,9,10;


DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP20;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP20 AS

SELECT 
											
    g.Formato AS FORMATO,
    i.Tribu AS TRIBU,
    i.MEGA_SQUAD AS MEGA_SQUAD,
    i.Squad AS SQUAD,
    c.Dept_nbr AS NUMDEPTO,
    h.NumDepartamento AS DEPARTAMENTO,
    CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    i.NumCategoria AS CATEGORIA,
    c.Fineline_nbr AS NUMFL,
    j.NumFineline AS FINELINE,
    COUNT(DISTINCT a.store_nbr||''||a.visit_nbr)AS CLIENTES_UNI_DUR_TY

FROM wmt-edw-prod.MX_WM_MB_VM.SCAN a
INNER JOIN wmt-edw-prod.MX_WM_MB_VM.VISIT b ON (a.visit_nbr=b.visit_nbr AND a.store_nbr=b.store_nbr AND a.visit_date=b.visit_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM c ON (a.scan_id = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC d ON (c.old_nbr = d.old_nbr AND c.item_nbr = d.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY e ON (a.visit_date = e.gregorian_date AND b.visit_date = e.gregorian_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO f ON (a.store_nbr = f.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES g ON (a.store_nbr = g.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES h ON (c.dept_nbr = h.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES i ON (CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2))=i.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES j ON (c.Dept_nbr=j.NumDepto AND c.Fineline_nbr=j.NumFl)
WHERE e.gregorian_date BETWEEN DATE '2025-06-01' AND  DATE '2025-07-31'
AND d.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND g.Formato IN ('SUPERCENTER')
--AND g.Det IN (3845)
--AND g.DET IN (3858,3876,3847,3863,3846)

--Las Torres
--AND g.Det IN (2034)
--AND g.Det IN (1139,2044,3114,3239)

--Lincoln
--AND g.Det IN (3720)
--AND g.Det IN (1027,1833,2676,3051,3800)

--San Isidro
AND g.Det  IN (1810)
--AND g.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND g.Det in (4547)
--AND g.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND g.Det in (1584)
--AND g.Det in (3847,1032,3504)

--Patio Santa Fe
--AND g.Det in (1770)
--AND g.Det in (1580,2466,2644)

--Lomas Toreo
--AND g.Det in (2344)
--AND g.Det in (2464,3005,3851)

--Interlomas
--AND g.Det in (2382)
--AND g.Det in (1834,3872,3877)


GROUP BY 1,2,3,4,5,6,7,8,9,10;


DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP21;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP21 AS

SELECT 
											
    g.Formato AS FORMATO,
    i.Tribu AS TRIBU,
    i.MEGA_SQUAD AS MEGA_SQUAD,
    i.Squad AS SQUAD,
    c.Dept_nbr AS NUMDEPTO,
    h.NumDepartamento AS DEPARTAMENTO,
    CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    i.NumCategoria AS CATEGORIA,
    c.Fineline_nbr AS NUMFL,
    j.NumFineline AS FINELINE,
    COUNT(DISTINCT a.store_nbr||''||a.visit_nbr)AS CLIENTES_CON_DUR_TY

FROM wmt-edw-prod.MX_WM_MB_VM.SCAN a
INNER JOIN wmt-edw-prod.MX_WM_MB_VM.VISIT b ON (a.visit_nbr=b.visit_nbr AND a.store_nbr=b.store_nbr AND a.visit_date=b.visit_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM c ON (a.scan_id = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC d ON (c.old_nbr = d.old_nbr AND c.item_nbr = d.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY e ON (a.visit_date = e.gregorian_date AND b.visit_date = e.gregorian_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO f ON (a.store_nbr = f.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES g ON (a.store_nbr = g.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES h ON (c.dept_nbr = h.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES i ON (CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2))=i.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES j ON (c.Dept_nbr=j.NumDepto AND c.Fineline_nbr=j.NumFl)
WHERE e.gregorian_date BETWEEN DATE '2025-06-01' AND  DATE '2025-07-31'
AND d.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND g.Formato IN ('SUPERCENTER')
--AND g.Det IN (3845)
--AND g.DET IN (3858,3876,3847,3863,3846)

--Las Torres
--AND g.Det IN (2034)
--AND g.Det IN (1139,2044,3114,3239)

--Lincoln
--AND g.Det IN (3720)
--AND g.Det IN (1027,1833,2676,3051,3800)

--San Isidro
--AND g.Det  IN (1810)
AND g.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND g.Det in (4547)
--AND g.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND g.Det in (1584)
--AND g.Det in (3847,1032,3504)

--Patio Santa Fe
--AND g.Det in (1770)
--AND g.Det in (1580,2466,2644)

--Lomas Toreo
--AND g.Det in (2344)
--AND g.Det in (2464,3005,3851)

--Interlomas
--AND g.Det in (2382)
--AND g.Det in (1834,3872,3877)


GROUP BY 1,2,3,4,5,6,7,8,9,10;


-- DESPUES

DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP22;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP22 AS

SELECT 
											
    g.Formato AS FORMATO,
    i.Tribu AS TRIBU,
    i.MEGA_SQUAD AS MEGA_SQUAD,
    i.Squad AS SQUAD,
    c.Dept_nbr AS NUMDEPTO,
    h.NumDepartamento AS DEPARTAMENTO,
    CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    i.NumCategoria AS CATEGORIA,
    c.Fineline_nbr AS NUMFL,
    j.NumFineline AS FINELINE,
    COUNT(DISTINCT a.store_nbr||''||a.visit_nbr)AS CLIENTES_UNI_DES_LY

FROM wmt-edw-prod.MX_WM_MB_VM.SCAN a
INNER JOIN wmt-edw-prod.MX_WM_MB_VM.VISIT b ON (a.visit_nbr=b.visit_nbr AND a.store_nbr=b.store_nbr AND a.visit_date=b.visit_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM c ON (a.scan_id = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC d ON (c.old_nbr = d.old_nbr AND c.item_nbr = d.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY e ON (a.visit_date = e.gregorian_date AND b.visit_date = e.gregorian_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO f ON (a.store_nbr = f.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES g ON (a.store_nbr = g.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES h ON (c.dept_nbr = h.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES i ON (CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2))=i.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES j ON (c.Dept_nbr=j.NumDepto AND c.Fineline_nbr=j.NumFl)
WHERE e.gregorian_date BETWEEN DATE '2024-08-01' AND  DATE '2025-01-31'
AND d.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND g.Formato IN ('SUPERCENTER')
--AND g.Det IN (3845)
--AND g.DET IN (3858,3876,3847,3863,3846)

--Las Torres
--AND g.Det IN (2034)
--AND g.Det IN (1139,2044,3114,3239)

--Lincoln
--AND g.Det IN (3720)
--AND g.Det IN (1027,1833,2676,3051,3800)

--San Isidro
AND g.Det  IN (1810)
--AND g.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND g.Det in (4547)
--AND g.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND g.Det in (1584)
--AND g.Det in (3847,1032,3504)

--Patio Santa Fe
--AND g.Det in (1770)
--AND g.Det in (1580,2466,2644)

--Lomas Toreo
--AND g.Det in (2344)
--AND g.Det in (2464,3005,3851)

--Interlomas
--AND g.Det in (2382)
--AND g.Det in (1834,3872,3877)


GROUP BY 1,2,3,4,5,6,7,8,9,10;


DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP23;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP23 AS

SELECT 
											
    g.Formato AS FORMATO,
    i.Tribu AS TRIBU,
    i.MEGA_SQUAD AS MEGA_SQUAD,
    i.Squad AS SQUAD,
    c.Dept_nbr AS NUMDEPTO,
    h.NumDepartamento AS DEPARTAMENTO,
    CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    i.NumCategoria AS CATEGORIA,
    c.Fineline_nbr AS NUMFL,
    j.NumFineline AS FINELINE,
    COUNT(DISTINCT a.store_nbr||''||a.visit_nbr)AS CLIENTES_CON_DES_LY

FROM wmt-edw-prod.MX_WM_MB_VM.SCAN a
INNER JOIN wmt-edw-prod.MX_WM_MB_VM.VISIT b ON (a.visit_nbr=b.visit_nbr AND a.store_nbr=b.store_nbr AND a.visit_date=b.visit_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM c ON (a.scan_id = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC d ON (c.old_nbr = d.old_nbr AND c.item_nbr = d.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY e ON (a.visit_date = e.gregorian_date AND b.visit_date = e.gregorian_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO f ON (a.store_nbr = f.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES g ON (a.store_nbr = g.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES h ON (c.dept_nbr = h.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES i ON (CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2))=i.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES j ON (c.Dept_nbr=j.NumDepto AND c.Fineline_nbr=j.NumFl)
WHERE e.gregorian_date BETWEEN DATE '2024-08-01' AND  DATE '2025-01-31'
AND d.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND g.Formato IN ('SUPERCENTER')
--AND g.Det IN (3845)
--AND g.DET IN (3858,3876,3847,3863,3846)

--Las Torres
--AND g.Det IN (2034)
--AND g.Det IN (1139,2044,3114,3239)

--Lincoln
--AND g.Det IN (3720)
--AND g.Det IN (1027,1833,2676,3051,3800)

--San Isidro
--AND g.Det  IN (1810)
AND g.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND g.Det in (4547)
--AND g.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND g.Det in (1584)
--AND g.Det in (3847,1032,3504)

--Patio Santa Fe
--AND g.Det in (1770)
--AND g.Det in (1580,2466,2644)

--Lomas Toreo
--AND g.Det in (2344)
--AND g.Det in (2464,3005,3851)

--Interlomas
--AND g.Det in (2382)
--AND g.Det in (1834,3872,3877)

GROUP BY 1,2,3,4,5,6,7,8,9,10;


DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP24;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP24 AS

SELECT 
											
    g.Formato AS FORMATO,
    i.Tribu AS TRIBU,
    i.MEGA_SQUAD AS MEGA_SQUAD,
    i.Squad AS SQUAD,
    c.Dept_nbr AS NUMDEPTO,
    h.NumDepartamento AS DEPARTAMENTO,
    CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    i.NumCategoria AS CATEGORIA,
    c.Fineline_nbr AS NUMFL,
    j.NumFineline AS FINELINE,
    COUNT(DISTINCT a.store_nbr||''||a.visit_nbr)AS CLIENTES_UNI_DES_TY

FROM wmt-edw-prod.MX_WM_MB_VM.SCAN a
INNER JOIN wmt-edw-prod.MX_WM_MB_VM.VISIT b ON (a.visit_nbr=b.visit_nbr AND a.store_nbr=b.store_nbr AND a.visit_date=b.visit_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM c ON (a.scan_id = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC d ON (c.old_nbr = d.old_nbr AND c.item_nbr = d.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY e ON (a.visit_date = e.gregorian_date AND b.visit_date = e.gregorian_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO f ON (a.store_nbr = f.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES g ON (a.store_nbr = g.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES h ON (c.dept_nbr = h.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES i ON (CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2))=i.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES j ON (c.Dept_nbr=j.NumDepto AND c.Fineline_nbr=j.NumFl)
WHERE e.gregorian_date BETWEEN DATE '2025-08-01' AND CURRENT_DATE
AND d.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND g.Formato IN ('SUPERCENTER')
--AND g.Det IN (3845)
--AND g.DET IN (3858,3876,3847,3863,3846)

--Las Torres
--AND g.Det IN (2034)
--AND g.Det IN (1139,2044,3114,3239)

--Lincoln
--AND g.Det IN (3720)
--AND g.Det IN (1027,1833,2676,3051,3800)

--San Isidro
AND g.Det  IN (1810)
--AND g.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND g.Det in (4547)
--AND g.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND g.Det in (1584)
--AND g.Det in (3847,1032,3504)

--Patio Santa Fe
--AND g.Det in (1770)
--AND g.Det in (1580,2466,2644)

--Lomas Toreo
--AND g.Det in (2344)
--AND g.Det in (2464,3005,3851)

--Interlomas
--AND g.Det in (2382)
--AND g.Det in (1834,3872,3877)

GROUP BY 1,2,3,4,5,6,7,8,9,10;


DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP25;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP25 AS

SELECT 
											
    g.Formato AS FORMATO,
    i.Tribu AS TRIBU,
    i.MEGA_SQUAD AS MEGA_SQUAD,
    i.Squad AS SQUAD,
    c.Dept_nbr AS NUMDEPTO,
    h.NumDepartamento AS DEPARTAMENTO,
    CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    i.NumCategoria AS CATEGORIA,
    c.Fineline_nbr AS NUMFL,
    j.NumFineline AS FINELINE,
    COUNT(DISTINCT a.store_nbr||''||a.visit_nbr)AS CLIENTES_CON_DES_TY

FROM wmt-edw-prod.MX_WM_MB_VM.SCAN a
INNER JOIN wmt-edw-prod.MX_WM_MB_VM.VISIT b ON (a.visit_nbr=b.visit_nbr AND a.store_nbr=b.store_nbr AND a.visit_date=b.visit_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM c ON (a.scan_id = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC d ON (c.old_nbr = d.old_nbr AND c.item_nbr = d.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY e ON (a.visit_date = e.gregorian_date AND b.visit_date = e.gregorian_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO f ON (a.store_nbr = f.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES g ON (a.store_nbr = g.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES h ON (c.dept_nbr = h.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES i ON (CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2))=i.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES j ON (c.Dept_nbr=j.NumDepto AND c.Fineline_nbr=j.NumFl)
WHERE e.gregorian_date BETWEEN DATE '2025-08-01' AND  CURRENT_DATE
AND d.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,33,34,35,36,38,40,46,47,53,54,55,56,58,60,69,80,81,82,83,87,88,90,91,92,93,94,95,96,97,98)
AND g.Formato IN ('SUPERCENTER')
--AND g.Det IN (3845)
--AND g.DET IN (3858,3876,3847,3863,3846)

--Las Torres
--AND g.Det IN (2034)
--AND g.Det IN (1139,2044,3114,3239)

--Lincoln
--AND g.Det IN (3720)
--AND g.Det IN (1027,1833,2676,3051,3800)

--San Isidro
--AND g.Det  IN (1810)
AND g.Det IN (1686,1512,2541,4012,4071)

--Eduardo Molina
--AND g.Det in (4547)
--AND g.Det in (2033,2079,3005,3794,3857)

--Espacio Esmeralda
--AND g.Det in (1584)
--AND g.Det in (3847,1032,3504)

--Patio Santa Fe
--AND g.Det in (1770)
--AND g.Det in (1580,2466,2644)

--Lomas Toreo
--AND g.Det in (2344)
--AND g.Det in (2464,3005,3851)

--Interlomas
--AND g.Det in (2382)
--AND g.Det in (1834,3872,3877)

GROUP BY 1,2,3,4,5,6,7,8,9,10;


-- TABLA FINAL

DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_1810;

CREATE TABLE wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_1810 AS

SELECT

    a.FORMATO,
    --'3845' AS Tienda,
    --'2034' AS Tienda,
    --'3720' AS Tienda,
    '1810' AS Tienda,
    --'4547' AS Tienda,
    --'1584' AS Tienda,
    --'1770' AS Tienda,
    --'2344' AS Tienda,
    --'2382' AS Tienda,
    a.TRIBU,
    a.MEGA_SQUAD,
    a.SQUAD,
    a.NUMDEPTO,
    a.DEPARTAMENTO,
    a.NUMCAT,
    a.CATEGORIA,
    a.NUMFL,
    a.FINELINE,
    IF(z.string_field_2 IS NULL,"RESTO CATEGORIAS",z.string_field_2) AS INICIATIVA,
    b.VENTA_PIEZAS_UNI_ANT_LY,
    b.VENTA_PESOS_UNI_ANT_LY,
    c.VENTA_PIEZAS_CON_ANT_LY,
    c.VENTA_PESOS_CON_ANT_LY,
    d.VENTA_PIEZAS_UNI_ANT_TY,
    d.VENTA_PESOS_UNI_ANT_TY,
    e.VENTA_PIEZAS_CON_ANT_TY,
    e.VENTA_PESOS_CON_ANT_TY,
    f.VENTA_PIEZAS_UNI_DUR_LY,
    f.VENTA_PESOS_UNI_DUR_LY,
    g.VENTA_PIEZAS_CON_DUR_LY,
    g.VENTA_PESOS_CON_DUR_LY,
    h.VENTA_PIEZAS_UNI_DUR_TY,
    h.VENTA_PESOS_UNI_DUR_TY,
    i.VENTA_PIEZAS_CON_DUR_TY,
    i.VENTA_PESOS_CON_DUR_TY,
    j.VENTA_PIEZAS_UNI_DES_LY,
    j.VENTA_PESOS_UNI_DES_LY,
    k.VENTA_PIEZAS_CON_DES_LY,
    k.VENTA_PESOS_CON_DES_LY,
    l.VENTA_PIEZAS_UNI_DES_TY,
    l.VENTA_PESOS_UNI_DES_TY,
    m.VENTA_PIEZAS_CON_DES_TY,
    m.VENTA_PESOS_CON_DES_TY,
    n.CLIENTES_UNI_ANT_LY,
    o.CLIENTES_CON_ANT_LY,
    p.CLIENTES_UNI_ANT_TY,
    q.CLIENTES_CON_ANT_TY,
    r.CLIENTES_UNI_DUR_LY,
    s.CLIENTES_CON_DUR_LY,
    t.CLIENTES_UNI_DUR_TY,
    u.CLIENTES_CON_DUR_TY,
    v.CLIENTES_UNI_DES_LY,
    w.CLIENTES_CON_DES_LY,
    x.CLIENTES_UNI_DES_TY,
    y.CLIENTES_CON_DES_TY

FROM wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP1 a 
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP2 b ON (a.FORMATO=b.FORMATO AND a.TRIBU=b.TRIBU AND a.MEGA_SQUAD=b.MEGA_SQUAD AND a.SQUAD=b.SQUAD AND a.NUMDEPTO=b.NUMDEPTO AND a.NUMCAT=b.NUMCAT AND a.NUMFL=b.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP3 c ON (a.FORMATO=c.FORMATO AND a.TRIBU=c.TRIBU AND a.MEGA_SQUAD=c.MEGA_SQUAD AND a.SQUAD=c.SQUAD AND a.NUMDEPTO=c.NUMDEPTO AND a.NUMCAT=c.NUMCAT AND a.NUMFL=c.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP4 d ON (a.FORMATO=d.FORMATO AND a.TRIBU=d.TRIBU AND a.MEGA_SQUAD=d.MEGA_SQUAD AND a.SQUAD=d.SQUAD AND a.NUMDEPTO=d.NUMDEPTO AND a.NUMCAT=d.NUMCAT AND a.NUMFL=d.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP5 e ON (a.FORMATO=e.FORMATO AND a.TRIBU=e.TRIBU AND a.MEGA_SQUAD=e.MEGA_SQUAD AND a.SQUAD=e.SQUAD AND a.NUMDEPTO=e.NUMDEPTO AND a.NUMCAT=e.NUMCAT AND a.NUMFL=e.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP6 f ON (a.FORMATO=f.FORMATO AND a.TRIBU=f.TRIBU AND a.MEGA_SQUAD=f.MEGA_SQUAD AND a.SQUAD=f.SQUAD AND a.NUMDEPTO=f.NUMDEPTO AND a.NUMCAT=f.NUMCAT AND a.NUMFL=f.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP7 g ON (a.FORMATO=g.FORMATO AND a.TRIBU=g.TRIBU AND a.MEGA_SQUAD=g.MEGA_SQUAD AND a.SQUAD=g.SQUAD AND a.NUMDEPTO=g.NUMDEPTO AND a.NUMCAT=g.NUMCAT AND a.NUMFL=g.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP8 h ON (a.FORMATO=h.FORMATO AND a.TRIBU=h.TRIBU AND a.MEGA_SQUAD=h.MEGA_SQUAD AND a.SQUAD=h.SQUAD AND a.NUMDEPTO=h.NUMDEPTO AND a.NUMCAT=h.NUMCAT AND a.NUMFL=h.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP9 i ON (a.FORMATO=i.FORMATO AND a.TRIBU=i.TRIBU AND a.MEGA_SQUAD=i.MEGA_SQUAD AND a.SQUAD=i.SQUAD AND a.NUMDEPTO=i.NUMDEPTO AND a.NUMCAT=i.NUMCAT AND a.NUMFL=i.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP10 j ON (a.FORMATO=j.FORMATO AND a.TRIBU=j.TRIBU AND a.MEGA_SQUAD=j.MEGA_SQUAD AND a.SQUAD=j.SQUAD AND a.NUMDEPTO=j.NUMDEPTO AND a.NUMCAT=j.NUMCAT AND a.NUMFL=j.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP11 k ON (a.FORMATO=k.FORMATO AND a.TRIBU=k.TRIBU AND a.MEGA_SQUAD=k.MEGA_SQUAD AND a.SQUAD=k.SQUAD AND a.NUMDEPTO=k.NUMDEPTO AND a.NUMCAT=k.NUMCAT AND a.NUMFL=k.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP12 l ON (a.FORMATO=l.FORMATO AND a.TRIBU=l.TRIBU AND a.MEGA_SQUAD=l.MEGA_SQUAD AND a.SQUAD=l.SQUAD AND a.NUMDEPTO=l.NUMDEPTO AND a.NUMCAT=l.NUMCAT AND a.NUMFL=l.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP13 m ON (a.FORMATO=m.FORMATO AND a.TRIBU=m.TRIBU AND a.MEGA_SQUAD=m.MEGA_SQUAD AND a.SQUAD=m.SQUAD AND a.NUMDEPTO=m.NUMDEPTO AND a.NUMCAT=m.NUMCAT AND a.NUMFL=m.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP14 n ON (a.FORMATO=n.FORMATO AND a.TRIBU=n.TRIBU AND a.MEGA_SQUAD=n.MEGA_SQUAD AND a.SQUAD=n.SQUAD AND a.NUMDEPTO=n.NUMDEPTO AND a.NUMCAT=n.NUMCAT AND a.NUMFL=n.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP15 o ON (a.FORMATO=o.FORMATO AND a.TRIBU=o.TRIBU AND a.MEGA_SQUAD=o.MEGA_SQUAD AND a.SQUAD=o.SQUAD AND a.NUMDEPTO=o.NUMDEPTO AND a.NUMCAT=o.NUMCAT AND a.NUMFL=o.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP16 p ON (a.FORMATO=p.FORMATO AND a.TRIBU=p.TRIBU AND a.MEGA_SQUAD=p.MEGA_SQUAD AND a.SQUAD=p.SQUAD AND a.NUMDEPTO=p.NUMDEPTO AND a.NUMCAT=p.NUMCAT AND a.NUMFL=p.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP17 q ON (a.FORMATO=q.FORMATO AND a.TRIBU=q.TRIBU AND a.MEGA_SQUAD=q.MEGA_SQUAD AND a.SQUAD=q.SQUAD AND a.NUMDEPTO=q.NUMDEPTO AND a.NUMCAT=q.NUMCAT AND a.NUMFL=q.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP18 r ON (a.FORMATO=r.FORMATO AND a.TRIBU=r.TRIBU AND a.MEGA_SQUAD=r.MEGA_SQUAD AND a.SQUAD=r.SQUAD AND a.NUMDEPTO=r.NUMDEPTO AND a.NUMCAT=r.NUMCAT AND a.NUMFL=r.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP19 s ON (a.FORMATO=s.FORMATO AND a.TRIBU=s.TRIBU AND a.MEGA_SQUAD=s.MEGA_SQUAD AND a.SQUAD=s.SQUAD AND a.NUMDEPTO=s.NUMDEPTO AND a.NUMCAT=s.NUMCAT AND a.NUMFL=s.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP20 t ON (a.FORMATO=t.FORMATO AND a.TRIBU=t.TRIBU AND a.MEGA_SQUAD=t.MEGA_SQUAD AND a.SQUAD=t.SQUAD AND a.NUMDEPTO=t.NUMDEPTO AND a.NUMCAT=t.NUMCAT AND a.NUMFL=t.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP21 u ON (a.FORMATO=u.FORMATO AND a.TRIBU=u.TRIBU AND a.MEGA_SQUAD=u.MEGA_SQUAD AND a.SQUAD=u.SQUAD AND a.NUMDEPTO=u.NUMDEPTO AND a.NUMCAT=u.NUMCAT AND a.NUMFL=u.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP22 v ON (a.FORMATO=v.FORMATO AND a.TRIBU=v.TRIBU AND a.MEGA_SQUAD=v.MEGA_SQUAD AND a.SQUAD=v.SQUAD AND a.NUMDEPTO=v.NUMDEPTO AND a.NUMCAT=v.NUMCAT AND a.NUMFL=v.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP23 w ON (a.FORMATO=w.FORMATO AND a.TRIBU=w.TRIBU AND a.MEGA_SQUAD=w.MEGA_SQUAD AND a.SQUAD=w.SQUAD AND a.NUMDEPTO=w.NUMDEPTO AND a.NUMCAT=w.NUMCAT AND a.NUMFL=w.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP24 x ON (a.FORMATO=x.FORMATO AND a.TRIBU=x.TRIBU AND a.MEGA_SQUAD=x.MEGA_SQUAD AND a.SQUAD=x.SQUAD AND a.NUMDEPTO=x.NUMDEPTO AND a.NUMCAT=x.NUMCAT AND a.NUMFL=x.NUMFL)
LEFT JOIN wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP25 y ON (a.FORMATO=y.FORMATO AND a.TRIBU=y.TRIBU AND a.MEGA_SQUAD=y.MEGA_SQUAD AND a.SQUAD=y.SQUAD AND a.NUMDEPTO=y.NUMDEPTO AND a.NUMCAT=y.NUMCAT AND a.NUMFL=y.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGO_INICIATIVAS_SOTF_SC z ON (a.NUMCAT=z.string_field_0);


DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP1;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP2;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP3;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP4;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP5;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP6;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP7;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP8;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP9;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP10;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP11;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP12;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP13;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP14;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP15;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP16;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP17;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP18;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP19;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP20;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP21;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP22;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP23;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP24;
DROP TABLE IF EXISTS wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_TMP25;



--SELECT * FROM wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_3845;
--SELECT * FROM wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_2034;
--SELECT * FROM wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_3720;
SELECT * FROM wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_1810;
--SELECT * FROM wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_3845;
--SELECT * FROM wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_3845;
--SELECT * FROM wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_3845;
--SELECT * FROM wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_3845;
--SELECT * FROM wmt-edw-sandbox.Black_Bird.REPORTE_VENTAS_SOFT_SC_3845;
