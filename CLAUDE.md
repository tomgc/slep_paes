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

**RAMA A** (proyecto publico, datos PAES del DEMRE versionados en el repo). Raiz
unificada, `.gitignore` estandar sin bloque de datos, sin data root externo.

**Sesion 1 (scaffold):** Paso 1 del plan completado — estructura canonica Rama A,
stubs de orquestador y escaner, `10_utils` con bootstrapping y configuracion,
contrato copiado, README/CLAUDE/LICENSE, git local, primer escaneo. Pipeline aun
sin pasos construidos.

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

1. **Sesion 1 — scaffold Rama A.** Estructura canonica por decenas, `00_run_all.R`
   y `00_escanear_proyecto.R`, `10_utils/10_utils.R` (bootstrapping) y
   `10_configuracion.R` (Rama A, vocabulario de dominio PAES sin congelar esquema),
   `.gitignore` publico, README, LICENSE (MIT + clausula de datos DEMRE), contrato
   copiado desde slep_idps. Pendiente: reuso de d3/pako y auxiliares (paso 2),
   `20_insumos/` + manifiesto + gobernanza + contexto_paes (paso 3), stubs de ETL
   y motor con doble foco (paso 4).
