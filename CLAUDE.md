# CLAUDE.md — slep_paes

Contrato de trabajo para Claude Code en este proyecto.

## Protocolo

El protocolo completo de sesiones (apertura, cierre, protocolos bajo demanda) y
la arquitectura del proyecto viven en la knowledge base del Project y en
`50_documentacion/activa/`:

- `POLITICA_PROYECTO.md` — estructura, gobernanza de datos, principios tecnicos.
- `SETTINGS_Y_PROMPTS_OPERACIONALES.md` — protocolos de sesion y de operacion.

Leer ambos al inicio de cada sesion. No pedir que se adjunten.

## Descripcion

Panorama nacional de la **Prueba de Acceso a la Educacion Superior (PAES)** con
datos publicos del **DEMRE**, navegable por territorio, publicado como sitio HTML
autocontenido en GitHub Pages. Cuarto panorama del **Area de Monitoreo y
Seguimiento de Procesos y Resultados Educativos** del SLEP Costa Central. Hermano
estetico y arquitectonico de `slep_categoria_desempeno`, `slep_idps` y
`slep_simce_adecuado`.

## Stack tecnologico

- **Pipeline (R):** R 4.5.x en Positron, nunca Python. Tidyverse, pipe nativo
  `|>`, `dplyr >= 1.1` con `.by=`, `here::here()`, `arrow`,
  `janitor::clean_names()` tras cada lectura.
- **Frontend (HTML autocontenido):** un unico `.html` con JSON embebido y
  comprimido. `d3.min.js` y `pako.min.js` LOCALES en `10_utils/` (reusados de los
  hermanos), nunca de CDN. Fuentes gobCL / Museo Sans embebidas.

## Reglas no negociables de este proyecto

- **R es el unico lenguaje de analisis.** Positron, no RStudio.
- **Llaves siempre `character`** (RBD, codigos comunales): un join con tipos
  mezclados falla en silencio.
- **Dos focos PARES, ninguno subordinado al otro** (regla de diseno, brief):
  - **Cobertura:** el embudo (egresados de EM como *denominador* -> inscripcion ->
    rendicion -> resultados -> postulacion -> seleccion) contra el denominador de
    elegibles. La caracterizacion de egresados es el denominador, no una etapa mas.
  - **Rendimiento:** distribucion de puntajes de quienes rinden, por prueba
    (Competencia Lectora, M1, M2, Ciencias + version TP, Historia y Cs. Sociales),
    escala 100-1000, con NEM y Ranking como contexto.
  El motor alterna o cruza ambos focos sobre la misma navegacion territorial.
- **Agregacion territorial RBD -> comuna -> nacional.** El dato nace en el
  postulante, se asigna al RBD de egreso cuando existe. Directorio oficial
  REUSADO de los hermanos, nunca reconstruido.
- **Categoria explicita de rezagados.** Quienes rinden sin RBD de egreso vigente
  (egresados de anios anteriores) se agregan ETIQUETADOS y visibles, jamas como
  hueco ni descarte. Es informacion, no error.
- **Solo agregados territoriales en la web.** Nunca microdato individual ni
  identificadores de postulantes. Supresion de celdas chicas con umbral como
  constante nombrada (`UMBRAL_SUPRESION_CELDA` en `10_configuracion.R`).
- **No inventar metodologia, conteos ni glosas** (B.1). Las definiciones salen de
  `contexto_paes.md` y de las glosas del DEMRE; lo que no consta se pregunta o se
  deja pendiente, no se fabrica.
- **Paleta PROPIA de PAES.** Prohibido heredar la paleta de un hermano (se define
  en el paso 2, nota de patron comun).
- **Sin dependencias web externas (CDN).** d3/pako y fuentes van locales o
  embebidas.
- **Naming** sin tildes, ñ, espacios ni guiones medios; estructura por decenas.
- Formato numerico chileno en outputs (coma decimal, punto miles); locale espanol
  en Excel.

## Estado

**RAMA B** (dos raices; reclasificado 2026-07-01). Las bases DEMRE/MINEDUC son
MICRODATO por persona con datos personales (`MRUN` de NNA en egresados,
`FECHA_NACIMIENTO` en ArchivoB): viven FUERA del repo, en la raiz de datos de
OneDrive (`SLEP_PAES_DATA_ROOT`). El repo solo tiene codigo, docs y
`docs/index.html` (agregados). `.gitignore` blindado. Acceso a datos SIEMPRE via
`ruta_insumos()` / `ruta_salidas()`.

**Sesion 1 (scaffold):** Pasos 1-4 del plan completados — estructura canonica Rama
A, orquestador y escaner, `10_utils` (incluida `PALETA_PAES` + React/d3/pako
locales), contrato, docs, reuso de auxiliares, nota de patron comun, `20_insumos/`
por etapa + manifiesto + gobernanza + `contexto_paes.md`, y los cuatro scripts de
`30_procesamiento/` + motor. `run_all()` corre end-to-end: `30` construye
catalogos (real), `33` genera un motor-esqueleto autocontenido (sin CDN) con
el doble foco. Pendiente: validacion visual de la paleta; primer push.

