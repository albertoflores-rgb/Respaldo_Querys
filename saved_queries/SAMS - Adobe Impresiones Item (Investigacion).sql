-- ============================================================
-- SAMS - Adobe Impresiones Item (Investigacion).sql
-- Estado  : INVESTIGACION / borrador validado con datos reales.
--           NO es un pipeline productivo todavia -- ver "Siguiente
--           paso recomendado" al final antes de correr esto en serio.
-- Fecha   : 02-sep-2026
-- Objetivo: pegarle a nivel ITEM las "impresiones"/"ocurrencias" en
--           sitio (search/browse) de Adobe Analytics Sam's Club MX,
--           para poder unirlas (por Item_Nbr) a los queries de
--           venta e inventarios YTD/MTD/L7D/L1D ya existentes:
--             - "SAMS - Venta e Inventarios Ecatman - YTD MTD 7Dias
--                TY vs LY (Item Total).sql"
--             - "SAMS - Venta e Inventarios Ecatman - YTD MTD 7Dias
--                TY vs LY.sql"
--
-- TABLA FUENTE:
--   wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event
--   -> VIEW sobre una TABLA EXTERNA (ORC) particionada por `ds` (DATE).
--   -> SIEMPRE filtrar por `ds` (rango pequeno) -- es obligatorio y
--      ademas evita escanear toda la tabla.
--   -> op_cmpny_cd = 'SAMS-MX'  es el filtro de banner (no existe una
--      columna literal de "report suite"/walmar17 en este export).
--
-- ============================================================
-- HALLAZGOS CLAVE (validados contra datos reales, 01-sep-2026;
-- ver drawer de investigacion en Puppy Kennel para el detalle
-- completo del proceso con bigquery-explorer + confluence-search)
-- ============================================================
--
-- 1) ITEM/SKU: vive DENTRO de `prod_lst_txt` (formato Adobe estandar:
--    "categoria;producto;qty;precio;eventos;eVars", multiples
--    productos separados por coma). El SKU se extrae con:
--        REGEXP_EXTRACT(segmento, r'eVar168=([^|;,]+)')
--    Confirmado: eVar168 == posicion estandar [1] en 100% de una
--    muestra de 69,597 segmentos (para browse/search). Se usa
--    eVar168 de todas formas por ser explicito y a prueba de
--    cambios de formato futuros (asi lo hace tambien el pipeline
--    documentado en Confluence "Use case of hive table
--    mx_csd_secured_dl_tables").
--
-- 2) "IMPRESION"/"OCURRENCIA": Confluence documentaba los codigos
--    20256 (Product Impression on Browse) y 20258 (Product
--    Impression on Search) -- **ESTOS CODIGOS NO APARECEN EN LOS
--    DATOS REALES** de este pipeline (se busco explicitamente en
--    miles de filas, cero matches). NO USAR esos codigos.
--
--    El proxy real y verificable, confirmado contra datos:
--      Cada segmento de producto dentro de `prod_lst_txt` en un hit
--      con chnl_txt IN ('searchResults', 'browseResults')
--      = 1 impresion/ocurrencia de ESE item en ESE listado.
--    Esto es, de hecho, la semantica estandar de Adobe: el product
--    string en una pagina de listado ya representa que productos
--    se mostraron al socio.
--
-- 3) `page_type_nm` esta 100% NULL en toda la tabla (verificado en
--    57.4M filas de un dia completo) -- NO sirve como filtro,
--    ignorarlo pase lo que pase.
--
-- 4) `chnl_txt` SI trae valores utiles y reales (no es un string
--    compuesto con "|" como sugeria Confluence, es un valor simple):
--      'searchResults', 'browseResults', 'contentListings',
--      'homePage', 'productPage', etc.
--
-- ============================================================
-- ADVERTENCIA DE COSTO -- LEER ANTES DE CORRER NADA DE ESTO
-- ============================================================
-- `chnl_txt` NO es columna de particion (solo `ds` lo es). Cualquier
-- filtro sobre chnl_txt/prod_lst_txt obliga a BigQuery a leer esa
-- columna completa por cada dia de la particion.
--
-- Estimado real (validado con muestras, NO con dry_run real por
-- falta de credenciales del CLI en el momento de la investigacion):
--   - 1 dia completo (~57.4M filas)  ~= 50+ GB
--   - YTD (~245 dias, Ene -> hoy)    ~= varios TB
--
-- Esto es MUY distinto a los queries de venta (SKU_DLY_POS / Sams_
-- Ventas), que escanean un fijo de ~19.3 GB sin importar el rango
-- de fechas. Correr un YTD de impresiones "a lo bruto" cada vez que
-- se quiera refrescar el tablero seria carisimo e innecesario.
--
-- ============================================================
-- QUERY DE EJEMPLO (validado el patron, NO corrido para el dia
-- completo -- correrlo tal cual escanea ~50GB para UN dia)
-- ============================================================
DECLARE fecha_reporte DATE DEFAULT DATE_SUB(CURRENT_DATE('America/Mexico_City'), INTERVAL 1 DAY);

