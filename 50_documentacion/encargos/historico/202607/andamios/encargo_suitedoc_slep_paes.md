# Encargo autónomo — Generar suite de documentación (`suitedoc`) para `slep_paes`

> Sigue el patrón de `encargo_autonomo_claude_code_v1.md`. Protocolo de contenido:
> `SETTINGS_Y_PROMPTS_OPERACIONALES.md` §4.6 (generación) y §4.6.4 (standalone offline,
> activado desde el inicio en este encargo, no como migración posterior).

## Modo y disciplina

Autónomo, secuencial, ejecuta todo en este turno. Rutas absolutas siempre. R-only.
Sin asumir `cd` previo: cada comando de terminal incluye `cd ~/Projects/slep_paes`.

## Regla de detención

PARA y reporta solo si:
(a) faltan los insumos imprescindibles (escáner o traspaso) y no están en el repo;
(b) `suitedoc` instalado no expone `generar_suite(..., standalone=)` y la reinstalación falla;
(c) `inlinar_suite()` aborta por un ícono `data-lucide` sin equivalente lucide obvio;
(d) una decisión metodológica (contenido de `decisiones`, `anomalias`, `reglas_calculo`) no consta en ningún insumo leído.
En estos casos, reporta y espera. No fabricar metodología (B.1).

## Contexto mínimo suficiente

- Proyecto: `slep_paes`, raíz de código `~/Projects/slep_paes` (Rama B: datos en OneDrive, `SLEP_PAES_DATA_ROOT`).
- Sesión BIBLIOTECA: produce `documentar.R` + los 4 HTML de la suite, no toca el pipeline PAES.
- Salida canónica: `50_documentacion/suite/` (SETTINGS §4.6.3.5).
- El proyecto ya tiene 4 sesiones de traspaso; el traspaso más reciente es `traspaso_cierre_v04.md` (corregido, con pendiente 4 = esta tarea).

## Insumos a leer (Fase 0, no asumir contenido)

Del filesystem del repo (`~/Projects/slep_paes`), en este orden:

1. `50_documentacion/estructura/estructura_actual.md` — imprescindible. Diagrama técnico: etapas, insumos, intermedios, rutas reales.
2. `50_documentacion/traspasos/traspaso_cierre_v04.md` — imprescindible. Decisiones, anomalías, reglas de cálculo, restricciones técnicas.
3. `README.md` — identidad, origen de datos.
4. `CLAUDE.md` — convenciones técnicas.
5. `50_documentacion/activa/decisiones/*.md` (los 4 archivos existentes) — decisiones con su porqué.
6. `30_procesamiento/31_leer_normalizar.R`, `32_agregar_territorial.R`, `33_generar_html.R` (no los utils) — diccionario de datos, detalle de etapas.
7. `50_documentacion/activa/gobernanza_datos.md` — gobernanza; qué NO publicar.
8. `50_documentacion/activa/contexto_paes.md` — glosario de dominio (Rasch, PAES/PDT, DEMRE), útil para `glosario_tec` y prosa técnica.

Si (1) o (2) no existen en el repo, PARA (regla de detención a).

## Invariantes (🔒)

- 🔒 `UMBRAL_SUPRESION_CELDA=8` — mencionar como constante de gobernanza, no reinterpretar.
- 🔒 Modelo psicométrico Rasch (un parámetro), nunca "IRT 3PL" (error de transcripción ya corregido en el proyecto; no reintroducirlo en la documentación).
- 🔒 "Generaciones anteriores" nunca como "rezagados" en texto visible.
- 🔒 Sentence case en toda la prosa generada.
- 🔒 Sin nombres de establecimientos, estudiantes ni funcionarios en ningún documento de la suite (gobernanza §6.4; los 4 HTML se publican).
- 🔒 Terminología institucional: "establecimiento educacional" completo en la primera mención de cada párrafo, "establecimiento(s)" en repeticiones del mismo párrafo. Nunca "EE" en texto visible (sí en notación técnica de fórmulas). Nunca "colegio" como sustantivo genérico (excepciones: voz de FAQ, ejemplo de universo, nombres propios externos).
- 🔒 `gobernanza_datos.md` define la categoría real (Ley 21.719) — usar esa categoría exacta en `cfg$gobernanza`, no inventar una.

## Fases en orden estricto

### Fase 1 — Verificación de entorno y paquete

1. `npm --version`. Si falla, PARA (regla de detención, precondición de `inlinar_suite`).
2. Confirmar que `suitedoc` instalado expone `generar_suite(cfg, salida_dir=, copiar_tema=, verificar=, standalone=, verbose=)`. Si no, reinstalar: `devtools::install("/Users/tomgc/Projects/herramientas_dev/suitedoc")`.

### Fase 2 — Lectura y extracción (SETTINGS §4.6.2)

