library(bibliometrix)
library(dplyr)

# ==============================================================================
# 1. Cargar únicamente archivos que comiencen con "wos" en data/raw/bib_raw/
# ==============================================================================
archivos_bib <- list.files("data/raw/bib_raw", pattern = "^wos.*\\.bib$", full.names = TRUE)

if (length(archivos_bib) == 0) {
  archivos_bib <- list.files("refs", pattern = "^wos.*\\.bib$", full.names = TRUE)
}

if (length(archivos_bib) == 0) {
  stop("ERROR: No se encontraron archivos 'wos_*.bib' en 'data/raw/bib_raw/' ni en 'refs/'.")
}

cat("Archivos WoS detectados para procesamiento:\n")
cat(paste("-", archivos_bib, collapse = "\n"), "\n\n")

# Leer cada lote y consolidar
lista_dfs <- lapply(archivos_bib, function(f) {
  convert2df(f, dbsource = "wos", format = "bibtex")
})

# Solución al error: bind_rows tolera DataFrames con columnas o campos desiguales
m_wos_raw <- as.data.frame(bind_rows(lista_dfs))
n_identificados <- nrow(m_wos_raw)

# ==============================================================================
# 2. Eliminación de duplicados entre lotes
# ==============================================================================
m_wos_undup <- duplicatedMatching(m_wos_raw, Field = "TI", tol = 0.95)
n_duplicados <- n_identificados - nrow(m_wos_undup)
m_screened <- m_wos_undup

# ==============================================================================
# 3. Filtrado por palabras clave en Resumen (AB) y Título (TI)
# ==============================================================================
# Filtro automatizado multilingüe; no sustituye el cribado manual de elegibilidad.
pattern <- paste(
  "CASEN|PNAD|EPH|income|ingreso|renda|poverty|pobreza|wage|salario",
  "purchasing power|poder adquisitivo|cost of living|costo de vida|custo de vida",
  "inflation|inflación|inflação|basic basket|canasta básica|cesta básica",
  "transfer|transferencia|transferência|inequality|desigualdad|desigualdade",
  "distribution|distribución|distribuição|informal|food insecurity|inseguridad alimentaria",
  sep = "|"
)

texto_busqueda <- paste(
  ifelse(is.na(m_screened$TI), "", m_screened$TI),
  ifelse(is.na(m_screened$AB), "", m_screened$AB)
)

idx_incluidos <- grep(pattern, texto_busqueda, ignore.case = TRUE)

m_filtered <- m_screened[idx_incluidos, ]
n_filtrados_abstract <- nrow(m_filtered)
n_excluidos_abstract <- nrow(m_screened) - n_filtrados_abstract

# ==============================================================================
# 4. Exportación BibTeX robusta (segura ante campos ausentes)
# ==============================================================================
if (!dir.exists("zotero")) dir.create("zotero", recursive = TRUE)
if (!dir.exists("output")) dir.create("output", recursive = TRUE)

dois_limpios <- unique(na.omit(m_filtered$DI))
writeLines(dois_limpios, "zotero/dois_filtrados.txt")
saveRDS(m_filtered, "output/corpus_trinacional.rds")

export_bibtex_robust <- function(df, file_path) {
  get_col <- function(col_name) {
    if (col_name %in% names(df)) {
      val <- df[[col_name]]
      val[is.na(val)] <- ""
      as.character(val)
    } else {
      rep("", nrow(df))
    }
  }

  ut     <- get_col("UT")
  ti     <- get_col("TI")
  af     <- get_col("AF")
  au     <- get_col("AU")
  so     <- get_col("SO")
  py     <- get_col("PY")
  di     <- get_col("DI")
  vl     <- get_col("VL")
  is_col <- get_col("IS")
  ab     <- get_col("AB")

  con <- file(file_path, "w", encoding = "UTF-8")
  on.exit(close(con))

  for (i in seq_len(nrow(df))) {
    cite_key <- if (ut[i] != "") gsub(":", "_", ut[i]) else paste0("ref_", i)
    
    # Priorizar AF sobre AU para conservar nombres completos
    raw_auth <- if (af[i] != "") af[i] else au[i]
    author   <- gsub("\\s*;\\s*", " and ", raw_auth)
    
    title    <- gsub("[{}]", "", ti[i])
    abstract <- gsub("[{}]", "", ab[i])
    
    entry <- sprintf(
      "@article{%s,\n  author = {%s},\n  title = {{%s}},\n  journal = {%s},\n  year = {%s},\n  volume = {%s},\n  number = {%s},\n  doi = {%s},\n  abstract = {%s}\n}\n\n",
      cite_key, author, title, so[i], py[i], vl[i], is_col[i], di[i], abstract
    )
    cat(entry, file = con)
  }
}

export_bibtex_robust(m_filtered, "zotero/corpus_trinacional.bib")

# ==============================================================================
# 5. Métricas PRISMA
# ==============================================================================
prisma_metrics <- list(
  n_identificados     = n_identificados,
  n_duplicados        = n_duplicados,
  n_cribados_tit_abs  = nrow(m_screened),
  n_excluidos_tit_abs = n_excluidos_abstract,
  n_retenidos_automatizacion = n_filtrados_abstract,
  n_doi_disponibles   = length(dois_limpios),
  n_incluidos_final   = NA_integer_
)

saveRDS(prisma_metrics, "output/prisma_metrics.rds")

# ==============================================================================
# Diagnóstico en consola
# ==============================================================================
cat("=== RESUMEN DE PROCESAMIENTO PRISMA ===\n")
cat("1. Registros identificados en WoS (lotes)    :", n_identificados, "\n")
cat("2. Duplicados removidos entre lotes        :", n_duplicados, "\n")
cat("3. Evaluados por título y resumen           :", nrow(m_screened), "\n")
cat("4. Excluidos por irrelevancia              :", n_excluidos_abstract, "\n")
cat("5. Registros con DOI disponible             :", length(dois_limpios), "\n")
cat("========================================\n")