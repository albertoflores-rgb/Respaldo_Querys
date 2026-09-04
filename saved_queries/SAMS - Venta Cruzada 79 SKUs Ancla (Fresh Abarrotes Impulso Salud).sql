-- =============================================================================
-- SAMS - VENTA CRUZADA 79 SKUS ANCLA (Fresh/Abarrotes/Impulso/Salud y Bienestar)
-- Escalamiento del piloto de 4 anclas a los 79 SKUs ancla del listado de
-- Category, aplicando los 3 ajustes acordados tras el piloto:
--   1) JOIN CORREGIDO item_id = LPAD(CAST(ITEM_ID AS STRING),9,'0') (ver
--      hallazgo critico documentado en query_piloto_4_anclas_venta_cruzada.sql:
--      sales_order_detail_item_id SIEMPRE viene con 9 digitos; el catalogo
--      pierde ceros a la izquierda al hacer CAST simple -> sin el LPAD se
--      pierde el match de TODOS los SKUs con <9 digitos, ~37% de la venta).
--   2) DIAGNOSTICO DE CONFIANZA AUTOMATIZADO POR ANCLA (no un umbral fijo
--      30%/10% para las 79): para cada ancla se corre la escalera de
--      confianza 70/50/40/30/20/10/5% (SELECT "ladder" mas abajo) y se elige
--      automaticamente el escalon MAS ALTO que sostenga >= 3 pares con
--      variedad real; si ni al 5% hay 3 pares, se usa 5% y se marca
--      advertencia. Con las 79 anclas reales: ningun ancla quedo con
--      "advertencia_pocos_pares" (todas alcanzaron >=3 pares en algun
--      escalon), pero los umbrales elegidos van de 5% a 30% segun el ancla
--      -- confirma que un numero fijo (30% o 10%) NO es correcto a nivel SKU.
--   3) SEPARACION INTRA-BUCKET (mismo bucket real de catalogo que el ancla,
--      = juego de surtido/anaquel) vs CROSS-BUCKET (bucket real distinto,
--      = candidato genuino a bundle/carrusel cruzado) usando el bucket REAL
--      de catalogo (columna anchor_bucket_real / companion_bucket), NO el
--      bucket que traia el listado del cliente (columna *_bucket_cliente,
--      que se conserva solo para referencia/QA).
--
-- ADVERTENCIAS DE CALIDAD DE DATO encontradas en el listado de 79 SKUs
-- (diagnostico corrido ANTES de la corrida completa, ver SELECT "diagnostico"
-- mas abajo):
--   - Los 79 SKUs SI matchean con catalogo y SI tienen ventas en los ultimos
--     180 dias (0 SIN_MATCH_CATALOGO, 0 SQUAD_EXCLUIDO, 0 SIN_VENTAS).
--   - 2 SKUs tienen la DESCRIPCION DEL CLIENTE COMPLETAMENTE DISTINTA a la
--     descripcion real en catalogo/ventas (mismo patron que el caso Nutella
--     del piloto -- posible SKU mal mapeado en el listado fuente):
--       * 000811780 -- cliente dice "300G NESCAFE DECAF", real es
--         "3/380GR RAJAS VERDES" (rajas de chile en lata, ABARROTES real vs
--         IMPULSO esperado). Se corrio la ancla CON el SKU tal cual vino
--         (produce resultados de venta cruzada de "rajas verdes", NO de cafe
--         descafeinado) -- si el cliente tiene el SKU correcto de Nescafe
--         Decaf, re-correr con ese.
--       * 981008308 -- cliente dice "3/380GR JALAPENO", real es
--         "MM 3K PINA EN TROZOS" (piña en trozos, ABARROTES real vs IMPULSO
--         esperado). Mismo tratamiento: se corrio tal cual, resultados son
--         de "piña en trozos", NO de jalapeños.
--   - 8 SKUs adicionales tienen el MISMO producto correcto pero el
--     BUCKET DE NEGOCIO que trae el listado del cliente no coincide con el
--     bucket real de catalogo (columna SQUAD) -- no es error de SKU, es
--     clasificacion de bucket distinta (ej. yogurts/helados/tortillas
--     etiquetados "FRESH" por el cliente en realidad viven en PERECEDEROS
--     via SQUAD "REFRIGERADOS, CONGELADOS Y BEBIDAS"; "MM PISTACHE CASCARA"
--     y "24/400 ML MULTISABOR" etiquetados SALUD por el cliente en realidad
--     son IMPULSO): 000070421, 980018560, 980002895, 981018204, 981022419,
--     981032472, 981050897, 981053172, 000111419, 000213109. La clasificacion
--     INTRA/CROSS-BUCKET de este query usa SIEMPRE el bucket REAL (catalogo),
--     no el del listado, para que la etiqueta sea consistente con el resto
--     del negocio.
--   - 18 anclas tienen VOLUMEN BAJO (<1,500 canastas totales en TY_90D,
--     algunas con <100) -- sus metricas de % de canastas con cruce son
--     direccionalmente correctas pero estadisticamente menos robustas que
--     las de alto volumen (ver columna canastas_totales_ancla_ty en el
--     resumen ejecutivo antes de accionar sobre ellas con presupuesto grande).
--
-- NOTA DE ENTORNO (sep-2026): en esta corrida el `bq` CLI del entorno tenia
-- las credenciales de usuario expiradas y requeria reauth interactiva
-- ("Reauthentication failed. cannot prompt during non-interactive execution"),
-- por lo que las 3 etapas de este query se ejecutaron como SELECTs
-- autocontenidos (CTEs) via el conector de BigQuery en vez de via `bq query`
-- con DECLARE/CREATE TEMP TABLE. Este archivo SI usa DECLARE/CREATE TEMP
-- TABLE (para quedar documentado y ser reutilizable en el futuro cuando la
-- auth de `bq` este vigente) -- es funcionalmente equivalente a los 3 SELECTs
-- que sí corrieron.
-- =============================================================================

