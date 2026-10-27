-- =============================================================================
-- KW / MOMENTOS DE CONSUMO -- NOVIEMBRE, FRESH y PERECEDEROS (Sam's Club MX .com)
-- =============================================================================
-- Encargo: identificar las principales "KW" (keywords/intenciones/términos de
-- búsqueda) y los principales MOMENTOS DE CONSUMO para los departamentos
-- FRESH y PERECEDEROS durante noviembre, con comparativo TY vs LY, adyacencias
-- de canasta y recomendaciones de calendario comercial/landing.
--
-- INTERPRETACIÓN DE "KW" (documentada por requerimiento explícito del
-- usuario: "si 'KW' requiere interpretación, usa la más útil con los datos
-- disponibles y explícitala"):
--   Fuente ideal = `ecom.Top_Searches_Adobe_MOM` (Banner='Sams', Formato='Sams')
--   -> términos de búsqueda reales en Sams.com.mx vía Adobe Analytics, Top 50
--   términos/día. EXISTE y es la fuente correcta para "KW" literal.
--   HALLAZGO CRÍTICO (validado con COUNTIF antes de usarla, ver diagnóstico
--   abajo): esta tabla tiene un HUECO TOTAL en noviembre y diciembre 2025
--   (0 filas ambos meses) -- la serie salta de oct-2025 (28 días con dato)
--   directo a ene-2026. Noviembre 2026 tampoco existe porque aún no ocurre
--   (HOY = 2026-10-27). CONCLUSIÓN: no hay un solo día de noviembre, de
--   ningún año, con dato de búsqueda real en esta fuente. Esto es una
--   LIMITACIÓN DE COBERTURA DE LA FUENTE, no un supuesto ni un error de query.
--
--   Por lo tanto, "KW" se resuelve con DOS piezas complementarias, ambas
--   con datos reales (ninguna inventada):
--   (A) KW-PROXY POR TRANSACCIÓN: top item_desc (descripción de producto,
--       que en Sam's funciona como el "término" bajo el cual el cliente
--       encuentra/reconoce el producto) comprados en FRESH y PERECEDEROS
--       durante noviembre TY (2025, el noviembre completo más reciente
--       disponible -- noviembre 2026 aún no ocurre) y LY (2024), rankeado
--       por venta/piezas/crecimiento. Esto es compra REAL, no intención de
--       búsqueda, pero es el proxy más defendible con datos disponibles.
--   (B) KW REAL DE ADOBE, fuera de noviembre pero lo más cercano posible:
--       se escanean los términos de búsqueda reales de Sams.com.mx en los
--       meses que SÍ tienen dato alrededor de noviembre (sep-oct 2025 como
--       "previo inmediato a noviembre" de referencia histórica, y oct-2026
--       como la señal más fresca justo antes del noviembre que se está
--       planeando), filtrados a vocabulario de Fresh/Perecederos. Se usa
--       EXCLUSIVAMENTE como señal DIRECCIONAL de qué tipo de términos
--       genéricos de la categoría tienen volumen de búsqueda -- NUNCA se
--       presenta como "dato de noviembre".
--
-- MOMENTOS DE CONSUMO: se resuelven con datos 100% reales de Sams_Ventas,
-- descomponiendo noviembre TY/LY por semana calendario y por fin de semana
-- vs entre semana, dentro del universo FRESH+PERECEDEROS. Los momentos de
-- negocio (Buen Fin, Día de Muertos, Revolución Mexicana, Thanksgiving) se
-- mapean a fechas reales -- ver sección de EVIDENCIA vs SUPUESTOS más abajo
-- y en el reporte entregado al usuario.
--
-- PERIODOS (mismo criterio que el query maestro query_adyacencias_canasta_
-- apriori.sql -- noviembre 2026 aún no ocurre, HOY=2026-10-27):
--   TY_NOV = Noviembre 2025 completo (01 al 30) -- noviembre más reciente
--            disponible en la fuente, usado para proyectar nov-2026.
--   LY_NOV = Noviembre 2024 completo (01 al 30) -- referencia año anterior.
--
-- MOTOR: mismo Apriori de 2 niveles, mismo mapeo SQUAD->bucket, mismo dedup
-- de catálogo, mismo LPAD a 9 dígitos, misma canasta mínima dinámica
-- (GREATEST(2, ROUND(AVG(piezas)/2))) que el query maestro. Ancla de negocio:
-- FRESH y PERECEDEROS (se reporta tanto adyacencia intra-bucket como
-- cross-bucket hacia Abarrotes/Impulso/Salud y Bienestar).
--
-- NOTA DE EJECUCIÓN: el CLI `bq` no pudo autenticarse en esta sesión (mismo
-- problema recurrente de gcloud reauth no interactivo). Igual que en
-- query_weekend_dia_muertos_octubre.sql, el pipeline de abajo (con
-- DECLARE/CREATE TEMP TABLE) es la versión canónica/reproducible para correr
-- con `bq query --use_legacy_sql=false` cuando haya sesión interactiva. La
-- corrida real de esta sesión se hizo como SELECTs equivalentes con WITH-CTEs
-- vía bigquery_execute_query -- resultados documentados en el reporte y en
-- bigquery_results/.
-- =============================================================================

DECLARE ty_inicio DATE DEFAULT DATE '2025-11-01';
DECLARE ty_fin    DATE DEFAULT DATE '2025-11-30';
DECLARE ly_inicio DATE DEFAULT DATE '2024-11-01';
DECLARE ly_fin    DATE DEFAULT DATE '2024-11-30';

DECLARE min_items_canasta INT64;                  -- dinámico, mitad del promedio real de piezas/orden (universo calificado, TY+LY combinado)
DECLARE min_support       FLOAT64 DEFAULT 0.001;  -- 0.1% -> poda Apriori nivel 1, por periodo
DECLARE min_confidence    FLOAT64 DEFAULT 0.05;   -- 5% -> barra de "fuerte" (igual que el query maestro)
DECLARE min_lift          FLOAT64 DEFAULT 1.2;
DECLARE top_n             INT64   DEFAULT 500;

-- -----------------------------------------------------------------------------
-- 1) Item -> bucket de negocio
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
-- 2) Líneas crudas de Noviembre TY (2025) y LY (2024)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE lineas_crudas AS
SELECT
  CASE
    WHEN v.sales_order_detail_order_created_date BETWEEN ty_inicio AND ty_fin THEN 'NOV_TY_2025'
    WHEN v.sales_order_detail_order_created_date BETWEEN ly_inicio AND ly_fin THEN 'NOV_LY_2024'
  END AS periodo,
  v.sales_order_detail_order_nbr        AS order_nbr,
  v.sales_order_detail_order_created_date AS fecha_compra,
  v.sales_order_detail_item_id          AS item_id,
  v.sales_order_detail_item_short_desc  AS item_desc,
  v.sales_order_detail_commercial_sale_qty_base AS piezas,
  v.sales_order_detail_net_paid_orders_wo_shipping_amount_1 AS monto,
  cb.bucket_negocio
