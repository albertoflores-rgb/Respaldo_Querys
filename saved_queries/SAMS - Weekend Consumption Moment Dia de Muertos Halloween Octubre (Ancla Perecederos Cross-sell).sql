-- =============================================================================
-- WEEKEND CONSUMPTION MOMENT: Día de Muertos / Halloween (última semana de
-- octubre) -- ancla real en Perecederos, cross-sell hacia Abarrotes/Impulso/
-- Salud y Bienestar. Nivel CADENA/NACIONAL (no existe tier de "tiendas de
-- bajo performance" en el modelo -- confirmado, no se fuerza ese corte).
--
-- Deriva del motor de query_adyacencias_canasta_apriori.sql (mismo Apriori
-- 2 niveles, mismo mapeo SQUAD->bucket, mismo dedup de catálogo, mismo LPAD
-- a 9 dígitos para el join Sams_Ventas <-> catálogo).
--
-- PERIODOS: Sams_Ventas arranca 2024-01-01, HOY=2026-09-09 -> Octubre 2026
-- AÚN NO ocurre. Solo hay 2 Octubres completos en la fuente:
--   TY_OCT = Octubre 2025 (el más reciente -> señal más fresca para
--            proyectar el Oct-2026 que se está planeando)
--   LY_OCT = Octubre 2024 (referencia año anterior)
-- Limitación honesta: la estacionalidad de "qué semana repunta más" se basa
-- en apenas 2 observaciones (2024 y 2025) -- es una señal direccional, NO
-- una serie robusta de 5+ años.
--
-- HALLAZGO EMPÍRICO PREVIO (keyword-scan sobre item_short_desc, Oct-2024 y
-- Oct-2025, validado antes de tocar el motor Apriori):
--   Items temáticos reales de Día de Muertos/Halloween con bucket de
--   negocio válido (se excluyen items de decoración/disfraces -- no
--   matchean a ningún SQUAD de negocio, son Mercancías Generales/Seasonal):
--     FRESH:       MM MINIMUERTO 15 PZA, MM 1K PAN DE MUERTO,
--                  MM 1KG PAN MUERTO, CALABAZA HALLOWEEN P
--     IMPULSO:     VERO MIX DULCE, SKWINKLES DULCES
--     PERECEDEROS: MM CALABAZAS 1.19K, DIP CALABAZA CEBOLLA,
--                  KEFIR PAY CALABAZA -- los 3 con <$11K de venta en su
--                  mejor año y CERO (o casi cero) piezas en Oct-2025 ->
--                  NO sobreviven la poda de soporte mínimo del Apriori.
--   CONCLUSIÓN: no hay ancla de PERECEDEROS con etiqueta explícita de
--   Día de Muertos/Halloween y venta suficiente. Los anclas reales del
--   momento (por venta) son FRESH e IMPULSO. Por eso el "ancla de
--   Perecederos" se resuelve con Apriori real: se busca qué item(s) de
--   PERECEDEROS tienen mayor confianza/lift de compra conjunta CON esos
--   anclas temáticas -- ese es el Perecedero que de verdad viaja en la
--   canasta del convivio, aunque su etiqueta no diga "Halloween".
-- =============================================================================

-- NOTA DE EJECUCIÓN (09-sep-2026): el CLI `bq` no pudo autenticarse en esta
-- sesión (gcloud reauth falló, entorno no interactivo). El pipeline de abajo
-- SÍ se corrió completo, pero como una serie de SELECTs con WITH-CTEs
-- (equivalentes 1:1 a los DECLARE/CREATE TEMP TABLE de aquí abajo, con
-- min_items_canasta=7 ya resuelto como literal) vía bigquery_execute_query.
-- Este .sql queda como la versión canónica/reproducible del pipeline; si se
-- vuelve a tener acceso a `bq` CLI, corre tal cual con `bq query --use_legacy_sql=false`.
--
-- RESULTADOS REALES OBTENIDOS (09-sep-2026, quedan documentados para no
-- repetir el diagnóstico de umbral cada vez):
--   min_items_canasta = 7 (avg piezas/orden combinado Oct24+Oct25 = 14.70)
--   canastas_calificadas_oct_ty_2025 = 192,035 | items_frecuentes = 1,706 | pares = 1,166,472
--   Diagnóstico de confianza en pares con >=1 lado temático (Oct-2025):
--     >=70%: 0 | >=50%: 0 | >=40%: 1 | >=30%: 7 | >=20%: 36 | >=10%: 106 | >=5%: 337 (de 7,964 pares tematicos totales)
--   -> Los 7 pares a 30%+ son TODOS candy-con-candy dentro de IMPULSO (ej.
--      Vero Mix Dulce <-> Vero Mix Fuego, confianza 47%/45%, lift 26). Ninguno
--      cruza hacia Abarrotes/Perecederos/Salud y Bienestar a esa barra alta.
--      Por eso, para ARMAR la canasta de 20 items con variedad real de bucket,
--      se usó la barra general de "fuerte" (confianza>=5% + lift>=1.2, el
--      mismo criterio del query maestro) en vez de forzar 30% -- a 30% la
--      canasta se hubiera quedado sin Abarrotes/Perecederos/Salud.
--   -> Los MEJORES candidatos reales de PERECEDEROS conectados a los anclas
--      temáticos (FRESH/IMPULSO), NINGUNO por encima de 12% de confianza:
--        30 PZ HUEVO BLANCO      (conf 11.9%/11.2% desde pan de muerto, lift 1.3-1.4)
--        900 GR CREMA ACIDA      (conf hasta 7.8%, lift hasta 2.0)
--        1 KG OAXACA ORGANICO    (lift 2.1, conf baja por bajo volumen)
--        MM 18/1LT AGUA PURIFIC. (lift 1.6-1.61)
--        DELIGHT PUMPKIN         (lift 2.07 -- genuinamente tematico, sabor calabaza)
--   CONCLUSIÓN VALIDADA: NO existe un ancla de PERECEDEROS con etiqueta
--   explícita de Día de Muertos/Halloween Y volumen/confianza fuerte. Los
--   anclas reales del momento (por venta y por fuerza de conexión) son FRESH
--   (Minimuerto, Pan de Muerto x2, Calabaza Halloween) e IMPULSO (Vero Mix
--   Dulce, Skwinkles). Los items de Perecederos arriba SÍ tienen adyacencia
--   real (lift>1.2, pasan la barra de "fuerte") pero son riders modestos, no
--   anclas dominantes -- se documentan y usan como tales en el pull de 20
--   items, sin forzar una narrativa de "ancla fuerte" que los datos no sostienen.

DECLARE ty_inicio DATE DEFAULT DATE '2025-10-01';
DECLARE ty_fin    DATE DEFAULT DATE '2025-10-31';
DECLARE ly_inicio DATE DEFAULT DATE '2024-10-01';
DECLARE ly_fin    DATE DEFAULT DATE '2024-10-31';

DECLARE min_items_canasta INT64;                 -- dinámico, mitad del promedio real de piezas/orden (universo calificado, TY+LY combinado)
DECLARE min_support       FLOAT64 DEFAULT 0.001; -- 0.1% -> poda Apriori nivel 1
DECLARE min_confidence_fuerte FLOAT64 DEFAULT 0.05; -- 5% -> clasificar un par como "fuerte" (igual criterio que el query maestro)
DECLARE min_lift          FLOAT64 DEFAULT 1.2;
DECLARE top_n             INT64   DEFAULT 400;

-- EXCLUSION PERSISTENTE (solicitada 23-sep-2026, re-ejecutada y VALIDADA
-- 23-sep-2026 via bq CLI -- job padre bqjob_r1389d206c4da2fbc_000001a0cfbd070d_1,
-- 0 filas en la validacion final): estos 19 SKUs no participan en canastas,
-- pares, candidatos ni agregados TY/LY de esta rutina. Se aplica despues del
-- join de catalogo para mantener la llave normalizada.
-- Identidad completa (bucket + venta) documentada en
-- weekend_consumption_dia_muertos_exclusiones_20260923.md -- los 19 son,
-- sin excepcion, staples genericos de mayoreo (agua, leche, papel, jabon,
-- formula infantil, huevo, uva, pan de caja, vinagre) que aparecen en
-- cualquier canasta grande sin importar el tema -- ruido real, no senal.
DECLARE excluded_items ARRAY<STRING> DEFAULT ['000254784','000263093','980002314','981017658','980030166','981000288','981018491','000034289','000954468','981019852','981000289','000930962','980038901','000718515','980006032','980042829','980007591','980016043','000019039'];

-- NOTA "PAN DE MUERTO SIMILARES" (investigado 23-sep-2026, a peticion del
-- usuario que senalo 000046531/000186909 como "articulos similares"):
-- diagnostico completo (venta mensual lado a lado, ago-2024 a hoy) confirma
-- que AMBOS SKUs venden en paralelo todos los meses, sin que uno reemplace
-- al otro -- NO son un duplicado de catalogo/re-numeracion, son 2 productos
-- reales y activos (variantes Member's Mark del Pan de Muerto). Por eso NO
-- se agregan a excluded_items (eso borraria revenue real y 2 de las 4 anclas
-- de FRESH sin respaldo de dato). La consolidacion pedida por el usuario se
-- resuelve a nivel de DISPLAY en el HTML (una sola fila combinada), no aqui.
-- Si el negocio decide por criterio COMERCIAL (no de calidad de dato)
-- retirar una de las dos variantes del motor completo, activar esta linea
-- alternativa (reemplazando la de arriba) con el SKU que se quiera fuera:
-- DECLARE excluded_items ARRAY<STRING> DEFAULT ['000254784','000263093','980002314','981017658','980030166','981000288','981018491','000034289','000954468','981019852','981000289','000930962','980038901','000718515','980006032','980042829','980007591','980016043','000019039','000186909'];

-- -----------------------------------------------------------------------------
-- 1) Item -> bucket de negocio (dedup catálogo, igual que el query maestro)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE catalogo_bucket AS
SELECT * FROM (
  SELECT
    LPAD(CAST(ITEM_ID AS STRING), 9, '0') AS item_id,
    CASE
      WHEN SQUAD = 'GROCERIES' THEN 'ABARROTES'
      WHEN SQUAD = 'IMPULSO' THEN 'IMPULSO'
      WHEN SQUAD = 'REFRIGERADOS, CONGELADOS Y BEBIDAS' THEN 'PERECEDEROS'
      WHEN SQUAD = 'PRODUCE AND MEAT' THEN 'FRESH'
      WHEN SQUAD = 'SALUD Y BIENESTAR' THEN 'SALUD Y BIENESTAR'
      ELSE NULL
    END AS bucket_negocio,
    ROW_NUMBER() OVER (PARTITION BY ITEM_ID ORDER BY FECHA_INTEGRACION DESC) AS rn
  FROM `wmt-mx-dl-controlledmgzn-prod.SAMS_AD_HOC_COM.SAMS_CONTENIDO_CATALOGO`
  WHERE ITEM_ID IS NOT NULL
)
WHERE rn = 1 AND bucket_negocio IS NOT NULL;

-- -----------------------------------------------------------------------------
-- 2) Líneas crudas de Octubre TY (2025) y LY (2024), con flag de item
--    temático (curado a partir del keyword-scan previo, no LIKE crudo aquí
--    para evitar falsos positivos ya detectados: "MINI PIMIENTO DULCE",
--    "RG 4KG CREMA DULCE", "525G SALSA AGRIDULCE" NO son temáticos, son
--    coincidencias de la palabra "DULCE" en productos genéricos).
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE lineas_crudas AS
SELECT
  CASE
    WHEN v.sales_order_detail_order_created_date BETWEEN ty_inicio AND ty_fin THEN 'OCT_TY_2025'
    WHEN v.sales_order_detail_order_created_date BETWEEN ly_inicio AND ly_fin THEN 'OCT_LY_2024'
  END AS periodo,
  v.sales_order_detail_order_nbr        AS order_nbr,
  v.sales_order_detail_order_created_date AS fecha_compra,
  v.sales_order_detail_item_id          AS item_id,
  v.sales_order_detail_item_short_desc  AS item_desc,
  v.sales_order_detail_commercial_sale_qty_base AS piezas,
  v.sales_order_detail_net_paid_orders_wo_shipping_amount_1 AS monto,
  cb.bucket_negocio,
  (v.sales_order_detail_item_id IN (
     '000155139','000046531','000186909','000318261',              -- FRESH: minimuerto, pan de muerto x2, calabaza halloween
     '980032203','981028844',                                        -- IMPULSO: vero mix dulce, skwinkles
     '980036097','981040416','981028675'                             -- PERECEDEROS: calabazas, dip calabaza-cebolla, kefir pay calabaza
  )) AS is_tematico
