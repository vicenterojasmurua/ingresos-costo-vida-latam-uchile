required_packages <- c("DiagrammeR", "DiagrammeRsvg", "rsvg")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing_packages) > 0) {
  stop(
    "Restaure las dependencias del proyecto; faltan: ",
    paste(missing_packages, collapse = ", "),
    call. = FALSE
  )
}

library(DiagrammeR)
library(DiagrammeRsvg)
library(rsvg)

# Cargar métricas exportadas
metrics <- readRDS("output/prisma_metrics.rds")

if (!"n_incluidos_final" %in% names(metrics)) {
  stop("Las métricas no incluyen el estado de selección a texto completo.", call. = FALSE)
}
incluidos_label <- if (is.na(metrics$n_incluidos_final)) {
  "pendiente de verificación"
} else {
  as.character(metrics$n_incluidos_final)
}

# Construir diagrama Graphviz
dot_code <- sprintf("
digraph prisma {
  graph [layout = dot, rankdir = TB, nodesep = 0.5, ranksep = 0.5]
  node [shape = rectangle, style = filled, fillcolor = White, fontname = Helvetica, fontsize = 10, width = 3.5]
  
  subgraph cluster_ident {
    label = 'Identificación';
    style = dashed; color = gray;
    node1 [label = 'Registros identificados en\\nWeb of Science (n = %d)'];
    node2 [label = 'Registros duplicados eliminados\\n(n = %d)'];
  }
  
  subgraph cluster_screen {
    label = 'Cribado (Screening)';
    style = dashed; color = gray;
    node3 [label = 'Registros examinados por título/resumen\\n(n = %d)'];
    node4 [label = 'Registros excluidos por el filtro automatizado\\n(n = %d)'];
  }
  
  subgraph cluster_elig {
    label = 'Elegibilidad e Inclusión';
    style = dashed; color = gray;
    node5 [label = 'Registros retenidos para revisión manual\\n(n = %d)'];
    node6 [label = 'Estudios incluidos tras revisión a texto completo\\n(n = %s)'];
  }
  
  node1 -> node3;
  node1 -> node2;
  node3 -> node5;
  node3 -> node4;
  node5 -> node6;
}
", metrics$n_identificados, metrics$n_duplicados, metrics$n_cribados_tit_abs,
  metrics$n_excluidos_tit_abs, metrics$n_retenidos_automatizacion, incluidos_label)

# Renderizar y guardar gráficos
graph <- grViz(dot_code)
svg_code <- export_svg(graph)

# Guardar en formatos de alta resolución
rsvg_png(charToRaw(svg_code), "images/prisma-flowchart.png", width = 1800, height = 2200)
rsvg_pdf(charToRaw(svg_code), "images/prisma-flowchart.pdf")

cat("Diagrama PRISMA generado en 'images/prisma-flowchart.png' y 'images/prisma-flowchart.pdf'\n")