# Datos y comparabilidad

## Fuentes disponibles en la carpeta local

Los microdatos se descargan de las instituciones productoras y se mantienen fuera del control de versiones. Los nombres que siguen describen el inventario local conocido; confirme la licencia y los metadatos con cada fuente antes de reutilizarlos.

| País | Encuesta / archivo local | Período identificado | Uso previsto |
|---|---|---|---|
| Chile | `data/raw/chile/casen_2024.dta` | CASEN 2024 | Ingreso del hogar, composición, pobreza y variables sociodemográficas. |
| Chile | `data/raw/chile/base-gastos-ix-epf-stata.dta` y `base-personas-ix-epf-stata.dta` | IX EPF 2021–2022 | Describir gasto observado y composición de hogares; no equivale por sí sola a una canasta normativa. |
| Brasil | `data/raw/brasil/PNADC_2025_visita1_20260508.zip` y `dicionario_PNADC_microdados_2025_visita1_20260508.xls` | 2025, visita 1 | Insumo de la armonización inicial. Se conservan hogares de capitales estatales y se usa el ponderador calibrado `V1032`. |
| Brasil | `data/raw/brasil/PNADC_012026.zip` | Primer trimestre de 2026 | Microdatos trimestrales disponibles localmente, pero no procesados: requieren su diccionario y ponderador específicos. No se aplica el diccionario anual 2025 a este archivo. |
| Argentina | `data/raw/argentina/usu_hogar_T126.xlsx` y `usu_individual_T126.xlsx` | EPH, primer trimestre de 2026 | Ingreso del hogar e individual, características y ponderadores; encuesta urbana por aglomerados. |
| Argentina | `data/processed/argentina/usu_hogar_T126.dta` | EPH, primer trimestre de 2026 | Copia procesada local del archivo de hogares; no se versiona. |
| Regional | `data/raw/bib_raw/wos_*.bib` | Consulta bibliográfica del proyecto | Insumo de la revisión bibliográfica y del flujo PRISMA. |

CASEN 2024, EPH 1T2026, PNAD 2025/1T2026 e IX EPF 2021–2022 no son observaciones simultáneas. No forman automáticamente una serie temporal ni una muestra regional única.

## Insumo de costo de vida que falta

Para estimar cobertura, descargue y documente para cada fuente como mínimo:

- institución y URL oficial de descarga;
- nombre oficial del indicador (por ejemplo, CBA/CBT o medida local equivalente);
- valor, moneda y unidad (por persona u hogar);
- mes o período de referencia;
- cobertura geográfica y población de referencia;
- composición / metodología y enlace a su documentación;
- fecha de descarga.

