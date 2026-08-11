# Respaldo de Queries — BigQuery

Repositorio de respaldo (versionado con git) de las queries de BigQuery de Alberto Flores.

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

## Historial

- 2026-08-11: Se crea el repo. Intento automatizado con `bq_migrate.py` contra
  `wmt-edw-sandbox` — Saved Queries API devolvió 404 (falta permiso Dataplex);
  Scheduled Queries devolvió 14,134 resultados de todo el proyecto compartido
  (descartado por ser de terceros y demasiado pesado — no se commiteó).