FROM `wmt-mx-dl-controlledmgzn-prod.ecom.Sams_Ventas` v
INNER JOIN catalogo_bucket cb ON v.sales_order_detail_item_id = cb.item_id
WHERE v.Estatus = 'VENTA'
  AND v.sales_order_detail_order_nbr IS NOT NULL
  AND (
    v.sales_order_detail_order_created_date BETWEEN ty_inicio AND ty_fin
    OR v.sales_order_detail_order_created_date BETWEEN ly_inicio AND ly_fin
  );

-- -----------------------------------------------------------------------------
-- 3) Umbral dinámico de canasta calificada
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
-- 4) Canastas calificadas por periodo (mismo umbral TY/LY)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE lineas_calificadas AS
SELECT DISTINCT periodo, order_nbr, item_id, item_desc, bucket_negocio
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
-- 5) NIVEL 1 Apriori (poda por soporte), POR PERIODO
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE items_frecuentes AS
SELECT
  ci.periodo, ci.item_id,
  ANY_VALUE(ci.item_desc)      AS item_desc,
  ANY_VALUE(ci.bucket_negocio) AS bucket_negocio,
  COUNT(DISTINCT ci.order_nbr) AS canastas_con_item,
  SAFE_DIVIDE(COUNT(DISTINCT ci.order_nbr), ANY_VALUE(tc.n)) AS support_item