1. Leer los 8 insumos de principio a fin.
2. Extraer y mapear a la `cfg`:
   - `slug` = `slep_paes`; `area`, `fuente` desde `README.md`.
   - Etapas del pipeline desde el escáner: `30_construir_auxiliares.R`, `31_leer_normalizar.R`, `32_agregar_territorial.R`, `33_generar_html.R` (en orden real).
   - Insumos/intermedios desde `20_insumos/`, `40_salidas/` (Rama B: solo `README.md` de referencia en el repo; documentar la raíz externa `SLEP_PAES_DATA_ROOT` como ubicación real, sin exponer rutas absolutas de la máquina de Tomás).
   - `decisiones`: las 4 de `decisiones/` (Camino A, patrón común y paleta, schema de `31`, territorialización de `D_MATR`), cada una con `id`, `titulo`, `cuerpo`, `por_que`.
   - `anomalias` y `reglas_calculo` desde el traspaso v04: KPI de prioridad (`orden_pref==1`, regla de precedencia `estado_pref` 24 vs. 26), escala tipográfica `--fs-*`.
   - `glosario_tec` desde `contexto_paes.md` y `CLAUDE.md` (Rasch, PAES/PDT, `id_aux`, DEMRE/MINEDUC, `UMBRAL_SUPRESION_CELDA`).
   - `cfg$gobernanza` desde `gobernanza_datos.md` (categoría Ley 21.719 real, no inventada).
3. Redactar prosa de comunidad (`faq`, `garantias`, `notas`, `prosa$gen_porque`, hero-notes): sin fuente directa en los insumos, marcar cada bloque con `# REVISAR (voz): ...`.

### Fase 3 — Generación standalone (SETTINGS §4.6.4, activado desde el inicio)

1. Escribir `50_documentacion/suite/documentar.R` completo, con `cfg` poblada (Fase 2) y llamada:

```r
suitedoc::generar_suite(
  cfg,
  salida_dir  = here::here("50_documentacion", "suite"),
  copiar_tema = TRUE,
  verificar   = TRUE,
  standalone  = TRUE,
  verbose     = TRUE
)
```

2. Regenerar: `Rscript -e 'setwd("/Users/tomgc/Projects/slep_paes"); source("/Users/tomgc/Projects/slep_paes/50_documentacion/suite/documentar.R")'`.
3. Si `inlinar_suite()` aborta por ícono sin resolver: sustituir por el equivalente lucide más cercano, registrar la sustitución. Si no hay equivalente obvio, PARA (regla de detención c).
4. Si `verificar=TRUE` aborta por texto de ejemplo de fábrica residual: corregir el bloque de `cfg` correspondiente (no bajar a `FALSE` sin reportarlo como decisión aparte).

### Fase 4 — Verificación empírica (sobre los `*_standalone.html` reales)

1. `grep` de referencias de red por archivo = 0 (`http://`, `https://`, `src=`/`href=` a CDN, `<link rel="stylesheet" href="http`). Reportar conteo por archivo.
2. Confirmar íconos como `<svg>` embebido (no `<i data-lucide>` ni `<script>` de lucide).
3. Confirmar fuentes como `data:` URIs.
4. Abrir los 4 HTML y verificar visualmente: diagrama técnico con rutas reales, sin nombres de establecimientos, terminología institucional correcta (grep de "EE " y "colegio" como sustantivo en el texto visible = 0 salvo excepciones documentadas).

### Fase 5 — Versionado

1. `git status` antes de `git add` (nunca `git add .`).
2. Versionar: los 4 `*_standalone.html` + `documentar.R` + CSS de la suite.
3. `fonts/` y `assets/` al `.gitignore` si no están (standalone los embebe, no se versionan).
4. Confirmar con `git ls-files` que el tema no entra al índice.
5. Commit atómico. **NO push** (gate del titular, igual que el resto de la sesión 5).

## Criterios de éxito verificables (B.4)

- `documentar.R` completo en `50_documentacion/suite/`, cfg sin bloques vacíos ni residuo de ejemplo.
- 4 `*_standalone.html` generados, 0 referencias de red en los 4.
- 0 apariciones de "IRT 3PL", "rezagados" (en texto visible), "EE" (en texto visible), nombres de establecimientos.
- `cfg$gobernanza` con la categoría real de `gobernanza_datos.md`.
- Commit local con `git ls-files` confirmando que `fonts/`/`assets/` no entraron.

## Mandato de auto-auditoría

Sin riesgo de datos nuevos (la suite documenta, no recalcula cifras): basta el principio general (verificar en navegador, no reportar sobre supuesto) más el grep de Fase 4. No se requiere panel adversarial.

## Mandato del log y reporte final

Generar `50_documentacion/andamios/logs/20260702_suitedoc_generacion_log.md` (plantilla fija, `encargo_autonomo_claude_code_v1.md` §4). Reportar en el chat: hash del commit, conteo de red por archivo (los 4), sustituciones de íconos si las hubo, marcas `# REVISAR` pendientes, ruta del log.
