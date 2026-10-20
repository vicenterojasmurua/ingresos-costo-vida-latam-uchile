# Análisis de Ingresos y Costo de Vida en Chile, Brasil y Argentina 📊

![Stata version](https://img.shields.io/badge/Stata-17.0+-blue)
![R version](https://img.shields.io/badge/R-4.3.0+-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Overleaf Sync](https://img.shields.io/badge/Overleaf-Compatible-brightgreen)

## Descripción

Este proyecto analiza la relación entre ingresos y costo de vida en Chile mediante el procesamiento de microdatos de la encuesta CASEN 2024, EPH (Argentina) y PNAD (Brasil). El flujo de trabajo está diseñado bajo estándares estrictos de **Open Science**, garantizando replicabilidad determinista y conexión automatizada con LaTeX (Overleaf).

## 📁 Estructura del Proyecto

```text
ingresos-costo-vida-chile/
├── data/
│   ├── raw/              # Microdatos crudos (CASEN, EPH, PNAD)
│   └── processed/        # Microdatos limpios y armonizados
├── scripts/
│   ├── stata/            # Do-files de Stata 17 (Procesamiento y Modelos)
│   └── r/                # Scripts auxiliares en R
├── output/               # Salidas vinculadas a Overleaf
│   ├── tables/           # Tablas estadísticas en código LaTeX (.tex)
│   └── figures/          # Gráficos vectoriales (.pdf)
├── logs/                 # Registros de ejecución para auditoría
├── .gitignore            # Exclusión de datos pesados
└── README.md             # Instrucciones de replicación
```

## 🚀 Inicio Rápido

### Requisitos Previos
- **R**: versión 4.3.0 o superior
- **RStudio** (opcional pero recomendado)
- **Git**: para control de versiones

### Instalación

1. Clonar el repositorio:
```bash
git clone <repository-url>
cd ingresos-costo-vida-chile
```

2. Restaurar el entorno con `renv`:
```R
install.packages("renv")
renv::restore()
```

3. Ejecutar el pipeline:
```R
# En orden de dependencia:
source("scripts/01_carga_datos.R")
source("scripts/02_limpieza_datos.R")
source("scripts/03_analisis_exploratorio.R")
source("scripts/04_visualizaciones.R")
```

## 📊 Dependencias Principales

- **tidyverse** (2.0.0) - Manipulación y visualización de datos
- **readxl** (1.4.3) - Lectura de archivos Excel
- **janitor** (2.2.0) - Limpieza de datos
- **ggplot2** - Visualizaciones avanzadas
- **plotly** - Gráficos interactivos
- **knitr** - Generación de reportes

Ver [renv.lock](renv.lock) para la lista completa de dependencias y versiones.

## 📝 Flujo de Trabajo

### Scripts Principales

| Script | Descripción | Entrada | Salida |
|--------|-------------|---------|--------|
| `01_carga_datos.R` | Carga datos de fuentes | - | `data/raw/` |
| `02_limpieza_datos.R` | Limpia y transforma | `data/raw/` | `data/processed/` |
| `03_analisis_exploratorio.R` | Análisis exploratorio | `data/processed/` | Estadísticas básicas |
| `04_visualizaciones.R` | Genera gráficos | `data/processed/` | `output/` |

## 🤝 Contribución

Las contribuciones son bienvenidas. Por favor, consulta [CONTRIBUIR.md](docs/CONTRIBUIR.md) para detalles sobre el proceso de contribución.

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver LICENSE para más detalles.

## 👤 Autor

Creado para análisis de datos económicos de Chile.

## 📞 Contacto

Para preguntas o sugerencias, abre un issue en el repositorio. 