FROM canasta_items ci
INNER JOIN total_canastas tc ON tc.periodo = ci.periodo
GROUP BY ci.periodo, ci.item_id
HAVING SAFE_DIVIDE(COUNT(DISTINCT ci.order_nbr), ANY_VALUE(tc.n)) >= min_support;

-- -----------------------------------------------------------------------------
-- 6) NIVEL 2 Apriori (pares), self-join dentro del mismo periodo
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE pares_canasta AS
SELECT
  a.periodo, a.item_id AS item_a_id, b.item_id AS item_b_id,
  COUNT(DISTINCT a.order_nbr) AS canastas_con_ambos
FROM canasta_items a
INNER JOIN canasta_items b
  ON a.periodo = b.periodo AND a.order_nbr = b.order_nbr AND a.item_id < b.item_id
INNER JOIN items_frecuentes fa ON fa.periodo = a.periodo AND fa.item_id = a.item_id
INNER JOIN items_frecuentes fb ON fb.periodo = b.periodo AND fb.item_id = b.item_id
GROUP BY a.periodo, item_a_id, item_b_id;

CREATE TEMP TABLE resultado_periodo AS
SELECT
  p.periodo,
  p.item_a_id, fa.item_desc AS item_a_desc, fa.bucket_negocio AS item_a_bucket,
  p.item_b_id, fb.item_desc AS item_b_desc, fb.bucket_negocio AS item_b_bucket,
  p.canastas_con_ambos, fa.canastas_con_item AS canastas_con_a, fb.canastas_con_item AS canastas_con_b,
  SAFE_DIVIDE(p.canastas_con_ambos, tc.n) AS support_par,
  SAFE_DIVIDE(p.canastas_con_ambos, fa.canastas_con_item) AS confianza_a_b,
  SAFE_DIVIDE(p.canastas_con_ambos, fb.canastas_con_item) AS confianza_b_a,
  SAFE_DIVIDE(SAFE_DIVIDE(p.canastas_con_ambos, tc.n), fa.support_item * fb.support_item) AS lift
FROM pares_canasta p
INNER JOIN items_frecuentes fa ON fa.periodo = p.periodo AND fa.item_id = p.item_a_id
INNER JOIN items_frecuentes fb ON fb.periodo = p.periodo AND fb.item_id = p.item_b_id
INNER JOIN total_canastas tc   ON tc.periodo = p.periodo;

CREATE TEMP TABLE resultado_periodo_flag AS
SELECT *, (lift >= min_lift AND GREATEST(confianza_a_b, confianza_b_a) >= min_confidence) AS es_fuerte
FROM resultado_periodo;

CREATE TEMP TABLE resultado_ty AS
SELECT item_a_id, item_a_desc, item_a_bucket, item_b_id, item_b_desc, item_b_bucket,
  canastas_con_ambos AS canastas_con_ambos_ty, support_par AS support_ty,
  confianza_a_b AS confianza_ty_a_b, confianza_b_a AS confianza_ty_b_a, lift AS lift_ty, es_fuerte AS fuerte_ty
FROM resultado_periodo_flag WHERE periodo = 'NOV_TY_2025';

CREATE TEMP TABLE resultado_ly AS
SELECT item_a_id, item_a_desc, item_a_bucket, item_b_id, item_b_desc, item_b_bucket,
  canastas_con_ambos AS canastas_con_ambos_ly, support_par AS support_ly,
  confianza_a_b AS confianza_ly_a_b, confianza_b_a AS confianza_ly_b_a, lift AS lift_ly, es_fuerte AS fuerte_ly
FROM resultado_periodo_flag WHERE periodo = 'NOV_LY_2024';

-- =============================================================================
-- RESULTADO 1: bookkeeping
-- =============================================================================
SELECT
  min_items_canasta AS umbral_canasta_usado,
  (SELECT n FROM total_canastas WHERE periodo='NOV_TY_2025') AS canastas_calificadas_nov_ty_2025,
  (SELECT n FROM total_canastas WHERE periodo='NOV_LY_2024') AS canastas_calificadas_nov_ly_2024,
  (SELECT COUNT(*) FROM items_frecuentes WHERE periodo='NOV_TY_2025') AS items_frecuentes_ty,
  (SELECT COUNT(*) FROM items_frecuentes WHERE periodo='NOV_LY_2024') AS items_frecuentes_ly,
  (SELECT COUNT(*) FROM pares_canasta WHERE periodo='NOV_TY_2025') AS pares_ty,
  (SELECT COUNT(*) FROM pares_canasta WHERE periodo='NOV_LY_2024') AS pares_ly;

