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
catalogos (real), `31`/`32` son stubs que se omiten sin abortar hasta que el
titular deposite las bases DEMRE, `33` genera un motor-esqueleto autocontenido
(sin CDN) con el doble foco. Pendiente: bases del DEMRE; validacion visual de la
paleta; primer push.

## Pipeline

```r
source("00_run_all.R")            # define run_all(); orquesta 30 -> 31 -> 32 -> 33
run_all()                         # pipeline completo (avisa de pasos aun ausentes)
run_all(only = 33)                # solo regenera el motor HTML (= regenerar_motor())
source("00_escanear_proyecto.R")  # snapshot de estructura (al abrir y cerrar sesion)
```

- `30_construir_auxiliares.R` — catalogos territoriales (directorio oficial
  reusado) RBD -> comuna -> SLEP -> region -> nacional.
- `31_leer_normalizar.R` — lectura de las bases por etapa (inscripcion, rendicion,
  resultados, postulacion, seleccion) + caracterizacion de egresados; normaliza,
  tipa llaves como character, homologa esquema.
- `32_agregar_territorial.R` — agrega los dos focos: cobertura (embudo vs.
  denominador de egresados, con la categoria de rezagados) y rendimiento (puntajes
  por prueba/escala/NEM/Ranking).
- `33_generar_html.R` (+ `33_motor_template.html`) — motor HTML autocontenido,
  TODO CHILE, navegacion territorial, doble foco. Salida `40_salidas/motor_paes.html`
  (= `docs/index.html` para Pages).

## Ultimos cambios

1. **Sesion 1 (Fase A) — migracion Rama A -> B (codigo).** Diagnostico de las
   bases reales: microdato por persona (~953 MB) con PII (`MRUN`/`MRUN_IPE` de NNA
   en egresados 2023-2025; `FECHA_NACIMIENTO` en ArchivoB) y `ArchivoD_2023`
   (104 MB) sobre el limite de GitHub. Se migra a DOS RAICES: `10_configuracion.R`
   resuelve `SLEP_PAES_DATA_ROOT` (`obtener_data_root/ruta_insumos/ruta_salidas`),
   `.gitignore` blindado, `.Renviron.example`, `gobernanza_datos.md` -> Rama B,
   README con configuracion de maquina nueva, `30/31/32/33` leen via
   `ruta_insumos()/ruta_salidas()`, `git rm --cached` de lo versionado bajo
   `20_insumos/`. Hallazgos de esquema (para 31 futuro): patron
   `<PRUEBA>_<REG|INV>_<ACTUAL|ANTERIOR>` en ArchivoC (varia por año); ArchivoD
   wide(186 col, 2023) -> long(6 col, 2024+); ArchivoMatr = matricula
   universitaria; egresados 2026 ausente. **Fase B/C/D completadas:** datos en el
   data root, `~/.Renviron` con `SLEP_PAES_DATA_ROOT`, validacion 8.3.7 verde,
   `run_all(only=30)` corre desde OneDrive. **Renombrado** de los 74 archivos a
   snake_case + `demre/glosas/`->`demre/referencia/` (log en
   `andamios/20260701_renombrado_insumos_datos.csv`); `manifiesto_insumos.md`
   actualizado. PENDIENTE: el titular debe vaciar la copia vieja que quedo en el
   repo (`~/Projects/slep_paes/20_insumos/`, gitignoreada pero con PII en disco);
   diseño de 31 contra el esquema real; egresados 2026.
2. **Sesion 1 (paso 4) — stubs de ETL y motor.** Cuatro scripts en
   `30_procesamiento/`: `30_construir_auxiliares.R` (FUNCIONAL: catalogos
   territoriales desde el directorio publico + listado SLEP; 10.945 EE, 345
   comunas, Costa Central OK); `31_leer_normalizar.R` y `32_agregar_territorial.R`
   (stubs con compuerta: se omiten sin abortar si faltan las bases DEMRE; ya traen
   la logica de embudo, rezagados y supresion de celdas < 8); `33_generar_html.R` +
   `33_motor_template.html` (motor autocontenido, React/d3/pako LOCALES sin CDN,
   JSON columnar gzip+base64+pako, navegacion territorial + toggle de doble foco,
   `PALETA_PAES` como fuente unica; copia a `docs/index.html`). React libs copiadas
   a `10_utils/`. `run_all()` corre end-to-end (0 refs de red en el motor). Fix:
   el comentario del template repetia el token `__JSON_DATA__` y `sub()` lo
   reemplazaba antes que el real; reescrito.
2. **Sesion 1 (paso 3) — insumos, gobernanza y reseña.** Estructura de
   `20_insumos/` por etapa (`demre/{inscripcion,rendicion_resultados,
   postulacion_seleccion,glosas}` + `egresados_em/`) con README por carpeta y
   nombres canonicos; `manifiesto_insumos.md` (mapa etapa->base->nombre->foco->glosa).
   `gobernanza_datos.md` (datos abiertos DEMRE k-anonimizados con `ID_aux`;
   supresion de celdas < 8 = k-anonimato del DEMRE, `UMBRAL_SUPRESION_CELDA` a 8L;
   solo agregados en la web; terminologia SLEP). Reseña `Guia_Completa_de_la_PAES.docx`
   convertida a `contexto_paes.md` (fuente unica de dominio; fórmulas IRT/NEM no
   sobrevivieron la extraccion, se marcan, NO se rellenan). Guia de uso de datos
   abiertos DEMRE movida a `auxiliares/`.
2. **Sesion 1 (paso 2) — reuso y patron comun.** Reuso verbatim de d3/pako (md5
   identicos a los hermanos) y de los auxiliares territoriales desde slep_idps
   (directorio depurado SIN RUT/MRUN; .gitignore blinda el nombre del crudo). Nota
   `decisiones/20260630_decision_patron_comun_y_paleta.md` con el patron de familia
   (pipeline 30->33, JSON columnar gzip+base64+pako, motor autocontenido, Pages
   docs/) y las divergencias de PAES (microdato por postulante -> SI suprime celdas
   chicas; dos focos; agregacion en R). `PALETA_PAES` propia (uva/terracota), fuente
   unica en `10_configuracion.R`, v1 a validar visualmente.
2. **Sesion 1 (paso 1) — scaffold Rama A.** Estructura canonica por decenas, `00_run_all.R`
   y `00_escanear_proyecto.R`, `10_utils/10_utils.R` (bootstrapping) y
   `10_configuracion.R` (Rama A, vocabulario de dominio PAES sin congelar esquema),
   `.gitignore` publico, README, LICENSE (MIT + clausula de datos DEMRE), contrato
   copiado desde slep_idps. Pendiente: reuso de d3/pako y auxiliares (paso 2),
   `20_insumos/` + manifiesto + gobernanza + contexto_paes (paso 3), stubs de ETL
   y motor con doble foco (paso 4).