DECLARE ty_inicio DATE DEFAULT DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY);
DECLARE ty_fin    DATE DEFAULT CURRENT_DATE();
DECLARE ly_inicio DATE DEFAULT DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 1 YEAR);
DECLARE ly_fin    DATE DEFAULT LAST_DAY(ly_inicio);
DECLARE min_items_canasta INT64;
DECLARE min_support FLOAT64 DEFAULT 0.001;   -- poda Nivel 1 (companeros, no anclas)
DECLARE min_confidence FLOAT64 DEFAULT 0.05; -- umbral "fuerte" general (comparativo TY vs LY)
DECLARE min_lift FLOAT64 DEFAULT 1.2;

CREATE TEMP TABLE anchors AS
SELECT * FROM UNNEST([
  STRUCT('980002895' AS raw_id, 'FRESH' AS bucket_cliente, '12/220GR DANUP YOGHU' AS desc_cliente),
  STRUCT('981032472' AS raw_id, 'FRESH' AS bucket_cliente, '12/120GRS YOGURT' AS desc_cliente),
  STRUCT('71228' AS raw_id, 'FRESH' AS bucket_cliente, 'CHAMPINON BLANCO' AS desc_cliente),
  STRUCT('980016775' AS raw_id, 'FRESH' AS bucket_cliente, 'MANZANA GALA' AS desc_cliente),
  STRUCT('981029562' AS raw_id, 'FRESH' AS bucket_cliente, 'AGUACATE HASS' AS desc_cliente),
  STRUCT('260293' AS raw_id, 'FRESH' AS bucket_cliente, 'LECHUGA HIDROPONICA' AS desc_cliente),
  STRUCT('69438' AS raw_id, 'FRESH' AS bucket_cliente, 'BROCOLI FLORETES' AS desc_cliente),
  STRUCT('981017622' AS raw_id, 'FRESH' AS bucket_cliente, 'LECHUGA SWEET CRUNCH' AS desc_cliente),
  STRUCT('980007149' AS raw_id, 'FRESH' AS bucket_cliente, 'PLATANO ORGANICO' AS desc_cliente),
  STRUCT('121432' AS raw_id, 'FRESH' AS bucket_cliente, 'CEBOLLA BLANCA' AS desc_cliente),
  STRUCT('45955' AS raw_id, 'FRESH' AS bucket_cliente, 'MM POLLO ROSTIZADO' AS desc_cliente),
  STRUCT('980042415' AS raw_id, 'FRESH' AS bucket_cliente, 'BROWNIE CHOCOLATE 27' AS desc_cliente),
  STRUCT('980042414' AS raw_id, 'FRESH' AS bucket_cliente, '825GR CINNAMON ROLL' AS desc_cliente),
  STRUCT('981050897' AS raw_id, 'FRESH' AS bucket_cliente, 'TORTILLAS DE MAIZ CR' AS desc_cliente),
  STRUCT('981053172' AS raw_id, 'FRESH' AS bucket_cliente, 'TORTILLA DE HARINA' AS desc_cliente),
  STRUCT('981018204' AS raw_id, 'FRESH' AS bucket_cliente, 'MINI MAGNUM ALMENDRA' AS desc_cliente),
  STRUCT('981022419' AS raw_id, 'FRESH' AS bucket_cliente, 'MAGNUM PALETA CUBIER' AS desc_cliente),
  STRUCT('673840' AS raw_id, 'FRESH' AS bucket_cliente, 'MM 900 GR MINI DONA' AS desc_cliente),
  STRUCT('981034447' AS raw_id, 'FRESH' AS bucket_cliente, 'MM GALLETAS CHOCOCHI' AS desc_cliente),
  STRUCT('374357' AS raw_id, 'FRESH' AS bucket_cliente, 'MM 10PZ BOLILLO 10PZ' AS desc_cliente),
  STRUCT('70421' AS raw_id, 'ABARROTES' AS bucket_cliente, '2.63 L JUGO NARANJA' AS desc_cliente),
  STRUCT('980018560' AS raw_id, 'ABARROTES' AS bucket_cliente, 'DELIGHT VAINILLA' AS desc_cliente),
  STRUCT('238812' AS raw_id, 'ABARROTES' AS bucket_cliente, '4/1KG CARNATION' AS desc_cliente),
  STRUCT('980029284' AS raw_id, 'ABARROTES' AS bucket_cliente, 'MM 1K SUSTITUTO' AS desc_cliente),
  STRUCT('214464' AS raw_id, 'ABARROTES' AS bucket_cliente, '8/140GR ATUN EN AGUA' AS desc_cliente),
  STRUCT('981007488' AS raw_id, 'ABARROTES' AS bucket_cliente, '900G LECHERA' AS desc_cliente),
  STRUCT('981036189' AS raw_id, 'ABARROTES' AS bucket_cliente, '200/8G CATSUP HEINZ' AS desc_cliente),
  STRUCT('6918' AS raw_id, 'ABARROTES' AS bucket_cliente, '980ML SALSA INGLESA' AS desc_cliente),
  STRUCT('980003072' AS raw_id, 'ABARROTES' AS bucket_cliente, 'MM 1.2K MERMELADA' AS desc_cliente),
  STRUCT('980001884' AS raw_id, 'ABARROTES' AS bucket_cliente, 'MM 1.2K JARABE MAPLE' AS desc_cliente),
  STRUCT('1343' AS raw_id, 'ABARROTES' AS bucket_cliente, '800ML JUGO MAGGI' AS desc_cliente),
  STRUCT('10693' AS raw_id, 'ABARROTES' AS bucket_cliente, '3K QUESO P/NACHOS' AS desc_cliente),
  STRUCT('677763' AS raw_id, 'ABARROTES' AS bucket_cliente, 'MM ACEITUNAS DESHUES' AS desc_cliente),
  STRUCT('980029327' AS raw_id, 'ABARROTES' AS bucket_cliente, 'MM 1L ACEITE OLIVA E' AS desc_cliente),
  STRUCT('980017302' AS raw_id, 'ABARROTES' AS bucket_cliente, 'MM REBANADA DE PIÑA' AS desc_cliente),
  STRUCT('980015802' AS raw_id, 'ABARROTES' AS bucket_cliente, 'ITALPASTA PASTA DE S' AS desc_cliente),
  STRUCT('4165' AS raw_id, 'ABARROTES' AS bucket_cliente, '2.9KG ELOTE DORADO E' AS desc_cliente),
  STRUCT('231658' AS raw_id, 'ABARROTES' AS bucket_cliente, '4L VALENTINA SALSA P' AS desc_cliente),
  STRUCT('94422' AS raw_id, 'ABARROTES' AS bucket_cliente, '1 KG NUTELLA CREMA' AS desc_cliente),
  STRUCT('811780' AS raw_id, 'IMPULSO' AS bucket_cliente, '300G NESCAFE DECAF' AS desc_cliente),
  STRUCT('981008308' AS raw_id, 'IMPULSO' AS bucket_cliente, '3/380GR JALAPENO' AS desc_cliente),
  STRUCT('981036721' AS raw_id, 'IMPULSO' AS bucket_cliente, 'PEKEPAKES' AS desc_cliente),
  STRUCT('981000276' AS raw_id, 'IMPULSO' AS bucket_cliente, 'KINDER DELICE' AS desc_cliente),
  STRUCT('845100' AS raw_id, 'IMPULSO' AS bucket_cliente, '2/2.54LT CLAMATO JUG' AS desc_cliente),
  STRUCT('980006523' AS raw_id, 'IMPULSO' AS bucket_cliente, 'GALLETAS OREO' AS desc_cliente),
  STRUCT('981003552' AS raw_id, 'IMPULSO' AS bucket_cliente, '24/600 ML GATORADE' AS desc_cliente),
  STRUCT('980043199' AS raw_id, 'IMPULSO' AS bucket_cliente, '12/1LT POWERADE' AS desc_cliente),
  STRUCT('981015640' AS raw_id, 'IMPULSO' AS bucket_cliente, '24/460ML ARIZONA' AS desc_cliente),
  STRUCT('981002940' AS raw_id, 'IMPULSO' AS bucket_cliente, 'TOSTADITAS SALMAS' AS desc_cliente),
  STRUCT('981006674' AS raw_id, 'IMPULSO' AS bucket_cliente, 'MIX MARINELA' AS desc_cliente),
  STRUCT('114792' AS raw_id, 'IMPULSO' AS bucket_cliente, 'MM KETTLE CHIPS' AS desc_cliente),
  STRUCT('981033504' AS raw_id, 'IMPULSO' AS bucket_cliente, 'MIX MARS' AS desc_cliente),
  STRUCT('326679' AS raw_id, 'IMPULSO' AS bucket_cliente, 'GALLETAS MARIAS' AS desc_cliente),
  STRUCT('332944' AS raw_id, 'IMPULSO' AS bucket_cliente, '2/1L JARABE NATURAL' AS desc_cliente),
  STRUCT('213109' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, '24/400 ML MULTISABOR' AS desc_cliente),
  STRUCT('111419' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, 'MM PISTACHE CASCARA' AS desc_cliente),
  STRUCT('146120' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, '6/100ML COLGATE MFP' AS desc_cliente),
  STRUCT('62961' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, 'TOALLAS FEMENINAS SA' AS desc_cliente),
  STRUCT('981004056' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, '150PZ SABA PANTI' AS desc_cliente),
  STRUCT('981018825' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, '50PZS KOTEX NOCTURNA' AS desc_cliente),
  STRUCT('110159' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, '4P GILLETTE COOL WAV' AS desc_cliente),
  STRUCT('143755' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, '16 PZ PRESTOBARBA RA' AS desc_cliente),
  STRUCT('981036536' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, '10+2 ESCUDO JABON EN' AS desc_cliente),
  STRUCT('980039540' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, '4L L&W JABON LIQUIDO' AS desc_cliente),
  STRUCT('980021945' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, '5 50G OLD SPICE DEO' AS desc_cliente),
  STRUCT('981003577' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, '3PZ 250ML NIVEA PO M' AS desc_cliente),
  STRUCT('980043008' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, '3P REXONA WOMEN POWD' AS desc_cliente),
  STRUCT('980043009' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, '3P REXONA MEN V8 DEO' AS desc_cliente),
  STRUCT('981015843' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, 'OFF! REPELENTE SPRAY' AS desc_cliente),
  STRUCT('980008357' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, 'METAMUCIL FIBRA LAXA' AS desc_cliente),
  STRUCT('981009536' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, 'THERAFLU SABOR LIMON' AS desc_cliente),
  STRUCT('155650' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, 'PEDIASURE PLUS POLVO' AS desc_cliente),
  STRUCT('980010697' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, 'FLANAX 550 MG 30 TAB' AS desc_cliente),
  STRUCT('980007307' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, 'SAL DE UVAS PICOT 6' AS desc_cliente),
  STRUCT('980026397' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, 'REDOXON AOX 3 PACK E' AS desc_cliente),
  STRUCT('980024640' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, '4/4.98 KG FRESHSTEP' AS desc_cliente),
  STRUCT('000251511' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, 'MM 210PZ BLSA GDE' AS desc_cliente),
  STRUCT('000064266' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, 'MM 90PZ BLSA JBO' AS desc_cliente),
  STRUCT('000251427' AS raw_id, 'SALUD Y BIENESTAR' AS bucket_cliente, 'MM 500PZ BLSA MED' AS desc_cliente)
]);

