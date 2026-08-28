--- CATALOGO MAESTRO DE CATEGORIAS-FINELINES AUTOSERVICIOS (MTD)

DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP1;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP1 AS

SELECT

  a.FORMATO,
  a.TRIBU,
  a.SQUAD,
  a.NUMDEPTO,
  a.DEPARTAMENTO,
  a.NUMCAT,
  a.CATEGORIA,
  a.NUMFL,
  a.FINELINE,
  SUM(a.VENTA_PIEZAS_TT) AS VENTA_PIEZAS_TT,
  SUM(a.VENTA_PESOS_TT) AS VENTA_PESOS_TT,
  SUM(a.OH_QTY_TT) AS OH_QTY_TT,
  SUM(a.NUMTIENDAS_TT_INV) AS NUMTIENDAS_TT_INV

FROM (
      SELECT

        a.FORMATO,
        a.TRIBU,
        a.SQUAD,
        a.NUMDEPTO,
        a.DEPARTAMENTO,
        a.NUMCAT,
        a.CATEGORIA,
        a.NUMFL,
        a.FINELINE,
        SUM(a.VENTA_PIEZAS_TT) AS VENTA_PIEZAS_TT,
        SUM(a.VENTA_PESOS_TT) AS VENTA_PESOS_TT,
        SUM(a.OH_QTY_TT) AS OH_QTY_TT,
        SUM(a.NUMTIENDAS_TT_INV) AS NUMTIENDAS_TT_INV

      FROM (
            SELECT

              a.FORMATO,
              a.TRIBU,
              a.SQUAD,
              a.NUMDEPTO,
              a.DEPARTAMENTO,
              a.NUMCAT,
              a.CATEGORIA,
              a.NUMFL,
              a.FINELINE,
              IF(a.VENTA_PIEZAS_TT IS NULL,0,a.VENTA_PIEZAS_TT) AS VENTA_PIEZAS_TT,
              IF(a.VENTA_PESOS_TT IS NULL,0,a.VENTA_PESOS_TT) AS VENTA_PESOS_TT,
              IF(b.OH_QTY_TT IS NULL,0,b.OH_QTY_TT) AS OH_QTY_TT,
              IF(b.NUMTIENDAS_TT_INV IS NULL,0,b.NUMTIENDAS_TT_INV) AS NUMTIENDAS_TT_INV

            FROM (
                  SELECT 

                    IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
                    g.Tribu AS TRIBU,
                    g.Squad AS SQUAD,
                    b.Dept_nbr AS NUMDEPTO,
                    f.NumDepartamento AS DEPARTAMENTO,
                    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
                    g.NumCategoria AS CATEGORIA,
                    b.Fineline_nbr AS NUMFL,
                    i.NumFineline AS FINELINE,
                    SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_TT,
                    SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_TT

                  FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS a
                  INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
                  INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
                  INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
                  INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
                  INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
                  INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
                  LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
                  LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
                  WHERE h.gregorian_date BETWEEN DATE '2025-01-01' AND  CURRENT_DATE('-06')-1
                  AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
                  AND j.trait_nbr IN (9,297,11)
                  GROUP BY 1,2,3,4,5,6,7,8,9 ) a

            LEFT JOIN (
                        SELECT 

                          IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
                          g.Tribu AS TRIBU,
                          g.Squad AS SQUAD,
                          b.Dept_nbr AS NUMDEPTO,
                          f.NumDepartamento AS DEPARTAMENTO,
                          CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
                          g.NumCategoria AS CATEGORIA,
                          b.Fineline_nbr AS NUMFL,
                          i.NumFineline AS FINELINE,
                          SUM(a.on_hand_qty) + SUM(a.in_transit_qty) + SUM(a.IN_WAREHOUSE_QTY) + SUM(a.ON_ORDER_QTY) AS OH_QTY_TT,
                          COUNT(DISTINCT a.store_nbr) AS NUMTIENDAS_TT_INV

                        FROM wmt-edw-prod.MX_WM_VM.STOCK_KEEPING_UNIT a
                        INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.old_nbr) 
                        INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
                        INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
                        INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
                        INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
                        LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(Dept_nbr,"-",SUBSTRING(CAST(Fineline_nbr AS STRING),1,2))  = g.NumCat)
                        LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
                        WHERE c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
                        AND j.trait_nbr IN (9,297,11)
                        GROUP BY 1,2,3,4,5,6,7,8,9
                        HAVING OH_QTY_TT> 0) b ON (a.FORMATO=b.FORMATO AND a.TRIBU=b.TRIBU AND a.SQUAD=b.SQUAD AND a.NUMDEPTO=b.NUMDEPTO AND a.NUMCAT=b.NUMCAT AND a.NUMFL=b.NUMFL)

            UNION DISTINCT

              SELECT

                b.FORMATO,
                b.TRIBU,
                b.SQUAD,
                b.NUMDEPTO,
                b.DEPARTAMENTO,
                b.NUMCAT,
                b.CATEGORIA,
                b.NUMFL,
                b.FINELINE,
                IF(a.VENTA_PIEZAS_TT IS NULL,0,a.VENTA_PIEZAS_TT) AS VENTA_PIEZAS_TT,
                IF(a.VENTA_PESOS_TT IS NULL,0,a.VENTA_PESOS_TT) AS VENTA_PESOS_TT,
                IF(b.OH_QTY_TT IS NULL,0,b.OH_QTY_TT) AS OH_QTY_TT,
                IF(b.NUMTIENDAS_TT_INV IS NULL,0,b.NUMTIENDAS_TT_INV) AS NUMTIENDAS_TT_INV

              FROM (
                    SELECT 

                      IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
                      g.Tribu AS TRIBU,
                      g.Squad AS SQUAD,
                      b.Dept_nbr AS NUMDEPTO,
                      f.NumDepartamento AS DEPARTAMENTO,
                      CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
                      g.NumCategoria AS CATEGORIA,
                      b.Fineline_nbr AS NUMFL,
                      i.NumFineline AS FINELINE,
                      SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_TT,
                      SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_TT

                    FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS a
                    INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
                    INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
                    INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
                    INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
                    INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
                    INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
                    LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
                    LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
                    WHERE h.gregorian_date BETWEEN DATE '2025-01-01' AND  CURRENT_DATE('-06')-1
                    AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
                    AND j.trait_nbr IN (9,297,11)
                    GROUP BY 1,2,3,4,5,6,7,8,9 ) a

              RIGHT JOIN (
                          SELECT 

                            IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
                            g.Tribu AS TRIBU,
                            g.Squad AS SQUAD,
                            b.Dept_nbr AS NUMDEPTO,
                            f.NumDepartamento AS DEPARTAMENTO,
                            CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
                            g.NumCategoria AS CATEGORIA,
                            b.Fineline_nbr AS NUMFL,
                            i.NumFineline AS FINELINE,
                            SUM(a.on_hand_qty) + SUM(a.in_transit_qty) + SUM(a.IN_WAREHOUSE_QTY) + SUM(a.ON_ORDER_QTY) AS OH_QTY_TT,
                            COUNT(DISTINCT a.store_nbr) AS NUMTIENDAS_TT_INV

                          FROM wmt-edw-prod.MX_WM_VM.STOCK_KEEPING_UNIT a
                          INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.old_nbr) 
                          INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
                          INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
                          INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
                          INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
                          LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(Dept_nbr,"-",SUBSTRING(CAST(Fineline_nbr AS STRING),1,2))  = g.NumCat)
                          LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
                          WHERE c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
                          AND j.trait_nbr IN (9,297,11)
                          GROUP BY 1,2,3,4,5,6,7,8,9
                          HAVING OH_QTY_TT> 0) b ON (a.FORMATO=b.FORMATO AND a.TRIBU=b.TRIBU AND a.SQUAD=b.SQUAD AND a.NUMDEPTO=b.NUMDEPTO AND a.NUMCAT=b.NUMCAT AND a.NUMFL=b.NUMFL))a
      GROUP BY 1,2,3,4,5,6,7,8,9) a 

