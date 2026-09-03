-- ============================================================
-- SAMS - Adobe Impresiones Item (Investigacion) v2.sql
-- Estado  : INVESTIGACION -- v2, YA VALIDADA CON UN DIA COMPLETO
--           (no solo muestra). v1 se deja intacta como referencia
--           historica del proceso de descubrimiento -- ver
--           "SAMS - Adobe Impresiones Item (Investigacion).sql".
-- Fecha   : 02-sep-2026
-- Objetivo: el mismo de v1 -- pegarle a nivel ITEM las
--           "impresiones"/"ocurrencias" en sitio (search/browse) de
--           Adobe Analytics Sam's Club MX, para poder unirlas (por
--           Item_Nbr) a los queries de venta e inventarios
--           YTD/MTD/L7D/L1D (Item Total y Club x Item).
--
-- QUE CAMBIA vs v1:
--   v1 dejo el patron validado solo con MUESTRAS (LIMIT 50,000 hits,
--   ~875MB) y una ADVERTENCIA de costo estimada "a ojo" (~50GB/dia,
--   varios TB en YTD) por no tener dry_run disponible en ese momento.
--
--   v2 corrio el DIA COMPLETO real (con el visto bueno explicito de
--   Alberto) y el costo real resulto MUCHO MENOR de lo temido:
--   ~11 GB/dia (no ~50 GB). Esto cambia la recomendacion final sobre
--   que tan viable es un pipeline diario -- ver seccion final.
-- ============================================================
-- TABLA FUENTE (igual que v1):
--   wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event
--   -> VIEW sobre TABLA EXTERNA (ORC) particionada por `ds` (DATE).
--   -> op_cmpny_cd = 'SAMS-MX' es el filtro de banner.
--   -> `chnl_txt` NO es columna de particion -- el filtro sobre esa
--      columna + `prod_lst_txt` obliga a leer esas columnas
--      completas por cada dia de la particion (de ahi el costo).
--
-- PATRON VALIDADO (idéntico a v1, sin cambios en la logica):
--   - Item/SKU: REGEXP_EXTRACT(segmento, r'eVar168=([^|;,]+)')
--     dentro de cada segmento de `prod_lst_txt` (coma-separado).
--   - "Impresion"/"ocurrencia": cada segmento de producto dentro de
--     un hit con chnl_txt IN ('searchResults', 'browseResults').
--     Los codigos 20256/20258 que documentaba Confluence NO existen
--     en los datos reales -- no usarlos (ver v1 para el detalle del
--     descarte).
--   - page_type_nm sigue 100% NULL -- inservible, ignorar.
-- ============================================================

DECLARE fecha_reporte DATE DEFAULT '2026-09-02';   -- MAX(ds) real disponible al validar v2

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
-- RESULTADOS REALES -- corrida validada 02-sep-2026, fecha_reporte
-- = 2026-09-02 (el MAX(ds) disponible en ese momento)
-- ============================================================
--
-- COSTO REAL (esto es lo importante -- reemplaza el estimado de v1):
--   bytes_processed : 11,817,703,632 bytes
--   bytes_billed    : 11,818,500,096 bytes  ~= 11.01 GB
--   (MUCHO menor al estimado previo de ~50 GB/dia de v1 -- ese
--   estimado fue conservador/a-ojo por falta de dry_run real en el
--   momento de la exploracion inicial)
--
-- VOLUMEN DEL DIA:
--   Items distintos con >=1 impresion : 12,339
--   Suma total de Ocurrencias (dia)   : 10,332,116
--   Segmentos con Item_Nbr NULL (no matchearon eVar168) : 112
--     (0.001% del total -- marginal, no distorsiona el analisis,
--      pero queda documentado por si se quiere auditar despues)
--
-- TOP 15 ITEMS POR OCURRENCIAS (2026-09-02):
--   #   Item_Nbr     Ocurrencias
--   1   980003268    14,520
--   2   980006737    13,649
--   3   000954468    13,460
--   4   981033963    13,055
--   5   981004806    13,044
--   6   980036357    12,571
--   7   000263093    11,762
--   8   981040532    11,655
--   9   981038765    11,253
--   10  000389388    10,955
--   11  980023707    10,759
--   12  980021233    10,647
--   13  980042829    10,553
--   14  000389773    10,391
--   15  981002919    10,205
--
-- Nota de negocio: el top 15 esta dominado por SKUs con prefijo
-- 980xxx/981xxx (probablemente items de campana/patrocinados) mas
-- un par de 000xxx (posible marca privada / Member's Mark). Pendiente
-- de cruzar contra el catalogo de items para confirmar categoria y
-- nombre real.
-- ============================================================

-- ============================================================
-- SIGUIENTE PASO RECOMENDADO -- ACTUALIZADO (v2)
-- ============================================================
-- Con el costo real confirmado en ~11 GB/dia (no ~50 GB como se
-- temia en v1), un pipeline DIARIO es mucho mas viable de lo que
-- se penso originalmente. Sigue sin ser gratis corridito "a lo
-- bruto" contra un rango YTD completo (~245 dias x 11GB ~= 2.7 TB),
-- asi que la recomendacion de fondo NO cambia:
--
--   1. Rutina diaria (Task Scheduler, mismo patron que
--      SamsAbarrotesReporte7AM) que jala SOLO el dia de ayer
--      (query de arriba) -- costo fijo real de ~11 GB/dia, UNA
--      sola vez por dia.
--   2. Acumular esos resultados diarios en un Parquet/tabla local
--      (Fecha x Item_Nbr x Ocurrencias), append-only -- mismo
--      patron que tablero_insights_com_abarrotes/historico_app.
--   3. YTD/MTD/L7D/L1D de impresiones se calculan sumando ESE
--      historico local ya acumulado (barato, pandas/SQL local),
--      nunca re-escaneando BQ para dias ya capturados.
--   4. Union final con los queries de venta e inventarios por
--      Item_Nbr (LEFT JOIN, igual que ya se hace con T1/T3 en esos
--      queries).
--
-- PENDIENTE FUERA DE BQ (igual que v1, sigue abierto):
--   Pedir al equipo de Adobe Admin (Claudia Ornelas / Eduardo
--   Visoso, Datamesh) el nombre OFICIAL del evento de "impresion"
--   en el Report Suite -- lo que tenemos es un proxy validado con
--   datos (chnl_txt de listado = impresion), no una etiqueta
--   oficial de Adobe Event Manager.
--
-- PENDIENTE NUEVO (v2): correr 2-3 dias mas (distintos dias de la
-- semana) para confirmar que el costo de ~11GB/dia es consistente
-- y no un caso particular de un dia con trafico bajo/alto atipico,
-- antes de construir la rutina diaria en serio.
-- ============================================================