CREATE TEMP TABLE anchors_padded AS
SELECT LPAD(raw_id, 9, '0') AS item_id, bucket_cliente, desc_cliente FROM anchors;

-- -----------------------------------------------------------------------------
-- 0) DIAGNOSTICO de calidad de dato (correr y revisar ANTES del resto):
--    match a catalogo, bucket real vs esperado, ventas 180d, descripcion real
--    vs descripcion del listado del cliente.
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE catalogo_dedup_qa AS
SELECT * FROM (
  SELECT
    LPAD(CAST(ITEM_ID AS STRING), 9, '0') AS item_id,
    SQUAD, DESCRIPCION_UNO,
    CASE
      WHEN SQUAD = 'GROCERIES' THEN 'ABARROTES'
      WHEN SQUAD = 'IMPULSO' THEN 'IMPULSO'
      WHEN SQUAD = 'REFRIGERADOS, CONGELADOS Y BEBIDAS' THEN 'PERECEDEROS'
      WHEN SQUAD = 'PRODUCE AND MEAT' THEN 'FRESH'
      WHEN SQUAD = 'SALUD Y BIENESTAR' THEN 'SALUD Y BIENESTAR'
      WHEN SQUAD IN ('APPAREL','SEASONAL','TECHNOLOGY') THEN 'MERCANCIAS_GENERALES_EXCLUIDO'
      ELSE NULL
    END AS bucket_negocio_real,
    ROW_NUMBER() OVER (PARTITION BY ITEM_ID ORDER BY FECHA_INTEGRACION DESC) AS rn
  FROM `wmt-mx-dl-controlledmgzn-prod.SAMS_AD_HOC_COM.SAMS_CONTENIDO_CATALOGO`
  WHERE ITEM_ID IS NOT NULL
) WHERE rn = 1;

