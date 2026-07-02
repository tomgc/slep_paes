# Log — Generación de la suite de documentación (`suitedoc`) — slep_paes

- **Fecha:** 2026-07-02
- **Tipo de sesión:** BIBLIOTECA (produce `documentar.R` + los 4 HTML de la suite; no toca el pipeline PAES).
- **Encargo:** autónomo, secuencial, standalone offline activado desde el inicio (SETTINGS §4.6 + §4.6.4).
- **Entorno:** Claude Code, `~/Projects/slep_paes`, R-only, macOS. Paquete `suitedoc` 0.3.0.
- **Salida canónica:** `50_documentacion/suite/`.

## 1. Qué se hizo

Se generó la suite de 4 documentos HTML **standalone offline** de `slep_paes` a
partir de un `documentar.R` con la `cfg` poblada desde el material real del
proyecto. La `cfg` no parte de `cfg_ejemplo()`: se escribió como literal completo
para garantizar cero residuo del ejemplo de fábrica (SIMCE).

Documentos producidos (en `50_documentacion/suite/`):

- `arquitectura_slep_paes_standalone.html` (diagrama técnico)
- `documentacion_proyecto_slep_paes_standalone.html` (manual)
- `arquitectura_general_slep_paes_standalone.html` (línea de producción)
- `documentacion_general_slep_paes_standalone.html` (guía breve)

## 2. Insumos leídos (Fase 0)

Los 8 del encargo, de principio a fin, del filesystem del repo:

1. `estructura/estructura_actual.md` (escáner) — etapas, insumos, intermedios, rutas.
2. `traspasos/traspaso_cierre_v04.md` — decisiones, anomalías, KPI de prioridad, escala `--fs-*`.
3. `README.md` — identidad, origen de datos.
4. `CLAUDE.md` — convenciones técnicas.
5. `activa/decisiones/*.md` (4 archivos) — decisiones con su porqué.
6. `30_procesamiento/31_leer_normalizar.R`, `32_agregar_territorial.R`, `33_generar_html.R` — diccionario y etapas.
7. `activa/gobernanza_datos.md` — categoría Ley 21.719, qué no publicar.
8. `activa/contexto_paes.md` — glosario de dominio (Rasch, PAES/PDT, DEMRE, id_aux, escala 100–1000).

También se leyó el paquete `suitedoc` (`generar.R`, `builders.R`, `utils.R`,
`cfg_ejemplo.R`, `inline.R`, `encargo_suitedoc_inline_standalone.md`) para
confirmar el esquema de `cfg`, la firma `standalone=` y el detector de residuos.

## 3. Fases y resultado

- **Fase 1 — Entorno/paquete.** `npm --version` = 11.12.1 (OK). `suitedoc` 0.3.0
  expone `generar_suite(cfg, salida_dir, copiar_tema, verificar, standalone, verbose)`
  e `inlinar_suite`. No hizo falta reinstalar.
- **Fase 2 — Lectura y extracción.** `cfg` poblada: identidad y `fuente` del README;
  etapas 30→33 del escáner; insumos/intermedios de los scripts (Rama B: raíz externa
  `SLEP_PAES_DATA_ROOT` documentada sin exponer rutas absolutas); 4 decisiones de
  `decisiones/`; anomalías A1–A4 y reglas de cálculo (KPI de prioridad `orden_pref==1`
  con precedencia `estado_pref` 24 vs. 26; escala tipográfica `--fs-*`) del traspaso
  v04 y los scripts; `glosario_tec` de `contexto_paes.md`/`CLAUDE.md`; `cfg$gobernanza`
  con la categoría real de `gobernanza_datos.md`.
- **Fase 3 — Generación standalone.** `documentar.R` escrito y ejecutado por
  `Rscript` con la llamada canónica (`verificar=TRUE`, `standalone=TRUE`). Pasó a la
  primera: sin abortar por residuo del ejemplo y sin iconos `data-lucide` sin
  resolver. **Sin sustituciones de iconos** (todos resolvieron en lucide-static).
- **Fase 4 — Verificación empírica** (ver §5).
- **Fase 5 — Versionado** (ver §6).

## 4. Decisiones y notas de implementación

- **`cfg` como literal completo, no `cfg_ejemplo()`.** El detector de residuos
  (`.SUITEDOC_RESIDUOS_EJEMPLO`) aplana toda la `cfg`; partir del ejemplo dejaría
  términos SIMCE en bloques opcionales (`textos`, `reglas_calculo`, `dic_*`) que
  harían abortar `verificar=TRUE`. Escribir la `cfg` entera evita ese riesgo.
- **Encoding.** Los valores visibles llevan acentos/ñ (UTF-8). Se verificó, con una
  probe controlada (Encoding "unknown" + `.asegurar_utf8()` + `enc2utf8`) y luego
  sobre los HTML reales, que los bytes se preservan aun corriendo por `Rscript` bajo
  locale C: **0 mojibake** (`c3 83`). Los avisos "cannot be translated from US-ASCII
  to UTF-8, but is valid UTF-8" son inocuos (el propio mensaje confirma "valid UTF-8").
  Los nombres de campo e identificadores de código (`id_aux`, `estado_pref`,
  `*.parquet`, `--fs-*`) se mantienen en ASCII a propósito.