GROUP BY 1,2,3,4,5,6,7,8,9;


-- VENTAS MTD AUTOSERVICIOS


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP2;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP2 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_TY,
  SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_TY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE EXTRACT (YEAR FROM h.gregorian_date) IN (EXTRACT(YEAR FROM CURRENT_DATE('-06')))
AND EXTRACT (MONTH FROM h.gregorian_date) IN (EXTRACT(MONTH FROM CURRENT_DATE('-06')))
AND h.gregorian_date BETWEEN DATE_ADD (CURRENT_DATE('-06'), INTERVAL - (EXTRACT(DAY FROM (DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 DAY)))) DAY) 
AND DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 DAY)
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP3;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP3 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_LY,
  SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_LY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE EXTRACT (YEAR FROM h.gregorian_date) IN (EXTRACT (YEAR FROM (DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR))))
AND EXTRACT (MONTH FROM h.gregorian_date) IN (EXTRACT (MONTH FROM (DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR))))
AND h.gregorian_date BETWEEN DATE_ADD((DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR)), INTERVAL - (EXTRACT(DAY FROM (DATE_ADD((DATE_ADD (CAST(CURRENT_DATE('-06') AS DATE), INTERVAL -1 YEAR)), INTERVAL -2 DAY)))) DAY) 
                           AND DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR)
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


-- NETSHIPS COST AND RTL MTD AUTOSERVICIOS


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP4;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP4 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  SUM(((sat_ship_qty * sat_mult) +(sun_ship_qty * sun_mult) +(mon_ship_qty  * mon_mult) +(tue_ship_qty * tue_mult) +(wed_ship_qty * wed_mult) +(thu_ship_qty * thu_mult) +(fri_ship_qty * fri_mult))* ship_cost) AS NETSHIPS_COST_TY,
  SUM(((sat_ship_qty * sat_mult) +(sun_ship_qty * sun_mult) +(mon_ship_qty  * mon_mult) +(tue_ship_qty * tue_mult) +(wed_ship_qty * wed_mult) +(thu_ship_qty * thu_mult) +(fri_ship_qty * fri_mult))* retail_amt) AS NETSHIPS_RTL_TY,
  SUM(((sat_ship_qty * sat_mult) +(sun_ship_qty * sun_mult) +(mon_ship_qty  * mon_mult) +(tue_ship_qty * tue_mult) +(wed_ship_qty * wed_mult) +(thu_ship_qty * thu_mult) +(fri_ship_qty * fri_mult))) AS NETSHIPS_QTY_TY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_SHIP a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE EXTRACT (YEAR FROM h.gregorian_date) IN (EXTRACT(YEAR FROM CURRENT_DATE('-06')))
AND EXTRACT (MONTH FROM h.gregorian_date) IN (EXTRACT(MONTH FROM CURRENT_DATE('-06')))
AND h.gregorian_date BETWEEN DATE_ADD (CURRENT_DATE('-06'), INTERVAL - (EXTRACT(DAY FROM (DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 DAY)))) DAY) 
AND DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 DAY)
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP5;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP5 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  SUM(((sat_ship_qty * sat_mult) +(sun_ship_qty * sun_mult) +(mon_ship_qty  * mon_mult) +(tue_ship_qty * tue_mult) +(wed_ship_qty * wed_mult) +(thu_ship_qty * thu_mult) +(fri_ship_qty * fri_mult))* ship_cost) AS NETSHIPS_COST_LY,
  SUM(((sat_ship_qty * sat_mult) +(sun_ship_qty * sun_mult) +(mon_ship_qty  * mon_mult) +(tue_ship_qty * tue_mult) +(wed_ship_qty * wed_mult) +(thu_ship_qty * thu_mult) +(fri_ship_qty * fri_mult))* retail_amt) AS NETSHIPS_RTL_LY,
  SUM(((sat_ship_qty * sat_mult) +(sun_ship_qty * sun_mult) +(mon_ship_qty  * mon_mult) +(tue_ship_qty * tue_mult) +(wed_ship_qty * wed_mult) +(thu_ship_qty * thu_mult) +(fri_ship_qty * fri_mult))) AS NETSHIPS_QTY_LY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_SHIP a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE EXTRACT (YEAR FROM h.gregorian_date) IN (EXTRACT (YEAR FROM (DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR))))
AND EXTRACT (MONTH FROM h.gregorian_date) IN (EXTRACT (MONTH FROM (DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR))))
AND h.gregorian_date BETWEEN DATE_ADD((DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR)), INTERVAL - (EXTRACT(DAY FROM (DATE_ADD((DATE_ADD (CAST(CURRENT_DATE('-06') AS DATE), INTERVAL -1 YEAR)), INTERVAL -2 DAY)))) DAY) 
                           AND DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR)
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


-- MUMD RETAIL MTD AUTOSERVICIOS


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP6;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP6 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  SUM(sat_ITEM_QTY * sat_mult + sun_ITEM_QTY * sun_mult + mon_ITEM_QTY  * mon_mult + tue_ITEM_QTY * tue_mult + wed_ITEM_QTY * wed_mult + thu_ITEM_QTY * thu_mult + fri_ITEM_QTY * fri_mult) AS MUMD_QTY_TY,
  (SUM(sat_pre_tot_retl * sat_mult + sun_pre_tot_retl * sun_mult + mon_pre_tot_retl  * mon_mult + tue_pre_tot_retl * tue_mult + wed_pre_tot_retl * wed_mult + thu_pre_tot_retl * thu_mult + fri_pre_tot_retl * fri_mult)) - 
  (SUM(sat_cur_tot_retl * sat_mult +sun_cur_tot_retl * sun_mult + mon_cur_tot_retl  * mon_mult + tue_cur_tot_retl * tue_mult + wed_cur_tot_retl * wed_mult + thu_cur_tot_retl * thu_mult + fri_cur_tot_retl * fri_mult)) AS MUMD_RTL_TY
                                                      