FROM `wmt-mx-dl-controlledmgzn-prod.ecom.Sams_Ventas` v
INNER JOIN catalogo_bucket cb ON v.sales_order_detail_item_id = cb.item_id
WHERE v.Estatus = 'VENTA'
  AND v.sales_order_detail_order_nbr IS NOT NULL
  AND LPAD(CAST(v.sales_order_detail_item_id AS STRING), 9, '0') NOT IN UNNEST(excluded_items)
  AND (
    v.sales_order_detail_order_created_date BETWEEN ty_inicio AND ty_fin
    OR v.sales_order_detail_order_created_date BETWEEN ly_inicio AND ly_fin
  );

-- -----------------------------------------------------------------------------
-- 3) Umbral dinámico de canasta calificada (mitad del promedio real de
--    piezas/orden, universo calificado TY+LY combinado -- mismo criterio
--    que el query maestro, NUNCA un número fijo)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE resumen_orden AS
SELECT periodo, order_nbr,
  ANY_VALUE(fecha_compra) AS fecha_compra,
  SUM(piezas) AS piezas_totales,
  SUM(monto)  AS monto_total
FROM lineas_crudas
GROUP BY periodo, order_nbr;

SET min_items_canasta = (
  SELECT GREATEST(2, CAST(ROUND(AVG(piezas_totales) / 2) AS INT64))
  FROM resumen_orden
);

