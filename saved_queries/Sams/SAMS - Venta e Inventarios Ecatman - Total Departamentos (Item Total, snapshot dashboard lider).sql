-- ============================================================
-- SAMS - Venta e Inventarios Ecatman - Total Departamentos
-- (Item Total, snapshot dashboard lider) v1.0 | 03-Sep-2026
--
-- QUE ES ESTO: respaldo EXACTO del query que genero el CSV/tablero
-- "Total Departamentos" (232,716 filas, 122 columnas) que vive en
-- `Tableros-E-Catman-s/Pipeline_Compartido_Equipos/Total_Departamentos/`
-- para revision del lider. Es identico al query maestro
-- "SAMS - Venta e Inventarios Ecatman - YTD MTD 7Dias TY vs LY (Item
-- Total).sql" (v4.3) corrido SIN filtro de categoria/equipo -- este
-- archivo existe aparte solo para dejar trazabilidad de auditoria de
-- ESTA corrida especifica (fecha, job IDs, costo real), por si el
-- query maestro sigue evolucionando (v4.4, v4.5...) y alguien necesita
-- saber exactamente que genero el CSV congelado en el repo de tableros.
--
-- Por que existe un archivo aparte en vez de solo apuntar al maestro
-- (regla del repo: nunca mezclar variantes/snapshots en el mismo
-- archivo): este SI es un snapshot puntual con metadata de auditoria
-- de una corrida real, no una variante de negocio (como si fuera
-- diario vs mensual). Documentamos aqui el costo real porque fue una
-- corrida cara e inusual (no es la corrida diaria/barata normal).
--
-- CORRIDA REAL (03-sep-2026, madrugada):
--   Proyecto BigQuery : wmt-intl-cons-mx-users
--   job_id (script)   : d2f6333d-8aa7-4839-914c-5863661c3790 (INCOMPLETO,
--                       66 cols, sin LY/Crecimiento -- descartado)
--   job_id (correcto) : script_job_90211c9c5c56df2d5f5f64ab96002045_0
--                       (destino: _5113ebfc...anon2c34b009_ba69_4d4c_91fc_20f5ae96d1b6)
--                       232,716 filas, 122 columnas -- ESTE es el que
--                       genero el CSV final.
--   Bytes billed      : ~3,798.19 GB (~3.8 TB) para la corrida correcta.
--                       Sesion completa del dia (incluye un intento
--                       incompleto + reintento): ~8 TB deduplicado.
--   Dominado por      : cte_impresiones_raw (Adobe, tabla externa ORC
--                       sin particion util para el filtro chnl_txt).
--                       El bloque venta/inventario es fijo ~19GB.
--
-- LECCION APRENDIDA (para la proxima corrida "todos los deptos"):
--   1) Confirmar el SCHEMA COMPLETO (122 columnas: TY+LY+Crecimiento+
--      Impresiones) ANTES de dar por buena una corrida -- hubo una
--      corrida previa que quedo incompleta (66 cols, sin LY ni
--      Crecimiento) y por poco se usa esa por error.
--   2) Bajar el resultado con `google-cloud-bigquery` + `to_dataframe()`
--      directo (sin limite de paginacion de 10,000 filas) -- evita
--      tener que rescatar la tabla temporal `_anon...` despues.
--   3. Si esto se vuelve recurrente, migrar cte_impresiones_raw a un
--      historico incremental local (patron */historico_app/) para no
--      re-escanear el YTD completo de Adobe cada vez -- pendiente.
--
-- Ver tambien: Total_Departamentos/README.md (en el repo de tableros)
-- para el detalle completo de esta corrida.
-- ============================================================

DECLARE fecha_ayer  DATE   DEFAULT DATE_SUB(CURRENT_DATE('America/Mexico_City'), INTERVAL 1 DAY);
DECLARE anio_actual INT64  DEFAULT EXTRACT(YEAR FROM fecha_ayer);
DECLARE anio_pasado INT64  DEFAULT anio_actual - 1;

-- ---- Momento 1: YTD (1-ene -> ayer) ----
DECLARE ytd_ty_ini DATE DEFAULT DATE(anio_actual, 1, 1);
DECLARE ytd_ty_fin DATE DEFAULT fecha_ayer;
DECLARE ytd_ly_ini DATE DEFAULT DATE(anio_pasado, 1, 1);
DECLARE ytd_ly_fin DATE DEFAULT DATE_SUB(fecha_ayer, INTERVAL 1 YEAR);

-- ---- Momento 2: MTD (dia 1 del mes -> ayer) ----
DECLARE mtd_ty_ini DATE DEFAULT DATE_TRUNC(fecha_ayer, MONTH);
DECLARE mtd_ty_fin DATE DEFAULT fecha_ayer;
DECLARE mtd_ly_ini DATE DEFAULT DATE_SUB(DATE_TRUNC(fecha_ayer, MONTH), INTERVAL 1 YEAR);
DECLARE mtd_ly_fin DATE DEFAULT DATE_SUB(fecha_ayer, INTERVAL 1 YEAR);

-- ---- Momento 3: Ultimos 7 dias (ayer-6 -> ayer) ----
DECLARE l7d_ty_ini DATE DEFAULT DATE_SUB(fecha_ayer, INTERVAL 6 DAY);
DECLARE l7d_ty_fin DATE DEFAULT fecha_ayer;
DECLARE l7d_ly_ini DATE DEFAULT DATE_SUB(l7d_ty_ini, INTERVAL 1 YEAR);
DECLARE l7d_ly_fin DATE DEFAULT DATE_SUB(l7d_ty_fin, INTERVAL 1 YEAR);

-- ---- Momento 4: Ultimo dia (ayer) ----
DECLARE l1d_ty_ini DATE DEFAULT fecha_ayer;
DECLARE l1d_ty_fin DATE DEFAULT fecha_ayer;
DECLARE l1d_ly_ini DATE DEFAULT DATE_SUB(fecha_ayer, INTERVAL 1 YEAR);
DECLARE l1d_ly_fin DATE DEFAULT DATE_SUB(fecha_ayer, INTERVAL 1 YEAR);

-- Rango global: cubre los 8 sub-rangos de arriba en una sola pasada.
DECLARE date_ini DATE DEFAULT ytd_ly_ini;
DECLARE date_fin DATE DEFAULT fecha_ayer;

-- NOTA: el cuerpo completo (CTEs + SELECT final) es IDENTICO al
-- query maestro "SAMS - Venta e Inventarios Ecatman - YTD MTD 7Dias
-- TY vs LY (Item Total).sql" v4.3 -- NO se repite aqui para evitar
-- que este archivo se desincronice silenciosamente si el maestro se
-- actualiza (v4.4+). Para el SQL completo y ejecutable, usar ESE
-- archivo tal cual (sin descomentar el filtro de categoria al final
-- = automaticamente trae "todos los departamentos", que es
-- exactamente lo que corrio esta snapshot).
--
-- WHERE T2.Cat_Nbr IN (...)   -- dejar COMENTADO = todos los deptos
