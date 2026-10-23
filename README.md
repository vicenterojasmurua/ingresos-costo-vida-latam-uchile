# Ingresos y costo de vida en América del Sur

Estudio comparativo de la relación entre los ingresos de los hogares y el costo de una canasta básica en **Chile, Brasil y Argentina**. El repositorio reúne la tesis, los scripts de análisis, la revisión bibliográfica y la presentación del seminario.

## Alcance y datos disponibles

El diseño compara encuestas oficiales de hogares con medidas de costo de vida documentadas para cada país. Los períodos disponibles en este equipo no coinciden: CASEN 2024 e IX EPF 2021–2022 para Chile; PNAD Contínua 2025 y el primer trimestre de 2026 para Brasil; y EPH del primer trimestre de 2026 para Argentina. Por ello, los resultados deben presentarse como **cortes por país y período**, no como una serie temporal común ni como una comparación simultánea.

La carpeta local incluye microdatos y documentación descargados de CASEN, EPF, PNAD Contínua y EPH. **Los archivos de microdatos no se versionan en Git**; consulte [docs/DATOS.md](docs/DATOS.md) para el inventario, los requisitos y las brechas pendientes.

## Estructura

```text
data/
  raw/                 Microdatos originales, organizados por país (locales/ignorados por Git)
  processed/           Bases procesadas regenerables (locales/ignoradas por Git)
scripts/
  00_lit_review/       Deduplicación, cribado bibliográfico y diagrama PRISMA
  01_data_analysis/    Análisis de encuestas en R y Stata
presentaciones/        Fuente Quarto y presentación HTML renderizada
latex/                 Tesis en LaTeX, capítulos y PDF
refs/                  Bibliografía BibTeX y estilo APA
images/                Logo y figuras incluidas en la tesis
output/                Tablas y figuras analíticas generadas
docs/                  Alcance, datos, instalación y contribución
```

## Requisitos

- R 4.3 o posterior y los paquetes declarados en `renv.lock`.
- Stata 17 para ejecutar el do-file de CASEN.
- Quarto para renderizar la presentación.
- Una distribución de LaTeX con `latexmk`, Biber y los paquetes usados por la tesis.

## Preparación

1. Clonar el repositorio y abrir una terminal en su raíz.
2. En R, instalar y restaurar el entorno:

   ```r
   install.packages("renv")
   renv::restore()
   ```

3. Descargar los microdatos directamente desde las instituciones productoras y ubicarlos bajo `data/raw/{chile,brasil,argentina}/`. No suba microdatos restringidos ni archivos pesados al repositorio.
4. Consulte [docs/DATOS.md](docs/DATOS.md) antes de ejecutar los análisis. Deben incorporarse y verificarse las series de costo de vida para los períodos y territorios comparados.

## Flujos de trabajo

### Revisión bibliográfica

Desde la raíz del proyecto, ejecute en R:

```r
source("scripts/00_lit_review/01_deduplicar.r")
source("scripts/00_lit_review/02_prisma_flowchart.R")
```

El primer script necesita los lotes bibliográficos de Web of Science en `data/raw/bib_raw/`; genera registros procesados en `output/` y `zotero/`. El segundo requiere las métricas generadas por el primero.

El último flujo reproducible identificó 3.982 registros, eliminó 18 duplicados y retuvo 3.750 tras excluir automáticamente 214. La selección manual y el número final de estudios incluidos siguen pendientes; tener DOI no equivale a disponer del texto completo ni a cumplir criterios de inclusión.

### Armonización inicial de encuestas

Desde la raíz del repositorio, ejecute:

```powershell
Rscript scripts/01_data_analysis/r/01_harmonize_households.R
```

El script crea una base local por país en `data/processed/`: CASEN 2024, PNAD Contínua 2025 (visita 1; solo capitales estatales) y EPH 1T2026 (Gran Buenos Aires). Requiere los microdatos locales indicados en [docs/DATOS.md](docs/DATOS.md). No calcula cobertura de canastas: aún deben documentarse y emparejarse valores compatibles por período, unidad y territorio. El archivo PNAD del primer trimestre de 2026 no se procesa con el diccionario de 2025.

### Encuesta CASEN en Stata

Abra Stata, sitúese en la raíz del repositorio y ejecute:

```stata
do scripts/01_data_analysis/stata/proc_rojas_murua_vicente.do
```

Este flujo conserva el análisis descriptivo de CASEN 2024 y genera tablas LaTeX y un gráfico. La armonización inicial de los tres países se ejecuta por separado con el script R anterior; no se deben interpretar las salidas de CASEN como resultados de los tres países.

### Presentación

Desde la carpeta `presentaciones/`, ejecute:

```powershell
quarto render seminario-ingresos-costo-vida-latinoamerica.qmd
```

La fuente es el archivo `.qmd`; el `.html` es su versión renderizada. Los bloques que calculan indicadores de asequibilidad necesitan las bases y series oficiales especificadas en [docs/DATOS.md](docs/DATOS.md).

### Tesis

Abra `latex/main.tex` en LaTeX Workshop o compile desde `latex/` con `latexmk -pdf main.tex`. Los archivos auxiliares de compilación se regeneran y están excluidos de Git.

## Reproducibilidad y límites

- Las encuestas tienen poblaciones, diseños muestrales, coberturas geográficas, conceptos de ingreso y períodos de referencia distintos. Documente cada decisión de armonización.
- Un valor nominal en pesos chilenos, reales brasileños o pesos argentinos no es comparable por sí solo. Use una medida oficial de costo de vida de cada país para el indicador de cobertura y no interprete esa razón como equivalencia entre canastas nacionales.
- Chile y Argentina cuentan con series oficiales de canastas, con diferencias de definición y cobertura. Brasil no tiene una canasta monetaria equivalente publicada por IBGE en los insumos revisados; la canasta DIEESE es una fuente independiente y específica por ciudad, no una estadística gubernamental nacional. No la presente como si fuera equivalente a las canastas oficiales de los otros países.
- Los microdatos, archivos procesados y resultados con datos personales o condiciones de uso institucional deben permanecer fuera de Git; véanse las condiciones de las respectivas fuentes.

## Licencia y uso

Consulte las condiciones de uso de cada fuente de datos. No se especifica una licencia de software en este repositorio; no asuma que los microdatos oficiales pueden redistribuirse junto con el código.

## Autoría

Proyecto de tesis de Vicente Rojas Murúa, Facultad de Ciencias Sociales, Universidad de Chile.