-- =============================================================================
-- RESULTADO 2: comparativo TY vs LY, SOLO pares donde al menos un lado es
-- FRESH o PERECEDEROS (ancla pedida por el usuario)
-- =============================================================================
SELECT
  min_items_canasta AS umbral_canasta_usado,
  COALESCE(t.item_a_id, l.item_a_id) AS item_a_id, COALESCE(t.item_a_desc, l.item_a_desc) AS item_a_desc,
  COALESCE(t.item_a_bucket, l.item_a_bucket) AS item_a_bucket,
  COALESCE(t.item_b_id, l.item_b_id) AS item_b_id, COALESCE(t.item_b_desc, l.item_b_desc) AS item_b_desc,
  COALESCE(t.item_b_bucket, l.item_b_bucket) AS item_b_bucket,
  t.canastas_con_ambos_ty, t.support_ty, t.confianza_ty_a_b, t.confianza_ty_b_a, t.lift_ty, IFNULL(t.fuerte_ty, FALSE) AS fuerte_ty,
  l.canastas_con_ambos_ly, l.support_ly, l.confianza_ly_a_b, l.confianza_ly_b_a, l.lift_ly, IFNULL(l.fuerte_ly, FALSE) AS fuerte_ly,
  CASE
    WHEN IFNULL(t.fuerte_ty, FALSE) AND IFNULL(l.fuerte_ly, FALSE) THEN 'CONSISTENTE (ambos noviembres)'
    WHEN IFNULL(t.fuerte_ty, FALSE) AND NOT IFNULL(l.fuerte_ly, FALSE) THEN 'EMERGENTE (solo Nov-2025)'
    WHEN NOT IFNULL(t.fuerte_ty, FALSE) AND IFNULL(l.fuerte_ly, FALSE) THEN 'ESTACIONAL/HISTORICA (solo Nov-2024)'
    ELSE 'DEBIL'
  END AS tipo_adyacencia
FROM resultado_ty t
FULL OUTER JOIN resultado_ly l ON t.item_a_id = l.item_a_id AND t.item_b_id = l.item_b_id
WHERE (IFNULL(t.fuerte_ty, FALSE) OR IFNULL(l.fuerte_ly, FALSE))
  AND (COALESCE(t.item_a_bucket, l.item_a_bucket) IN ('FRESH','PERECEDEROS')
       OR COALESCE(t.item_b_bucket, l.item_b_bucket) IN ('FRESH','PERECEDEROS'))
QUALIFY ROW_NUMBER() OVER (ORDER BY GREATEST(IFNULL(t.lift_ty,0), IFNULL(l.lift_ly,0)) DESC) <= top_n
ORDER BY GREATEST(IFNULL(t.lift_ty,0), IFNULL(l.lift_ly,0)) DESC;

-- =============================================================================
-- RESULTADO 3: momentos de consumo -- venta/piezas por semana calendario y
-- por fin de semana vs entre semana, SOLO Fresh + Perecederos, TY vs LY
-- =============================================================================
SELECT
  periodo,
  CASE
    WHEN EXTRACT(DAY FROM fecha_compra) BETWEEN 1 AND 2  THEN 'Semana 0 (1-2, cola Día de Muertos)'
    WHEN EXTRACT(DAY FROM fecha_compra) BETWEEN 3 AND 9  THEN 'Semana 1 (3-9)'
    WHEN EXTRACT(DAY FROM fecha_compra) BETWEEN 10 AND 16 THEN 'Semana 2 (10-16, Buen Fin/Revolución)'
    WHEN EXTRACT(DAY FROM fecha_compra) BETWEEN 17 AND 23 THEN 'Semana 3 (17-23)'
    ELSE 'Semana 4 (24-30, cierre de mes/prep. diciembre)'
  END AS bloque_mes,
  EXTRACT(DAYOFWEEK FROM fecha_compra) IN (1,7) AS es_fin_de_semana,
  bucket_negocio,
  COUNT(DISTINCT order_nbr) AS canastas,
  SUM(piezas) AS piezas,
  ROUND(SUM(monto),2) AS venta