-- =============================================================================
-- SELECT "diagnostico": correr PRIMERO, revisar flag_catalogo/flag_ventas
-- antes de confiar en los resultados de las anclas marcadas.
-- =============================================================================
SELECT
  a.item_id, a.bucket_cliente, a.desc_cliente,
  c.SQUAD AS squad_catalogo, c.bucket_negocio_real, c.DESCRIPCION_UNO AS desc_catalogo,
  CASE
    WHEN c.item_id IS NULL THEN 'SIN_MATCH_CATALOGO'
    WHEN c.bucket_negocio_real IS NULL THEN 'SQUAD_EXCLUIDO_O_DESCONOCIDO'
    WHEN c.bucket_negocio_real != a.bucket_cliente THEN 'BUCKET_DISTINTO_AL_ESPERADO'
    ELSE 'OK'
  END AS flag_catalogo
FROM anchors_padded a
LEFT JOIN catalogo_dedup_qa c ON c.item_id = a.item_id
ORDER BY flag_catalogo, a.bucket_cliente, a.item_id;

-- -----------------------------------------------------------------------------
-- 1) Universo (5 buckets), TY_90D + LY_MES_ANTERIOR, canasta calificada dinamica
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE catalogo_bucket AS
SELECT item_id, bucket_negocio_real AS bucket_negocio
FROM catalogo_dedup_qa
WHERE bucket_negocio_real IS NOT NULL AND bucket_negocio_real != 'MERCANCIAS_GENERALES_EXCLUIDO';

