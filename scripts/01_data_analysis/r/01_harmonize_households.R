# Armoniza una fila por hogar con ingreso, tamaño y ponderador de cada encuesta.
required_packages <- c("dplyr", "haven", "readr", "readxl", "tidyselect")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing_packages) > 0) {
  stop(
    "Instale los paquetes requeridos: ",
    paste(missing_packages, collapse = ", "),
    call. = FALSE
  )
}

project_root <- normalizePath(".", winslash = "/", mustWork = TRUE)
if (!dir.exists(file.path(project_root, "data", "raw"))) {
  stop("Ejecute este script desde la raíz del repositorio.", call. = FALSE)
}

required_file <- function(path) {
  if (!file.exists(path)) {
    stop("No se encontró el archivo requerido: ", path, call. = FALSE)
  }
  path
}

to_numeric <- function(x, variable) {
  if (haven::is.labelled(x)) {
    x <- haven::zap_labels(x)
  }
  if (is.factor(x)) {
    x <- as.character(x)
  }

  if (is.character(x)) {
    x <- trimws(x)
    x[x == ""] <- NA_character_
  }

  result <- suppressWarnings(as.numeric(x))
  invalid <- !is.na(x) & is.na(result)
  if (any(invalid)) {
    examples <- paste(utils::head(unique(x[invalid]), 5), collapse = ", ")
    stop(
      "Valores no numéricos en ", variable, ": ", examples,
      call. = FALSE
    )
  }
  result
}