**Sesion 2:** `31_leer_normalizar.R` y `32_agregar_territorial.R` implementados
y verificados contra las bases reales (ver Ultimos cambios).

**Sesion 4:** `33_generar_html.R` + `33_motor_template.html` recrean el motor
final (Camino A) consumiendo los parquets territoriales de 32. `run_all()`
corre 30->31->32->33 end-to-end sobre datos reales y produce
`docs/index.html`. Pendiente: primer push; validacion visual del titular.

## Pipeline

```r
source("00_run_all.R")            # define run_all(); orquesta 30 -> 31 -> 32 -> 33
run_all()                         # pipeline completo (avisa de pasos aun ausentes)
run_all(only = 33)                # solo regenera el motor HTML (= regenerar_motor())
source("00_escanear_proyecto.R")  # snapshot de estructura (al abrir y cerrar sesion)
```

- `30_construir_auxiliares.R` — catalogos territoriales (directorio oficial
  reusado) RBD -> comuna -> SLEP -> region -> nacional.
- `31_leer_normalizar.R` — lectura y normalizacion de ArchivoB/C/D/Matr
  2023-2026 + egresados EM contra el esquema real (FUNCIONAL): pivot LONG de
  ArchivoC (prueba/tipo_rendicion/vigencia), unificacion wide/long de ArchivoD
  con atributos `*_solo2023` preservados, llaves character, manifiesto de
  archivos clasificado por nombre (ver decision 20260701).
- `32_agregar_territorial.R` — agrega los dos focos al arbol territorial RBD ->
  comuna -> SLEP -> region -> nacional (+ rezagados), con supresion de celdas
  chicas (FUNCIONAL): cobertura (embudo egresados/marca_egreso==1 ->
  inscripcion -> rendicion(vigencia=="actual") -> resultados(CLEC+M1) ->
  postulacion -> seleccion(estado_pref 24/26); ArchivoD/Matr sin `rbd` propio,
  ver decision 20260701) y rendimiento (puntaje por prueba/tipo_rendicion/
  vigencia + NEM/Ranking, media enmascarada si la celda se suprime).
- `33_generar_html.R` (+ `33_motor_template.html`) — motor HTML autocontenido
  (FUNCIONAL, Camino A): recrea el diseno hi-fi del handoff adaptado al contrato
  real de 32 (SOLO agregados; sin microdato; sin nivel establecimiento,
  POLITICA 6.4; media en vez de mediana; embudo de 6 etapas). React/ReactDOM/D3/
  pako locales + fuentes gobCL/Museo Sans embebidas base64 + JSON columnar
  gzip+base64 (sin CDN). Doble foco x vista (por territorio / comparar hasta 10)
  x periodo (actual/historica) + toggle de generaciones anteriores + modal de
  seleccion territorial (nacional->region->SLEP->comuna) + exportadores SVG/XLSX
  sin librerias. Salida `40_salidas/motor_paes.html` (= `docs/index.html` para Pages).

## Ultimos cambios

1. **Sesion — rendimiento publica «mejor puntaje vigente» por prueba (Decision 6,
   ventana=4).** El foco RENDIMIENTO pasa de publicar solo `reg`+`actual` al mejor
   puntaje vigente = `max(puntaje)` sobre las 4 casillas `REG/INV × ACTUAL/ANTERIOR`
   (regla oficial DEMRE «puntaje bloque»; `contexto_paes.md` sec.5; ventana=4
   aprobada). Fase 0: `PROCEDENCIA_*` no existe en ArchivoC -> se calcula el max.
   `32` gana bloque `rendimiento_vigente` (`tipo_rendicion="vigente"`, colapsa a 1
   mejor por persona-prueba antes de promediar; `bind_rows` preserva reg/inv/
   anterior); `33` filtra `vigente`+actual; motor: 5 notas aclaran la métrica.
   **Embudo intacto** (Decision 6: personas únicas; 0 cambios en `etapa_*`).
   Verificado: panel adversarial MATCH TOTAL (22.800 celdas), NEM/Ranking 0,
   DOM==recálculo, 0 errores. Delta nacional (vigente−reg, todas): +2..+15 pts,
   ~18-27k personas agregadas/prueba-año (solo-inv + solo-anterior); pocos
   negativos (CLEC 2023 −0,2; M1 2023 −5,9) por mezcla de cohortes de ventana=4.
   Commit `2163f69`. Log: `andamios/logs/20260703_rendimiento_vigente_ventana4_log.md`.
