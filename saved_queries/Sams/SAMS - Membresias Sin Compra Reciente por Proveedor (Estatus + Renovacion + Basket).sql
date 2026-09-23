-- =============================================================================
-- PLANTILLA GENÉRICA: Membresías SIN compra reciente de un proveedor
-- + estatus/renovación de membresía + basket size promedio (30 días)
-- DESGLOSADO POR SQUAD (fineline) + fila TOTAL por socio
-- =============================================================================
-- Ver también la variante ya preparada para Nestlé en este mismo folder:
--   "SAMS - Membresias Sin Compra Reciente - Nestle (...).sql"
--
-- Fuentes:
--   ecom.Sams_Ventas                         -> ventas a nivel línea de pedido
--   SAMS_AD_HOC_COM.SAMS_CONTENIDO_CATALOGO  -> catálogo item -> proveedor
--   membershipADN.Foto                       -> estatus + fechas de renovación por socio
--   Black_Bird.Catalogo_CatID                -> categoria (cat_id/cat) -> squad (fineline)
--
-- SQUAD = campo `fineline` de Black_Bird.Catalogo_CatID (33 categorías agrupadas
-- en 14 squads: Abarrotes, Bebes, Congelados, Dulces y Botanas, Farmacia,
-- Frutas y Verduras, Higiene Personal, Jugos y Bebidas, Limpieza, Mascotas,
-- Oficina y Papelería, Panadería, Refrigerados, Refrigerados y Congelados,
-- Automotriz y Ferretería). Join: Sams_Ventas.sales_order_detail_category_id
-- (INTEGER) = Catalogo_CatID.cat_id (INTEGER) -- match directo, sin CAST,
-- validado 1:1 (33 filas = 33 cat_id distintos, sin duplicados).
--
-- Notas de diseño (por qué está armado así):
--   - Sams_Ventas.Estatus tiene 4 valores: VENTA / DEVOLUCION / ANTICIPO /
--     WISDOM-NULL. Solo 'VENTA' es venta consumada real -> se filtra siempre.
--   - sales_order_detail_membership_nbr (17 dígitos) NO cruza directo con
--     membershipADN.Foto.MEMBERSHIP_NBR (9 dígitos). El match validado (98%)
--     es tomar los últimos 9 dígitos del membership_nbr de ventas.
--   - membershipADN.Foto tiene ~21K MEMBERSHIP_NBR duplicados -> se dedup por
--     socio quedándonos con el registro de renovación más reciente.
--   - El filtro de proveedor usa PROVEDOR (nombre). Si conoces el/los
--     NUMERO_DE_PROVEEDOR es más robusto (nombres pueden variar/tener typos
--     en el catálogo) -> cambia el WHERE de catalogo_proveedor si aplica
--     (ver variante Nestlé para el patrón con IN UNNEST de varios vendors).
--
-- FORMATO DE SALIDA: por cada socio sin compra reciente, sale 1 fila con
-- squad = 'TOTAL' (comportamiento general) + N filas adicionales (una por
-- squad donde tuvo actividad en los últimos 30 días). Formato "tidy/largo"
-- -> ideal para armar una Tabla Dinámica en Excel filtrando/agrupando por squad.
-- =============================================================================

DECLARE proveedor_nombre STRING DEFAULT 'NOMBRE_DEL_PROVEEDOR_AQUI'; -- <-- reemplazar (match exacto en PROVEDOR)
DECLARE dias_sin_compra  INT64  DEFAULT 15;                          -- umbral "no ha comprado en"
DECLARE ventana_basket   INT64  DEFAULT 30;                          -- ventana para basket/piezas

-- -----------------------------------------------------------------------------
-- 1) Item -> Proveedor (catálogo)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE catalogo_proveedor AS
SELECT
  ITEM_ID,
  PROVEDOR              AS proveedor_nombre,
  NUMERO_DE_PROVEEDOR   AS proveedor_numero