require_columns <- function(data, columns, source) {
  missing <- setdiff(columns, names(data))
  if (length(missing) > 0) {
    stop(
      "Faltan variables en ", source, ": ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }
}

one_row_per_household <- function(data, source) {
  grouped <- dplyr::group_by(data, household_id)
  distinct_counts <- dplyr::summarise(
    grouped,
    dplyr::across(
      dplyr::everything(),
      ~ dplyr::n_distinct(.x, na.rm = TRUE)
    ),
    .groups = "drop"
  )
  conflicts <- names(distinct_counts)[
    vapply(distinct_counts[-1], function(x) any(x > 1), logical(1))
  ]
  if (length(conflicts) > 0) {
    stop(
      source, ": variables inconsistentes dentro del hogar: ",
      paste(conflicts, collapse = ", "),
      call. = FALSE
    )
  }

  dplyr::summarise(
    grouped,
    dplyr::across(dplyr::everything(), function(x) {
      observed <- x[!is.na(x)]
      if (length(observed) == 0) x[NA_integer_] else observed[1]
    }),
    .groups = "drop"
  )
}

make_households <- function(
  country,
  survey,
  period,
  currency,
  household_id,
  geography,
  income_monthly,
  household_size,
  weight,
  income_concept
) {
  income_monthly <- to_numeric(income_monthly, "income_monthly")
  household_size <- to_numeric(household_size, "household_size")
  weight <- to_numeric(weight, "survey_weight")
  household_id <- as.character(household_id)
  geography <- as.character(geography)

  valid <- !is.na(household_id) &
    nzchar(household_id) &
    !is.na(geography) &
    is.finite(income_monthly) &
    income_monthly >= 0 &
    is.finite(household_size) &
    household_size > 0 &
    is.finite(weight) &
    weight > 0

  removed <- sum(!valid)
  if (removed > 0) {
    message(country, ": se excluyeron ", removed,
            " hogares por identificador, ingreso, tamaño o ponderador inválido.")
  }

  result <- data.frame(
    country = country,
    survey = survey,
    reference_period = period,
    geography = geography[valid],
    household_id = household_id[valid],
    currency = currency,
    household_income_monthly = income_monthly[valid],
    household_size = household_size[valid],
    household_income_pc_monthly =
      income_monthly[valid] / household_size[valid],
    survey_weight = weight[valid],
    income_concept = income_concept,
    stringsAsFactors = FALSE
  )

  if (anyDuplicated(result$household_id)) {
    stop(
      country, ": el identificador no es único por hogar después de armonizar.",
      call. = FALSE
    )
  }
  result
}

save_households <- function(data, country) {
  output_dir <- file.path(project_root, "data", "processed", country)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  output_file <- file.path(output_dir, "hogares_armonizados.rds")
  saveRDS(data, output_file, version = 3)
  message(
    country, ": ", nrow(data), " hogares guardados en ",
    normalizePath(output_file, winslash = "/", mustWork = TRUE)
  )
  invisible(data)
}

read_haven_source <- function(path, variables) {
  path <- required_file(path)
  data <- haven::read_dta(
    path,
    col_select = tidyselect::all_of(variables)
  )
  require_columns(data, variables, path)
  data
}

casen <- read_haven_source(
  file.path(project_root, "data", "raw", "chile", "casen_2024.dta"),
  c("folio", "region", "expr", "ytotcorh", "numper")
)
casen_households_raw <- one_row_per_household(
  data.frame(
    household_id = paste(casen$region, casen$folio, sep = "-"),
    region = casen$region,
    income_monthly = casen$ytotcorh,
    household_size = casen$numper,
    weight = casen$expr,
    stringsAsFactors = FALSE
  ),
  "CASEN"
)
casen_households <- make_households(
  country = "Chile",
  survey = "CASEN",
  period = "2024",
  currency = "CLP",
  household_id = casen_households_raw$household_id,
  geography = ifelse(
    is.na(casen_households_raw$region),
    NA_character_,
    "Chile; cobertura nacional"
  ),
  income_monthly = casen_households_raw$income_monthly,
  household_size = casen_households_raw$household_size,
  weight = casen_households_raw$weight,
  income_concept = "Ingreso total corregido del hogar (ytotcorh)"
)
save_households(casen_households, "chile")
rm(casen, casen_households_raw, casen_households)

argentina <- read_haven_source(
  file.path(project_root, "data", "raw", "argentina", "usu_hogar_T126.dta"),
  c("codusu", "nro_hogar", "region", "pondih", "itf", "ix_tot")
)
arg_region <- to_numeric(argentina$region, "region")
argentina <- argentina[!is.na(arg_region) & arg_region == 1, , drop = FALSE]
arg_households <- make_households(
  country = "Argentina",
  survey = "EPH",
  period = "2026-T1",
  currency = "ARS",
  household_id = paste(argentina$codusu, argentina$nro_hogar, sep = "-"),
  geography = rep("Gran Buenos Aires (EPH, REGION=01)", nrow(argentina)),
  income_monthly = argentina$itf,
  household_size = argentina$ix_tot,
  weight = argentina$pondih,
  income_concept = "Ingreso total familiar (ITF)"
)
save_households(arg_households, "argentina")
rm(argentina, arg_region, arg_households)

pnad_archive <- required_file(file.path(
  project_root, "data", "raw", "brasil", "PNADC_2025_visita1_20260508.zip"
))
pnad_dictionary <- readxl::read_excel(
  required_file(file.path(
    project_root, "data", "raw", "brasil",
    "dicionario_PNADC_microdados_2025_visita1_20260508.xls"
  )),
  col_names = FALSE
)
pnad_variables <- c(
  "UPA", "V1008", "V1014", "UF", "V1023", "V1032", "V2001", "VD5002"
)
pnad_rows <- match(pnad_variables, trimws(as.character(pnad_dictionary[[3]])))
if (anyNA(pnad_rows)) {
  stop(
    "No se encontraron variables requeridas en el diccionario PNAD: ",
    paste(pnad_variables[is.na(pnad_rows)], collapse = ", "),
    call. = FALSE
  )
}
pnad_starts <- to_numeric(pnad_dictionary[[1]][pnad_rows], "posiciones PNAD")
pnad_widths <- to_numeric(pnad_dictionary[[2]][pnad_rows], "anchos PNAD")
if (anyNA(pnad_starts) || anyNA(pnad_widths) ||
    any(pnad_starts < 1) || any(pnad_widths < 1)) {
  stop("El diccionario PNAD contiene posiciones o anchos inválidos.", call. = FALSE)
}

pnad_connection <- unz(pnad_archive, "PNADC_2025_visita1.txt", open = "rb")
pnad <- readr::read_fwf(
  pnad_connection,
  readr::fwf_positions(
    start = pnad_starts,
    end = pnad_starts + pnad_widths - 1,
    col_names = pnad_variables
  ),
  col_types = readr::cols(.default = readr::col_character()),
  show_col_types = FALSE,
  progress = interactive()
)
close(pnad_connection)
require_columns(pnad, pnad_variables, pnad_archive)

pnad_capital <- !is.na(pnad$V1023) & pnad$V1023 == "1"
pnad_household_id <- paste(pnad$UPA, pnad$V1008, pnad$V1014, sep = "-")
pnad_household_size <- to_numeric(pnad$V2001, "V2001")
pnad_income_pc <- to_numeric(pnad$VD5002, "VD5002")
pnad_households_raw <- data.frame(
  household_id = pnad_household_id,
  UF = pnad$UF,
  household_size = pnad_household_size,
  income_pc = pnad_income_pc,
  weight = to_numeric(pnad$V1032, "V1032"),
  stringsAsFactors = FALSE
)
pnad_households_raw <- pnad_households_raw[pnad_capital, , drop = FALSE]
pnad_households_raw <- one_row_per_household(pnad_households_raw, "PNAD Contínua")
pnad_households <- make_households(
  country = "Brasil",
  survey = "PNAD Contínua, visita 1",
  period = "2025 (anual, visita 1)",
  currency = "BRL",
  household_id = pnad_households_raw$household_id,
  geography = paste0("Capital da UF ", pnad_households_raw$UF, " (V1023=1)"),
  income_monthly =
    pnad_households_raw$income_pc * pnad_households_raw$household_size,
  household_size = pnad_households_raw$household_size,
  weight = pnad_households_raw$weight,
  income_concept = paste(
    "VD5002 (rendimento domiciliar efetivo per capita) multiplicado",
    "por V2001; exclui pensionistas e empregados domésticos conforme IBGE"
  )
)
save_households(pnad_households, "brasil")

message(
  "No se calculó cobertura de canasta: faltan valores documentados y",
  " compatibles en período, unidad y geografía."
)