FROM lineas_crudas
WHERE bucket_negocio IN ('FRESH','PERECEDEROS')
GROUP BY periodo, bloque_mes, es_fin_de_semana, bucket_negocio
ORDER BY periodo, bloque_mes, es_fin_de_semana;

-- =============================================================================
-- RESULTADO 4 (KW-PROXY A): top item_desc por venta, FRESH + PERECEDEROS,
-- Noviembre TY vs LY -- proxy de "qué buscan/qué quieren" vía lo que compran
-- =============================================================================
SELECT
  bucket_negocio, item_id, item_desc,
  SUM(IF(periodo='NOV_TY_2025', piezas, 0)) AS piezas_ty,
  ROUND(SUM(IF(periodo='NOV_TY_2025', monto, 0)),2) AS venta_ty,
  SUM(IF(periodo='NOV_LY_2024', piezas, 0)) AS piezas_ly,
  ROUND(SUM(IF(periodo='NOV_LY_2024', monto, 0)),2) AS venta_ly,
  ROUND(SAFE_DIVIDE(SUM(IF(periodo='NOV_TY_2025', monto, 0)) - SUM(IF(periodo='NOV_LY_2024', monto, 0)), NULLIF(SUM(IF(periodo='NOV_LY_2024', monto, 0)),0))*100, 1) AS crecimiento_venta_pct
FROM lineas_crudas
WHERE bucket_negocio IN ('FRESH','PERECEDEROS')
GROUP BY bucket_negocio, item_id, item_desc
QUALIFY ROW_NUMBER() OVER (PARTITION BY bucket_negocio ORDER BY venta_ty DESC) <= 25
ORDER BY bucket_negocio, venta_ty DESC;