FROM wmt-edw-prod.MX_WM_VM.SKU_TY_DLY_MUMD a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE EXTRACT (YEAR FROM h.gregorian_date) IN (EXTRACT(YEAR FROM CURRENT_DATE('-06')))
AND EXTRACT (MONTH FROM h.gregorian_date) IN (EXTRACT(MONTH FROM CURRENT_DATE('-06')))
AND h.gregorian_date BETWEEN DATE_ADD (CURRENT_DATE('-06'), INTERVAL - (EXTRACT(DAY FROM (DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 DAY)))) DAY) 
AND DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 DAY)
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP7;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP7 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  SUM(sat_ITEM_QTY * sat_mult + sun_ITEM_QTY * sun_mult + mon_ITEM_QTY  * mon_mult + tue_ITEM_QTY * tue_mult + wed_ITEM_QTY * wed_mult + thu_ITEM_QTY * thu_mult + fri_ITEM_QTY * fri_mult) AS MUMD_QTY_LY,
  (SUM(sat_pre_tot_retl * sat_mult + sun_pre_tot_retl * sun_mult + mon_pre_tot_retl  * mon_mult + tue_pre_tot_retl * tue_mult + wed_pre_tot_retl * wed_mult + thu_pre_tot_retl * thu_mult + fri_pre_tot_retl * fri_mult)) - 
  (SUM(sat_cur_tot_retl * sat_mult +sun_cur_tot_retl * sun_mult + mon_cur_tot_retl  * mon_mult + tue_cur_tot_retl * tue_mult + wed_cur_tot_retl * wed_mult + thu_cur_tot_retl * thu_mult + fri_cur_tot_retl * fri_mult)) AS MUMD_RTL_LY
                                                      
FROM wmt-edw-prod.MX_WM_VM.SKU_TY_DLY_MUMD a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE EXTRACT (YEAR FROM h.gregorian_date) IN (EXTRACT (YEAR FROM (DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR))))
AND EXTRACT (MONTH FROM h.gregorian_date) IN (EXTRACT (MONTH FROM (DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR))))
AND h.gregorian_date BETWEEN DATE_ADD((DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR)), INTERVAL - (EXTRACT(DAY FROM (DATE_ADD((DATE_ADD (CAST(CURRENT_DATE('-06') AS DATE), INTERVAL -1 YEAR)), INTERVAL -2 DAY)))) DAY) 
                           AND DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR)
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


-- MD RETAIL MTD AUTOSERVICIOS


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP8;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP8 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  (SUM(sat_pre_tot_retl * sat_mult + sun_pre_tot_retl * sun_mult + mon_pre_tot_retl  * mon_mult + tue_pre_tot_retl * tue_mult + wed_pre_tot_retl * wed_mult + thu_pre_tot_retl * thu_mult + fri_pre_tot_retl * fri_mult)) - 
  (SUM(sat_cur_tot_retl * sat_mult +sun_cur_tot_retl * sun_mult + mon_cur_tot_retl  * mon_mult + tue_cur_tot_retl * tue_mult + wed_cur_tot_retl * wed_mult + thu_cur_tot_retl * thu_mult + fri_cur_tot_retl * fri_mult)) AS MD_RTL_TY
                                                      
FROM wmt-edw-prod.MX_WM_VM.SKU_TY_DLY_MUMD a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE EXTRACT (YEAR FROM h.gregorian_date) IN (EXTRACT(YEAR FROM CURRENT_DATE('-06')))
AND EXTRACT (MONTH FROM h.gregorian_date) IN (EXTRACT(MONTH FROM CURRENT_DATE('-06')))
AND h.gregorian_date BETWEEN DATE_ADD (CURRENT_DATE('-06'), INTERVAL - (EXTRACT(DAY FROM (DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 DAY)))) DAY) 
AND DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 DAY)
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND a.event_id IN (1001,1002,1003,1004,1100,1101,1201,1202,1300,1305,1401,1402,1500,1505,1515,1516,1517,1518,1519,1521,1600,1700,1804,1805,1814)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP9;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP9 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  (SUM(sat_pre_tot_retl * sat_mult + sun_pre_tot_retl * sun_mult + mon_pre_tot_retl  * mon_mult + tue_pre_tot_retl * tue_mult + wed_pre_tot_retl * wed_mult + thu_pre_tot_retl * thu_mult + fri_pre_tot_retl * fri_mult)) - 
  (SUM(sat_cur_tot_retl * sat_mult +sun_cur_tot_retl * sun_mult + mon_cur_tot_retl  * mon_mult + tue_cur_tot_retl * tue_mult + wed_cur_tot_retl * wed_mult + thu_cur_tot_retl * thu_mult + fri_cur_tot_retl * fri_mult)) AS MD_RTL_LY
                                                      
FROM wmt-edw-prod.MX_WM_VM.SKU_TY_DLY_MUMD a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE EXTRACT (YEAR FROM h.gregorian_date) IN (EXTRACT (YEAR FROM (DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR))))
AND EXTRACT (MONTH FROM h.gregorian_date) IN (EXTRACT (MONTH FROM (DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR))))
AND h.gregorian_date BETWEEN DATE_ADD((DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR)), INTERVAL - (EXTRACT(DAY FROM (DATE_ADD((DATE_ADD (CAST(CURRENT_DATE('-06') AS DATE), INTERVAL -1 YEAR)), INTERVAL -2 DAY)))) DAY) 
                           AND DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR)
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND a.event_id IN (1001,1002,1003,1004,1100,1101,1201,1202,1300,1305,1401,1402,1500,1505,1515,1516,1517,1518,1519,1521,1600,1700,1804,1805,1814)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


-- MU RETAIL MTD AUTOSERVICIOS


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP10;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP10 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  (SUM(sat_pre_tot_retl * sat_mult + sun_pre_tot_retl * sun_mult + mon_pre_tot_retl  * mon_mult + tue_pre_tot_retl * tue_mult + wed_pre_tot_retl * wed_mult + thu_pre_tot_retl * thu_mult + fri_pre_tot_retl * fri_mult)) - 
  (SUM(sat_cur_tot_retl * sat_mult +sun_cur_tot_retl * sun_mult + mon_cur_tot_retl  * mon_mult + tue_cur_tot_retl * tue_mult + wed_cur_tot_retl * wed_mult + thu_cur_tot_retl * thu_mult + fri_cur_tot_retl * fri_mult)) AS MU_RTL_TY
                                                      
FROM wmt-edw-prod.MX_WM_VM.SKU_TY_DLY_MUMD a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE EXTRACT (YEAR FROM h.gregorian_date) IN (EXTRACT(YEAR FROM CURRENT_DATE('-06')))
AND EXTRACT (MONTH FROM h.gregorian_date) IN (EXTRACT(MONTH FROM CURRENT_DATE('-06')))
AND h.gregorian_date BETWEEN DATE_ADD (CURRENT_DATE('-06'), INTERVAL - (EXTRACT(DAY FROM (DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 DAY)))) DAY) 
AND DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 DAY)
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND a.event_id IN (1815,1816,1821,5001,5002,5003,5004,5100,5101,5201,5202,5300,5305,5401,5402,5500,5505,5515,5516,5518,5519,5600,5700,5804,5805,5816,5705,5811)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP11;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP11 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  (SUM(sat_pre_tot_retl * sat_mult + sun_pre_tot_retl * sun_mult + mon_pre_tot_retl  * mon_mult + tue_pre_tot_retl * tue_mult + wed_pre_tot_retl * wed_mult + thu_pre_tot_retl * thu_mult + fri_pre_tot_retl * fri_mult)) - 
  (SUM(sat_cur_tot_retl * sat_mult +sun_cur_tot_retl * sun_mult + mon_cur_tot_retl  * mon_mult + tue_cur_tot_retl * tue_mult + wed_cur_tot_retl * wed_mult + thu_cur_tot_retl * thu_mult + fri_cur_tot_retl * fri_mult)) AS MU_RTL_LY
                                                      
