# Instalación y ejecución

## Requisitos

- Windows, macOS o Linux.
- Git.
- R 4.3 o posterior y los paquetes fijados en `renv.lock`.
- Stata 17 para el procesamiento CASEN existente.
- Quarto y una distribución de LaTeX (con `latexmk` y Biber) para los productos editoriales.

RStudio y Visual Studio Code son opcionales; el proyecto no depende de una ruta local específica ni de un archivo de proyecto de RStudio.

## Preparar el entorno R

Desde la raíz del repositorio, ejecute en la consola de R:

```r
install.packages("renv")
renv::restore()
```

El archivo `.Rprofile` configura opciones al abrir una sesión interactiva. No contiene credenciales ni sustituye la restauración de paquetes.

## Ubicar datos

Descargue los archivos originales desde sus instituciones y respete sus términos de uso. Consulte [DATOS.md](DATOS.md) para la estructura local, los períodos disponibles y los metadatos necesarios. Las bases bajo `data/raw/` y `data/processed/` se excluyen de Git intencionalmente.

No use las salidas locales procesadas de Argentina como sustituto de sus bases originales para reproducibilidad; mantenga una copia de trabajo local con su procedencia anotada.

## Ejecutar las tareas actuales

### Procesamiento CASEN (Stata)

Desde la raíz del repositorio, abra Stata y ejecute:

```stata
do scripts/01_data_analysis/stata/proc_rojas_murua_vicente.do
```

El do-file disponible actualmente procesa CASEN 2024. No realiza aún la armonización de PNAD Contínua y EPH.

### Armonización inicial de hogares (R)

Desde la raíz del repositorio, ejecute:

```powershell
Rscript scripts/01_data_analysis/r/01_harmonize_households.R
```

El flujo requiere los microdatos locales indicados en [DATOS.md](DATOS.md) y guarda una base RDS por país bajo `data/processed/`. En su alcance inicial, procesa CASEN 2024, PNAD Contínua 2025 (visita 1; capitales estatales) y EPH 1T2026 (Gran Buenos Aires). No calcula razones de cobertura ni combina monedas; para PNAD 1T2026 hace falta incorporar su diccionario y ponderador específicos.

### Revisión bibliográfica (R)

Ejecute primero el cribado:

```r
source("scripts/00_lit_review/01_deduplicar.r")
```

El script necesita los registros `wos_*.bib` en `data/raw/bib_raw/`. Después de verificar el archivo de métricas generado, puede construir el diagrama:

```r
source("scripts/00_lit_review/02_prisma_flowchart.R")
```

El diagrama actual es preliminar: informa el filtrado automatizado de WoS, pero no incorpora aún la revisión manual a texto completo ni un número final de estudios incluidos.

### Presentación (Quarto)

Desde `presentaciones/`:

```powershell
quarto render seminario-ingresos-costo-vida-latinoamerica.qmd
```

La fuente reproducible es el `.qmd`; el `.html` es un producto generado. Algunos bloques usan microdatos locales, por lo que su ejecución depende de tener los archivos y paquetes disponibles.

### Tesis (LaTeX)

Abra `latex/main.tex` con LaTeX Workshop o compile desde `latex/`:

```powershell
latexmk -pdf main.tex
```

Los archivos auxiliares de compilación se regeneran y están excluidos de Git. Mantenga los capítulos `.tex`, la bibliografía, las figuras y el PDF final que desee distribuir.

## Actualizar dependencias

Cuando agregue o actualice un paquete R:

```r
renv::snapshot()
```

Revise el cambio en `renv.lock` y asegúrese de no incluir bibliotecas locales, microdatos, credenciales o archivos temporales.

## Antes de publicar resultados

1. Confirme que el período, la geografía y el universo de cada canasta coincidan con los ingresos comparados.
2. Verifique la unidad de análisis, el ponderador y el diseño muestral de cada encuesta.
3. Rotule explícitamente la fuente y el período en tablas y gráficos.
4. No presente el índice IPCA como un precio de canasta ni una encuesta de gasto como una canasta oficial.
5. Revise que los productos publicados no incluyan identificadores ni microdatos sujetos a restricciones.
