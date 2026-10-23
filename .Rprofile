# ===========================================
# Configuración del entorno R
# Proyecto: ingresos-costo-vida-latinoamerica
# ===========================================

if (interactive()) {

  # Verificar si renv está disponible
  if (!require("renv", quietly = TRUE, warn.conflicts = FALSE)) {
    message("renv no encontrado. Instálalo con: install.packages('renv')")
  }

  # CONFIGURACIÓN REGIONAL Y LOCALE
  if (Sys.info()["sysname"] == "Windows") {
    Sys.setlocale("LC_TIME", "Spanish")
    Sys.setlocale("LC_COLLATE", "Spanish_Spain.1252")
  } else {
    Sys.setlocale("LC_ALL", "es_ES.UTF-8")
  }

  # OPCIONES GLOBALES
  options(
    width = 100,
    digits = 4,
    scipen = 999,
    max.print = 1000,
    repos = c(CRAN = "https://cloud.r-project.org"),
    warn = 1,
    stringsAsFactors = FALSE,
    timeout = 300
  )

  # MENSAJE DE BIENVENIDA
  cat("\n")
  cat("╔════════════════════════════════════════════════════════════╗\n")
  cat("║   Ingresos y Costo de Vida en el Cono Sur                ║\n")
  cat("║   Chile, Brasil y Argentina                               ║\n")
  cat("╚════════════════════════════════════════════════════════════╝\n")
  cat("\n")

  # DEFINIR RUTAS DEL PROYECTO
  project_root <- tryCatch({
    getwd()
  }, error = function(e) {
    path.expand("~")
  })

  data_raw <- file.path(project_root, "data", "raw")
  data_processed <- file.path(project_root, "data", "processed")
  scripts_dir <- file.path(project_root, "scripts")
  output_dir <- file.path(project_root, "output")

  invisible(lapply(
    list(data_raw, data_processed, output_dir),
    function(dir) {
      if (!dir.exists(dir)) {
        dir.create(dir, showWarnings = FALSE, recursive = TRUE)
      }
    }
  ))

  # FUNCIONES AUXILIARES
  clean_env <- function() {
    rm(list = ls(envir = .GlobalEnv)[-which(ls(envir = .GlobalEnv) %in% 
                                              c("clean_env", "project_info", "load_project_libs"))],
       envir = .GlobalEnv)
    gc()
    cat("✓ Entorno limpiado\n")
  }

  project_info <- function() {
    cat("\n📊 Información del Proyecto:\n")
    cat("─────────────────────────────\n")
    cat("Directorio raíz:", project_root, "\n")
    cat("Datos raw:", data_raw, "\n")
    cat("Datos procesados:", data_processed, "\n")
    cat("Scripts:", scripts_dir, "\n")
    cat("Output:", output_dir, "\n")
    cat("\n")
    cat("R version:", R.version$version.string, "\n")
    cat("Paquetes cargados:", length(loadedNamespaces()), "\n")
    cat("─────────────────────────────\n\n")
  }

  load_project_libs <- function() {
    suppressPackageStartupMessages({
      library(tidyverse, quietly = TRUE, warn.conflicts = FALSE)
      library(readxl, quietly = TRUE, warn.conflicts = FALSE)
      library(janitor, quietly = TRUE, warn.conflicts = FALSE)
    })
    
    cat("✓ Librerías principales cargadas\n")
  }

  # CONFIGURACIÓN DE PROMPT
  options(prompt = "R> ", continue = "+ ")

  # MENSAJES FINALES
  cat("✓ Entorno configurado correctamente\n")
  cat("  Ejecuta project_info() para ver detalles\n")
  cat("  Ejecuta load_project_libs() para cargar todas las librerías\n\n")
}