FROM wmt-edw-prod.MX_WM_VM.SKU_TY_DLY_MUMD a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE EXTRACT (YEAR FROM h.gregorian_date) IN (EXTRACT (YEAR FROM (DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR))))
AND EXTRACT (MONTH FROM h.gregorian_date) IN (EXTRACT (MONTH FROM (DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR))))
AND h.gregorian_date BETWEEN DATE_ADD((DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR)), INTERVAL - (EXTRACT(DAY FROM (DATE_ADD((DATE_ADD (CAST(CURRENT_DATE('-06') AS DATE), INTERVAL -1 YEAR)), INTERVAL -2 DAY)))) DAY) 
                           AND DATE_ADD (CURRENT_DATE('-06'), INTERVAL -1 YEAR)
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND a.event_id IN (1815,1816,1821,5001,5002,5003,5004,5100,5101,5201,5202,5300,5305,5401,5402,5500,5505,5515,5516,5518,5519,5600,5700,5804,5805,5816,5705,5811)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


-- TABLA FINAL MARGEN INICIAL Y SOSTENIDO POR FORMATO CATEGORIA-FINELINE (MTD)


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP12;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP12 AS

SELECT

  a.FORMATO,
  a.TRIBU,
  a.SQUAD,
  a.NUMDEPTO,
  a.DEPARTAMENTO,
  a.NUMCAT,
  a.CATEGORIA,
  a.NUMFL,
  a.FINELINE,
  CONCAT(EXTRACT (YEAR FROM CURRENT_DATE('-06')),"-",EXTRACT (MONTH FROM CURRENT_DATE('-06'))) AS YEAR_MONTH,
  b.VENTA_PIEZAS_TY,
  b.VENTA_PESOS_TY,
  c.VENTA_PIEZAS_LY,
  c.VENTA_PESOS_LY,
  d.NETSHIPS_COST_TY,
  d.NETSHIPS_RTL_TY,
  d.NETSHIPS_QTY_TY,
  e.NETSHIPS_COST_LY,
  e.NETSHIPS_RTL_LY,
  e.NETSHIPS_QTY_LY,
  f.MUMD_QTY_TY,
  f.MUMD_RTL_TY,
  g.MUMD_QTY_LY,
  g.MUMD_RTL_LY,
  h.MD_RTL_TY,
  i.MD_RTL_LY,
  j.MU_RTL_TY,
  k.MU_RTL_LY