FROM `wmt-mx-dl-controlledmgzn-prod.SAMS_AD_HOC_COM.SAMS_CONTENIDO_CATALOGO`
WHERE PROVEDOR = proveedor_nombre;
-- Alternativa más robusta si conoces el número de proveedor:
-- WHERE NUMERO_DE_PROVEEDOR = 123456
-- o para varios proveedores del mismo grupo:
-- WHERE NUMERO_DE_PROVEEDOR IN UNNEST([123456, 234567])

-- -----------------------------------------------------------------------------
-- 1b) Categoria -> Squad (fineline)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE catalogo_categoria AS
SELECT
  cat_id,
  cat       AS categoria_desc,
  fineline  AS squad
FROM `wmt-mx-dl-controlledmgzn-prod.Black_Bird.Catalogo_CatID`;

-- -----------------------------------------------------------------------------
-- 2) Ventas del proveedor por socio (histórico completo, para sacar última compra)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE ventas_proveedor AS
SELECT
  v.sales_order_detail_membership_nbr AS membership_nbr,
  v.sales_order_detail_order_nbr      AS order_nbr,
  v.sales_order_detail_order_created_date AS fecha_compra
FROM `wmt-mx-dl-controlledmgzn-prod.ecom.Sams_Ventas` v
INNER JOIN catalogo_proveedor c
  ON SAFE_CAST(v.sales_order_detail_item_id AS INT64) = c.ITEM_ID
WHERE v.Estatus = 'VENTA'
  AND v.sales_order_detail_membership_nbr IS NOT NULL;

-- -----------------------------------------------------------------------------
-- 3) Última compra por socio a ese proveedor + días sin comprar
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE membresias_sin_compra_reciente AS
SELECT
  membership_nbr,
  MAX(fecha_compra)               AS ultima_compra_proveedor,
  COUNT(DISTINCT order_nbr)       AS pedidos_historicos_proveedor,
  DATE_DIFF(CURRENT_DATE(), MAX(fecha_compra), DAY) AS dias_sin_comprar
FROM ventas_proveedor
GROUP BY membership_nbr
HAVING DATE_DIFF(CURRENT_DATE(), MAX(fecha_compra), DAY) >= dias_sin_compra;

-- -----------------------------------------------------------------------------
-- 4) Estatus de membresía + fechas de renovación (dedup: renovación más reciente)
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE membresia_estatus AS
SELECT * EXCEPT(rn) FROM (
  SELECT
    MEMBERSHIP_NBR,
    card_status_nm,        -- ACTIVE / PICKUP / REVOKED
    card_paid_status_nm,   -- PAID / UNPAID / ...
    TIER_TYPE_CD,
    NEXT_RENEW_DATE,
    LAST_RENEW_DATE,
    mbrshp_auto_renew_ind,
    ROW_NUMBER() OVER (
      PARTITION BY MEMBERSHIP_NBR
      ORDER BY LAST_RENEW_DATE DESC, NEXT_RENEW_DATE DESC
    ) AS rn
  FROM `wmt-mx-dl-controlledmgzn-prod.membershipADN.Foto`
)
WHERE rn = 1;

-- -----------------------------------------------------------------------------
-- 5) Líneas de venta (TODAS las categorías, no solo del proveedor) del socio
--    en los últimos 30 días, ya etiquetadas con su squad -> base del desglose
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE ventas_lineas_30d AS
SELECT
  v.sales_order_detail_membership_nbr AS membership_nbr,
  v.sales_order_detail_order_nbr      AS order_nbr,
  COALESCE(cc.squad, 'SIN CLASIFICAR') AS squad,
  v.sales_order_detail_net_paid_orders_wo_shipping_amount_1 AS monto,
  v.sales_order_detail_commercial_sale_qty_base AS piezas
FROM `wmt-mx-dl-controlledmgzn-prod.ecom.Sams_Ventas` v
LEFT JOIN catalogo_categoria cc
  ON v.sales_order_detail_category_id = cc.cat_id
