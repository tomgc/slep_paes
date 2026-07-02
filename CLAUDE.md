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

1. **Sesion — rotulo «1.ª prioridad», marca visual de cambio de base, y
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
2. **Sesion 4 — motor `33` recreado con datos reales (Camino A).** Tras la
   detencion de la sesion anterior (el prototipo del handoff asumia un contrato
   que 32 no produce: 7 etapas con matricula, KPIs de prioridad, nivel
   establecimiento, strip plots por alumno + tooltip con dependencia = microdato
   reidentificable, mediana/sd, split rec/ant cruzado), el titular resolvio 4
   decisiones y confirmo Camino A. `33_generar_html.R` + `33_motor_template.html`
   recrean el diseno hi-fi del handoff (tokens/chrome/comportamiento) adaptado al
   agregado real: SOLO agregados (nacional/region/SLEP/comuna + generaciones
   anteriores), sin microdato, sin nivel establecimiento (POLITICA 6.4), media
   (no mediana), embudo de 6 etapas (sin matricula), toggle de generaciones
   anteriores (bucket `rezagados`), comparar hasta 10 territorios (default 4
   comunas de Costa Central, ampliable a SLEP/region/nacional). React/ReactDOM/
   D3/pako locales + fuentes gobCL/Museo Sans embebidas base64 + JSON columnar
   gzip+base64 (136 KB), 0 CDN. Modal de seleccion territorial con busqueda;
   exportadores SVG y XLSX sin librerias (XLSX valido, abre en `readxl`). Copy de
   resguardo del patron hermano (`sin dato (resguardo estadistico)`), modelo
   Rasch en notas. `anio_actual`=2025 (ultimo con denominador de egresados; 2026
   no trae egresados). Fixes durante verificacion: paren faltante en el modal;
   hook `useState` movido fuera de `Modal` (violaba rules-of-hooks al render
   condicional -> React #310); marcado UTF-8 recursivo de literales `.R` (locale
   C corrompia acentos/ñ via `enc2utf8`). Verificado: `run_all()` completo sin
   abortar; 6 combinaciones Foco×Vista×Periodo sin error de consola; panel
   adversarial recalculo 15 cifras (todas MATCH) contra los parquets por codigo
   independiente. Log: `andamios/logs/20260702_motor_33_datos_reales_log.md`.
2. **Sesion 3 — `32_agregar_territorial.R` implementado.** Decision delegada
   documentada en `decisiones/20260701_decision_territorializacion_d_matr.md`:
   ArchivoD (postulacion/seleccion) se territorializa via join por
   `(id_aux, anio_proceso)` contra `paes_inscripcion` (verificado: 100% de las
   751.175 combinaciones de ArchivoD existen en inscripcion, sin duplicados de
   llave); ArchivoMatr queda FUERA del arbol territorial en esta v1 (no es
   etapa de `ETAPAS_EMBUDO` ni fue pedida). FOCO COBERTURA: embudo egresados
   (`marca_egreso==1`, ver hallazgo abajo) -> inscripcion -> rendicion
   (`vigencia=="actual"`) -> resultados (rindio CLEC+M1 este anio, sin el
   umbral fino de 458 ptos/10% superior: `PORC_SUP_NOTAS` real es un decil sin
   glosa que confirme el mapeo -> alcance documentado, no inventado) ->
   postulacion -> seleccion (`estado_pref` 24/26; 25="lista de espera" no
   cuenta). Rezagados visibles como `tipo_entidad` propio, nunca hueco.
   Hallazgo real en egresados: el archivo trae ~4x mas filas que personas
   (999.446 vs. ~254.750 en 2023) porque incluye un registro por grado
   (1°-4° medio) por estudiante; `MARCA_EGRESO==1` identifica la fila de
   egreso efectivo (verificado: tras filtrar, MRUN es unico por año y las
   cardinalidades resultantes -254.750/257.261/281.356- calzan con cohortes
   reales de egreso de EM en Chile; sin glosa oficial para esa columna, el
   archivo MINEDUC no trae libro de codigos). FOCO RENDIMIENTO: puntaje por
   prueba/tipo_rendicion/vigencia + NEM/Ranking (sentinela 0 excluido, mismo
   patron que puntaje), deduplicando NEM/Ranking por persona antes de
   promediar (son atributos por persona, no por fila pivoteada). Verificado
   end-to-end: supresion de celdas aplicada (83 celdas de cobertura, 5.873 de
   rendimiento, media enmascarada junto con n); embudo inscripcion->seleccion
   100% monotonico a nivel nacional/region/SLEP y 99,7% a nivel comuna (4
   excepciones puntuales: postulacion levemente > resultados donde el
   postulante usa un puntaje `vigencia=="anterior"` sin re-rendir CLEC/M1 este
   año, consistente con el mecanismo de "puntaje vigente" documentado).
   `egresados` vs. `inscripcion` NO es monotonico por diseño (poblaciones
   distintas: egresados = cohorte de ESE año; inscripcion incluye rezagados de
   años previos) — esperado, no defecto.
3. **Sesion 2 — `31_leer_normalizar.R` implementado (Fase B).** Diagnostico
   previo en `decisiones/20260701_decision_schema_31_leer_normalizar.md`
   (mapeo wide->long de ArchivoD 2023 + esquema LONG para ArchivoC),
   aprobado por el titular con dos resoluciones: `SITUACION_POSTULANTE[_BEA|
   _PACE]`/flags `BEA`/`PACE` de 2023 se preservan como atributos
   `*_solo2023` (NA en 2024+); postulantes repetidos entre `_reg`/`_inv` 2026
   se apilan sin fusion (sin regla de precedencia confirmada). Lee y
   normaliza ArchivoB/C/D/Matr 2023-2026 + egresados EM (delimitador `,`,
   distinto de los planos DEMRE en `;`) desde el manifiesto de archivos
   clasificado por NOMBRE (nunca por posicion ni por carpeta unica: ArchivoD
   y ArchivoMatr conviven en `postulacion_seleccion/`). ArchivoC se pivotea
   LONG (`prueba, tipo_rendicion, vigencia, puntaje`), descartando el
   sentinela 0; `MODULO_*` (BIO/FIS/QUI/TEC) se pivotea aparte por no ser un
   puntaje y se adjunta solo a `prueba == "cien"`. Bug encontrado y
   corregido en la verificacion: ArchivoD 2023 mezcla separador decimal
   coma/punto dentro del bloque PACE (~1967 celdas) — se lee siempre como
   texto y se parsea con `parsear_numero_flex()` tolerante a ambas
   notaciones (antes se perdian esos puntajes como NA en el read inicial).
   Verificado end-to-end contra los datos reales: 4 anios, sin NA
   inesperados en llaves/puntajes (los NA de `rbd` y `ptje_pref` trazan a
   causas de negocio conocidas — rezagados sin RBD vigente, preferencias
   rechazadas sin ponderado — no a fallas de parsing). `32_agregar_
   territorial.R` sigue como stub.
4. **Sesion 2 — `31_leer_normalizar.R`: limpieza MODULO_*.** Las columnas
   crudas `modulo_{reg,inv}_{actual,anterior}` quedaban replicadas sin
   pivotear en `paes_rendicion_resultados.parquet` (redundantes con
   `modulo_ciencias`, ya derivada). Se excluyen del `df` base antes del pivot
   de puntajes. Verificado: parquet regenerado con 4.845.570 filas (sin
   cambio) y 22 columnas (antes 26); `modulo_ciencias` intacta.