CREATE TEMP TABLE lineas_crudas AS
SELECT
  CASE
    WHEN v.sales_order_detail_order_created_date BETWEEN ty_inicio AND ty_fin THEN 'TY_90D'
    WHEN v.sales_order_detail_order_created_date BETWEEN ly_inicio AND ly_fin THEN 'LY_MES_ANTERIOR'
  END AS periodo,
  v.sales_order_detail_order_nbr AS order_nbr,
  v.sales_order_detail_item_id AS item_id,
  v.sales_order_detail_item_short_desc AS item_desc,
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

CREATE TEMP TABLE resumen_orden AS
SELECT periodo, order_nbr, SUM(piezas) AS piezas_totales, SUM(monto) AS monto_total
FROM lineas_crudas GROUP BY periodo, order_nbr;

SET min_items_canasta = (
  SELECT GREATEST(2, CAST(ROUND(AVG(piezas_totales) / 2) AS INT64)) FROM resumen_orden
);

CREATE TEMP TABLE lineas_calificadas AS
SELECT DISTINCT periodo, order_nbr, item_id, item_desc, bucket_negocio FROM lineas_crudas;

CREATE TEMP TABLE canastas_calificadas AS
SELECT periodo, order_nbr FROM lineas_calificadas
GROUP BY periodo, order_nbr
HAVING COUNT(DISTINCT item_id) >= min_items_canasta;

CREATE TEMP TABLE canasta_items AS
SELECT lc.* FROM lineas_calificadas lc
INNER JOIN canastas_calificadas cc USING (periodo, order_nbr);

CREATE TEMP TABLE total_canastas AS
SELECT periodo, COUNT(DISTINCT order_nbr) AS n FROM canasta_items GROUP BY periodo;

-- -----------------------------------------------------------------------------
-- 2) Nivel 1 Apriori (poda por soporte minimo)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE items_soporte AS
SELECT
  ci.periodo, ci.item_id,
  ANY_VALUE(ci.item_desc) AS item_desc,
  ANY_VALUE(ci.bucket_negocio) AS bucket_negocio,
  COUNT(DISTINCT ci.order_nbr) AS canastas_item,
  SAFE_DIVIDE(COUNT(DISTINCT ci.order_nbr), ANY_VALUE(tc.n)) AS support_item