2. **Sesion — auditoria de datos pre-push + fix F1/F2 (denominador egresados y
   1.a prioridad).** Auditoria adversarial en R (4 fases, codigo propio en
   `andamios/auditoria_datos_pre_push/`) hallo: (F1, bloqueante) `etapa_egresados`
   en `32` se indexaba por `agno` (año de egreso) mientras las demas etapas por
   año de PROCESO -> desalineacion de 1 año -> 29 celdas %>100% en cohorte actual
   (max 207%, visible en DOM); (F2, menor) `coalesce(n_prioridad_1 suprimido, 0L)`
   mostraba «0% (0)» en 354 celdas donde el conteo real era 1..7. Autorizado por el
   titular: **F1** `anio_proceso = agno + 1L` (`35f7bd9`) -> `anio_actual` 2025->2026,
   2026 gana denominador y 2023 queda hueco; nacional actual 80,6%/79,1% (a 1,1pp
   de lo documentado). **F2** conserva `suprimida_p1` y emite resguardo (NA) en vez
   de 0 (`0a25277`). Re-auditoria (`927cc1a`): Fase 1 MATCH TOTAL, Fase 2 aditividad
   exacta, F2 resuelto, **residual F3** (comuna Santo Domingo 101%, 189 vs 188, por
   diferencia inter-archivo de rbd de egreso; NO corregido, decision del titular).
   Logs: `20260703_auditoria_datos_pre_push_log.md`,
   `20260703_reauditoria_post_fix_f1_f2_log.md`. Sin push.
2. **Sesion — fix denominador cohorte «Todas» (>100% en cobertura).** Bug en
   `CobComp` (`8a614c3`): en cohorte «Todas» el % se calculaba sobre `egresados`
   (solo actual) con numerador actual+anterior -> >100% (Viña 118%, 5.203/4.418).
   Misma causa raíz en las tres vistas y el export. Helper nuevo `baseCob()`
   rebasa a inscritos cuando la cohorte no es «actual»; columna/slab «Egresados»
   pasa a «—» en cohorte mixta. Corregido en `CobComp` (`baseN`), `CobActual`
   (`funnelStages` neutraliza egresados como base), `CobHist` (`baseY`, «actual»
   conserva egresados-o-hueco por año) y export XLSX (comp/hist/actual). Notas
   cohorte-conscientes («sobre inscritos» en anterior/todas). Interfaz pura (sin
   cambios en 32). Verificado B.4: 0 >100% en las tres vistas, Actual/Anteriores
   sin regresión, 0 errores. Commit `175787b`. Log:
   `andamios/logs/20260702_fix_base_todas_log.md`.
2. **Sesion — bloque «Universo de seleccionados» en la tabla comparativa de
   Cobertura (handoff Claude Design).** Reemplaza el tratamiento visual de la Fase 2
   anterior (`1d22d44`: borde simple + flecha, rechazado «2/10») por el bloque del
   handoff en `CobComp`: banda superior `colSpan=2` sobre Seleccionado +
   1.ª prioridad («UNIVERSO DE SELECCIONADOS · la 1.ª prioridad es % de este
   grupo», fondo `rgba(21,62,94,.05)`), marco exterior `BRK` (1.5px plum .42)
   envolviendo ambas columnas por los cuatro lados, separacion interna `BRK_IN`
   (1px `var(--line2)`) + flecha en `--plum`, header 1.ª prioridad en `--plum`,
   heatmap P1 con rango propio (`rangoP1`). `supCell` pasa a firma `(key,bl,br)`
   (bordes de grupo tambien en celdas suprimidas); caller de `RenComp` adaptado
   (preserva su 1px `var(--line2)`). Nota al pie con la redaccion corregida de la
   cohorte «Anteriores». Interfaz pura: `pct_prioridad_1` sin cambios. Verificado
   B.4 en navegador (banda/marco/flecha, rango propio P1, 0 errores). Commit
   `8a614c3`. Log: `andamios/logs/20260702_universo_seleccionados_log.md`.
2. **Sesion — rotulo «1.ª prioridad», marca visual de cambio de base, y
   DETENCION (a) en conteo invierno/regular.** Fase 1: rename «Prioridad 1» ->
   «1.ª prioridad» en texto visible del motor (header `heads` + nota
   metodologica; identificadores `n_prioridad_1`/`pct_prioridad_1` intactos)
   (`363d55a`). Fase 2: marca visual de que «1.ª prioridad» cambia de
   denominador (seleccionados, no egresados) — borde izq `2px var(--line2)` en
   cabecera y celdas + flecha `→` con `title` al hover; heatmap y calculo sin
   cambios; verificado B.4 (`1d22d44`). Fase 3: **DETENCION (a)** — se descubrio
   que `convocatoria_archivo` es SIEMPRE "REGULAR" (inerte); el invierno/regular
   real vive en `tipo_rendicion` (ArchivoC), y `etapa_rendicion`/`etapa_resultados`
   deduplican por `distinct(id_aux, rbd, anio_proceso)` SIN `tipo_rendicion`, por
   lo que una persona que rinde invierno+regular el mismo anio cuenta UNA vez
   (~19k-22k personas/anio). El embudo cuenta personas unicas por anio, NO
   participaciones intra-anio. NO se cambio el calculo ni se agrego la nota de
   «participaciones» (seria falsa). Pendiente: decision del titular (corregir la
   nota vs. cambiar el criterio a participaciones). Log:
   `andamios/logs/20260702_rotulo_p1_convocatoria_log.md`.
