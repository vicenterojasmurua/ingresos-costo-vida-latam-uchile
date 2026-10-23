# Registro de Cambios

Todos los cambios notables en este proyecto se documentan en este archivo.

El formato se basa en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/) 
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

## [Sin versión] - 2026-10-23

### Cambiado
- Se reformuló el alcance como una comparación de Chile, Brasil y Argentina.
- Se distinguieron los períodos disponibles: CASEN 2024 y EPF 2021--2022; PNAD Contínua 2025 y 1T2026; EPH 1T2026.
- Se sustituyó la comparación de una supuesta canasta homogénea por medidas locales con fuente, período, unidad y geografía explícitos.
- Se actualizó la presentación para separar los resultados exploratorios de Chile de los resultados comparativos aún pendientes.
- Se incorporó un flujo R inicial para armonizar hogares de CASEN 2024, PNAD Contínua 2025 (visita 1; capitales estatales) y EPH 1T2026 (Gran Buenos Aires).
- Se amplió el filtro bibliográfico automatizado a términos en español, portugués e inglés, y se dejó pendiente el conteo de inclusión a texto completo hasta validar el registro manual.
- Se regeneró el flujo preliminar de WoS: 3.982 registros, 18 duplicados, 3.964 cribados automáticamente, 214 excluidos y 3.750 retenidos para revisión manual. La inclusión final sigue pendiente.
- Se renombró la fuente de la presentación al alcance latinoamericano y se eliminaron plantillas R genéricas que no pertenecen a los flujos seleccionados.
- Se retiraron de la bibliografía las rutas locales de adjuntos de Zotero, que no están disponibles para otros colaboradores.
- Se renombró el repositorio GitHub a `ingresos-costo-vida-latinoamerica` y se actualizaron su descripción y temas.

### Documentado
- La CBA/CBT de Argentina refiere al Gran Buenos Aires y se expresa por adulto equivalente.
- DIEESE es una fuente brasileña independiente y por capital; el IPCA de IBGE es un índice de precios, no un valor monetario de canasta.
- Se añadió una plantilla versionable para documentar series de costo de vida.

### Pendiente
- Incorporar series de canastas/precios y verificar su compatibilidad con cada encuesta.
- Incorporar PNAD 1T2026 con su documentación específica.
- Estimar resultados ponderados respetando los diseños muestrales y validar la correspondencia de períodos, unidades y geografías antes de publicar razones de cobertura.

## [Sin versión] - 2026-08-14

### Agregado
- ✅ Configuración completa del proyecto
  - `.Rprofile` mejorado con funciones auxiliares
  - `.gitignore` completo para R
  - `renv.lock` con dependencias pinned
  - `.vscode/settings.json` con configuración de R

- ✅ Documentación
  - `README.md` con estructura clara
  - `docs/SETUP.md` - Guía de instalación paso a paso
  - `docs/CONTRIBUIR.md` - Directrices de contribución
  - `docs/DATOS.md` - Especificación de estructura de datos
  - `CHANGELOG.md` - Este archivo

- ✅ Funciones auxiliares
  - `scripts/0_funciones_auxiliares.R` con utilidades comunes
  - Funciones para carga, limpieza, análisis y exportación de datos

- ✅ Estructura de carpetas
  - Directorios `data/raw/`, `data/processed/`, `output/`
  - Archivos `.gitkeep` para mantener directorios vacíos

- ✅ Configuración de entorno
  - `.Renviron.example` para variables de ambiente
  - Soporte multiplatforma (Windows, Linux, macOS)

### Modificado
- `.Rprofile` - Versión simplificada mejorada con más funciones
- `.gitignore` - Ampliado con más patrones
- `README.md` - Documentación expandida

### Estado de aquella versión

Esta sección documenta la configuración inicial de agosto de 2026. En ese momento el flujo comparativo aún estaba pendiente; el estado vigente se describe en el README y las guías bajo `docs/`.

---

## Notas de Desarrollo

### Convenciones Adoptadas

- **Idioma**: Español para comentarios, inglés para código (estándar R)
- **Nombres de funciones**: `snake_case`
- **Nombres de variables**: `snake_case`
- **Ancho líneas**: Max 100 caracteres (configurado en .Rprofile)
- **Indentación**: 2 espacios
- **Commits**: Semánticos con prefijos (feat, fix, docs, etc)

### Dependencias Principales

- `tidyverse` - Manipulación y visualización de datos
- `readxl` - Lectura de archivos Excel
- `janitor` - Limpieza de datos y nombres
- `writexl` - Escritura de archivos Excel
- `ggplot2` - Visualizaciones avanzadas (incluido en tidyverse)

### Versionado de Dependencias

Usar `renv` para garantizar reproducibilidad:
```bash
# Restaurar versiones exactas
renv::restore()

# Después de instalar nuevo paquete
renv::snapshot()

# Comitear cambios
git add renv.lock
git commit -m "chore: actualizar renv.lock"
```

---

## Historial de Cambios Anteriores

*La configuración inicial del repositorio se realizó en agosto de 2026.*

---

## Cómo Contribuir

Ver [docs/CONTRIBUIR.md](docs/CONTRIBUIR.md) para detalles sobre cómo reportar bugs, sugerir cambios, y hacer contribuciones.

---

**Mantenido por**: Vicente Rojas Murúa
**Última actualización**: 2026-10-23