-- -----------------------------------------------------------------------------
-- 4) Canastas calificadas por periodo (mismo umbral para TY y LY)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE lineas_calificadas AS
SELECT DISTINCT periodo, order_nbr, item_id, item_desc, bucket_negocio, is_tematico
FROM lineas_crudas;

CREATE TEMP TABLE canastas_calificadas AS
SELECT periodo, order_nbr
FROM lineas_calificadas
GROUP BY periodo, order_nbr
HAVING COUNT(DISTINCT item_id) >= min_items_canasta;

CREATE TEMP TABLE canasta_items AS
SELECT lc.*
FROM lineas_calificadas lc
INNER JOIN canastas_calificadas cc USING (periodo, order_nbr);

CREATE TEMP TABLE total_canastas AS
SELECT periodo, COUNT(DISTINCT order_nbr) AS n
FROM canasta_items
GROUP BY periodo;

-- -----------------------------------------------------------------------------
-- 5) NIVEL 1 Apriori (poda por soporte) -- SOLO OCT_TY_2025 (la corrida
--    pesada del self-join se limita al periodo mas fresco; TY vs LY a nivel
--    item/categoria se resuelve directo desde lineas_crudas mas abajo, sin
--    necesitar el pruning de itemsets)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE items_frecuentes_ty AS
SELECT
  ci.item_id,
  ANY_VALUE(ci.item_desc)      AS item_desc,
  ANY_VALUE(ci.bucket_negocio) AS bucket_negocio,
  LOGICAL_OR(ci.is_tematico)   AS is_tematico,
  COUNT(DISTINCT ci.order_nbr) AS canastas_con_item,
  SAFE_DIVIDE(COUNT(DISTINCT ci.order_nbr), ANY_VALUE(tc.n)) AS support_item
