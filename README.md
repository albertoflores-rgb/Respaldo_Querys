# Respaldo de Queries — BigQuery

Repositorio de respaldo (versionado con git) de las queries de BigQuery de Alberto Flores.
Incluye queries de trabajo de SAM's y W2.

>  **Confidencial**: este repo puede contener SQL con nombres de datasets/tablas internas
> de Walmart. Manténlo **privado** en GitHub y no compartas el link fuera de los canales
> internos autorizados.

## Estructura

```
saved_queries/       -> Queries guardadas en BigQuery Studio (una por archivo .sql)
scheduled_queries/   -> Scheduled queries propias (si aplica)
manifest.json         -> Metadata (nombre, proyecto, fecha de export) — se agrega cuando
                         se genera un respaldo automatizado
```

## Cómo se alimenta este repo

Hay dos caminos posibles para traer las queries desde BigQuery:

1. **Automatizado** (`bq_migrate.py`, en `../bq_migrate/`): requiere el rol IAM
   `roles/dataplex.viewer` (o `dataplex.dataReader`) sobre el proyecto donde viven las
   Saved Queries de BigQuery Studio, porque esa funcionalidad está respaldada por la API
   de Dataplex, no por la API clásica de BigQuery. Sin ese permiso, el script no puede
   listar las Saved Queries (aunque sí puede listar Scheduled Queries, con cuidado:
   en proyectos sandbox compartidos puede traer configs de OTRAS personas — hay que
   filtrar antes de commitear).

2. **Manual**: copiar el SQL de cada query desde el panel "Saved queries" de BigQuery
   Studio y pegarlo aquí como un archivo `.sql` individual, con nombre descriptivo.

## Como pedir el permiso Dataplex (para desbloquear el respaldo automatico)

El permiso que falta es `roles/dataplex.viewer` (o `roles/dataplex.dataReader`) sobre
`wmt-edw-sandbox`. En Walmart el flujo es via ServiceNow + AD groups, no self-service
directo en la consola de GCP:

1. Formulario ServiceNow "Active Directory Request Form":
   https://walmartglobal.service-now.com/wm_sp?id=sc_cat_item_guide&sys_id=b3234c3b4fab8700e4cd49cf0310c7d7
2. AD group candidato para el sandbox: `gcp-edw-sandbox-user@walmart.com`
   (ver Confluence: https://confluence.walmart.com/spaces/GDAPFNWSBQ/pages/337003911/Google+Groups+Google+Roles+and+Service+Accounts)
3. Contexto de gobierno de Dataplex en Walmart (roles admin/developer estan restringidos
   a proposito; puede requerir proceso de excepcion):
   https://confluence.walmart.com/spaces/GDODGE/pages/1560921530/Data+Management+Tools+Dataplex
4. Referencia general de acceso GCP/BigQuery via ServiceNow:
   https://confluence.walmart.com/spaces/SASRO/pages/2518489554/GCP+Access

Una vez aprobado el acceso, correr de nuevo:
```
cd ../bq_migrate
.venv\Scripts\python.exe bq_migrate.py --source wmt-edw-sandbox --dry-run --output ..\Respaldo_Querys\bq_backups
```
y mover el contenido de `saved_queries/` generado hacia este repo.

## Historial

- 2026-08-11: Se crea el repo. Intento automatizado con `bq_migrate.py` contra
  `wmt-edw-sandbox` — Saved Queries API devolvió 404 (falta permiso Dataplex);
  Scheduled Queries devolvió 14,134 resultados de todo el proyecto compartido
  (descartado por ser de terceros y demasiado pesado — no se commiteó).