FROM canasta_items ci
INNER JOIN total_canastas tc ON tc.periodo = ci.periodo
GROUP BY ci.periodo, ci.item_id;

CREATE TEMP TABLE items_frecuentes AS
SELECT * FROM items_soporte WHERE support_item >= min_support;

CREATE TEMP TABLE anchors_soporte AS
SELECT s.*, a.bucket_cliente, a.desc_cliente
FROM items_soporte s
INNER JOIN anchors_padded a ON a.item_id = s.item_id;

-- -----------------------------------------------------------------------------
-- 3) Nivel 2: self-join ancla <-> companion frecuente (cualquier bucket)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE pares_ancla_ordenes AS
SELECT ca.periodo, ca.item_id AS anchor_id, cb2.item_id AS companion_id, ca.order_nbr
FROM canasta_items ca
INNER JOIN anchors_padded an ON an.item_id = ca.item_id
INNER JOIN canasta_items cb2
  ON cb2.periodo = ca.periodo AND cb2.order_nbr = ca.order_nbr AND cb2.item_id != ca.item_id
INNER JOIN items_frecuentes fc ON fc.periodo = cb2.periodo AND fc.item_id = cb2.item_id;

CREATE TEMP TABLE pares_ancla_canasta AS
SELECT p.periodo, p.anchor_id, p.companion_id,
  COUNT(DISTINCT p.order_nbr) AS canastas_con_ambos,
  ROUND(SUM(ro.monto_total), 2) AS monto_capturado_par
FROM pares_ancla_ordenes p
INNER JOIN resumen_orden ro ON ro.periodo = p.periodo AND ro.order_nbr = p.order_nbr
GROUP BY p.periodo, p.anchor_id, p.companion_id;

CREATE TEMP TABLE resultado_periodo AS
SELECT
  p.periodo,
  p.anchor_id, aso.desc_cliente AS anchor_desc_cliente, aso.bucket_cliente AS anchor_bucket_cliente,
  aso.item_desc AS anchor_desc_real, aso.bucket_negocio AS anchor_bucket_real,
  p.companion_id, fc.item_desc AS companion_desc, fc.bucket_negocio AS companion_bucket,
  p.canastas_con_ambos, p.monto_capturado_par,
  aso.canastas_item AS canastas_con_anchor, fc.canastas_item AS canastas_con_companion,
  SAFE_DIVIDE(p.canastas_con_ambos, tc.n) AS support_par,
  SAFE_DIVIDE(p.canastas_con_ambos, aso.canastas_item) AS conf_ancla_a_comp,
  SAFE_DIVIDE(p.canastas_con_ambos, fc.canastas_item) AS conf_comp_a_ancla,
  SAFE_DIVIDE(SAFE_DIVIDE(p.canastas_con_ambos, tc.n), aso.support_item * fc.support_item) AS lift
FROM pares_ancla_canasta p
INNER JOIN anchors_soporte aso ON aso.periodo = p.periodo AND aso.item_id = p.anchor_id
INNER JOIN items_frecuentes fc ON fc.periodo = p.periodo AND fc.item_id = p.companion_id
INNER JOIN total_canastas tc ON tc.periodo = p.periodo;

CREATE TEMP TABLE resultado_periodo_flag AS
SELECT *, (lift >= min_lift AND GREATEST(conf_ancla_a_comp, conf_comp_a_ancla) >= min_confidence) AS es_fuerte
FROM resultado_periodo;

CREATE TEMP TABLE resultado_ty AS
SELECT *, GREATEST(conf_ancla_a_comp, conf_comp_a_ancla) AS conf_max
FROM resultado_periodo_flag WHERE periodo = 'TY_90D';

CREATE TEMP TABLE resultado_ly AS
SELECT * FROM resultado_periodo_flag WHERE periodo = 'LY_MES_ANTERIOR';