FROM canasta_items ci
INNER JOIN total_canastas tc ON tc.periodo = ci.periodo
WHERE ci.periodo = 'OCT_TY_2025'
GROUP BY ci.item_id
HAVING SAFE_DIVIDE(COUNT(DISTINCT ci.order_nbr), ANY_VALUE(tc.n)) >= min_support;

-- -----------------------------------------------------------------------------
-- 6) NIVEL 2 Apriori (pares) -- self-join solo entre items frecuentes,
--    solo OCT_TY_2025
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE pares_canasta_ty AS
SELECT
  a.item_id AS item_a_id,
  b.item_id AS item_b_id,
  COUNT(DISTINCT a.order_nbr) AS canastas_con_ambos
FROM canasta_items a
INNER JOIN canasta_items b
  ON a.periodo = b.periodo AND a.order_nbr = b.order_nbr AND a.item_id < b.item_id
INNER JOIN items_frecuentes_ty fa ON fa.item_id = a.item_id
INNER JOIN items_frecuentes_ty fb ON fb.item_id = b.item_id
WHERE a.periodo = 'OCT_TY_2025'
GROUP BY item_a_id, item_b_id;

CREATE TEMP TABLE resultado_ty AS
SELECT
  p.item_a_id, fa.item_desc AS item_a_desc, fa.bucket_negocio AS item_a_bucket, fa.is_tematico AS item_a_tematico,
  p.item_b_id, fb.item_desc AS item_b_desc, fb.bucket_negocio AS item_b_bucket, fb.is_tematico AS item_b_tematico,
  p.canastas_con_ambos,
  fa.canastas_con_item AS canastas_con_a,
  fb.canastas_con_item AS canastas_con_b,
  SAFE_DIVIDE(p.canastas_con_ambos, tc.n) AS support_par,
  SAFE_DIVIDE(p.canastas_con_ambos, fa.canastas_con_item) AS confianza_a_b,
  SAFE_DIVIDE(p.canastas_con_ambos, fb.canastas_con_item) AS confianza_b_a,
  SAFE_DIVIDE(SAFE_DIVIDE(p.canastas_con_ambos, tc.n), fa.support_item * fb.support_item) AS lift
