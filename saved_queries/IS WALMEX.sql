SELECT

  a.TRIBU,
  a.SQUAD,
  a.NUMDEPTO,
  a.DEPARTAMENTO,
  a.NUMCAT,
  a.CATEGORIA,
  a.NUMFL,
  a.FINELINE,
  a.UPC,
  a.SIGNING_DESC,
  a.STATUS,
  a.TYPE,
  SUM(a.COMBINACIONES) AS COMBINACIONES_WE,
  SUM(a.FALTANTES_OH) AS FALTANTES_OH_WE, 
  SUM(a.FALTANTES_IT) AS FALTANTES_IT_WE, 
  SUM(a.FALTANTES_IW) AS FALTANTES_IW_WE, 
  SUM(a.FALTANTES_IO) AS FALTANTES_IO_WE,
  SUM(a.PACKS_ORD) AS PACKS_ORD_WE,
  SUM(a.PACKS_REC) AS PACKS_REC_WE

FROM (
      SELECT

        a.DET,
        a.TRIBU,
        a.SQUAD,
        a.NUMDEPTO,
        a.DEPARTAMENTO,
        a.NUMCAT,
        a.CATEGORIA,
        a.NUMFL,
        a.FINELINE,
        a.UPC,
        a.ITEM_NBR,
        a.ITEM_DESC1,
        a.ITEM_DESC2,
        a.SIGNING_DESC,
        a.STATUS,
        a.TYPE,
        SUM(a.COMBINACIONES) AS COMBINACIONES,
        SUM(a.FALTANTES_OH) AS FALTANTES_OH, 
        SUM(a.FALTANTES_IT) AS FALTANTES_IT, 
        SUM(a.FALTANTES_IW) AS FALTANTES_IW, 
        SUM(a.FALTANTES_IO) AS FALTANTES_IO,
        SUM(a.OH_QTY) AS OH_QTY,
        SUM(a.IT_QTY) AS IT_QTY,
        SUM(a.IW_QTY) AS IW_QTY,
        SUM(a.IO_QTY) AS IO_QTY,
        SUM(a.PACKS_ORD) AS PACKS_ORD,
        SUM(a.PACKS_REC) AS PACKS_REC

      FROM (
            SELECT

              a.DET,
              a.TRIBU,
              a.SQUAD,
              a.NUMDEPTO,
              a.DEPARTAMENTO,
              a.NUMCAT,
              a.CATEGORIA,
              a.NUMFL,
              a.FINELINE,
              a.UPC,
              a.ITEM_NBR,
              a.ITEM_DESC1,
              a.ITEM_DESC2,
              a.SIGNING_DESC,
              a.STATUS,
              a.TYPE,
              a.COMBINACIONES,
              a.SALES_FCST,
              IF(a.OH_QTY < a.SALES_FCST,1,0) AS FALTANTES_OH, 
              IF(a.OH_IT_QTY < (a.SALES_FCST*3),1,0) AS FALTANTES_IT, 
              IF(a.OH_IT_IW_QTY < (a.SALES_FCST*5),1,0) AS FALTANTES_IW, 
              IF(a.OH_IT_IW_IO_QTY < ( a.SALES_FCST*7),1,0) AS FALTANTES_IO,
              a.OH_QTY,
              a.IT_QTY,
              a.IW_QTY,
              a.IO_QTY,
              a.PACKS_ORD,
              a.PACKS_REC

            FROM (
                  SELECT

                    a.DET,
                    a.TRIBU,
                    a.SQUAD,
                    a.NUMDEPTO,
                    a.DEPARTAMENTO,
                    a.NUMCAT,
                    a.CATEGORIA,
                    a.NUMFL,
                    a.FINELINE,
                    a.UPC,
                    a.ITEM_NBR,
                    a.ITEM_DESC1,
                    a.ITEM_DESC2,
                    a.SIGNING_DESC,
                    a.STATUS,
                    a.TYPE,
                    a.COMBINACIONES,
                    IF(a.SALES_FCST=0,a.INFO_FCST,a.SALES_FCST) AS SALES_FCST,
                    a.OH_QTY,
                    a.IT_QTY,
                    a.IW_QTY,
                    a.IO_QTY,
                    a.OH_IT_QTY,
                    a.OH_IT_IW_QTY,
                    a.OH_IT_IW_IO_QTY,
                    a.PACKS_ORD,
                    a.PACKS_REC

                  FROM (
                        SELECT

                          a.DET,
                          a.TRIBU,
                          a.SQUAD,
                          a.NUMDEPTO,
                          a.DEPARTAMENTO,
                          a.NUMCAT,
                          a.CATEGORIA,
                          a.NUMFL,
                          a.FINELINE,
                          a.UPC,
                          a.ITEM_NBR,
                          a.ITEM_DESC1,
                          a.ITEM_DESC2,
                          a.SIGNING_DESC,
                          a.STATUS,
                          a.TYPE,
                          1 AS COMBINACIONES,
                          IF(b.SALES_FCST IS NULL,0,b.SALES_FCST) AS SALES_FCST,
                          IF(c.OH_QTY IS NULL,0,c.OH_QTY) AS OH_QTY,
                          IF(c.IT_QTY IS NULL,0,c.IT_QTY) AS IT_QTY,
                          IF(c.IW_QTY IS NULL,0,c.IW_QTY) AS IW_QTY,
                          IF(c.IO_QTY IS NULL,0,c.IO_QTY) AS IO_QTY,
                          IF(c.OH_IT_QTY IS NULL,0,c.OH_IT_QTY) AS OH_IT_QTY,
                          IF(c.OH_IT_IW_QTY IS NULL,0,c.OH_IT_IW_QTY) AS OH_IT_IW_QTY,
                          IF(c.OH_IT_IW_IO_QTY IS NULL,0,c.OH_IT_IW_IO_QTY) AS OH_IT_IW_IO_QTY,
                          IF(d.INFO_FCST IS NULL,0,d.INFO_FCST) AS INFO_FCST,
                          IF(e.PACKS_ORD IS NULL,0,e.PACKS_ORD) AS PACKS_ORD,
                          IF(e.PACKS_REC IS NULL,0,e.PACKS_REC) AS PACKS_REC

                        FROM (
                              SELECT

                                a.DET,
                                a.TRIBU,
                                a.SQUAD,
                                a.NUMDEPTO,
                                a.DEPARTAMENTO,
                                a.NUMCAT,
                                a.CATEGORIA,
                                a.NUMFL,
                                a.FINELINE,
                                a.UPC,
                                a.ITEM_NBR,
                                a.ITEM_DESC1,
                                a.ITEM_DESC2,
                                a.SIGNING_DESC,
                                a.STATUS,
                                a.TYPE

                              FROM (
                                    SELECT

                                      a.store_nbr AS DET,
                                      g.Tribu AS TRIBU,
                                      g.Squad AS SQUAD,
                                      b.Dept_nbr AS NUMDEPTO,
                                      f.NumDepartamento AS DEPARTAMENTO,
                                      CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
                                      g.NumCategoria AS CATEGORIA,
                                      b.Fineline_nbr AS NUMFL,
                                      h.NumFineline AS FINELINE,
                                      b.upc_nbr AS UPC,
                                      b.old_nbr AS ITEM_NBR,
                                      b.item1_desc AS ITEM_DESC1,
                                      b.item2_desc AS ITEM_DESC2,
                                      b.signing_desc AS SIGNING_DESC,
                                      b.item_status_code AS STATUS,
                                      c.type_code AS TYPE,

                                    FROM wmt-edw-prod.MX_WM_VM.ITEM b 
                                    INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON ( b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr)
                                    INNER JOIN wmt-edw-prod.MX_WM_VM.INFOREM_MANAGED_SKU a ON (b.item_nbr = a.item_nbr)
                                    INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr)
                                    INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
                                    INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
                                    INNER JOIN wmt-edw-prod.MX_WM_REPL_VM.GRS_VENDOR_AGREEMENT i ON (b.vendor_nbr = i.vendor_nbr)
                                    LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
                                    LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES h ON (b.Dept_nbr=h.NumDepto and b.Fineline_nbr=h.NumFl)
                                    WHERE c.effective_date <= CURRENT_DATE -15 
                                    AND d.Open_date <= CURRENT_DATE -15 
                                    AND c.ordbk_flag IN ('Y')
                                    AND c.status_code IN ('A') 
                                    AND c.cancel_when_out_flag IN ('N') 
                                    AND c.itm_mbm_code IN ('M','I')
                                    AND j.trait_nbr IN (11)
                                    AND c.type_code IN ('20','33','37','40')
                                    AND b.vendor_nbr NOT IN (18) 
                                    AND i.jda_vndr_stat_cd IN (2)
                                    AND d.store_nbr NOT IN (3836) 
                                    AND d.open_status NOT IN ('0','03','3','07','7','6','06','8','08') 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER NOT IN (21)
                                    AND a.carry_option IN ('R')  
                                    AND a.carried_status IN ('R') 
                                    AND b.Dept_nbr||c.type_code||c.ORDER_BOOK_SEQUENCE_NUMBER 
                                    NOT IN ('933721','83339','83401','83200','93221','833321','93070','81030','93030','83039','980789','93401','930787','810787',
                                    '933320','98379','83429','98221','93371','932021','83071','83220','81370', '83079','980797','81221','98070','810389',
                                    '983721','832021','98071','930714','98331','830714','812021','93409','813321','98079','98039','98200','83221','98371',
                                    '93071','93379','81201','930789','983321','83400','93420','83420','93200','83030','98339','81070','81200','81220','98370',
                                    '933321','93220','81331','98030','98220','83370','982021','93201','81071','83409','93039','83201','93331','81079','83421',
                                    '810789','81039','93421',     '83070','810714','980714','93079','93400')
                                    OR c.effective_date <= CURRENT_DATE -15 
                                    AND d.Open_date <= CURRENT_DATE -15 
                                    AND b.dept_nbr IN(90,91,97) 
                                    AND c.type_code IN ('20','33','37','40')
                                    AND c.ordbk_flag IN ('Y') 
                                    AND c.status_code IN ('A') 
                                    AND c.cancel_when_out_flag IN ('N') 
                                    AND c.itm_mbm_code IN ('M','I') 
                                    AND b.vendor_nbr NOT IN (18)
                                    AND i.jda_vndr_stat_cd NOT IN (2) 
                                    AND d.store_nbr NOT IN (3836) 
                                    AND d.open_status NOT IN ('0','3','7') 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER NOT IN (21)
                                    AND j.trait_nbr IN (11)
                                    AND a.carry_option IN ('R') 
                                    AND a.carried_status IN ('R') 
                                    AND b.Dept_nbr||c.type_code||c.ORDER_BOOK_SEQUENCE_NUMBER 
                                    NOT IN ('933721','83339','83401','83200','93221','833321','93070','81030','93030','83039','980789','93401','930787','810787',
                                    '933320','98379','83429','98221','93371','932021','83071','83220','81370', '83079','980797','81221','98070','810389',
                                    '983721','832021','98071','930714','98331','830714','812021','93409','813321','98079','98039','98200','83221','98371',
                                    '93071','93379','81201','930789','983321','83400','93420','83420','93200','83030','98339','81070','81200','81220','98370',
                                    '933321','93220','81331','98030','98220','83370','982021','93201','81071','83409','93039','83201','93331','81079','83421',
                                    '810789','81039','93421',     '83070','810714','980714','93079','93400')
                                    OR c.effective_date <= CURRENT_DATE -15 
                                    AND d.Open_date <= CURRENT_DATE -15 
                                    AND b.dept_nbr IN(90,91,97) 
                                    AND c.type_code IN ('20')
                                    AND c.ordbk_flag IN ('Y') 
                                    AND c.status_code IN ('A') 
                                    AND c.cancel_when_out_flag IN ('N') 
                                    AND c.itm_mbm_code IN ('M','I') 
                                    AND b.vendor_nbr NOT IN (18)
                                    AND j.trait_nbr IN (11)
                                    AND i.jda_vndr_stat_cd NOT IN (2) 
                                    AND d.open_status NOT IN ('0','3','7') 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER NOT IN (21) 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER IN (1,0)
                                    AND a.carry_option IN ('R')  
                                    AND a.carried_status IN ('R')  
                                    AND b.Dept_nbr||c.type_code||c.ORDER_BOOK_SEQUENCE_NUMBER 
                                    NOT IN ('933721','83339','83401','83200','93221','833321','93070','81030','93030','83039','980789','93401','930787','810787',
                                    '933320','98379','83429','98221','93371','932021','83071','83220','81370', '83079','980797','81221','98070','810389',
                                    '983721','832021','98071','930714','98331','830714','812021','93409','813321','98079','98039','98200','83221','98371',
                                    '93071','93379','81201','930789','983321','83400','93420','83420','93200','83030','98339','81070','81200','81220','98370',
                                    '933321','93220','81331','98030','98220','83370','982021','93201','81071','83409','93039','83201','93331','81079','83421',
                                    '810789','81039','93421',     '83070','810714','980714','93079','93400')
                                    OR c.effective_date <= CURRENT_DATE -15 
                                    AND d.Open_date <= CURRENT_DATE -15  
                                    AND b.dept_nbr IN(91,97) 
                                    AND c.type_code IN ('20') 
                                    AND c.ordbk_flag IN ('Y')
                                    AND c.status_code IN ('A') 
                                    AND c.cancel_when_out_flag IN ('N') 
                                    AND c.itm_mbm_code IN ('M','I') 
                                    AND b.vendor_nbr NOT IN (18) 
                                    AND i.jda_vndr_stat_cd NOT IN (2)
                                    AND j.trait_nbr IN (11)
                                    AND d.open_status NOT IN ('0','3','7') 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER NOT IN (21) 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER IN (20) 
                                    AND a.carry_option IN ('R')  
                                    AND a.carried_status IN ('R') 
                                    AND b.Dept_nbr||c.type_code||c.ORDER_BOOK_SEQUENCE_NUMBER 
                                    NOT IN ('933721','83339','83401','83200','93221','833321','93070','81030','93030','83039','980789','93401','930787','810787',
                                    '933320','98379','83429','98221','93371','932021','83071','83220','81370', '83079','980797','81221','98070','810389',
                                    '983721','832021','98071','930714','98331','830714','812021','93409','813321','98079','98039','98200','83221','98371',
                                    '93071','93379','81201','930789','983321','83400','93420','83420','93200','83030','98339','81070','81200','81220','98370',
                                    '933321','93220','81331','98030','98220','83370','982021','93201','81071','83409','93039','83201','93331','81079','83421',
                                    '810789','81039','93421',     '83070','810714','980714','93079','93400')
                                    OR c.effective_date <= CURRENT_DATE -15 
                                    AND d.Open_date <= CURRENT_DATE -15  
                                    AND b.dept_nbr NOT IN(56,97,91,90,81,98,94,99) 
                                    AND c.type_code IN ('20','33','37','40')
                                    AND c.ordbk_flag IN ('Y') 
                                    AND c.status_code IN ('A') 
                                    AND c.cancel_when_out_flag IN ('N') 
                                    AND c.itm_mbm_code IN ('M','I') 
                                    AND b.vendor_nbr NOT IN (18) 
                                    AND i.jda_vndr_stat_cd NOT IN (2)
                                    AND j.trait_nbr IN (11)
                                    AND d.store_nbr NOT IN (3836) 
                                    AND d.open_status NOT IN ('0','3','7') 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER NOT IN (21) 
                                    AND a.carry_option IN ('R')  
                                    AND a.carried_status IN ('R') 
                                    AND b.Dept_nbr||c.type_code||c.ORDER_BOOK_SEQUENCE_NUMBER 
                                    NOT IN ('933721','83339','83401','83200','93221','833321','93070','81030','93030','83039','980789','93401','930787','810787',
                                    '933320','98379','83429','98221','93371','932021','83071','83220','81370', '83079','980797','81221','98070','810389',
                                    '983721','832021','98071','930714','98331','830714','812021','93409','813321','98079','98039','98200','83221','98371',
                                    '93071','93379','81201','930789','983321','83400','93420','83420','93200','83030','98339','81070','81200','81220','98370',
                                    '933321','93220','81331','98030','98220','83370','982021','93201','81071','83409','93039','83201','93331','81079','83421',
                                    '810789','81039','93421',     '83070','810714','980714','93079','93400')
                                    OR c.effective_date <= CURRENT_DATE -15 
                                    AND d.Open_date <= CURRENT_DATE -15  
                                    AND b.dept_nbr IN(81,98,94,56) 
                                    AND c.type_code IN ('20','33','37','40')
                                    AND c.ordbk_flag IN ('Y') 
                                    AND c.status_code IN ('A') 
                                    AND c.cancel_when_out_flag IN ('N') 
                                    AND c.itm_mbm_code IN ('M','I') 
                                    AND b.vendor_nbr NOT IN (18) 
                                    AND i.jda_vndr_stat_cd NOT IN (2)
                                    AND j.trait_nbr IN (11)
                                    AND d.store_nbr NOT IN (3836) 
                                    AND d.open_status NOT IN ('0','3','7') 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER NOT IN (21) 
                                    AND a.carry_option IN ('R')  
                                    AND a.carried_status IN ('R') 
                                    AND b.Dept_nbr||c.type_code||c.ORDER_BOOK_SEQUENCE_NUMBER 
                                    NOT IN ('933721','83339','83401','83200','93221','833321','93070','81030','93030','83039','980789','93401','930787','810787',
                                    '933320','98379','83429','98221','93371','932021','83071','83220','81370', '83079','980797','81221','98070','810389',
                                    '983721','832021','98071','930714','98331','830714','812021','93409','813321','98079','98039','98200','83221','98371',
                                    '93071','93379','81201','930789','983321','83400','93420','83420','93200','83030','98339','81070','81200','81220','98370',
                                    '933321','93220','81331','98030','98220','83370','982021','93201','81071','83409','93039','83201','93331','81079','83421',
                                    '810789','81039','93421',     '83070','810714','980714','93079','93400')
                                    OR c.effective_date <= CURRENT_DATE -15 
                                    AND d.Open_date <= CURRENT_DATE -15 
                                    AND b.dept_nbr IN(83,93) 
                                    AND c.type_code IN ('20') 
                                    AND c.ordbk_flag IN ('Y') 
                                    AND c.status_code IN ('A')
                                    AND c.cancel_when_out_flag IN ('N') 
                                    AND c.itm_mbm_code IN ('M','I') 
                                    AND b.vendor_nbr NOT IN (18) 
                                    AND i.jda_vndr_stat_cd NOT IN (2) 
                                    AND d.open_status NOT IN ('0','3','7')
                                    AND j.trait_nbr IN (11)
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER NOT IN (21) 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER IN (20) 
                                    AND a.carry_option IN ('R') 
                                    AND a.carried_status IN ('R') 
                                    AND b.Dept_nbr||c.type_code||c.ORDER_BOOK_SEQUENCE_NUMBER 
                                    NOT IN ('933721','83339','83401','83200','93221','833321','93070','81030','93030','83039','980789','93401','930787','810787',
                                    '933320','98379','83429','98221','93371','932021','83071','83220','81370', '83079','980797','81221','98070','810389',
                                    '983721','832021','98071','930714','98331','830714','812021','93409','813321','98079','98039','98200','83221','98371',
                                    '93071','93379','81201','930789','983321','83400','93420','83420','93200','83030','98339','81070','81200','81220','98370',
                                    '933321','93220','81331','98030','98220','83370','982021','93201','81071','83409','93039','83201','93331','81079','83421',
                                    '810789','81039','93421',     '83070','810714','980714','93079','93400')
                                    OR c.effective_date <= CURRENT_DATE -15 
                                    AND d.Open_date <= CURRENT_DATE -15  
                                    AND b.dept_nbr IN (81,98,94) 
                                    AND c.type_code IN ('20') 
                                    AND c.ordbk_flag IN ('Y') 
                                    AND c.status_code IN ('A')
                                    AND c.cancel_when_out_flag IN ('N') 
                                    AND c.itm_mbm_code IN ('M','I') 
                                    AND b.vendor_nbr NOT IN (18) 
                                    AND i.jda_vndr_stat_cd NOT IN (2) 
                                    AND d.store_nbr NOT IN (3836)
                                    AND j.trait_nbr IN (11)
                                    AND d.open_status NOT IN ('0','3','7') 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER NOT IN (21) 
                                    AND a.carry_option IN ('R')  
                                    AND a.carried_status IN ('R') 
                                    AND b.Dept_nbr||c.type_code||c.ORDER_BOOK_SEQUENCE_NUMBER 
                                    NOT IN ('933721','83339','83401','83200','93221','833321','93070','81030','93030','83039','980789','93401','930787','810787',
                                    '933320','98379','83429','98221','93371','932021','83071','83220','81370', '83079','980797','81221','98070','810389',
                                    '983721','832021','98071','930714','98331','830714','812021','93409','813321','98079','98039','98200','83221','98371',
                                    '93071','93379','81201','930789','983321','83400','93420','83420','93200','83030','98339','81070','81200','81220','98370',
                                    '933321','93220','81331','98030','98220','83370','982021','93201','81071','83409','93039','83201','93331','81079','83421',
                                    '810789','81039','93421',     '83070','810714','980714','93079','93400')
                                    GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16) a ) a

                              LEFT JOIN(                                                                                                                                                      
                                        SELECT

                                          a.store_nbr AS DET,
                                          b.upc_nbr AS UPC, 
                                          b.old_nbr AS ITEM_NBR, 
                                          (SUM(sales_fcst_each_qty )/7)  AS SALES_FCST

                                        FROM wmt-edw-prod.MX_WM_VM.STORE_ITEM_FCST_WK_CONV a
                                        INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr)
                                        INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON ( b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
                                        INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO e ON (a.store_nbr = e.store_nbr) 
                                        INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
                                        WHERE a.fcst_wm_yr_wk IN (SELECT DISTINCT wm_yr_wk FROM wmt-edw-prod.MX_WM_VM.CALENDAR_DAY WHERE gregorian_date = CURRENT_DATE)
                                        AND a.wm_yr_wk IN (SELECT DISTINCT wm_yr_wk FROM wmt-edw-prod.MX_WM_VM.CALENDAR_DAY WHERE gregorian_date = CURRENT_DATE)
                                        AND j.trait_nbr IN (11)
                                        GROUP BY 1,2,3 ) b ON (a.DET=b.DET AND a.UPC=b.UPC AND a.ITEM_NBR=b.ITEM_NBR)

                              LEFT JOIN (
                                          SELECT 

                                            a.store_nbr AS DET,
                                            b.upc_nbr AS UPC,
                                            b.old_nbr AS ITEM_NBR,
                                            SUM(a.on_hand_qty) AS OH_QTY,
                                            SUM(a.in_transit_qty) AS IT_QTY,
                                            SUM(a.IN_WAREHOUSE_QTY) AS IW_QTY,
                                            SUM(a.ON_ORDER_QTY) AS IO_QTY,
                                            SUM(a.on_hand_qty+a.in_transit_qty) AS OH_IT_QTY,
                                            SUM(a.on_hand_qty+a.in_transit_qty+a.IN_WAREHOUSE_QTY) AS OH_IT_IW_QTY,
                                            SUM(a.on_hand_qty+a.in_transit_qty+a.IN_WAREHOUSE_QTY+a.ON_ORDER_QTY) AS OH_IT_IW_IO_QTY

                                          FROM wmt-edw-prod.MX_WM_VM.STOCK_KEEPING_UNIT a
                                          INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.old_nbr) 
                                          INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
                                          INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
                                          INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
                                          WHERE b.item_status_code IN ('A')
                                          AND c.obsolete_date > CURRENT_DATE
                                          AND j.trait_nbr IN (11)
                                          GROUP BY 1,2,3 ) c ON (a.DET=c.DET AND a.UPC=c.UPC AND a.ITEM_NBR=c.ITEM_NBR)

                                LEFT JOIN( 
                                          SELECT 

                                            a.BUSINESS_UNIT_NBR AS DET,
                                            b.upc_nbr AS UPC,
                                            b.old_nbr AS ITEM_NBR,
                                            SUM(a.RTFCST) AS INFO_FCST
                                          
                                          FROM wmt-edw-prod.MX_WM_VM.INFOREM_RECYCLE_DATA a
                                          INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr)
                                          INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON ( b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
                                          INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO e ON (a.BUSINESS_UNIT_NBR = e.store_nbr) 
                                          INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.BUSINESS_UNIT_NBR = j.store_nbr) 
                                          WHERE a.ft NOT IN ('X','E','I') 
                                          AND j.trait_nbr IN (11)
                                          GROUP BY 1,2,3 )d ON (a.DET=d.DET AND a.UPC=d.UPC AND a.ITEM_NBR=d.ITEM_NBR)

                                LEFT JOIN (
                                            SELECT          

                                              c.store_nbr AS DET,
                                              e.upc_nbr AS UPC,
                                              e.old_nbr AS ITEM_NBR,
                                              SUM(c.whpk_ordered_qty) AS PACKS_ORD,
                                              SUM(c.whpk_received_qty) AS PACKS_REC

                                            FROM wmt-edw-prod.MX_WM_VM.PURCHASE_ORDER a
                                            INNER JOIN  wmt-edw-prod.MX_WM_VM.PO_LINE b ON (a.po_nbr = b.po_nbr AND a.order_date = b.order_date)
                                            INNER JOIN wmt-edw-prod.MX_WM_VM.PO_LINE_DISTRIBUTION c ON (a.po_nbr = c.po_nbr AND a.order_date = c.order_date)
                                            INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC d ON (c.item_nbr = d.item_nbr)
                                            INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM e ON ( d.old_nbr = e.old_nbr AND d.item_nbr = e.item_nbr) 
                                            INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO f ON (c.store_nbr = f.store_nbr) 
                                            INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (c.store_nbr = j.store_nbr)   
                                            WHERE a.cancel_date BETWEEN CURRENT_DATE-37 AND CURRENT_DATE-10
                                            AND j.trait_nbr IN (11)
                                            AND a.po_status IN ('C')                                                   
                                            GROUP BY  1,2,3 ) e ON (a.DET=e.DET AND a.UPC=e.UPC AND a.ITEM_NBR=e.ITEM_NBR) )a )a )a

        GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16) a

GROUP BY  1,2,3,4,5,6,7,8,9,10,11,12;