-- -----------------------------------------------------------------------------
-- 4) Comparativo TY vs LY + INTRA/CROSS-bucket + tipo_adyacencia
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE comparativo AS
SELECT
  min_items_canasta AS umbral_canasta_usado,
  COALESCE(t.anchor_id, l.anchor_id) AS anchor_id,
  COALESCE(t.anchor_desc_cliente, l.anchor_desc_cliente) AS anchor_desc_cliente,
  COALESCE(t.anchor_bucket_cliente, l.anchor_bucket_cliente) AS anchor_bucket_cliente,
  COALESCE(t.anchor_desc_real, l.anchor_desc_real) AS anchor_desc_real,
  COALESCE(t.anchor_bucket_real, l.anchor_bucket_real) AS anchor_bucket_real,
  COALESCE(t.companion_id, l.companion_id) AS companion_id,
  COALESCE(t.companion_desc, l.companion_desc) AS companion_desc,
  COALESCE(t.companion_bucket, l.companion_bucket) AS companion_bucket,
  CASE WHEN COALESCE(t.anchor_bucket_real, l.anchor_bucket_real) = COALESCE(t.companion_bucket, l.companion_bucket)
       THEN 'INTRA-BUCKET' ELSE 'CROSS-BUCKET' END AS tipo_bucket,
  t.canastas_con_ambos AS canastas_ambos_ty, t.monto_capturado_par AS monto_par_ty,
  t.support_par AS support_ty, t.conf_ancla_a_comp AS conf_ty_ancla_a_comp, t.conf_comp_a_ancla AS conf_ty_comp_a_ancla,
  t.lift AS lift_ty, IFNULL(t.es_fuerte, FALSE) AS fuerte_ty,
  l.canastas_con_ambos AS canastas_ambos_ly, l.monto_capturado_par AS monto_par_ly,
  l.support_par AS support_ly, l.conf_ancla_a_comp AS conf_ly_ancla_a_comp, l.conf_comp_a_ancla AS conf_ly_comp_a_ancla,
  l.lift AS lift_ly, IFNULL(l.es_fuerte, FALSE) AS fuerte_ly,
  CASE
    WHEN IFNULL(t.es_fuerte, FALSE) AND IFNULL(l.es_fuerte, FALSE) THEN 'CONSISTENTE'
    WHEN IFNULL(t.es_fuerte, FALSE) AND NOT IFNULL(l.es_fuerte, FALSE) THEN 'EMERGENTE'
    WHEN NOT IFNULL(t.es_fuerte, FALSE) AND IFNULL(l.es_fuerte, FALSE) THEN 'ESTACIONAL_HISTORICA'
    ELSE 'DEBIL'
  END AS tipo_adyacencia
FROM resultado_ty t
FULL OUTER JOIN resultado_ly l ON t.anchor_id = l.anchor_id AND t.companion_id = l.companion_id;

-- =============================================================================
-- SELECT "detalle_pares" (DELIVERABLE 1 - CSV consolidado): top 40 pares por
-- ancla (de los "fuertes"), ordenados por confianza -- suficiente para cubrir
-- todos los pares relevantes por ancla sin explotar el tamano del resultado.
-- =============================================================================
SELECT * FROM comparativo
WHERE fuerte_ty OR fuerte_ly
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY anchor_id
  ORDER BY GREATEST(IFNULL(conf_ty_ancla_a_comp,0), IFNULL(conf_ty_comp_a_ancla,0), IFNULL(conf_ly_ancla_a_comp,0), IFNULL(conf_ly_comp_a_ancla,0)) DESC
) <= 40
ORDER BY anchor_id, GREATEST(IFNULL(lift_ty,0), IFNULL(lift_ly,0)) DESC;

-- -----------------------------------------------------------------------------
-- 5) Umbral de confianza AUTOMATIZADO por ancla (escalera 70/50/40/30/20/10/5%,
--    elige el escalon mas alto con >= 3 pares; documentado en cabecera).
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE ladder AS
SELECT
  anchor_id, ANY_VALUE(anchor_desc_real) AS anchor_desc_real, ANY_VALUE(anchor_bucket_real) AS anchor_bucket_real,
  ANY_VALUE(anchor_bucket_cliente) AS anchor_bucket_cliente,
  COUNT(*) AS total_candidatos_ty,
  COUNTIF(conf_max >= 0.70) AS ge_70, COUNTIF(conf_max >= 0.50) AS ge_50,
  COUNTIF(conf_max >= 0.40) AS ge_40, COUNTIF(conf_max >= 0.30) AS ge_30,
  COUNTIF(conf_max >= 0.20) AS ge_20, COUNTIF(conf_max >= 0.10) AS ge_10,
  COUNTIF(conf_max >= 0.05) AS ge_05
FROM resultado_ty
GROUP BY anchor_id;

CREATE TEMP TABLE umbral_elegido AS
SELECT *,
  CASE
    WHEN ge_70 >= 3 THEN 0.70 WHEN ge_50 >= 3 THEN 0.50 WHEN ge_40 >= 3 THEN 0.40
    WHEN ge_30 >= 3 THEN 0.30 WHEN ge_20 >= 3 THEN 0.20 WHEN ge_10 >= 3 THEN 0.10
    ELSE 0.05
  END AS umbral_venta_cruzada,
  CASE
    WHEN ge_70 >= 3 THEN ge_70 WHEN ge_50 >= 3 THEN ge_50 WHEN ge_40 >= 3 THEN ge_40
    WHEN ge_30 >= 3 THEN ge_30 WHEN ge_20 >= 3 THEN ge_20 WHEN ge_10 >= 3 THEN ge_10
    ELSE ge_05
  END AS pares_al_umbral_elegido