FROM pares_canasta_ty p
INNER JOIN items_frecuentes_ty fa ON fa.item_id = p.item_a_id
INNER JOIN items_frecuentes_ty fb ON fb.item_id = p.item_b_id
CROSS JOIN (SELECT n FROM total_canastas WHERE periodo = 'OCT_TY_2025') tc;

-- =============================================================================
-- RESULTADO 1: bookkeeping -- umbral dinámico usado y tamaño del universo
-- =============================================================================
SELECT
  min_items_canasta AS umbral_canasta_usado,
  (SELECT n FROM total_canastas WHERE periodo='OCT_TY_2025') AS canastas_calificadas_oct_ty_2025,
  (SELECT n FROM total_canastas WHERE periodo='OCT_LY_2024') AS canastas_calificadas_oct_ly_2024,
  (SELECT COUNT(*) FROM items_frecuentes_ty) AS items_frecuentes_oct_ty_2025,
  (SELECT COUNT(*) FROM pares_canasta_ty)    AS pares_generados_oct_ty_2025;

-- =============================================================================
-- RESULTADO 2: DIAGNÓSTICO DE CONFIANZA -- pares donde al menos un lado es
-- temático (Día de Muertos/Halloween), a varios niveles de umbral. Se corre
-- ANTES de fijar cualquier umbral de venta cruzada (regla del playbook).
-- =============================================================================
SELECT
  COUNTIF(GREATEST(confianza_a_b, confianza_b_a) >= 0.70) AS pares_ge_70,
  COUNTIF(GREATEST(confianza_a_b, confianza_b_a) >= 0.50) AS pares_ge_50,
  COUNTIF(GREATEST(confianza_a_b, confianza_b_a) >= 0.40) AS pares_ge_40,
  COUNTIF(GREATEST(confianza_a_b, confianza_b_a) >= 0.30) AS pares_ge_30,
  COUNTIF(GREATEST(confianza_a_b, confianza_b_a) >= 0.20) AS pares_ge_20,
  COUNTIF(GREATEST(confianza_a_b, confianza_b_a) >= 0.10) AS pares_ge_10,
  COUNTIF(GREATEST(confianza_a_b, confianza_b_a) >= 0.05) AS pares_ge_05,
  COUNT(*) AS pares_totales_tematicos
FROM resultado_ty
WHERE item_a_tematico OR item_b_tematico;

-- =============================================================================
-- RESULTADO 3: TODOS los pares TEMÁTICO <-> PERECEDEROS (cualquier
-- confianza) -- para verificar si existe un ancla real de Perecederos
-- conectada al momento Día de Muertos/Halloween, sin forzar nada.
-- =============================================================================
SELECT
  item_a_id, item_a_desc, item_a_bucket, item_a_tematico,
  item_b_id, item_b_desc, item_b_bucket, item_b_tematico,
  canastas_con_ambos, canastas_con_a, canastas_con_b,
  ROUND(support_par,6) AS support_par,
  ROUND(confianza_a_b,4) AS confianza_a_b,
  ROUND(confianza_b_a,4) AS confianza_b_a,
  ROUND(lift,3) AS lift
FROM resultado_ty
WHERE (item_a_tematico AND item_b_bucket = 'PERECEDEROS')
   OR (item_b_tematico AND item_a_bucket = 'PERECEDEROS')
ORDER BY GREATEST(confianza_a_b, confianza_b_a) DESC;

-- =============================================================================
-- RESULTADO 4: universo completo de candidatos de cross-sell -- pares
-- donde al menos un lado es TEMÁTICO y el otro cae en ABARROTES / IMPULSO /
-- PERECEDEROS / SALUD Y BIENESTAR / FRESH, con la barra de "fuerte" (5% +
-- lift >= 1.2), para armar la canasta de 20 items con datos reales.
-- =============================================================================
SELECT
  item_a_id, item_a_desc, item_a_bucket, item_a_tematico,
  item_b_id, item_b_desc, item_b_bucket, item_b_tematico,
  canastas_con_ambos, canastas_con_a, canastas_con_b,
  ROUND(support_par,6) AS support_par,
  ROUND(confianza_a_b,4) AS confianza_a_b,
  ROUND(confianza_b_a,4) AS confianza_b_a,
  ROUND(lift,3) AS lift
