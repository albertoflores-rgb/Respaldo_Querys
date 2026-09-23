-- ============================================================
-- Venta_Com_Promociones_Mensual.sql
-- Canal   : Sam's Club MX .com — Todos los Clubs (176, agregado)
-- Área    : E-Catman
-- Versión : 1.1 | 03-sep-2026
-- Base    : Venta_Com_Promociones.sql (v2.2, grano DIARIO) -- este
--           archivo es la MISMA lógica de limpieza de promoción,
--           pero agregado a grano MENSUAL. Es un query APARTE a
--           propósito -- no se mezcla con el diario en el mismo
--           archivo/resultado (uno es para ver tendencia día a día,
--           este es para ver el panorama mes a mes sin tanto ruido).
--
-- QUÉ ES: Venta .com a nivel Mes + Ítem + Promoción atómica, con
--   piezas, pesos, órdenes y socios. Mismo hallazgo/limpieza que el
--   query diario: el campo `sales_order_detail_order_promotion_discount_desc`
--   viene concatenado con "/" (varias promos por línea de orden) y
--   con "null"/"NULL VALUE" como relleno -- se separa con
--   SPLIT(...,'/') + UNNEST y se descartan los placeholders, dejando
--   promociones atómicas reales (ROLLBACK, Descuento 2.3, "Ahorra
--   15% con Cupón <MES><pct>", etc.) en vez de miles de combinaciones.
--
-- OJO -- doble conteo esperado (igual que el diario): si una venta
--   tuvo 2+ promos combinadas, se cuenta UNA VEZ POR CADA promo en
--   Venta_Pzas_Com/Venta_Pesos_Com/Ordenes_Com/Numero_Socios_Com. No
--   sumar estas columnas entre filas de un mismo ítem/mes para sacar
--   un total general -- sirve para comparar promociones entre sí.
--
-- v1.1: se agregó `nombre_cupon` -- variable DECLARE opcional (default
--   NULL = sin filtro) para filtrar por nombre de cupón/promoción con
--   match parcial (LIKE), ej. SET nombre_cupon = 'AGO15'. Mismo cambio
--   que en la versión diaria.
--
-- Rango: 1-ene-2025 -> ayer (2025 completo + 2026 YTD), agregado por
--   mes calendario (columna Mes, formato YYYY-MM).
-- ============================================================

DECLARE date_ini DATE DEFAULT DATE(2025, 1, 1);
DECLARE date_fin DATE DEFAULT DATE_SUB(CURRENT_DATE('America/Mexico_City'), INTERVAL 1 DAY);
-- Filtro opcional por nombre de cupón/promoción. NULL = sin filtro (trae
-- TODAS las promos, comportamiento original). Match PARCIAL (LIKE) porque
-- el nombre real viene embebido en texto libre, ej. 'Ahorra 15% con Cupón
-- AGO15' -- basta con poner 'AGO15' o 'Cupón' para filtrar.
DECLARE nombre_cupon STRING DEFAULT NULL;  -- ej: 'AGO15' o 'Cupón'

WITH cte_com_promo_split AS (
  SELECT
    DATE_TRUNC(DATE(s.sales_order_detail_order_created_date), MONTH)  AS Mes,
    SAFE_CAST(s.sales_order_detail_item_id_short AS INT64)            AS ITEM_NBR,
    TRIM(promo_token)                                                 AS Promocion_Desc,
    s.sales_order_detail_commercial_sale_qty_base                     AS Piezas,
    s.sales_order_detail_net_paid_orders_wo_shipping_amount_1         AS Pesos,
    s.sales_order_detail_order_nbr                                    AS Orden_Nbr,
    s.sales_order_detail_membership_nbr                               AS Membresia_Nbr
  FROM `wmt-mx-dl-controlledmgzn-prod.ecom.Sams_Ventas` AS s,
    UNNEST(SPLIT(s.sales_order_detail_order_promotion_discount_desc, '/')) AS promo_token
  WHERE
    DATE(s.sales_order_detail_order_created_date) BETWEEN date_ini AND date_fin
    AND s.sales_order_detail_commercial_sale_qty_base > 0        -- excluir devoluciones / reversos
    AND s.sales_order_detail_item_id_short IS NOT NULL           -- excluir ghost records
    AND LOWER(TRIM(promo_token)) NOT IN ('null', 'null value', '')  -- descarta placeholders
    AND (nombre_cupon IS NULL OR TRIM(promo_token) LIKE CONCAT('%', nombre_cupon, '%'))  -- filtro opcional por nombre de cupón
)

SELECT
  FORMAT_DATE('%Y-%m', p.Mes)          AS Mes,
  p.ITEM_NBR,
  b.PRIMARY_DESC     AS ITEM_DESC_1,
  b.SECONDARY_DESC   AS ITEM_DESC_2,
  b.CATEGORY_NBR     AS CAT_NBR,
  p.Promocion_Desc,
  SUM(p.Piezas)                        AS Venta_Pzas_Com,
  SUM(p.Pesos)                         AS Venta_Pesos_Com,
  COUNT(DISTINCT p.Orden_Nbr)          AS Ordenes_Com,
  -- Socios (membresías) ÚNICAS con venta de ESTA promo en ESTE
  -- ítem/mes. Mismo caveat de doble conteo que las columnas de
  -- arriba -- no sumar entre filas para sacar "socios totales".
  COUNT(DISTINCT p.Membresia_Nbr)      AS Numero_Socios_Com

FROM cte_com_promo_split AS p
LEFT JOIN `wmt-edw-prod.MX_WC_VM.ITEM_DESC` AS b
  ON p.ITEM_NBR = b.Old_NBR

GROUP BY
  p.Mes, p.ITEM_NBR, ITEM_DESC_1, ITEM_DESC_2, CAT_NBR, p.Promocion_Desc

-- ── Filtros opcionales ────────────────────────────────────
--WHERE b.CATEGORY_NBR IN (41, 43, 46, 49, 53, 68)  -- Abarrotes, por ejemplo
--AND p.Promocion_Desc = 'ROLLBACK'

ORDER BY p.Mes DESC, p.ITEM_NBR