La EPF chilena es una encuesta de gastos y no reemplaza automáticamente la canasta básica oficial. Chile publica una CBA mensual a través del Ministerio de Desarrollo Social y Familia; los informes a partir de enero de 2026 aplican una metodología actualizada respecto de la serie anterior, por lo que debe documentarse cualquier quiebre. [Serie histórica CBA de Chile](https://observatorio.ministeriodesarrollosocial.gob.cl/historico-cba-2014) y [metodología de pobreza por ingresos 2024](https://observatorio.ministeriodesarrollosocial.gob.cl/storage/docs/casen/2024/Metodologia_de_Medicion_de_la_Pobreza_por_Ingresos_2024.pdf).

Argentina publica CBA y CBT mensuales para Gran Buenos Aires, con valores por adulto equivalente. No se deben presentar como una canasta nacional para todos los aglomerados de la EPH. [Serie histórica INDEC CBA/CBT](https://www.indec.gob.ar/ftp/cuadros/sociedad/serie_cba_cbt.xls) y [metodología / preguntas frecuentes](https://www.indec.gob.ar/ftp/cuadros/sociedad/preguntas_frecuentes_cba_cbt.pdf).

IBGE publica índices IPCA, entre ellos variaciones de precios de alimentación en el hogar, pero un índice de precios no es el valor monetario de una canasta. Para conservar un indicador de cobertura basado en canasta en Brasil, esta investigación propone como fuente independiente la cesta básica de alimentos de DIEESE, desagregada por capital. Debe vincularse solo con geografías compatibles y rotularse como fuente no gubernamental. Si no se logra la correspondencia territorial y temporal, no se calculará la razón de cobertura para ese caso. [IPCA IBGE / SIDRA tabla 7060](https://sidra.ibge.gov.br/tabela/7060).

Las unidades no coinciden automáticamente: Chile expresa la CBA por persona; Argentina usa adulto equivalente; las observaciones DIEESE son mensuales por capital y se refieren a una canasta de alimentación para una persona trabajadora adulta. Mantenga la unidad publicada y no convierta unidades sin aplicar la escala documentada.

Plantilla versionable para las observaciones de canastas y precios: [`data/metadata/canastas_y_precios.csv`](../data/metadata/canastas_y_precios.csv). No rellene valores sin una fuente verificable.

## Esquema armonizado propuesto

El script [`01_harmonize_households.R`](../scripts/01_data_analysis/r/01_harmonize_households.R) genera bases locales de ingresos de hogares para los tres países. Para Brasil procesa únicamente PNAD Contínua 2025, visita 1; restringe la muestra a capitales estatales con `V1023 = 1` y conserva la UF. Usa `V1032`, el ponderador anual de primera visita con corrección por no respuesta y calibración por proyección de población; no usa `V1031`, que no tiene esa calibración. El identificador de hogar PNAD es `UPA + V1008 + V1014`; el tamaño es `V2001` y `VD5002` contiene ingreso domiciliario efectivo per cápita en reales. `V1023` identifica el tipo de área, no un municipio por sí mismo. Véanse el [diccionario oficial PNAD](https://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Anual/Microdados/Visita/Visita_1/Documentacao/dicionario_PNADC_microdados_2025_visita1_20260923.xls) y la [guía oficial de claves](https://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Anual/Microdados/Visita/Documentacao_Geral/Chaves_PNADC.pdf).

Para Argentina, el flujo limita la EPH a `REGION = 01` (Gran Buenos Aires), consistente con la cobertura de la serie CBA/CBT citada abajo; forma el identificador de hogar con `CODUSU + NRO_HOGAR` y retiene el ingreso familiar `ITF`, el tamaño `IX_TOT` y el ponderador de hogar `PONDIH`. Para Chile usa `ytotcorh`, `numper` y `expr` de CASEN 2024. Estas transformaciones producen variables descriptivas armonizadas, no una estimación conjunta ni errores estándar comparables. El archivo de costo de canasta se mantiene separado: el script no calcula cobertura mientras no haya observaciones documentadas que coincidan en período, unidad y geografía.

Cuando las definiciones originales lo permitan, la base derivada debe mantener una fila por hogar e incluir:

| Campo | Definición |
|---|---|
| `country` | `Chile`, `Brasil` o `Argentina`. |
| `survey` | Nombre oficial de encuesta y versión. |
| `reference_period` | Mes / trimestre / año observado. |
| `geography` | Área territorial compatible con el valor de canasta. |
| `household_id` | Identificador anonimizado local; nunca publicar identificadores. |
| `currency` | Moneda nominal original. |
| `household_income_monthly` | Ingreso monetario del hogar según concepto documentado en cada encuesta. |
| `household_size` | Personas incluidas en la definición de hogar. |
| `household_income_pc_monthly` | Ingreso mensual dividido por integrantes, si esa definición está respaldada. |
| `survey_weight` | Ponderador apropiado para la unidad de análisis (persona u hogar). |
| `basket_cost_monthly` | Valor mensual local, conservando la unidad publicada (persona, adulto equivalente o ciudad). |
| `basket_coverage` | Ingreso en la misma unidad dividido por el costo de la canasta, solo si período, unidad y territorio son compatibles. |

No fuerce campos ausentes a cero ni combine ingresos laborales individuales con costos de canasta del hogar. Conserve las variables de origen, los nombres originales y un registro de cualquier transformación. Use los diseños muestrales oficiales para estimar porcentajes o medias poblacionales.

## Límites de interpretación

- No compare directamente pesos chilenos, reales y pesos argentinos por su valor nominal.
- La razón ingreso/canasta expresa capacidad de cobertura en las unidades de cada país; no constituye una medida armonizada de calidad de vida.
- Diferencias de año, trimestre, cobertura urbana/rural, diseño muestral, subdeclaración, definición del ingreso y metodología de canastas deben informarse.
- Con los archivos actuales no se debe publicar una tasa de cobertura de los tres países hasta verificar la correspondencia de territorio, período y unidad. DIEESE no es una estadística oficial de gobierno; IPCA no es un precio de canasta.
- Los microdatos no deben subirse al repositorio sin verificar que sus términos permitan redistribución. GitHub solo recibe código, documentación y resultados publicables.

## Organización local

```text
data/
  raw/
    chile/
    brasil/
    argentina/
    bib_raw/
  processed/
    chile/
    brasil/
    argentina/
  metadata/
```