FROM resultado_ty
WHERE (item_a_tematico OR item_b_tematico)
  AND GREATEST(confianza_a_b, confianza_b_a) >= min_confidence_fuerte
  AND lift >= min_lift
QUALIFY ROW_NUMBER() OVER (ORDER BY lift DESC, GREATEST(confianza_a_b, confianza_b_a) DESC) <= top_n
ORDER BY lift DESC;

-- =============================================================================
-- RESULTADO 5: TY vs LY a nivel ITEM (piezas y venta) -- para todos los
-- items frecuentes de Oct-2025 (incluye temáticos + no temáticos), con su
-- correspondiente Oct-2024 (si existía). Base para armar el comparativo de
-- los 20 items finales.
-- =============================================================================
SELECT
  f.item_id, f.item_desc, f.bucket_negocio, f.is_tematico,
  f.canastas_con_item AS canastas_oct_ty_2025,
  IFNULL(ty.piezas,0)  AS piezas_oct_ty_2025,
  IFNULL(ty.venta,0)   AS venta_oct_ty_2025,
  IFNULL(ly.canastas,0) AS canastas_oct_ly_2024,
  IFNULL(ly.piezas,0)  AS piezas_oct_ly_2024,
  IFNULL(ly.venta,0)   AS venta_oct_ly_2024
FROM items_frecuentes_ty f
LEFT JOIN (
  SELECT item_id, SUM(piezas) AS piezas, ROUND(SUM(monto),2) AS venta
  FROM lineas_crudas WHERE periodo='OCT_TY_2025' GROUP BY item_id
) ty ON ty.item_id = f.item_id
LEFT JOIN (
  SELECT item_id, COUNT(DISTINCT order_nbr) AS canastas, SUM(piezas) AS piezas, ROUND(SUM(monto),2) AS venta
  FROM lineas_crudas WHERE periodo='OCT_LY_2024' GROUP BY item_id
) ly ON ly.item_id = f.item_id
ORDER BY venta_oct_ty_2025 DESC;

-- =============================================================================
-- RESULTADO 6: TY vs LY a nivel CATEGORÍA (bucket de negocio), piezas y
-- venta, para los 5 buckets (todo Octubre completo, sin filtro de canasta
-- calificada -- es el universo total de ventas válidas del mes).
-- =============================================================================
SELECT
  bucket_negocio,
  COUNTIF(periodo='OCT_TY_2025') AS lineas_oct_ty_2025,
  SUM(IF(periodo='OCT_TY_2025', piezas, 0)) AS piezas_oct_ty_2025,
  ROUND(SUM(IF(periodo='OCT_TY_2025', monto, 0)),2) AS venta_oct_ty_2025,
  SUM(IF(periodo='OCT_LY_2024', piezas, 0)) AS piezas_oct_ly_2024,
  ROUND(SUM(IF(periodo='OCT_LY_2024', monto, 0)),2) AS venta_oct_ly_2024
FROM lineas_crudas
GROUP BY bucket_negocio
ORDER BY venta_oct_ty_2025 DESC;

-- =============================================================================
-- RESULTADO 7: ESTACIONALIDAD dentro de Octubre -- venta por semana
-- (bloques de 7 días desde el 1-oct) para TY-2025 y LY-2024, universo
-- completo (5 buckets) y, por separado, SOLO items temáticos. Señal
-- direccional (n=2 años -- ver limitación documentada arriba).
-- =============================================================================
SELECT
  CASE
    WHEN EXTRACT(DAY FROM fecha_compra) BETWEEN 1 AND 7  THEN 'Semana 1 (1-7)'
    WHEN EXTRACT(DAY FROM fecha_compra) BETWEEN 8 AND 14 THEN 'Semana 2 (8-14)'
    WHEN EXTRACT(DAY FROM fecha_compra) BETWEEN 15 AND 21 THEN 'Semana 3 (15-21)'
    WHEN EXTRACT(DAY FROM fecha_compra) BETWEEN 22 AND 28 THEN 'Semana 4 (22-28)'
    ELSE 'Semana 5 (29-31, previo inmediato a Día de Muertos)'
  END AS semana_octubre,
  periodo,
  SUM(IF(is_tematico, piezas, 0)) AS piezas_tematicos,
  ROUND(SUM(IF(is_tematico, monto, 0)),2) AS venta_tematicos,
  SUM(piezas) AS piezas_totales_universo,
  ROUND(SUM(monto),2) AS venta_total_universo