-- =============================================================================
-- HALLAZGOS REALES DE LA CORRIDA (27-oct-2026, via bigquery_execute_query con
-- WITH-CTEs equivalentes -- bq CLI no disponible, mismo problema de gcloud
-- reauth no interactivo documentado en el resto del repo). Se documentan aqui
-- para no repetir el diagnostico ni inventar numeros en corridas futuras.
-- =============================================================================
--
-- BOOKKEEPING: umbral_canasta_usado = 7 (igual que Octubre -- promedio de
-- piezas/orden similar entre meses). canastas_calificadas_nov_ty_2025 =
-- 190,268 | canastas_calificadas_nov_ly_2024 = 149,216 | items_frecuentes_ty
-- = 1,683 | items_frecuentes_ly = 1,744 | pares_ty = 1,108,684 | pares_ly =
-- 1,127,799.
--
-- *** HUECO DE DATOS DETECTADO Y VALIDADO (no es un supuesto): el dia
-- 2025-11-20 (Miercoles) tiene CERO filas en ecom.Sams_Ventas para CUALQUIER
-- Estatus (VENTA/DEVOLUCION/ANTICIPO/WISDOM-NULL) -- validado con query
-- directa agrupada por Estatus, 0 filas. Es el UNICO dia faltante en todo
-- noviembre 2025 (Nov-2024 esta completo, 30/30 dias). Efecto: todos los
-- totales de NOV_TY_2025 en este analisis son de 29/30 dias reales -- un
-- subconteo leve (~3.3%) de piezas/venta/canastas, NO una caida real de
-- demanda ese dia. No se interpolo ni se corrigio el hueco (no inventar
-- datos) -- se reporta como limitacion.
--
-- CATEGORIA TY vs LY (noviembre completo, 5 buckets no aplica aqui, solo
-- Fresh+Perecederos, universo total de ventas validas sin filtro de canasta
-- calificada): PERECEDEROS venta_ty=$146,519,995.99 (222,815 canastas) vs
-- venta_ly=$103,524,741.41 (166,261 canastas) => +41.5% venta. FRESH
-- venta_ty=$29,497,153.73 (105,198 canastas) vs venta_ly=$14,938,425.03
-- (63,639 canastas) => +97.4% venta (el crecimiento mas fuerte de los 5
-- buckets de negocio en noviembre TY vs LY).
--
-- DIAGNOSTICO DE CONFIANZA (pares donde >=1 lado es FRESH o PERECEDEROS,
-- NOV_TY_2025, 507,355 pares totales de ese universo): >=70%: 0 | >=50%: 3
-- | >=40%: 4 | >=30%: 35 | >=20%: 133 | >=10%: 2,409 | >=5%: 17,196. Salto
-- 20%->10% es de 18x -- se confirma el mismo patron de cola larga ya
-- documentado en el query maestro. Umbral de venta cruzada fijado en 30%
-- (mismo criterio: barra alta con variedad real, 35 pares vs 3 a 50%).
--
-- VENTA CRUZADA @30% (Fresh/Perecederos, NOV_TY_2025): 35 pares de alta
-- confianza, 6,538 canastas (3.44% de las 190,268 calificadas), $25,628,167
-- capturados. Top pares por confianza: helados Member's Mark 4.7L entre
-- sabores (fresa<->vainilla 67.6%/28.5%, chocolate<->vainilla 60.5%/29.8%,
-- chocolate<->fresa 49.6%/57.9%, cookies&cream<->vainilla 40.0%/11.9% --
-- canasta de "surtido de sabores" muy fuerte y consistente) y frambuesa<->
-- blueberries (44.9%/6.1%, canasta de berries mixtos).
--
-- MOMENTOS DE CONSUMO (evidencia real, ver detalle completo en el reporte
-- entregado al usuario): el dia de MAYOR venta de Fresh+Perecederos en
-- AMBOS noviembres (2024 y 2025) es el viernes de Black Friday
-- (29-nov-2024 parcialmente, pero el pico real fue 28-nov-2024 jueves =
-- Thanksgiving US ese año-- Perecederos $10.08M/15,044 canastas -- vs
-- 28-nov-2025 viernes = Black Friday ese año -- Perecederos $7.80M/11,222
-- canastas, Fresh $1.39M/5,081 canastas, ambos los picos absolutos del mes).
-- El "Buen Fin" calendario (semana 10-16 nov en el bloqueo usado aqui) NO
-- genera un pico comparable en Fresh/Perecederos -- consistente con que las
-- promociones de Buen Fin en Mexico se concentran mas en Mercancias
-- Generales/Electronica que en consumibles. El lunes de Revolucion Mexicana
-- (18-nov-2024 y 17-nov-2025, 3er lunes del mes) SI genera un pico
-- secundario notable, especialmente en FRESH (17-nov-2025: 5,246 canastas,
-- el dia con MAS canastas Fresh de todo el mes hasta ese punto, superando
-- incluso a Black Friday en conteo de canastas aunque no en venta total).
--
-- KW (keywords/busqueda): ver seccion de interpretacion al inicio del
-- archivo. Fuente ideal (ecom.Top_Searches_Adobe_MOM, Banner=Sams) tiene
-- CERO filas en noviembre y diciembre 2025 (validado con COUNTIF, 0 y 0) --
-- hueco total de la fuente curada top-50/dia. Existe una fuente RAW mas rica
-- (wmt-intl-cons-mc-mx-prod.mx_csd_secured_dl_tables.sams_mx_csd_adobe_event,
-- particionada por ds, campos prop14/evar2 = KW real) que SI tiene
-- noviembre 2025 completo -- pero el costo de escanear UN SOLO DIA fue
-- ~500 GB procesados (confirmado 2 veces, sin cache). Escalar a mes
-- completo (~15 TB) es prohibitivo sin antes construir una tabla agregada
-- diaria/mensual (recomendacion de accion, ver reporte). Se extrajo UNA
-- muestra puntual (28-nov-2025, Black Friday) como spot-check real --
-- confirma terminos de Fresh/Perecederos con volumen genuino (leche #6
-- con 91,951 instancias, queso 40,136, huevo 33,057, jamon 27,119, yogurt
-- 23,122, pavo 9,064 -- este ultimo NUNCA aparece en el Top 50/dia de
-- Top_Searches_Adobe_MOM en todo su historico Ene-2025 a Oct-2026, lo que
-- confirma que la fuente curada no captura terminos estacionales de nicho
-- aunque tengan demanda real).

