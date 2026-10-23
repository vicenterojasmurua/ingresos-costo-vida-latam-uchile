# Uso del repositorio

El repositorio reúne productos de tesis, análisis de encuestas y revisión bibliográfica, pero todavía no contiene un pipeline único que procese las tres encuestas de extremo a extremo.

## Iniciar R

Abra R en la raíz del proyecto y restaure el entorno una vez:

```r
install.packages("renv")
renv::restore()
```

Los paquetes fijados están descritos en `renv.lock`. Las bases descargadas no se incluyen; sus rutas y períodos aparecen en [DATOS.md](DATOS.md).

## Armonización inicial de los hogares

Desde la raíz del repositorio, con los microdatos locales y las dependencias restauradas:

```powershell
Rscript scripts/01_data_analysis/r/01_harmonize_households.R
```

El script guarda una base RDS por país en `data/processed/{chile,brasil,argentina}/`. La salida incluye ingresos mensuales, tamaño del hogar, ingreso per cápita, ponderador, período y ámbito geográfico; los identificadores y datos procesados permanecen locales. Brasil se limita a PNAD 2025, visita 1, y capitales estatales; Argentina, a Gran Buenos Aires. No se estima cobertura de canastas hasta verificar una fuente de costo compatible. Consulte [DATOS.md](DATOS.md) antes de interpretar estas salidas.

## CASEN 2024

El do-file existente en `scripts/01_data_analysis/stata/proc_rojas_murua_vicente.do` prepara una base individual reducida y genera tablas descriptivas y un histograma en `output/`. Ejecútelo desde la raíz del repositorio con Stata 17. Revise la unidad de observación y los ponderadores antes de reutilizar una salida.

El flujo R de `scripts/01_data_analysis/r/` armoniza inicialmente los ingresos de las tres encuestas; el do-file Stata se mantiene para los descriptivos de CASEN.

## Revisión de literatura

Con los archivos de Web of Science instalados localmente en `data/raw/bib_raw/`, ejecute:

```r
source("scripts/00_lit_review/01_deduplicar.r")
```

El script escribe el corpus depurado en `zotero/` y las métricas en `output/`. Revise las métricas antes de ejecutar el generador PRISMA:

```r
source("scripts/00_lit_review/02_prisma_flowchart.R")
```

La selección automatizada por título/resumen no reemplaza la revisión cualitativa de elegibilidad ni justifica, por sí sola, un número final de estudios incluidos.

## Presentación

La presentación Quarto carga datos locales para mostrar resultados exploratorios de CASEN y EPF. Renderícela desde `presentaciones/` con `quarto render`. Antes de distribuir la versión HTML, vuelva a ejecutarla con las bases correctas y revise las tablas, períodos y mensajes de limitación.

## Incorporar una observación de canasta

Agregue a `data/metadata/canastas_y_precios.csv` únicamente valores documentados con una fuente verificable. Incluya país, institución, URL, período, territorio, nombre de la medida, unidad, moneda, valor y definición. Para Brasil, la cesta DIEESE es una fuente independiente y territorialmente específica; no la describa como estadística oficial del gobierno.

No calcule una razón de cobertura cuando el ingreso de la encuesta y el costo de la canasta no compartan una unidad, un período y una cobertura geográfica compatibles. Véanse las limitaciones en [DATOS.md](DATOS.md).