FROM lineas_crudas
GROUP BY semana_octubre, periodo
ORDER BY periodo, semana_octubre;


-- VALIDACION DE EXCLUSION: debe devolver 0 filas y 0 ventas/piezas
-- en la salida filtrada del pipeline, no en la fuente cruda.
SELECT LPAD(CAST(item_id AS STRING), 9, '0') AS item_id,
       COUNT(*) AS lineas, SUM(piezas) AS piezas,
       ROUND(SUM(monto),2) AS venta
FROM lineas_crudas
WHERE LPAD(CAST(item_id AS STRING), 9, '0') IN UNNEST(excluded_items)
GROUP BY item_id
ORDER BY item_id;

-- =============================================================================
-- RESULTADOS POST-EXCLUSION (corrida real 23-sep-2026, via bq CLI, job padre
-- bqjob_r1389d206c4da2fbc_000001a0cfbd070d_1) -- documentados aqui para no
-- repetir el diagnostico. Validacion de exclusion: 0 FILAS (limpio).
--
--   umbral_canasta_usado = 7 (sin cambio)
--   canastas_calificadas_oct_ty_2025 = 170,446 (baja de 192,035 -- efecto
--     esperado de quitar 19 SKUs de alto volumen: algunas canastas que solo
--     calificaban gracias a esos SKUs ya no llegan al umbral de 7 items)
--   canastas_calificadas_oct_ly_2024 = 124,211
--   items_frecuentes_oct_ty_2025 = 1,734 | pares_generados = 1,172,119
--   Diagnostico confianza (pares tematicos, sin cambio material vs 09-sep):
--     >=70%:0 | >=50%:0 | >=40%:1 | >=30%:7 | >=20%:36 | >=10%:108 | >=5%:338
--     de 8,046 pares tematicos totales
--
--   CATEGORIA TY vs LY (recalculado, reemplaza los numeros del 09-sep que
--   incluian los 19 SKUs de ruido -- ver weekend_consumption_dia_muertos_
--   exclusiones_20260923.md seccion 1 para la tabla completa):
--     Fresh +130.62% venta / +88.59% piezas (antes +127.8%/+90.8%)
--     Perecederos +52.52% venta / +39.14% piezas (antes +52.1%/+38.2%)
--     Abarrotes +45.65% venta / +33.34% piezas (antes +46.4%/+33.8%)
--     Impulso +32.16% venta / +25.03% piezas (antes +34.7%/+28.3%, el mayor
--       ajuste: 4 de los 19 excluidos caian en IMPULSO -- aguas purificadas
--       mal clasificadas por SQUAD + pan de caja blanco)
--     Salud y Bienestar +17.28% venta / +10.99% piezas (antes +18.1%/+11.5%)
--
--   PULL DE ITEMS: de los 20 originales, 5 fueron excluidos directamente
--   (000254784 Huevo Blanco, 000263093 Soft Cotton, 980002314 Crema
--   Avellana, 000718515 Nutrioli Aceite, 980016043 Agua Purificada) y 1 mas
--   (000084281 Suavitel DC) dejo de cumplir la barra de "fuerte" (conf>=5%+
--   lift>=1.2) de forma organica tras el recalculo del universo de canastas
--   -- ya era la senal mas floja del pull original. Los candidatos nuevos de
--   Salud y Bienestar que si sobreviven la poda (gripa-tos, rastrillos,
--   desodorante, alimento para perro -- todos jalados solo por el ancla de
--   dulces) son el mismo tipo de ruido de canasta grande, ninguno defendible
--   como cross-sell tematico. RECOMENDACION: pull queda en 14 items (6
--   anclas + 5 Abarrotes + 3 Perecederos), SIN Salud y Bienestar -- mas
--   chico pero mas honesto que forzar un reemplazo debil.
--   CSV intermedio (INCOMPLETO, NO usar como final): bigquery_results/canasta_dia_muertos_14items_POST_EXCLUSION_20260923.csv