FROM ladder;

-- =============================================================================
-- SELECT "diagnostico_ladder": transparencia total del umbral elegido por
-- ancla -- revisar antes de confiar en el resumen ejecutivo.
-- =============================================================================
SELECT * FROM umbral_elegido ORDER BY anchor_desc_real;

CREATE TEMP TABLE companions_calificados AS
SELECT r.anchor_id, r.companion_id, r.companion_bucket,
  CASE WHEN r.anchor_bucket_real = r.companion_bucket THEN 'INTRA-BUCKET' ELSE 'CROSS-BUCKET' END AS tipo_bucket
FROM resultado_ty r
INNER JOIN umbral_elegido u ON u.anchor_id = r.anchor_id
WHERE r.conf_max >= u.umbral_venta_cruzada;

CREATE TEMP TABLE dominante_bucket AS
SELECT anchor_id,
  COUNTIF(tipo_bucket = 'INTRA-BUCKET') AS n_intra,
  COUNTIF(tipo_bucket = 'CROSS-BUCKET') AS n_cross,
  COUNT(*) AS n_companions_calificados
FROM companions_calificados GROUP BY anchor_id;

CREATE TEMP TABLE canastas_venta_cruzada AS
SELECT DISTINCT cc.anchor_id, ca.order_nbr
FROM canasta_items ca
INNER JOIN companions_calificados cc ON ca.item_id = cc.companion_id AND ca.periodo = 'TY_90D'
INNER JOIN canasta_items anc ON anc.periodo = 'TY_90D' AND anc.order_nbr = ca.order_nbr AND anc.item_id = cc.anchor_id;

CREATE TEMP TABLE cruce_agg AS
SELECT d.anchor_id,
  COUNT(DISTINCT d.order_nbr) AS n_canastas_cruce,
  ROUND(SUM(ro.monto_total), 2) AS monto_capturado
FROM (SELECT DISTINCT anchor_id, order_nbr FROM canastas_venta_cruzada) d
INNER JOIN resumen_orden ro ON ro.periodo = 'TY_90D' AND ro.order_nbr = d.order_nbr
GROUP BY d.anchor_id;

-- =============================================================================
-- SELECT "resumen_ejecutivo" (DELIVERABLE 2): ranking por ancla, monto
-- capturado, % canastas con cruce, y patron dominante INTRA vs CROSS-BUCKET.
-- =============================================================================
SELECT
  u.anchor_id, u.anchor_desc_real, u.anchor_bucket_real, u.anchor_bucket_cliente,
  u.umbral_venta_cruzada, u.pares_al_umbral_elegido,
  (u.pares_al_umbral_elegido < 3) AS advertencia_pocos_pares,
  IFNULL(d.n_companions_calificados, 0) AS n_companions_calificados,
  IFNULL(d.n_intra, 0) AS n_companions_intra,
  IFNULL(d.n_cross, 0) AS n_companions_cross,
  CASE WHEN IFNULL(d.n_cross,0) > IFNULL(d.n_intra,0) THEN 'CROSS-BUCKET (bundle)'
       WHEN IFNULL(d.n_intra,0) > 0 OR IFNULL(d.n_cross,0) > 0 THEN 'INTRA-BUCKET (surtido)'
       ELSE 'SIN CRUCE MATERIAL' END AS patron_dominante,
  aso.canastas_item AS canastas_totales_ancla_ty,
  IFNULL(v.n_canastas_cruce, 0) AS canastas_con_cruce_ty,
  ROUND(SAFE_DIVIDE(IFNULL(v.n_canastas_cruce,0), aso.canastas_item) * 100, 2) AS pct_canastas_con_cruce,
  IFNULL(v.monto_capturado, 0) AS monto_capturado_ty
FROM umbral_elegido u
LEFT JOIN dominante_bucket d ON d.anchor_id = u.anchor_id
LEFT JOIN cruce_agg v ON v.anchor_id = u.anchor_id
INNER JOIN (SELECT DISTINCT item_id AS anchor_id, canastas_item FROM anchors_soporte WHERE periodo = 'TY_90D') aso ON aso.anchor_id = u.anchor_id
ORDER BY monto_capturado_ty DESC;
