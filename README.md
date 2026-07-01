# slep_paes

Panorama nacional de la **Prueba de Acceso a la Educación Superior (PAES)**,
construido con datos 100% públicos del **DEMRE** (Departamento de Evaluación,
Medición y Registro Educacional, Universidad de Chile), navegable por territorio
(comuna, SLEP, región, nacional) y publicado como un sitio HTML autocontenido en
GitHub Pages.

Producto del **Área de Monitoreo y Seguimiento de Procesos y Resultados
Educativos** del Servicio Local de Educación Pública Costa Central (Región de
Valparaíso). Proyecto hermano de
[`slep_categoria_desempeno`](https://tomgc.github.io/slep_categoria_desempeno/),
[`slep_idps`](https://tomgc.github.io/slep_idps/) y
[`slep_simce_adecuado`](https://tomgc.github.io/slep_simce_adecuado/): comparte
su arquitectura, su identidad visual y la lógica de agregación RBD → comuna →
nacional, con una paleta propia de PAES.

**Sitio publicado:** _pendiente de despliegue_.

## Qué hace

A diferencia de los hermanos (un indicador por establecimiento y año), la PAES es
un **embudo de etapas**. El panorama lo lee desde **dos focos pares**, ninguno
subordinado al otro:

- **Foco A — Cobertura:** cuántos de quienes *pueden* rendir efectivamente avanzan
  en cada etapa del embudo (egresados de enseñanza media como **denominador** →
  inscriben → rinden → obtienen resultados válidos → postulan → son seleccionados),
  y cómo se atenúa el embudo en cada paso, navegable por territorio.
- **Foco B — Rendimiento:** cómo les va a quienes rinden — distribución de puntajes
  por prueba (Competencia Lectora, M1, M2, Ciencias con su versión TP, Historia y
  Ciencias Sociales), en escala 100-1000, con los factores de contexto escolar
  (NEM, Ranking).

El dato nace en el postulante, se asigna al establecimiento de egreso (RBD) cuando
existe, y se agrega RBD → comuna → nacional. Quienes rinden sin RBD de egreso
vigente (egresados de años anteriores) se agregan en una **categoría explícita y
etiquetada** de cobertura, nunca diluida ni descartada.

## Cómo correr el pipeline

Requiere R 4.5.x. El orquestador ejecuta el pipeline completo de principio a fin:

```r
source("00_run_all.R")
run_all()
```

Etapas (carpeta `30_procesamiento/`):

1. `30_construir_auxiliares.R` — catálogos territoriales y de establecimientos
   (directorio oficial reusado de los hermanos).
2. `31_leer_normalizar.R` — lectura de las bases por etapa y de la caracterización
   de egresados; normalización y tipado (RBD y códigos comunales como `character`).
3. `32_agregar_territorial.R` — agregación RBD → comuna → nacional para los dos
   focos (cobertura y rendimiento).
4. `33_generar_html.R` — construye `40_salidas/motor_paes.html` y copia a
   `docs/index.html` para publicación.

> **Estado (sesión 1):** scaffold inicializado. Los scripts de
> `30_procesamiento/` aún no existen; `run_all()` avisa de los pasos ausentes sin
> abortar. Se construyen cuando el titular deposite las bases del DEMRE.

## Estructura

Sigue la convención canónica de carpetas numeradas por flujo de ejecución
(`10_utils`, `20_insumos`, `30_procesamiento`, `40_salidas`, `50_documentacion`),
documentada en `50_documentacion/activa/POLITICA_PROYECTO.md`.

## Datos (RAMA B — dos raíces)

**Este repositorio NO contiene datos reales.** Las bases del **DEMRE** (inscritos,
rendición/resultados, postulación/selección) y de **MINEDUC** (egresados de EM)
son **microdato por persona** e incluyen datos personales (`MRUN` de estudiantes
en egresados; `FECHA_NACIMIENTO` en inscritos; Ley 19.628 / 21.719). Por eso viven
**fuera del repo**, en la raíz de datos de OneDrive institucional apuntada por la
variable de entorno `SLEP_PAES_DATA_ROOT`.

El panorama publica únicamente **agregados territoriales** (`docs/index.html`), con
supresión de celdas que pudieran individualizar (umbral k=8, alineado al
k-anonimato del DEMRE). Ver `50_documentacion/activa/gobernanza_datos.md` para la
clasificación de datos, `manifiesto_insumos.md` para qué archivo va dónde, y
`contexto_paes.md` para la reseña de dominio (pruebas, escala 100-1000 e IRT, NEM,
Ranking, etapas, estructura de las bases DEMRE).

## Configuración inicial en una máquina nueva

1. Clonar el repo en `~/Projects/`.
2. Verificar que OneDrive institucional esté sincronizado y localizar la raíz de
   datos del proyecto (`.../OneDrive-SLEP/Proyectos/slep_paes/`, con `20_insumos/`
   y `40_salidas/`).
3. Copiar `.Renviron.example` a `~/.Renviron`, ajustar la ruta de
   `SLEP_PAES_DATA_ROOT` al sistema operativo, y reiniciar R / Positron.
4. Validar:
   ```r
   source(here::here("10_utils", "10_configuracion.R"))
   obtener_data_root()          # ruta válida
   dir.exists(ruta_insumos())   # TRUE
   dir.exists(ruta_salidas())   # TRUE
   ```
5. Correr `source("00_run_all.R"); run_all()`.

> Este repositorio **no** contiene datos reales: se obtienen del DEMRE/MINEDUC y se
> colocan en la raíz de datos externa. Ver gobernanza de datos.

## Publicación (GitHub Pages)

El sitio se sirve desde la carpeta `docs/` en la rama `main` (modelo de archivo
único). `docs/index.html` es una copia derivada de `40_salidas/motor_paes.html`,
regenerada en cada corrida del paso 33. La fuente de verdad es `40_salidas/`;
`docs/` no se edita a mano.

Para activar Pages: Settings → Pages → Source: Deploy from a branch → Branch:
`main` / carpeta `/docs`.

## Licencia

Código bajo licencia **MIT** (ver `LICENSE`). La licencia cubre el código del
repositorio; **no** cubre los datos, que se rigen por las condiciones de uso de la
información del DEMRE.