-- =============================================================================
-- CORRECCION URGENTE (23-sep-2026, misma sesion, horas despues): el usuario
-- aclaro que la canasta SIEMPRE debe tener EXACTAMENTE 20 items -- la
-- exclusion de los 19 SKUs solo debe QUITARLOS del universo, y el Apriori
-- debe RECALCULAR/REEMPLAZAR con candidatos reales, nunca reducir el pull
-- ni eliminar un bucket completo por conveniencia. La version de 14 items de
-- arriba quedo OBSOLETA -- no se debe usar ni publicar.
--
-- Se re-escaneo bigquery_results/pares_fuerte_post_exclusion_20260923.csv
-- (325 pares con conf>=5%+lift>=1.2, universo YA sin los 19 excluidos) en
-- busca de 6 candidatos de reemplazo (2 Abarrotes, 2 Perecederos, 2 Salud y
-- Bienestar) que restauraran el pull a 20 sin repetir ningun SKU excluido:
--
--   ABARROTES:
--     980014852 6 350 ML SALSA PICANTE  <- ancla VERO MIX DULCE, conf 5.14%,
--       lift 2.73, 129 canastas de evidencia (reemplaza 980002314 Crema Avellana)
--     000191873 RG 2/500G MOLE XIQUENSE <- ancla MM MINIMUERTO, conf 5.99%,
--       lift 2.228, 22 canastas (volumen modesto, pero MOLE es plato tradicional
--       de ofrenda de Dia de Muertos -- defensibilidad tematica genuina;
--       reemplaza 000718515 Nutrioli Aceite)
--   PERECEDEROS:
--     981018204 MINI MAGNUM ALMENDRA    <- ancla MM MINIMUERTO, conf 6.15%,
--       lift 2.286, 85 canastas (reemplaza 000254784 Huevo Blanco)
--     000770256 12/100G DANETTE FLAN    <- ancla MM MINIMUERTO, conf 6.40%,
--       lift 2.38, 86 canastas (reemplaza 980016043 Agua Purificada)
--   SALUD Y BIENESTAR (bucket restaurado -- NO se elimina por conveniencia):
--     980014763 MM 6 PACK VELADORA      <- ancla MM 1KG PAN MUERTO, conf 5.32%,
--       lift 4.334, 19 canastas (volumen modesto, lift muy alto; VELADORAS son
--       genuinamente tematicas -- ofrenda de Dia de Muertos; reemplaza
--       000263093 Soft Cotton)
--     981038338 20PZ VELA LIMONERO      <- ancla VERO MIX DULCE, conf 5.75%,
--       lift 3.051, 20 canastas (tambien velas, mismo racional tematico;
--       reemplaza organicamente 000084281 Suavitel DC que ya no calificaba)
--
-- Ninguno de los 6 reemplazos pertenece a los 19 SKUs excluidos (validado
-- programaticamente: 0 overlap). Venta/delta TY vs LY de los 6 se obtuvo con
-- una query puntual (SELECT directo, sin DECLARE) sobre Sams_Ventas + catalogo
-- para Oct-2025 vs Oct-2024, mismos filtros Estatus='VENTA' que el resto del
-- pipeline.
--
-- Los dos SKUs de Pan de Muerto (000046531 "1K" y 000186909 "1KG") se
-- restauran a tratamiento NORMAL (NO se consolidan en una sola fila de
-- display): el usuario confirmo que, siendo SKUs distintos que pasan las
-- reglas de Apriori por si solos, deben participar como items independientes
-- salvo peticion explicita de exclusion (no se pidio). La consolidacion
-- visual aplicada en la iteracion anterior (14 items) queda revertida.
--
-- PULL FINAL RESTAURADO (20 items, validado 0 overlap con excluidos):
--   FRESH (4): Minimuerto, Pan de Muerto 1K, Pan de Muerto 1KG, Calabaza Halloween
--   IMPULSO (2): Vero Mix Dulce, Skwinkles Dulces
--   ABARROTES (7): Zucaritas, Lechera, Mayonesa c/Limon, Heinz Ketchup,
--                  Pumpkin Spice, Salsa Picante (nuevo), Mole Xiquense (nuevo)
--   PERECEDEROS (5): Crema Acida, Oaxaca Organico, Delight Pumpkin,
--                     Mini Magnum Almendra (nuevo), Danette Flan (nuevo)
--   SALUD Y BIENESTAR (2): MM 6 Pack Veladora (nuevo), 20PZ Vela Limonero (nuevo)
--
-- CSV final correcto (usar este, NO el de 14 items):
--   bigquery_results/canasta_dia_muertos_20items_RESTAURADA_20260923.csv
-- HTML regenerado: reportes/2026-10_weekend_consumption_dia_muertos/index.html (v5)
