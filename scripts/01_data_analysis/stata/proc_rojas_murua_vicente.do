* ==============================================================================
* PROYECTO: Tesis de Licenciatura en Sociología
* AUTOR: Vicente Rojas
* INSTITUCIÓN: Universidad de Chile - Facultad de Ciencias Sociales
* CHILE: CASEN 2024, procesamiento descriptivo y exportación de resultados
* ==============================================================================

* ------------------------------------------------------------------------------
* 1. CONFIGURACIÓN INICIAL Y ENTORNO REPRODUCIBLE
* ------------------------------------------------------------------------------

* Limpia la memoria de Stata (borra bases de datos previas)
clear all

* Evita que Stata pause la pantalla pidiendo presionar una tecla
set more off

* Elimina variables globales o locales guardadas anteriormente
macro drop _all

* Fija la versión de Stata para asegurar reproducibilidad
version 17

* Establece la semilla aleatoria para replicar resultados exactos
set seed 20260822

* Ejecutar este do-file desde la raíz del repositorio
local project_root "`c(pwd)'"
capture confirm file "`project_root'\data\raw\chile\casen_2024.dta"
if _rc {
    display as error "Ejecute el do-file desde la raíz del proyecto."
    display as error "No se encontró data/raw/chile/casen_2024.dta."
    exit 601
}

* Crea automáticamente las carpetas del proyecto si aún no existen
capture mkdir "logs"
capture mkdir "data"
capture mkdir "data/raw"
capture mkdir "data/raw/chile"
capture mkdir "data/raw/argentina"
capture mkdir "data/raw/brasil"
capture mkdir "data/processed"
capture mkdir "data/processed/chile"
capture mkdir "data/processed/argentina"
capture mkdir "data/processed/brasil"
capture mkdir "output"
capture mkdir "output/tables"
capture mkdir "output/figures"

* Cierra logs previos e intenta borrar el archivo anterior para evitar el error r(608)
capture log close _all
capture erase "logs/procesamiento_modulo01.log"

* Inicia la grabación del archivo log donde se guardará todo el historial de la consola
log using "logs/procesamiento_modulo01.log", replace text

* Muestra en pantalla la fecha y hora de inicio
display "Inicio de ejecucion: " c(current_date) " " c(current_time)

* ------------------------------------------------------------------------------
* 2. VERIFICACIÓN E INSTALACIÓN AUTOMÁTICA DE DEPENDENCIAS
* ------------------------------------------------------------------------------

* Revisa si los paquetes estout y outreg2 están instalados; si no, los instala automáticamente
local packages estout
foreach pkg in `packages' {
    capture which `pkg'
    if _rc != 0 {
        display "Instalando paquete requerido: `pkg'"
        ssc install `pkg', replace
    }
}

* ------------------------------------------------------------------------------
* 3. CARGA DE DATOS
* ------------------------------------------------------------------------------

* Carga la base de datos de Chile (CASEN 2024)
use "`project_root'\data\raw\chile\casen_2024.dta", clear

* Este do-file produce resultados de CASEN únicamente.
* PNAD Contínua y EPH requieren flujos de importación y armonización separados.

* ------------------------------------------------------------------------------
* 4. LIMPIEZA, FILTRADO Y CREACIÓN DE VARIABLES
* ------------------------------------------------------------------------------

* Mantiene únicamente las variables necesarias para el estudio
keep folio region sexo edad numper ytotcorh expr

* Elimina del análisis los casos sin información de ingresos (valores perdidos)
drop if missing(ytotcorh)

* Renombra variables para que sus nombres sean más claros y descriptivos
rename numper numero_personas
rename ytotcorh ingreso_total

* Calcula la variable 'ingreso per cápita' (Ingreso Total / Personas en el hogar)
generate ingreso_percapita = ingreso_total / numero_personas
label variable ingreso_percapita "Ingreso per cápita del hogar (CLP)"

* Construye la variable categórica para tramos de edad (1: 0-14, 2: 15-64, 3: 65+)
generate tramo_edad = .
replace tramo_edad = 1 if edad >= 0 & edad <= 14
replace tramo_edad = 2 if edad >= 15 & edad <= 64
replace tramo_edad = 3 if edad >= 65 & !missing(edad)

* Define y asigna las etiquetas de texto a los tramos de edad
label define etiquetas_edad 1 "0 a 14 años" 2 "15 a 64 años" 3 "65 o más años"
label values tramo_edad etiquetas_edad
label variable tramo_edad "Tramo etario"

* Guarda la base de datos limpia y procesada en la carpeta 'processed'
save "data/processed/chile/casen_2024_procesada.dta", replace

* ------------------------------------------------------------------------------
* 5. EXPORTACIÓN AUTOMÁTICA DE RESULTADOS A LATEX (OVERLEAF / GITHUB)
* ------------------------------------------------------------------------------

* A. TABLA DESCRIPTIVA: Tramos de Edad
eststo clear
* Calcula frecuencias y porcentajes ponderados por el factor de expansión
estpost tabulate tramo_edad [fw=round(expr)]

* Exporta la tabla en formato LaTeX (.tex) a la carpeta 'output/tables'
esttab using "output/tables/tabla_tramo_edad.tex", replace ///
    cell("b(fmt(0)) pct(fmt(2))") ///
    collabels("Frecuencia" "Porcentaje") ///
    unstack noobs nonumber ///
    booktabs ///
    title("Distribución por Tramos de Edad (CASEN 2024)")

* B. TABLA DESCRIPTIVA: Estadísticas de variables continuas
eststo clear
* Calcula Media, Desviación Estándar, Mediana, Mínimo y Máximo ponderados
estpost summarize ingreso_percapita numero_personas edad [aw=expr], detail

* Exporta los descriptivos a LaTeX
esttab using "output/tables/tabla_estadisticas_descriptivas.tex", replace ///
    cells("mean(fmt(2)) sd(fmt(2)) p50(fmt(2)) min(fmt(2)) max(fmt(2))") ///
    collabels("Media" "Desv. Est." "Mediana" "Mínimo" "Máximo") ///
    booktabs nonumber ///
    title("Estadísticas Descriptivas de Variables Clave")

* C. GENERACIÓN Y EXPORTACIÓN DE GRÁFICOS
* Crea un histograma del ingreso per cápita para personas con ingresos menores a $2.000.000 CLP
histogram ingreso_percapita [fw=round(expr)] if ingreso_percapita < 2000000, ///
    title("Distribución del Ingreso Per Cápita del Hogar") ///
    subtitle("Población con ingresos menores a $2.000.000 CLP") ///
    xtitle("Ingreso Per Cápita ($)") ytitle("Densidad") ///
    graphregion(color(white))

* Exporta el gráfico en formato PDF vectorial para alta calidad en Overleaf
graph export "output/figures/histograma_ingresos.pdf", as(pdf) replace

* Muestra mensaje final de éxito en la consola y cierra la grabación del Log
display "Procesamiento y exportacion finalizados correctamente: " c(current_date) " " c(current_time)
log close