FROM wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP1 a
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP2 b ON (a.FORMATO=b.FORMATO AND a.TRIBU=b.TRIBU AND a.SQUAD=b.SQUAD AND a.NUMDEPTO=b.NUMDEPTO AND a.NUMCAT=b.NUMCAT AND a.NUMFL=b.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP3 c ON (a.FORMATO=c.FORMATO AND a.TRIBU=c.TRIBU AND a.SQUAD=c.SQUAD AND a.NUMDEPTO=c.NUMDEPTO AND a.NUMCAT=c.NUMCAT AND a.NUMFL=c.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP4 d ON (a.FORMATO=d.FORMATO AND a.TRIBU=d.TRIBU AND a.SQUAD=d.SQUAD AND a.NUMDEPTO=d.NUMDEPTO AND a.NUMCAT=d.NUMCAT AND a.NUMFL=d.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP5 e ON (a.FORMATO=e.FORMATO AND a.TRIBU=e.TRIBU AND a.SQUAD=e.SQUAD AND a.NUMDEPTO=e.NUMDEPTO AND a.NUMCAT=e.NUMCAT AND a.NUMFL=e.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP6 f ON (a.FORMATO=f.FORMATO AND a.TRIBU=f.TRIBU AND a.SQUAD=f.SQUAD AND a.NUMDEPTO=f.NUMDEPTO AND a.NUMCAT=f.NUMCAT AND a.NUMFL=f.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP7 g ON (a.FORMATO=g.FORMATO AND a.TRIBU=g.TRIBU AND a.SQUAD=g.SQUAD AND a.NUMDEPTO=g.NUMDEPTO AND a.NUMCAT=g.NUMCAT AND a.NUMFL=g.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP8 h ON (a.FORMATO=h.FORMATO AND a.TRIBU=h.TRIBU AND a.SQUAD=h.SQUAD AND a.NUMDEPTO=h.NUMDEPTO AND a.NUMCAT=h.NUMCAT AND a.NUMFL=h.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP9 i ON (a.FORMATO=i.FORMATO AND a.TRIBU=i.TRIBU AND a.SQUAD=i.SQUAD AND a.NUMDEPTO=i.NUMDEPTO AND a.NUMCAT=i.NUMCAT AND a.NUMFL=i.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP10 j ON (a.FORMATO=j.FORMATO AND a.TRIBU=j.TRIBU AND a.SQUAD=j.SQUAD AND a.NUMDEPTO=j.NUMDEPTO AND a.NUMCAT=j.NUMCAT AND a.NUMFL=j.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP11 k ON (a.FORMATO=k.FORMATO AND a.TRIBU=k.TRIBU AND a.SQUAD=k.SQUAD AND a.NUMDEPTO=k.NUMDEPTO AND a.NUMCAT=k.NUMCAT AND a.NUMFL=k.NUMFL);


--- INFORMACIÓN DE ENERO

-- VENTAS ENE AUTOSERVICIOS


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP2;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP2 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_TY,
  SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_TY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2025-01-01' AND  DATE '2025-01-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP3;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP3 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_LY,
  SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_LY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2024-01-01' AND  DATE '2024-01-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


-- NETSHIPS COST AND RTL ENE AUTOSERVICIOS


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP4;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP4 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  SUM(((sat_ship_qty * sat_mult) +(sun_ship_qty * sun_mult) +(mon_ship_qty  * mon_mult) +(tue_ship_qty * tue_mult) +(wed_ship_qty * wed_mult) +(thu_ship_qty * thu_mult) +(fri_ship_qty * fri_mult))* ship_cost) AS NETSHIPS_COST_TY,
  SUM(((sat_ship_qty * sat_mult) +(sun_ship_qty * sun_mult) +(mon_ship_qty  * mon_mult) +(tue_ship_qty * tue_mult) +(wed_ship_qty * wed_mult) +(thu_ship_qty * thu_mult) +(fri_ship_qty * fri_mult))* retail_amt) AS NETSHIPS_RTL_TY,
  SUM(((sat_ship_qty * sat_mult) +(sun_ship_qty * sun_mult) +(mon_ship_qty  * mon_mult) +(tue_ship_qty * tue_mult) +(wed_ship_qty * wed_mult) +(thu_ship_qty * thu_mult) +(fri_ship_qty * fri_mult))) AS NETSHIPS_QTY_TY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_SHIP a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2025-01-01' AND  DATE '2025-01-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP5;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP5 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  SUM(((sat_ship_qty * sat_mult) +(sun_ship_qty * sun_mult) +(mon_ship_qty  * mon_mult) +(tue_ship_qty * tue_mult) +(wed_ship_qty * wed_mult) +(thu_ship_qty * thu_mult) +(fri_ship_qty * fri_mult))* ship_cost) AS NETSHIPS_COST_LY,
  SUM(((sat_ship_qty * sat_mult) +(sun_ship_qty * sun_mult) +(mon_ship_qty  * mon_mult) +(tue_ship_qty * tue_mult) +(wed_ship_qty * wed_mult) +(thu_ship_qty * thu_mult) +(fri_ship_qty * fri_mult))* retail_amt) AS NETSHIPS_RTL_LY,
  SUM(((sat_ship_qty * sat_mult) +(sun_ship_qty * sun_mult) +(mon_ship_qty  * mon_mult) +(tue_ship_qty * tue_mult) +(wed_ship_qty * wed_mult) +(thu_ship_qty * thu_mult) +(fri_ship_qty * fri_mult))) AS NETSHIPS_QTY_LY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_SHIP a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2024-01-01' AND  DATE '2024-01-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


-- MUMD RETAIL ENE AUTOSERVICIOS


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP6;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP6 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  SUM(sat_ITEM_QTY * sat_mult + sun_ITEM_QTY * sun_mult + mon_ITEM_QTY  * mon_mult + tue_ITEM_QTY * tue_mult + wed_ITEM_QTY * wed_mult + thu_ITEM_QTY * thu_mult + fri_ITEM_QTY * fri_mult) AS MUMD_QTY_TY,
  (SUM(sat_pre_tot_retl * sat_mult + sun_pre_tot_retl * sun_mult + mon_pre_tot_retl  * mon_mult + tue_pre_tot_retl * tue_mult + wed_pre_tot_retl * wed_mult + thu_pre_tot_retl * thu_mult + fri_pre_tot_retl * fri_mult)) - 
  (SUM(sat_cur_tot_retl * sat_mult +sun_cur_tot_retl * sun_mult + mon_cur_tot_retl  * mon_mult + tue_cur_tot_retl * tue_mult + wed_cur_tot_retl * wed_mult + thu_cur_tot_retl * thu_mult + fri_cur_tot_retl * fri_mult)) AS MUMD_RTL_TY
                                                      
FROM wmt-edw-prod.MX_WM_VM.SKU_TY_DLY_MUMD a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2025-01-01' AND  DATE '2025-01-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP7;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP7 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  SUM(sat_ITEM_QTY * sat_mult + sun_ITEM_QTY * sun_mult + mon_ITEM_QTY  * mon_mult + tue_ITEM_QTY * tue_mult + wed_ITEM_QTY * wed_mult + thu_ITEM_QTY * thu_mult + fri_ITEM_QTY * fri_mult) AS MUMD_QTY_LY,
  (SUM(sat_pre_tot_retl * sat_mult + sun_pre_tot_retl * sun_mult + mon_pre_tot_retl  * mon_mult + tue_pre_tot_retl * tue_mult + wed_pre_tot_retl * wed_mult + thu_pre_tot_retl * thu_mult + fri_pre_tot_retl * fri_mult)) - 
  (SUM(sat_cur_tot_retl * sat_mult +sun_cur_tot_retl * sun_mult + mon_cur_tot_retl  * mon_mult + tue_cur_tot_retl * tue_mult + wed_cur_tot_retl * wed_mult + thu_cur_tot_retl * thu_mult + fri_cur_tot_retl * fri_mult)) AS MUMD_RTL_LY
                                                      
FROM wmt-edw-prod.MX_WM_VM.SKU_TY_DLY_MUMD a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2024-01-01' AND  DATE '2024-01-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


-- MD RETAIL ENE AUTOSERVICIOS


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP8;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP8 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  (SUM(sat_pre_tot_retl * sat_mult + sun_pre_tot_retl * sun_mult + mon_pre_tot_retl  * mon_mult + tue_pre_tot_retl * tue_mult + wed_pre_tot_retl * wed_mult + thu_pre_tot_retl * thu_mult + fri_pre_tot_retl * fri_mult)) - 
  (SUM(sat_cur_tot_retl * sat_mult +sun_cur_tot_retl * sun_mult + mon_cur_tot_retl  * mon_mult + tue_cur_tot_retl * tue_mult + wed_cur_tot_retl * wed_mult + thu_cur_tot_retl * thu_mult + fri_cur_tot_retl * fri_mult)) AS MD_RTL_TY
                                                      
FROM wmt-edw-prod.MX_WM_VM.SKU_TY_DLY_MUMD a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2025-01-01' AND  DATE '2025-01-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND a.event_id IN (1001,1002,1003,1004,1100,1101,1201,1202,1300,1305,1401,1402,1500,1505,1515,1516,1517,1518,1519,1521,1600,1700,1804,1805,1814)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP9;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP9 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  (SUM(sat_pre_tot_retl * sat_mult + sun_pre_tot_retl * sun_mult + mon_pre_tot_retl  * mon_mult + tue_pre_tot_retl * tue_mult + wed_pre_tot_retl * wed_mult + thu_pre_tot_retl * thu_mult + fri_pre_tot_retl * fri_mult)) - 
  (SUM(sat_cur_tot_retl * sat_mult +sun_cur_tot_retl * sun_mult + mon_cur_tot_retl  * mon_mult + tue_cur_tot_retl * tue_mult + wed_cur_tot_retl * wed_mult + thu_cur_tot_retl * thu_mult + fri_cur_tot_retl * fri_mult)) AS MD_RTL_LY
                                                      
FROM wmt-edw-prod.MX_WM_VM.SKU_TY_DLY_MUMD a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2024-01-01' AND  DATE '2024-01-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND a.event_id IN (1001,1002,1003,1004,1100,1101,1201,1202,1300,1305,1401,1402,1500,1505,1515,1516,1517,1518,1519,1521,1600,1700,1804,1805,1814)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


-- MU RETAIL ENE AUTOSERVICIOS


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP10;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP10 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  (SUM(sat_pre_tot_retl * sat_mult + sun_pre_tot_retl * sun_mult + mon_pre_tot_retl  * mon_mult + tue_pre_tot_retl * tue_mult + wed_pre_tot_retl * wed_mult + thu_pre_tot_retl * thu_mult + fri_pre_tot_retl * fri_mult)) - 
  (SUM(sat_cur_tot_retl * sat_mult +sun_cur_tot_retl * sun_mult + mon_cur_tot_retl  * mon_mult + tue_cur_tot_retl * tue_mult + wed_cur_tot_retl * wed_mult + thu_cur_tot_retl * thu_mult + fri_cur_tot_retl * fri_mult)) AS MU_RTL_TY
                                                      
FROM wmt-edw-prod.MX_WM_VM.SKU_TY_DLY_MUMD a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2025-01-01' AND  DATE '2025-01-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND a.event_id IN (1815,1816,1821,5001,5002,5003,5004,5100,5101,5201,5202,5300,5305,5401,5402,5500,5505,5515,5516,5518,5519,5600,5700,5804,5805,5816,5705,5811)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP11;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP11 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  (SUM(sat_pre_tot_retl * sat_mult + sun_pre_tot_retl * sun_mult + mon_pre_tot_retl  * mon_mult + tue_pre_tot_retl * tue_mult + wed_pre_tot_retl * wed_mult + thu_pre_tot_retl * thu_mult + fri_pre_tot_retl * fri_mult)) - 
  (SUM(sat_cur_tot_retl * sat_mult +sun_cur_tot_retl * sun_mult + mon_cur_tot_retl  * mon_mult + tue_cur_tot_retl * tue_mult + wed_cur_tot_retl * wed_mult + thu_cur_tot_retl * thu_mult + fri_cur_tot_retl * fri_mult)) AS MU_RTL_LY
                                                      
FROM wmt-edw-prod.MX_WM_VM.SKU_TY_DLY_MUMD a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2024-01-01' AND  DATE '2024-01-31'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND a.event_id IN (1815,1816,1821,5001,5002,5003,5004,5100,5101,5201,5202,5300,5305,5401,5402,5500,5505,5515,5516,5518,5519,5600,5700,5804,5805,5816,5705,5811)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


-- TABLA FINAL MARGEN INICIAL Y SOSTENIDO POR FORMATO CATEGORIA-FINELINE (ENE)


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP13;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP13 AS

SELECT

  a.FORMATO,
  a.TRIBU,
  a.SQUAD,
  a.NUMDEPTO,
  a.DEPARTAMENTO,
  a.NUMCAT,
  a.CATEGORIA,
  a.NUMFL,
  a.FINELINE,
  CONCAT(EXTRACT (YEAR FROM CURRENT_DATE('-06')),"-",EXTRACT (MONTH FROM CURRENT_DATE('-06'))-2) AS YEAR_MONTH,
  b.VENTA_PIEZAS_TY,
  b.VENTA_PESOS_TY,
  c.VENTA_PIEZAS_LY,
  c.VENTA_PESOS_LY,
  d.NETSHIPS_COST_TY,
  d.NETSHIPS_RTL_TY,
  d.NETSHIPS_QTY_TY,
  e.NETSHIPS_COST_LY,
  e.NETSHIPS_RTL_LY,
  e.NETSHIPS_QTY_LY,
  f.MUMD_QTY_TY,
  f.MUMD_RTL_TY,
  g.MUMD_QTY_LY,
  g.MUMD_RTL_LY,
  h.MD_RTL_TY,
  i.MD_RTL_LY,
  j.MU_RTL_TY,
  k.MU_RTL_LY

FROM wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP1 a
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP2 b ON (a.FORMATO=b.FORMATO AND a.TRIBU=b.TRIBU AND a.SQUAD=b.SQUAD AND a.NUMDEPTO=b.NUMDEPTO AND a.NUMCAT=b.NUMCAT AND a.NUMFL=b.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP3 c ON (a.FORMATO=c.FORMATO AND a.TRIBU=c.TRIBU AND a.SQUAD=c.SQUAD AND a.NUMDEPTO=c.NUMDEPTO AND a.NUMCAT=c.NUMCAT AND a.NUMFL=c.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP4 d ON (a.FORMATO=d.FORMATO AND a.TRIBU=d.TRIBU AND a.SQUAD=d.SQUAD AND a.NUMDEPTO=d.NUMDEPTO AND a.NUMCAT=d.NUMCAT AND a.NUMFL=d.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP5 e ON (a.FORMATO=e.FORMATO AND a.TRIBU=e.TRIBU AND a.SQUAD=e.SQUAD AND a.NUMDEPTO=e.NUMDEPTO AND a.NUMCAT=e.NUMCAT AND a.NUMFL=e.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP6 f ON (a.FORMATO=f.FORMATO AND a.TRIBU=f.TRIBU AND a.SQUAD=f.SQUAD AND a.NUMDEPTO=f.NUMDEPTO AND a.NUMCAT=f.NUMCAT AND a.NUMFL=f.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP7 g ON (a.FORMATO=g.FORMATO AND a.TRIBU=g.TRIBU AND a.SQUAD=g.SQUAD AND a.NUMDEPTO=g.NUMDEPTO AND a.NUMCAT=g.NUMCAT AND a.NUMFL=g.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP8 h ON (a.FORMATO=h.FORMATO AND a.TRIBU=h.TRIBU AND a.SQUAD=h.SQUAD AND a.NUMDEPTO=h.NUMDEPTO AND a.NUMCAT=h.NUMCAT AND a.NUMFL=h.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP9 i ON (a.FORMATO=i.FORMATO AND a.TRIBU=i.TRIBU AND a.SQUAD=i.SQUAD AND a.NUMDEPTO=i.NUMDEPTO AND a.NUMCAT=i.NUMCAT AND a.NUMFL=i.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP10 j ON (a.FORMATO=j.FORMATO AND a.TRIBU=j.TRIBU AND a.SQUAD=j.SQUAD AND a.NUMDEPTO=j.NUMDEPTO AND a.NUMCAT=j.NUMCAT AND a.NUMFL=j.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP11 k ON (a.FORMATO=k.FORMATO AND a.TRIBU=k.TRIBU AND a.SQUAD=k.SQUAD AND a.NUMDEPTO=k.NUMDEPTO AND a.NUMCAT=k.NUMCAT AND a.NUMFL=k.NUMFL);


--- INFORMACIÓN DE FEBRERO

-- VENTAS FEB AUTOSERVICIOS


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP2;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP2 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_TY,
  SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_TY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2025-02-01' AND  DATE '2025-02-28'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP3;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP3 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  SUM(a.sat_qty * h.sat_mult + a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult + a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) AS VENTA_PIEZAS_LY,
  SUM((a.sat_qty * h.sat_mult +a.sun_qty * h.sun_mult +a.mon_qty * h.mon_mult + a.tue_qty * h.tue_mult +a.wed_qty * h.wed_mult + a.thu_qty * h.thu_mult + a.fri_qty * h.fri_mult) * a.sell_price) AS VENTA_PESOS_LY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2024-02-01' AND  DATE '2024-02-29'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


-- NETSHIPS COST AND RTL FEB AUTOSERVICIOS


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP4;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP4 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  SUM(((sat_ship_qty * sat_mult) +(sun_ship_qty * sun_mult) +(mon_ship_qty  * mon_mult) +(tue_ship_qty * tue_mult) +(wed_ship_qty * wed_mult) +(thu_ship_qty * thu_mult) +(fri_ship_qty * fri_mult))* ship_cost) AS NETSHIPS_COST_TY,
  SUM(((sat_ship_qty * sat_mult) +(sun_ship_qty * sun_mult) +(mon_ship_qty  * mon_mult) +(tue_ship_qty * tue_mult) +(wed_ship_qty * wed_mult) +(thu_ship_qty * thu_mult) +(fri_ship_qty * fri_mult))* retail_amt) AS NETSHIPS_RTL_TY,
  SUM(((sat_ship_qty * sat_mult) +(sun_ship_qty * sun_mult) +(mon_ship_qty  * mon_mult) +(tue_ship_qty * tue_mult) +(wed_ship_qty * wed_mult) +(thu_ship_qty * thu_mult) +(fri_ship_qty * fri_mult))) AS NETSHIPS_QTY_TY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_SHIP a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2025-02-01' AND  DATE '2025-02-28'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP5;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP5 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  SUM(((sat_ship_qty * sat_mult) +(sun_ship_qty * sun_mult) +(mon_ship_qty  * mon_mult) +(tue_ship_qty * tue_mult) +(wed_ship_qty * wed_mult) +(thu_ship_qty * thu_mult) +(fri_ship_qty * fri_mult))* ship_cost) AS NETSHIPS_COST_LY,
  SUM(((sat_ship_qty * sat_mult) +(sun_ship_qty * sun_mult) +(mon_ship_qty  * mon_mult) +(tue_ship_qty * tue_mult) +(wed_ship_qty * wed_mult) +(thu_ship_qty * thu_mult) +(fri_ship_qty * fri_mult))* retail_amt) AS NETSHIPS_RTL_LY,
  SUM(((sat_ship_qty * sat_mult) +(sun_ship_qty * sun_mult) +(mon_ship_qty  * mon_mult) +(tue_ship_qty * tue_mult) +(wed_ship_qty * wed_mult) +(thu_ship_qty * thu_mult) +(fri_ship_qty * fri_mult))) AS NETSHIPS_QTY_LY

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_SHIP a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2024-02-01' AND  DATE '2024-02-29'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


-- MUMD RETAIL FEB AUTOSERVICIOS


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP6;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP6 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  SUM(sat_ITEM_QTY * sat_mult + sun_ITEM_QTY * sun_mult + mon_ITEM_QTY  * mon_mult + tue_ITEM_QTY * tue_mult + wed_ITEM_QTY * wed_mult + thu_ITEM_QTY * thu_mult + fri_ITEM_QTY * fri_mult) AS MUMD_QTY_TY,
  (SUM(sat_pre_tot_retl * sat_mult + sun_pre_tot_retl * sun_mult + mon_pre_tot_retl  * mon_mult + tue_pre_tot_retl * tue_mult + wed_pre_tot_retl * wed_mult + thu_pre_tot_retl * thu_mult + fri_pre_tot_retl * fri_mult)) - 
  (SUM(sat_cur_tot_retl * sat_mult +sun_cur_tot_retl * sun_mult + mon_cur_tot_retl  * mon_mult + tue_cur_tot_retl * tue_mult + wed_cur_tot_retl * wed_mult + thu_cur_tot_retl * thu_mult + fri_cur_tot_retl * fri_mult)) AS MUMD_RTL_TY
                                                      
FROM wmt-edw-prod.MX_WM_VM.SKU_TY_DLY_MUMD a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2025-02-01' AND  DATE '2025-02-28'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP7;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP7 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  SUM(sat_ITEM_QTY * sat_mult + sun_ITEM_QTY * sun_mult + mon_ITEM_QTY  * mon_mult + tue_ITEM_QTY * tue_mult + wed_ITEM_QTY * wed_mult + thu_ITEM_QTY * thu_mult + fri_ITEM_QTY * fri_mult) AS MUMD_QTY_LY,
  (SUM(sat_pre_tot_retl * sat_mult + sun_pre_tot_retl * sun_mult + mon_pre_tot_retl  * mon_mult + tue_pre_tot_retl * tue_mult + wed_pre_tot_retl * wed_mult + thu_pre_tot_retl * thu_mult + fri_pre_tot_retl * fri_mult)) - 
  (SUM(sat_cur_tot_retl * sat_mult +sun_cur_tot_retl * sun_mult + mon_cur_tot_retl  * mon_mult + tue_cur_tot_retl * tue_mult + wed_cur_tot_retl * wed_mult + thu_cur_tot_retl * thu_mult + fri_cur_tot_retl * fri_mult)) AS MUMD_RTL_LY
                                                      
FROM wmt-edw-prod.MX_WM_VM.SKU_TY_DLY_MUMD a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2024-02-01' AND  DATE '2024-02-29'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


-- MD RETAIL FEB AUTOSERVICIOS


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP8;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP8 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  (SUM(sat_pre_tot_retl * sat_mult + sun_pre_tot_retl * sun_mult + mon_pre_tot_retl  * mon_mult + tue_pre_tot_retl * tue_mult + wed_pre_tot_retl * wed_mult + thu_pre_tot_retl * thu_mult + fri_pre_tot_retl * fri_mult)) - 
  (SUM(sat_cur_tot_retl * sat_mult +sun_cur_tot_retl * sun_mult + mon_cur_tot_retl  * mon_mult + tue_cur_tot_retl * tue_mult + wed_cur_tot_retl * wed_mult + thu_cur_tot_retl * thu_mult + fri_cur_tot_retl * fri_mult)) AS MD_RTL_TY
                                                      
FROM wmt-edw-prod.MX_WM_VM.SKU_TY_DLY_MUMD a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2025-02-01' AND  DATE '2025-02-28'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND a.event_id IN (1001,1002,1003,1004,1100,1101,1201,1202,1300,1305,1401,1402,1500,1505,1515,1516,1517,1518,1519,1521,1600,1700,1804,1805,1814)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP9;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP9 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  (SUM(sat_pre_tot_retl * sat_mult + sun_pre_tot_retl * sun_mult + mon_pre_tot_retl  * mon_mult + tue_pre_tot_retl * tue_mult + wed_pre_tot_retl * wed_mult + thu_pre_tot_retl * thu_mult + fri_pre_tot_retl * fri_mult)) - 
  (SUM(sat_cur_tot_retl * sat_mult +sun_cur_tot_retl * sun_mult + mon_cur_tot_retl  * mon_mult + tue_cur_tot_retl * tue_mult + wed_cur_tot_retl * wed_mult + thu_cur_tot_retl * thu_mult + fri_cur_tot_retl * fri_mult)) AS MD_RTL_LY
                                                      
FROM wmt-edw-prod.MX_WM_VM.SKU_TY_DLY_MUMD a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2024-02-01' AND  DATE '2024-02-29'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND a.event_id IN (1001,1002,1003,1004,1100,1101,1201,1202,1300,1305,1401,1402,1500,1505,1515,1516,1517,1518,1519,1521,1600,1700,1804,1805,1814)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


-- MU RETAIL FEB AUTOSERVICIOS


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP10;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP10 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  (SUM(sat_pre_tot_retl * sat_mult + sun_pre_tot_retl * sun_mult + mon_pre_tot_retl  * mon_mult + tue_pre_tot_retl * tue_mult + wed_pre_tot_retl * wed_mult + thu_pre_tot_retl * thu_mult + fri_pre_tot_retl * fri_mult)) - 
  (SUM(sat_cur_tot_retl * sat_mult +sun_cur_tot_retl * sun_mult + mon_cur_tot_retl  * mon_mult + tue_cur_tot_retl * tue_mult + wed_cur_tot_retl * wed_mult + thu_cur_tot_retl * thu_mult + fri_cur_tot_retl * fri_mult)) AS MU_RTL_TY
                                                      
FROM wmt-edw-prod.MX_WM_VM.SKU_TY_DLY_MUMD a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2025-02-01' AND  DATE '2025-02-28'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND a.event_id IN (1815,1816,1821,5001,5002,5003,5004,5100,5101,5201,5202,5300,5305,5401,5402,5500,5505,5515,5516,5518,5519,5600,5700,5804,5805,5816,5705,5811)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP11;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP11 AS

SELECT 

  IF(j.trait_nbr IN (9), 'BODEGA AURRERA', IF(j.trait_nbr IN (297), 'SUPERCENTER', IF(j.trait_nbr IN (11), 'WALMART EXPRESS','OTRO'))) AS FORMATO,
  g.Tribu AS TRIBU,
  g.Squad AS SQUAD,
  b.Dept_nbr AS NUMDEPTO,
  f.NumDepartamento AS DEPARTAMENTO,
  CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
  g.NumCategoria AS CATEGORIA,
  b.Fineline_nbr AS NUMFL,
  i.NumFineline AS FINELINE,
  (SUM(sat_pre_tot_retl * sat_mult + sun_pre_tot_retl * sun_mult + mon_pre_tot_retl  * mon_mult + tue_pre_tot_retl * tue_mult + wed_pre_tot_retl * wed_mult + thu_pre_tot_retl * thu_mult + fri_pre_tot_retl * fri_mult)) - 
  (SUM(sat_cur_tot_retl * sat_mult +sun_cur_tot_retl * sun_mult + mon_cur_tot_retl  * mon_mult + tue_cur_tot_retl * tue_mult + wed_cur_tot_retl * wed_mult + thu_cur_tot_retl * thu_mult + fri_cur_tot_retl * fri_mult)) AS MU_RTL_LY
                                                      
FROM wmt-edw-prod.MX_WM_VM.SKU_TY_DLY_MUMD a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY h ON (a.wm_yr_wk = h.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE h.gregorian_date BETWEEN DATE '2024-02-01' AND  DATE '2024-02-29'
AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND a.event_id IN (1815,1816,1821,5001,5002,5003,5004,5100,5101,5201,5202,5300,5305,5401,5402,5500,5505,5515,5516,5518,5519,5600,5700,5804,5805,5816,5705,5811)
AND j.trait_nbr IN (9,297,11)
GROUP BY 1,2,3,4,5,6,7,8,9;


-- TABLA FINAL MARGEN INICIAL Y SOSTENIDO POR FORMATO CATEGORIA-FINELINE (FEB)


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP14;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP14 AS

SELECT

  a.FORMATO,
  a.TRIBU,
  a.SQUAD,
  a.NUMDEPTO,
  a.DEPARTAMENTO,
  a.NUMCAT,
  a.CATEGORIA,
  a.NUMFL,
  a.FINELINE,
  CONCAT(EXTRACT (YEAR FROM CURRENT_DATE('-06')),"-",EXTRACT (MONTH FROM CURRENT_DATE('-06'))-1) AS YEAR_MONTH,
  b.VENTA_PIEZAS_TY,
  b.VENTA_PESOS_TY,
  c.VENTA_PIEZAS_LY,
  c.VENTA_PESOS_LY,
  d.NETSHIPS_COST_TY,
  d.NETSHIPS_RTL_TY,
  d.NETSHIPS_QTY_TY,
  e.NETSHIPS_COST_LY,
  e.NETSHIPS_RTL_LY,
  e.NETSHIPS_QTY_LY,
  f.MUMD_QTY_TY,
  f.MUMD_RTL_TY,
  g.MUMD_QTY_LY,
  g.MUMD_RTL_LY,
  h.MD_RTL_TY,
  i.MD_RTL_LY,
  j.MU_RTL_TY,
  k.MU_RTL_LY

FROM wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP1 a
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP2 b ON (a.FORMATO=b.FORMATO AND a.TRIBU=b.TRIBU AND a.SQUAD=b.SQUAD AND a.NUMDEPTO=b.NUMDEPTO AND a.NUMCAT=b.NUMCAT AND a.NUMFL=b.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP3 c ON (a.FORMATO=c.FORMATO AND a.TRIBU=c.TRIBU AND a.SQUAD=c.SQUAD AND a.NUMDEPTO=c.NUMDEPTO AND a.NUMCAT=c.NUMCAT AND a.NUMFL=c.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP4 d ON (a.FORMATO=d.FORMATO AND a.TRIBU=d.TRIBU AND a.SQUAD=d.SQUAD AND a.NUMDEPTO=d.NUMDEPTO AND a.NUMCAT=d.NUMCAT AND a.NUMFL=d.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP5 e ON (a.FORMATO=e.FORMATO AND a.TRIBU=e.TRIBU AND a.SQUAD=e.SQUAD AND a.NUMDEPTO=e.NUMDEPTO AND a.NUMCAT=e.NUMCAT AND a.NUMFL=e.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP6 f ON (a.FORMATO=f.FORMATO AND a.TRIBU=f.TRIBU AND a.SQUAD=f.SQUAD AND a.NUMDEPTO=f.NUMDEPTO AND a.NUMCAT=f.NUMCAT AND a.NUMFL=f.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP7 g ON (a.FORMATO=g.FORMATO AND a.TRIBU=g.TRIBU AND a.SQUAD=g.SQUAD AND a.NUMDEPTO=g.NUMDEPTO AND a.NUMCAT=g.NUMCAT AND a.NUMFL=g.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP8 h ON (a.FORMATO=h.FORMATO AND a.TRIBU=h.TRIBU AND a.SQUAD=h.SQUAD AND a.NUMDEPTO=h.NUMDEPTO AND a.NUMCAT=h.NUMCAT AND a.NUMFL=h.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP9 i ON (a.FORMATO=i.FORMATO AND a.TRIBU=i.TRIBU AND a.SQUAD=i.SQUAD AND a.NUMDEPTO=i.NUMDEPTO AND a.NUMCAT=i.NUMCAT AND a.NUMFL=i.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP10 j ON (a.FORMATO=j.FORMATO AND a.TRIBU=j.TRIBU AND a.SQUAD=j.SQUAD AND a.NUMDEPTO=j.NUMDEPTO AND a.NUMCAT=j.NUMCAT AND a.NUMFL=j.NUMFL)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP11 k ON (a.FORMATO=k.FORMATO AND a.TRIBU=k.TRIBU AND a.SQUAD=k.SQUAD AND a.NUMDEPTO=k.NUMDEPTO AND a.NUMCAT=k.NUMCAT AND a.NUMFL=k.NUMFL);


-- TABLE FINAL YTD 


DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO;

CREATE TABLE wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO AS

SELECT * FROM wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP12
UNION ALL
SELECT * FROM wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP13
UNION ALL
SELECT * FROM wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP14;




DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP1;
DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP2;
DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP3;
DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP4;
DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP5;
DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP6;
DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP7;
DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP8;
DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP9;
DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP10;
DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP11;
DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP12;
DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP13;
DROP TABLE IF EXISTS wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO_TMP14;



--SELECT * FROM wmt-edw-sandbox.WM_AD_HOC_MX.MARGEN_INICIAL_SOSTENIDO_AUTOSERVICIO
--WHERE TRIBU NOT IN ('','PERECEDEROS');