WHERE v.Estatus = 'VENTA'
  AND v.sales_order_detail_order_created_date >= DATE_SUB(CURRENT_DATE(), INTERVAL ventana_basket DAY)
  AND v.sales_order_detail_membership_nbr IS NOT NULL;

-- -----------------------------------------------------------------------------
-- 6) Basket por squad + fila TOTAL (UNION ALL) -> formato tidy/largo
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE basket_30d AS
SELECT membership_nbr, squad,
  COUNT(DISTINCT order_nbr)  AS pedidos_30d,
  SUM(monto)                 AS monto_total_30d,
  SUM(piezas)                AS piezas_total_30d
FROM ventas_lineas_30d
GROUP BY membership_nbr, squad

UNION ALL

SELECT membership_nbr, 'TOTAL' AS squad,
  COUNT(DISTINCT order_nbr)  AS pedidos_30d,
  SUM(monto)                 AS monto_total_30d,
  SUM(piezas)                AS piezas_total_30d
FROM ventas_lineas_30d
GROUP BY membership_nbr;

-- =============================================================================
-- RESULTADO DETALLE: N filas por socio (1 "TOTAL" + 1 por squad con actividad)
-- =============================================================================
SELECT
  m.membership_nbr,
  m.ultima_compra_proveedor,
  m.dias_sin_comprar,
  m.pedidos_historicos_proveedor,
  e.card_status_nm                                   AS estatus_membresia,
  CASE WHEN e.card_status_nm = 'ACTIVE' THEN 'Activa' ELSE 'Inactiva' END AS membresia_activa,
  e.card_paid_status_nm                               AS estatus_pago,
  e.TIER_TYPE_CD                                      AS tipo_membresia,
  e.LAST_RENEW_DATE                                   AS ultima_renovacion,
  e.NEXT_RENEW_DATE                                   AS proxima_renovacion,
  e.mbrshp_auto_renew_ind                             AS auto_renovacion,
  b.squad,
  IFNULL(b.pedidos_30d, 0)                            AS pedidos_ultimos_30d,
  ROUND(SAFE_DIVIDE(b.monto_total_30d, b.pedidos_30d), 2) AS basket_size_promedio_30d,
  ROUND(SAFE_DIVIDE(b.piezas_total_30d, b.pedidos_30d), 2) AS piezas_promedio_por_pedido_30d
FROM membresias_sin_compra_reciente m
LEFT JOIN membresia_estatus e
  ON SAFE_CAST(SUBSTR(m.membership_nbr, -9) AS INT64) = e.MEMBERSHIP_NBR
LEFT JOIN basket_30d b
  ON m.membership_nbr = b.membership_nbr
ORDER BY m.dias_sin_comprar DESC, m.membership_nbr,
  CASE WHEN b.squad = 'TOTAL' THEN 0 ELSE 1 END, b.squad;

-- =============================================================================
-- RESUMEN EJECUTIVO: agregado del segmento completo, por squad
-- (correr por separado si solo quieres los totales)
-- =============================================================================
-- SELECT
--   b.squad,
--   COUNT(DISTINCT m.membership_nbr)                               AS total_socios_sin_compra,
--   COUNTIF(e.card_status_nm = 'ACTIVE')                           AS socios_membresia_activa,
--   COUNTIF(e.card_status_nm != 'ACTIVE' OR e.card_status_nm IS NULL) AS socios_membresia_inactiva,
--   ROUND(AVG(SAFE_DIVIDE(b.monto_total_30d, b.pedidos_30d)), 2)   AS basket_promedio_segmento_30d,
--   ROUND(AVG(SAFE_DIVIDE(b.piezas_total_30d, b.pedidos_30d)), 2)  AS piezas_promedio_segmento_30d
-- FROM membresias_sin_compra_reciente m
-- LEFT JOIN membresia_estatus e
--   ON SAFE_CAST(SUBSTR(m.membership_nbr, -9) AS INT64) = e.MEMBERSHIP_NBR
-- LEFT JOIN basket_30d b
--   ON m.membership_nbr = b.membership_nbr
-- GROUP BY b.squad
-- ORDER BY b.squad;