- **`entidades`/motor sin nivel establecimiento.** La comparación llega hasta comuna
  (POLÍTICA 6.4); no se documenta un nivel de establecimiento que el motor no expone.

## 5. Verificación empírica (Fase 4) — 🔒 con evidencia

| Invariante | Resultado | Evidencia |
|---|---|---|
| 🔒-OFFLINE: 0 referencias de red por archivo | **PASA** | grep `https?://` (excluyendo `www.w3.org`, namespace SVG) = 0 en los 4 |
| Iconos como `<svg>` embebido, no `<i data-lucide>` ni `<script>` lucide | **PASA** | `data-lucide`=0 y `unpkg/createIcons`=0 en los 4; `<svg>`=19 (arq_general) y 5 (doc_general) |
| Fuentes como `data:` URIs | **PASA** | `@font-face`=6 y `data:font`=6 por archivo; `<link ... stylesheet ... http>`=0 |
| Sin mojibake / acentos correctos | **PASA** | `c3 83`=0 en los 4; render de "año/región/enseñanza/niños/Educación/Concón" correcto |
| "IRT 3PL" ausente en texto visible | **PASA** | 0 en texto visible ("3PL" solo aparece dentro de blobs base64 de fuentes) |
| "rezagados" ausente en texto visible | **PASA** | 0 en los 4 (se usa "generaciones anteriores") |
| "EE" como abreviatura visible | **PASA** | 0 (`\bEE\b`); "ee" solo en el nombre de archivo `directorio_oficial_ee_publico.csv` |
| "colegio" solo en voz de FAQ | **PASA** | 1 ocurrencia, en la FAQ "¿…datos de estudiantes o de mi colegio?" (excepción permitida) |
| Sin nombres de establecimientos/personas | **PASA** | universos en abstracto; sin nombres reales en la `cfg` |
| `cfg$gobernanza` = categoría real Ley 21.719 | **PASA** | sello al pie: "Datos personales de NNA (Ley 21.719); se publican solo agregados territoriales" |
| Diagrama con rutas reales | **PASA** | `20_insumos/`, `20_insumos/auxiliares/`, `40_salidas/intermedios/`, `00_run_all.R`, `docs/index.html` presentes |

**Render en navegador** (servidor estático local, no supuesto): los 4 abren sin
errores de consola; el diagrama técnico muestra las 4 fuentes reales (ArchivoB/C/D +
egresados MINEDUC) con chips de código (`ID_aux`, `FECHA_NACIMIENTO`, `MRUN`,
`marca_egreso==1`) y las etapas 2–5; el documento general renderiza 19 SVG lucide
embebidos (estaciones, garantías) y las fuentes de marca (gobCL/Museo Sans) aplicadas.

## 6. Versionado (Fase 5)

- `git status` antes de `git add`; **nunca** `git add .`.
- Se versionan: los 4 `*_standalone.html`, `documentar.R`, `suite_estilos.css`, el
  `.gitignore` (con las nuevas exclusiones del tema) y este log.
- `fonts/` y `assets/` de la suite → añadidos al `.gitignore` (standalone los embebe;
  no se versionan). Confirmado con `git ls-files` que no entraron al índice.
- **NO push** (gate del titular, igual que el resto de la sesión 5).
- Commit atómico: ver hash reportado en el chat de la sesión.

## 7. Marcas `# REVISAR (voz)` pendientes en `documentar.R`

Prosa de comunidad redactada sin fuente literal (el contenido traza a
gobernanza/decisiones, pero el tono es del titular):

- `garantias` (6 tarjetas de garantías de calidad).
- `notas` ("en qué fijarte", 5 claves de lectura).
- `faq` (7 preguntas frecuentes, voz simulada del lector).
- `prosa$gen_porque` ("por qué existe").
- `textos` hero-notes: `gen_hero`, `gen_frase`, `doc_gen_hero`.

## 8. Detenciones / no resueltos

- **Ninguna detención** (reglas a–d no se gatillaron).
- **0 sustituciones de iconos** (todos los `data-lucide` resolvieron en lucide-static).
- **0 residuos del ejemplo** (verificar=TRUE pasó a la primera).
- Sin bugs durante la generación.

## 9. Notas para el revisor

- Regenerar: `Rscript -e 'setwd("/Users/tomgc/Projects/slep_paes"); source("50_documentacion/suite/documentar.R")'` (requiere npm + red para bajar lucide-static; la suite resultante es 100% offline).
- Los `*_standalone.html` NO dependen del tema en disco; `suite_estilos.css`, `fonts/` y `assets/` quedan junto a ellos solo como fuente para regenerar (el CSS se versiona; fuentes y logos no).
- Para publicar la suite (si se decide), el gate es del titular; esta sesión no hace push.