WITH base AS (
  SELECT
    ds,
    prod_lst_txt
  FROM `wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event`
  WHERE op_cmpny_cd = 'SAMS-MX'
    AND ds = fecha_reporte                               -- filtro de particion, OBLIGATORIO
    AND chnl_txt IN ('searchResults', 'browseResults')   -- proxy real de "impresion"
    AND prod_lst_txt IS NOT NULL
),
segmentos AS (
  SELECT
    ds,
    REGEXP_EXTRACT(segment, r'eVar168=([^|;,]+)') AS Item_Nbr
  FROM base, UNNEST(SPLIT(prod_lst_txt, ',')) AS segment
  WHERE segment != ''
)
SELECT
  ds        AS Fecha,
  Item_Nbr,
  COUNT(*)  AS Ocurrencias
FROM segmentos
WHERE Item_Nbr IS NOT NULL
GROUP BY Fecha, Item_Nbr
ORDER BY Fecha, Ocurrencias DESC;

-- ============================================================
-- SIGUIENTE PASO RECOMENDADO (pendiente, NO implementado todavia)
-- ============================================================
-- En vez de recalcular YTD/MTD/L7D/L1D de impresiones desde cero
-- contra BQ cada vez (quemando TBs), replicar el MISMO patron que
-- ya usa el repo en `*/historico_app/` para ventas:
--
--   1. Rutina diaria (Task Scheduler, como SamsAbarrotesReporte7AM)
--      que jala SOLO el dia de ayer (fecha_reporte = ayer, query de
--      arriba) -- un cargo fijo de ~50GB por dia, UNA sola vez.
--   2. Acumular esos resultados diarios en un Parquet/tabla local
--      (Fecha x Item_Nbr x Ocurrencias), append-only.
--   3. YTD/MTD/L7D/L1D de impresiones se calculan sumando ESE
--      historico local ya acumulado (barato, pandas/SQL local),
--      nunca re-escaneando BQ para dias ya capturados.
--   4. Union final con los queries de venta e inventarios por
--      Item_Nbr (LEFT JOIN, igual que ya se hace con T1/T3 en esos
--      queries).
--
-- Esto es exactamente lo que ya resolvimos una vez para el volumen
-- de venta .com (15.3M filas Fecha x Club x Item) en
-- tablero_insights_com_abarrotes/historico_app -- mismo problema,
-- misma solucion: nunca re-escanear historia que ya se capturo.
--
-- PENDIENTE FUERA DE BQ: pedir al equipo de Adobe Admin (Claudia
-- Ornelas / Eduardo Visoso, Datamesh) el nombre OFICIAL del evento
-- de "impresion" en el Report Suite -- lo que tenemos aqui es un
-- proxy validado con datos (chnl_txt de listado = impresion), no
-- una etiqueta oficial de Adobe Event Manager.
-- ============================================================
