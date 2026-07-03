# Traspaso de cierre — slep_paes — v02

## 1. Identificación

- **Proyecto:** slep_paes
- **Versión:** v02
- **Fecha:** 2026-07-01
- **Sesión:** 2, foco en resolver Pendiente 2 (escala PDT/PAES), actualizar
  `contexto_paes.md` con fuentes oficiales, implementar `31_leer_normalizar.R`
  y `32_agregar_territorial.R` contra datos reales, e iniciar diseño UI/UX.
- **Entorno:** conversación con Claude (análisis) + Claude Code (ejecución
  autónoma en `~/Projects/slep_paes`) + Claude Design (alternativas de
  interfaz, en curso, sin cerrar).
- **Archivos principales modificados:** `contexto_paes.md`,
  `30_procesamiento/31_leer_normalizar.R`, `30_procesamiento/32_agregar_territorial.R`,
  `CLAUDE.md`, `50_documentacion/andamios/logs/20260701_escala_anterior_archivoc_2023.md`,
  `50_documentacion/andamios/logs/20260701_hallazgos_actualizacion_contexto_paes.{md,html}`,
  `50_documentacion/activa/decisiones/20260701_decision_schema_31_leer_normalizar.md`,
  `50_documentacion/activa/decisiones/20260701_decision_territorializacion_d_matr.md`

- **Commits locales por fase (hashes exactos, todos pusheados a `origin/main`):**

  | Hash | Contenido |
  |---|---|
  | `4609ccd` | Diagnóstico de escala PDT/PAES en `*_ANTERIOR` de ArchivoC_Adm2023 (Pendiente 2) |
  | `2033d01` | `contexto_paes.md` actualizado con fuentes oficiales DEMRE + hallazgos (md/html) |
  | `f554424` | Re-chequeo del Puntaje Ponderado 848,75 (confirmado sin cambios) |
  | `3c0a2c6` | Snapshot de estructura pendiente (chore) |
  | (sin hash registrado en esta conversación) | Diagnóstico Fase A de `31_leer_normalizar.R` (documento de decisión) |
  | `4fed022` | `31_leer_normalizar.R` implementado y verificado (Fase B) |
  | `119e5b1` | Limpieza de columnas `modulo_*` redundantes en `31` |
  | `9b74caf` | `32_agregar_territorial.R` implementado y verificado |
  | `e478392` | Confirmación de `marca_egreso` contra Libro de Códigos (docs, sin cambio de lógica) |

  Todos pusheados; `origin/main` en `e478392` al cierre de la sesión
  (confirmado por escáner del repo, 2026-07-01 17:32:34: `31_leer_normalizar.R`
  18.5K, `32_agregar_territorial.R` 16.2K, ambos con tamaño consistente con
  código funcional, no stub).

## 2. Resumen ejecutivo

Sesión 2 resolvió el bloqueante heredado de v01 (Pendiente 2: escala
PDT/PAES en `*_ANTERIOR` de ArchivoC_Adm2023), refutando la hipótesis del
traspaso anterior con evidencia empírica y documental doble (resultado:
escala PAES uniforme, no PDT). A partir de ahí, se ejecutó una revisión
completa de `contexto_paes.md` contra 23 documentos oficiales del DEMRE
más búsqueda web dirigida, con 7 correcciones (la mayor: el modelo
psicométrico es Rasch, no IRT 3PL, corrigiendo un error heredado de la
guía secundaria usada en sesión 1) y 12 adiciones (niveles de desempeño,
CCEA, marco legal Ley 21.490, entre otros). Con el contexto de dominio
corregido, se implementaron y verificaron contra los cuatro años de datos
reales `31_leer_normalizar.R` (con un bug real de parsing encontrado y
corregido: mezcla de separador decimal en ArchivoD 2023) y
`32_agregar_territorial.R` (con verificación de monotonicidad del embudo,
supresión de celdas chicas, y confirmación documental del filtro de
egresados que inicialmente se aplicó por inferencia). El pipeline de datos
reales queda funcional y verificado de punta a punta hasta la agregación
territorial. Se inició, sin cerrar, el diseño de interfaz UI/UX: se envió
un encargo a Claude Design con dos motores hermanos como referencia de
patrón de familia, pendiente de que el titular traiga las propuestas.
`33_generar_html.R` sigue generando el motor con datos de andamiaje, no
con los datos reales ya disponibles de `32`.

## 3. Estado al cierre

**Qué funciona (última ejecución exitosa, 2026-07-01):**
- `run_all(only=30)` — catálogos territoriales (sin cambios desde v01).
- `run_all(only=31)` — lee y normaliza ArchivoB/C/D/Matr 2023-2026 +
  egresados EM. Verificado: 4 años sin NA inesperados en llaves/puntajes,
  escala PAES 100-1000 confirmada, sentinela 0 excluido del pivot,
  atributos `*_solo2023` preservados y correctamente NA en 2024+.
- `run_all(only=32)` — agrega los dos focos (Cobertura, Rendimiento) al
  árbol territorial. Verificado: monotonicidad del embudo (100% nacional/
  región/SLEP, 99,7% comuna con explicación de negocio para las
  excepciones), supresión de celdas chicas aplicada (83 celdas en
  cobertura, 5.873 en rendimiento), rezagados visibles en las 6 etapas,
  denominador de egresados (`marca_egreso==1`) confirmado contra Libro de
  Códigos oficial (cardinalidad exacta, no aproximada).
- `contexto_paes.md` — 504 líneas, corregido y ampliado contra 23 fuentes
  oficiales DEMRE, 0 afirmaciones sin cita.
- Validación 8.3.7 y compuerta de gobernanza: sin cambios desde v01
  (siguen en verde; no se tocó la arquitectura de dos raíces esta sesión).

**Qué no funciona / no está construido:**
- `33_generar_html.R` sigue generando el motor con datos de andamiaje;
  no se regeneró contra los parquets reales de `32` (deliberado: primero
  se definirá la interfaz).
- La interfaz UI/UX está en diseño (encargo enviado a Claude Design),
  sin alternativas evaluadas todavía.

**Delta respecto a v01:**
- Pendiente 2 (v01): resuelto (escala PAES confirmada).
- `contexto_paes.md`: corregido y ampliado (7 correcciones, 12 adiciones,
  incluida la corrección mayor del modelo Rasch).
- `31_leer_normalizar.R`: de stub a funcional y verificado.
- `32_agregar_territorial.R`: de stub a funcional y verificado.
- Nuevo pendiente abierto: regenerar `33` con datos reales + definir e
  implementar la interfaz UI/UX (en curso).

## 4. Registro detallado de cambios

### Cambio 1 — Diagnóstico de escala PDT/PAES (Pendiente 2 de v01)
- **Archivos:** ninguno modificado; solo lectura + log
  (`andamios/logs/20260701_escala_anterior_archivoc_2023.md`).
- **Categoría:** dominio / diagnóstico.
- **Qué:** inspección empírica (rango de valores) + documental (Libro de
  Códigos ArchivoC 2023) de las columnas `*_REG_ANTERIOR`.
- **Por qué:** bloqueante heredado de v01 para diseñar `31`; B.1 exige no
  construir sobre un supuesto no verificado.
- **Cómo se verificó:** rango empírico min=100/max=1000 en 30k-60k valores
  por prueba (4 columnas), contrastado contra el Libro de Códigos (que no
  contradice, aunque tampoco declara escala numérica explícita).
- **Resultado:** refuta la hipótesis del traspaso v01 (Adm2022=PDT). Las
  columnas `*_ANTERIOR` de 2023 ya vienen en escala PAES (100-1000), no
  PDT (150-850). Implicancia para `31`: `*_ANTERIOR` y `*_ACTUAL` son
  directamente comparables sin reescalado; `0` es sentinela de "no
  rindió", no un puntaje.
- **Commit:** `4609ccd`.

### Cambio 2 — Revisión completa de `contexto_paes.md` con fuentes oficiales
- **Archivos:** `contexto_paes.md`,
  `andamios/logs/20260701_hallazgos_actualizacion_contexto_paes.{md,html}`.
- **Categoría:** dominio / documentación.
- **Qué:** contraste de 23 documentos oficiales del DEMRE (19 PDF + 4 HTML,
  depositados por el titular en `insumos_nuevo_contexto_paes/`, fuera del
  repo) más búsqueda web dirigida contra el `contexto_paes.md` existente
  (construido en sesión 1 desde una guía secundaria). Alcance: revisión
  completa (corrige lo ya transcrito, no solo agrega).
- **Por qué:** el titular calificó el material nuevo como "100% oficial,
  canónico, es ley"; instrucción explícita de revisión completa, no solo
  adición.
- **Cómo se verificó:** cada hallazgo cita archivo+página o URL exacta (0
  afirmaciones sin cita); 4 lectores paralelos mapearon el material contra
  el contexto vigente, clasificando cada hallazgo como confirmación,
  corrección o adición.
- **Correcciones mayores:**
  1. **Modelo psicométrico: Rasch (1 parámetro), no IRT 3PL.** El contexto
     original traía `P = c+(1-c)/(1+e^(-a(θ-b)))` (3 parámetros); el
     Informe Técnico PAES 2025 oficial (cap. 02, cap. 04, corroborado por
     el informe PDT-invierno) establece `p = e^(θ-δ)/(1+e^(θ-δ))`, solo
     dificultad, sin discriminación ni azar. Resuelto por jerarquía
     documental clara (Informe Técnico DEMRE > guía secundaria); no
     disparó la regla de detención del encargo.
  2. "5 preguntas excluidas": son margen de ajuste de calidad, no pilotaje.
  3. Ejes de M1: "Álgebra y Funciones"/"Probabilidad y Estadística"
     (nomenclatura oficial), no "Álgebra"/"Datos".
  4. Vía Pedagogía: rige la Ley 21.490 (percentil 60/20%/40%+percentil 50),
     no "percentil 50 = piso 567,5" como vía autónoma; 567,5 = percentil
     37, 603 = percentil 50 (Adm. 2026).
  5. 45 universidades adscritas (no 47).
  6. Ausencia de puntaje se codifica `0`, no NULL.
  7. La escala 100-1000 se inauguró con la PDT de Invierno (jul-2022), no
     con la PAES regular.
- **Adiciones mayores:** niveles de desempeño oficiales con cortes exactos
  (CL, M1); escalas CCEA (Autoeficacia, Autorregulación); marco legal Ley
  21.490; mecánica de equating por anclaje; "Nuevo Ranking" (Admisión
  2028); agrupación de establecimientos con <30 egresados en el Ranking;
  rótulos oficiales del portal (Archivo D + Base de Matrícula).
- **Pendientes marcados (no verificables con este material):** tabla NEM
  exacta, fórmula lineal del Ranking, piso 458 y su vigencia 2028, escala
  PSU 150-850/σ=110, niveles de desempeño de M2/Ciencias/Historia.
- **Commit:** `2033d01`.

### Cambio 3 — Re-chequeo del ejemplo del Puntaje Ponderado (848,75)
- **Archivos:** `contexto_paes.md` (front matter + nota de re-chequeo),
  logs de hallazgos.
- **Categoría:** dominio / verificación.
- **Qué:** el Cambio 2 no había re-chequeado explícitamente el ejemplo
  numérico verificado en sesión 1 (848,75). Se recalculó la aritmética
  (R), se buscó fórmula/ejemplo en el material local, y se complementó con
  búsqueda web dirigida a DEMRE.
- **Por qué:** decisión explícita del titular de verificar antes de cerrar
  (no dejarlo para la sesión de diseño de `31`, como se había ofrecido
  como alternativa).
- **Cómo se verificó:** aritmética exacta confirmada
  (825×0,15+870×0,20+700×0,10+900×0,35+820×0,10+840×0,10=848,75,
  ponderaciones suman 100%); fuente web (DEMRE — Conceptos claves de
  postulación; Mineduc — Consideraciones para los cálculos de puntajes
  ponderados) confirma la estructura de la fórmula sin contradecir el
  ejemplo.
- **Resultado:** confirmación, sin corrección. Se agregó precisión menor
  (prueba especial como factor adicional en algunas carreras).
- **Commit:** `f554424`.

### Cambio 4 — Diseño y aprobación del schema de `31_leer_normalizar.R`
- **Archivos:**
  `decisiones/20260701_decision_schema_31_leer_normalizar.md`.
- **Categoría:** arquitectura / diseño de pipeline.
- **Qué:** Fase A (diagnóstico y propuesta, sin implementar) sobre dos
  decisiones abiertas: (1) mapeo wide→long de ArchivoD 2023 (186
  columnas) contra el esquema long 2024+ (6 columnas); (2) esquema de
  salida REG/INV (long vs. wide).
- **Cómo se resolvió:**
  1. Mapeo confirmado contra el Libro de Códigos 2023: bloque de 186
     columnas = (NN=01-20) × (vía ∈ REGULAR/BEA/PACE) sobre
     `COD_CARRERA_PREF`/`ESTADO_PREF`/`PTJE_PREF`. Ambigüedad real
     detectada: `SITUACION_POSTULANTE[_BEA|_PACE]` y flags `BEA`/`PACE`
     (solo 2023) no tienen equivalente en 2024+.
  2. Recomendación LONG para ArchivoC (`id_aux, prueba, tipo_rendicion,
     vigencia, puntaje, convocatoria_archivo`), justificada porque el
     esquema de columnas varía por año y ambos focos del proyecto son
     literalmente group-by sobre esas dimensiones.
- **Decisiones del titular (gate):** (1) preservar
  `SITUACION_POSTULANTE[_BEA|_PACE]`/flags como atributos "solo-2023"
  (no descartar); (2) esquema LONG aprobado tal cual, sin fusión
  automática de postulantes repetidos entre `_reg`/`_inv` 2026 (sin regla
  de precedencia confirmada, no inventarla).
- **Dependencias:** base de la implementación del Cambio 5.

### Cambio 5 — Implementación y verificación de `31_leer_normalizar.R`
- **Archivos:** `30_procesamiento/31_leer_normalizar.R`, `CLAUDE.md`.
- **Categoría:** pipeline.
- **Qué:** de stub a funcional. Manifiesto de archivos DEMRE clasificado
  por nombre (tipo B/C/D/MATR + año + convocatoria, no por carpeta única,
  porque ArchivoD y ArchivoMatr conviven en `postulacion_seleccion/`).
  ArchivoC pivoteado LONG, sentinela 0 descartado. ArchivoD unificado
  wide/long con atributos `*_solo2023` preservados. `validar_columnas()`
  distingue críticas (aborta) de opcionales (solo informa) por año.
- **Bug encontrado y corregido:** ArchivoD 2023 mezcla separador decimal
  coma/punto dentro del bloque PACE (~1.967 celdas usan `.` en vez de
  `,`). La lectura inicial en locale-coma las convertía a `NA` antes del
  pivot. Corregido: lectura siempre como texto + `parsear_numero_flex()`
  tolerante a ambas notaciones. Verificado: 0 NA en `ptje_pref` para PACE
  2023 tras el fix.
- **Cómo se verificó:** los 4 años se leen sin abortar (directo y vía
  `run_all(only=31)`); rango de `puntaje` 100-1000 exacto; atributos
  `*_solo2023` poblados 100% en 2023 y 100% NA en 2024+; NA restantes
  trazan a causas de negocio conocidas (rezagados, preferencias
  rechazadas), no a fallas de parsing.
- **Commits:** `4fed022` (implementación), `119e5b1` (limpieza posterior,
  ver Cambio 6).

### Cambio 6 — Limpieza de columnas `modulo_*` redundantes
- **Archivos:** `30_procesamiento/31_leer_normalizar.R`.
- **Categoría:** deuda técnica / limpieza puntual.
- **Qué:** hallazgo colateral del diagnóstico de `32` (Cambio 7): las
  columnas crudas `modulo_reg_actual`, `modulo_inv_actual`,
  `modulo_reg_anterior`, `modulo_inv_anterior` quedaban replicadas sin
  pivotear en `paes_rendicion_resultados.parquet`, redundantes con
  `modulo_ciencias` ya derivada.
- **Cómo se verificó:** cardinalidad sin cambios (4.845.570 filas);
  columnas bajaron de 26 a 22; `modulo_ciencias` intacta (poblada
  exclusivamente en `prueba=="cien"`, mismos conteos BIO/FIS/QUI/TEC).
- **Commit:** `119e5b1`.

### Cambio 7 — Diagnóstico del contrato real de `31` (previo a diseñar `32`)
- **Archivos:** ninguno modificado; solo lectura + diagnóstico.
- **Categoría:** arquitectura / diagnóstico.
- **Qué:** `32` (stub de sesión 1) estaba cableado contra un esquema
  (`paes_egresados.parquet`, etc.) anterior al que `31` terminó
  produciendo. Se leyó `31` real + se inspeccionaron los 5 parquets en
  disco (nombres, columnas, tipos, cardinalidad).
- **Hallazgo clave:** `ArchivoD` y `ArchivoMatr` no traen columna `rbd`
  propia; el único puente a territorio es `id_aux` (join contra
  `paes_inscripcion`). Columna `rbd` (presente en inscripción/rendición/
  egresados) es semánticamente RBD de egreso, con NA legítimos
  (rezagados, extranjeros).
- **Dependencias:** insumo directo del Cambio 8.

### Cambio 8 — Implementación y verificación de `32_agregar_territorial.R`
- **Archivos:** `30_procesamiento/32_agregar_territorial.R`, `CLAUDE.md`,
  `decisiones/20260701_decision_territorializacion_d_matr.md`.
- **Categoría:** pipeline.
- **Qué:** de stub a funcional. FOCO COBERTURA: embudo egresados→
  inscripción→rendición→resultados_validos→postulación→selección, con
  categoría explícita de rezagados en las 6 etapas. FOCO RENDIMIENTO:
  puntajes por prueba/tipo_rendicion/vigencia, NEM/Ranking deduplicados
  por persona antes de promediar (sentinela 0 excluido), supresión de
  celdas chicas aplicada.
- **Decisión de diseño (delegada, aplicada y documentada):** ArchivoD SÍ
  se territorializa vía join por `(id_aux, anio_proceso)` contra
  `paes_inscripcion` (verificado seguro: 0 duplicados de llave en
  inscripción, 100% de las 751.175 combinaciones de ArchivoD encuentran
  match). ArchivoMatr queda fuera del árbol territorial en esta v1 (no es
  etapa de `ETAPAS_EMBUDO`, no fue pedida).
- **Hallazgo documentado sin fabricar certeza:** filtro `marca_egreso==1`
  para el denominador de egresados se aplicó inicialmente por inferencia
  (cardinalidades plausibles), sin glosa que lo confirmara. Ver Cambio 9
  (resuelto en la misma sesión, antes del cierre).
- **Cómo se verificó:**
  - `run_all(only=32)` corre sin abortar, dos veces (reproducible).
  - `paes_cobertura_territorial.parquet` (8.778 filas) y
    `paes_rendimiento_territorial.parquet` (28.466 filas) existen.
  - Supresión aplicada: 83 celdas en cobertura, 5.873 en rendimiento;
    ejemplo verificado (comuna 11302, etapa egresados 2023: n=NA,
    suprimida=TRUE).
  - Rezagados visibles en las 6 etapas (23 filas, nunca ausentes).
  - Monotonicidad inscripción→selección: 100% nacional (4/4), región
    (64/64), SLEP (144/144); 99,7% comuna (1266/1270) — 4 excepciones
    explicadas por mecanismo de "puntaje vigente" (postulantes que usan
    `vigencia=="anterior"` sin re-rendir ese año), documentado en
    `contexto_paes.md`. Egresados vs. inscripción no monotónico por
    diseño (poblaciones distintas: cohorte del año vs. incluye rezagados
    de años previos) — esperado, no defecto.
- **Commit:** `9b74caf`.

### Cambio 9 — Confirmación documental de `marca_egreso==1`
- **Archivos:** `30_procesamiento/32_agregar_territorial.R` (solo
  comentarios).
- **Categoría:** dominio / verificación.
- **Qué:** el filtro `marca_egreso==1` (Cambio 8) se había aplicado por
  inferencia. Se localizó el Libro de Códigos real de egresados
  (`demre/referencia/<AAAA>/er_notas_y_egresados_ensenanza_media_publ_<AAAA>.pdf`,
  no en `egresados_em/` como se buscó primero) y se confirmó la
  definición exacta.
- **Cómo se verificó:** cita literal (página 3/8, tabla "Variables"):
  `MARCA_EGRESO | Numérico | Indicador si el alumno egresa en el año... |
  0: No egresa / 1: Egresa`. Cardinalidad de la tabla oficial (página
  1/8) coincide EXACTA (no aproximada) con la que ya producía el filtro:
  254.750/257.261/281.356 (2023/2024/2025).
- **Resultado:** confirmación, sin cambio de lógica ni de datos (no fue
  necesario regenerar el parquet ni re-verificar monotonicidad).
- **Commit:** `e478392`.

### Cambio 10 — Encargo de alternativas UI/UX a Claude Design
- **Archivos:** ninguno en el repo (encargo entregado fuera del pipeline
  de código, en curso, sin resultado todavía).
- **Categoría:** diseño de interfaz.
- **Qué:** encargo redactado con contexto del proyecto (dos focos pares,
  embudo de 6 etapas, supresión de celdas), patrón de familia extraído de
  dos motores hermanos reales (`motor_categoria.html`, `motor_idps.html`,
  ambos igual de válidos como referencia), pidiendo 2 alternativas de
  interfaz (no implementación final) que resuelvan cómo conviven los dos
  focos con las dos vistas ya establecidas (Por territorio / Comparar
  territorios).
- **Por qué:** `33_generar_html.R` sigue generando el motor con datos de
  andamiaje; antes de regenerarlo con datos reales de `32`, se define la
  interfaz contra una referencia visual real (A19: reverse-engineering
  contra artefacto aprobado, no exploración sin referencia).
- **Estado:** enviado, sin resultado. El titular vuelve con las
  propuestas en una próxima sesión.

## 5. Backlog acumulativo

**Objetivo del proyecto:** (sin cambios respecto a v01) slep_paes es el
cuarto panorama nacional del Área de Monitoreo y Seguimiento de Procesos
y Resultados Educativos del SLEP Costa Central, construido con datos
100% públicos del DEMRE/MINEDUC sobre la PAES, publicado como sitio HTML
autocontenido en GitHub Pages, navegable por territorio, leído desde dos
focos pares (cobertura y rendimiento), hermano arquitectónico de
slep_categoria_desempeno, slep_idps y slep_simce_adecuado.

**Nota metodológica:** (sin cambios respecto a v01) cuenta como "cambio"
una solicitud distinguible del titular. No cuentan los errores del
asistente corregidos de inmediato dentro de la misma intervención; sí
cuentan los bugfixes que el titular reportó o que requirieron su
decisión. Clasificación por intención primaria. Fuente del conteo: esta
conversación completa (sesión 2).

**Clasificación temática (acumulada, sesiones 1-2):**

| Categoría | N° | % | Descripción |
|---|---|---|---|
| Scaffold y arquitectura | 3 | 12,5% | Estructura Rama A inicial, migración A→B, config de dos raíces |
| Gobernanza de datos | 4 | 16,7% | Compuerta PII, diagnóstico Fase 0, decisión Rama B, fuga PII hermano (delegada) |
| Reuso y patrón de familia | 1 | 4,2% | d3/pako/auxiliares/paleta |
| Dominio (contexto_paes) | 5 | 20,8% | Conversión inicial, transcripción manual sesión 1, diagnóstico escala PDT/PAES, revisión completa con fuentes oficiales, re-chequeo Ponderado |
| Organización de insumos | 3 | 12,5% | Estructura por etapa, renombrado snake_case, referencia/ |
| Pipeline (implementación) | 6 | 25,0% | Stubs 30-33 (sesión 1); diseño+implementación 31, limpieza modulo_*, diagnóstico contrato 31, implementación 32, confirmación marca_egreso (sesión 2) |
| Diseño de interfaz | 1 | 4,2% | Encargo UI/UX a Claude Design (en curso) |

Total: 23 cambios (14 sesión 1 + 9 sesión 2).

**Resumen estadístico por sesión:**

| Sesión | Traspasos generados | N° de cambios | Modelo | Foco |
|---|---|---|---|---|
| 1 | 1 (v01) | 14 | Claude (análisis) + Claude Code | Scaffold → migración A→B → insumos reales |
| 2 | 1 (v02, este) | 9 | Claude (análisis) + Claude Code + Claude Design | Resolver Pendiente 2 → contexto oficial → pipeline real (31/32) → inicio UI/UX |

**Detalle cronológico (numeración global continuando desde sesión 1):**

15. Diagnóstico de escala PDT/PAES en `*_ANTERIOR` de ArchivoC_Adm2023
    (Pendiente 2 de v01) — refutó la hipótesis original.
16. Revisión completa de `contexto_paes.md` contra 23 fuentes oficiales
    DEMRE + web — 7 correcciones (mayor: Rasch no 3PL), 12 adiciones.
17. Re-chequeo explícito del ejemplo del Puntaje Ponderado (848,75) —
    confirmado, decisión del titular de no diferirlo.
18. Diseño (Fase A) del schema de `31_leer_normalizar.R` — dos decisiones
    resueltas vía gate del titular (atributos solo-2023 preservados,
    esquema LONG aprobado).
19. Implementación y verificación de `31_leer_normalizar.R` contra los 4
    años reales — bug de parsing (separador decimal ArchivoD 2023)
    encontrado y corregido.
20. Limpieza de columnas `modulo_*` redundantes en `31` (hallazgo
    colateral, resuelto antes de diseñar `32`).
21. Diagnóstico del contrato real de `31` (parquets, columnas,
    cardinalidad) previo a diseñar `32`.
22. Implementación y verificación de `32_agregar_territorial.R` —
    decisión de territorialización de ArchivoD/Matr aplicada y
    documentada; monotonicidad y supresión verificadas.
23. Confirmación documental de `marca_egreso==1` contra Libro de Códigos
    oficial (resolviendo una inferencia sin glosa, antes del cierre).
24. Encargo de alternativas UI/UX a Claude Design, con patrón de familia
    extraído de dos motores hermanos — en curso, sin resultado.
25. Cierre de sesión con traspaso v02 (este documento).

**Delta del backlog:** +9 cambios respecto a v01. Taxonomía: se agregó la
categoría "Diseño de interfaz" (nueva desde sesión 2); "Pipeline" pasó de
stubs (7%) a implementación real (25%), el salto más grande — consistente
con el foco de la sesión. Ninguna categoría supera el 25% de forma
alarmante ni cae bajo el 2%; sin refinamiento de taxonomía necesario
todavía.

## 6. Bugs de la sesión

### Bug 3 — Separador decimal mixto en ArchivoD 2023 (bloque PACE)
- **Síntoma:** ~1.967 celdas de `PTJE_PREF` en el bloque PACE de
  ArchivoD_Adm2023 se leían como `NA` en vez de su valor numérico.
- **Causa raíz:** el archivo mezcla notación decimal coma y punto dentro
  del mismo bloque de columnas; la lectura inicial fijaba locale-coma
  (consistente con el resto del archivo), y las celdas en notación punto
  fallaban el parseo silenciosamente.
- **Solución exacta:** leer ArchivoD siempre en modo texto (sin locale
  numérico en la lectura) y parsear los valores numéricos con
  `parsear_numero_flex()`, tolerante a ambas notaciones.
- **Criterio de verificación:** 0 NA en `ptje_pref` para el bloque PACE
  2023 tras el fix (antes: ~1.967 NA espurios).
- **Patrón general aprendido:** los archivos DEMRE no garantizan
  consistencia interna de locale numérico incluso dentro de un mismo
  archivo/bloque; cualquier lectura de columnas numéricas de fuentes
  DEMRE debiera considerar parseo tolerante a ambas notaciones como
  default, no como excepción para casos ya conocidos.
- **Estado:** resuelto.

## 7. Aprendizajes y restricciones descubiertas

- **Regla:** cuando el titular describe un lote de material como "100%
  oficial, es ley", el protocolo de revisión debe ser "revisión completa"
  (corrige lo ya transcrito) por defecto, no solo "agregar lo nuevo" —
  aunque eso signifique revisar fórmulas ya dadas por verificadas en una
  sesión anterior. **Contexto:** si se asume que lo ya transcrito no
  necesita revisión, un error heredado de una fuente secundaria (el
  modelo 3PL de sesión 1) puede sobrevivir indefinidamente pese a existir
  material oficial que lo contradice. **Ejemplo de la sesión:** la
  corrección Rasch/3PL solo se detectó porque el alcance se definió como
  revisión completa, no solo adición.
- **Regla:** una decisión metodológica con impacto en un denominador o
  resultado publicado (ej. `marca_egreso==1`) no debe darse por cerrada
  solo con evidencia interna plausible (cardinalidades que "parecen
  correctas"); requiere confirmación documental explícita antes de
  cerrar la sesión, incluso si el encargo original no lo pedía
  explícitamente. **Contexto:** cardinalidades plausibles pueden coincidir
  por razones distintas a la hipótesis asumida; solo la cita exacta
  descarta esa posibilidad. **Ejemplo de la sesión:** Cambio 9,
  iniciado por señalamiento del asistente de análisis, no por pedido
  original del encargo de `32`.
- **Restricción:** al dar instrucciones de terminal a Claude Code en una
  sesión que ya viene posicionada en el repo, reafirmar la ruta completa
  desde la raíz en cada bloque de comandos nuevo, incluso si turnos
  anteriores ya establecieron el directorio de trabajo. **Contexto:** la
  sesión de terminal del titular puede no persistir el `cd` entre
  bloques pegados en momentos distintos. **Ejemplo de la sesión:**
  comandos `git` fallaron con "not a git repository" al ejecutarse desde
  `~` en vez de `~/Projects/slep_paes` (ver §15, error 1).
- **Regla:** cuando se dice "te lo dejo pegado abajo" refiriéndose al
  contenido de un archivo, el contenido debe estar efectivamente
  incrustado en el mismo mensaje, no en una ruta de un sandbox de
  análisis que Claude Code no puede alcanzar. **Contexto:** un archivo
  creado en `/home/claude/` (sandbox del asistente de análisis) no existe
  en la máquina del titular ni en el filesystem de Claude Code; solo el
  texto incrustado en el mensaje es una fuente accesible. **Ejemplo de la
  sesión:** primer intento del encargo de verificación de escala PDT/PAES
  (ver §15, error 2 — antipatrón ya documentado en
  `encargo_autonomo_claude_code_v1.md` §7, pero reincidido esta sesión).

## 8. Decisiones de diseño

### Decisión: revisión completa (no solo adición) de `contexto_paes.md`
- **Alternativas consideradas:** (1) solo agregar material nuevo sin
  tocar lo ya transcrito; (2) revisión completa, permitiendo corregir lo
  ya verificado en sesión 1.
- **Justificación (del titular):** el material nuevo es "documentos
  oficiales, 100% oficial y verificado, es ley" — jerarquía documental
  superior a la guía secundaria usada en sesión 1.
- **Implicancia:** permitió detectar y corregir el error del modelo
  psicométrico (3PL→Rasch), que habría persistido bajo la alternativa 1.
- **Documento de decisión:** no se generó archivo aparte en
  `decisiones/`; documentado en este traspaso y en el front matter de
  `contexto_paes.md`.

### Decisión: esquema LONG para ArchivoC (ver Cambio 4)
- Ya detallada en el registro de cambios (Cambio 4). Se replica aquí por
  ser de peso arquitectónico: queda como referencia canónica en
  `decisiones/20260701_decision_schema_31_leer_normalizar.md`.

### Decisión: territorialización de ArchivoD vía join por id_aux; Matr
fuera de alcance en v1
- Ya detallada en el registro de cambios (Cambio 8). Documento de
  decisión: `decisiones/20260701_decision_territorializacion_d_matr.md`.

### Decisión: encargo de UI/UX en dos fases (alternativas primero, luego
implementación)
- **Alternativas consideradas:** (1) implementar directamente el motor
  final con el patrón de un hermano; (2) pedir alternativas de diseño
  primero, con gate de elección del titular, antes de tocar
  `33_generar_html.R`.
- **Justificación:** slep_paes tiene dos focos pares (a diferencia de los
  hermanos, que reportan un indicador único); no hay una solución obvia
  de cómo conviven ambos focos con el patrón de dos vistas ya
  establecido (Por territorio/Comparar territorios). Alineado con A19
  (referencia aprobada antes de iterar visualmente).
- **Implicancia:** `33` sigue sin regenerarse con datos reales hasta que
  se elija una alternativa de interfaz.

## 9. Constantes y parámetros vigentes

| Constante | Valor | Archivo | Nota |
|---|---|---|---|
| `UMBRAL_SUPRESION_CELDA` | 8 | `10_configuracion.R` | Sin cambios desde v01 |
| `SLEP_PAES_DATA_ROOT` | `/Users/tomgc/Library/CloudStorage/OneDrive-SLEP/Proyectos/slep_paes` | `~/.Renviron` | Sin cambios desde v01 |
| `PALETA_PAES` | uva/terracota | `10_configuracion.R` | Sin cambios desde v01 |
| Modelo psicométrico PAES | Rasch (1 parámetro) | `contexto_paes.md` | **Corregido esta sesión** — antes decía IRT 3PL (error heredado, ver Cambio 2) |
| Escala `*_ANTERIOR` ArchivoC 2023 | PAES (100-1000) | `contexto_paes.md`, `31_leer_normalizar.R` | **Confirmado esta sesión** — refutó hipótesis PDT del traspaso v01 |
| `marca_egreso` (filtro de egresados) | `1` = egresa | `32_agregar_territorial.R` | **Confirmado con cita exacta esta sesión** (antes: inferencia sin glosa) |

## 10. Arquitectura de archivos

Ver `50_documentacion/estructura/estructura_actual.md` (escaneo del
cierre: 2026-07-01 17:32:34; 13 carpetas, 51 archivos en el code root).
Cambios estructurales respecto a v01: `31_leer_normalizar.R` creció de
stub a 18.5K; `32_agregar_territorial.R` creció de stub a 16.2K;
`contexto_paes.md` creció de ~51K a 66.3K; nuevos archivos en
`decisiones/` (2) y `andamios/logs/` (3, incluido el HTML trazable de
hallazgos). Sin cambios en la arquitectura de dos raíces (Rama B, sin
tocar esta sesión). Verificado contra POLITICA §1 y §6.2: sin
desviaciones nuevas detectadas.

## 11. Pendientes y ruta sugerida

### Pendiente 1 — Evaluar alternativas de UI/UX de Claude Design
- **Descripción:** encargo enviado (Cambio 10), sin resultado todavía. El
  titular vuelve con las propuestas en una sesión futura.
- **Contexto:** dos alternativas esperadas, resolviendo cómo conviven los
  dos focos (Cobertura/Rendimiento) con las dos vistas del patrón de
  familia (Por territorio/Comparar territorios).
- **Tipo:** funcionalidad (bloqueante para regenerar `33` con datos
  reales).
- **Impacto:** determina el diseño de `33_generar_html.R` y
  `33_motor_template.html`.
- **Dependencias:** ninguna técnica; depende de que el titular traiga las
  propuestas.
- **Complejidad:** Media (evaluación + posible iteración con Claude
  Design antes de implementar).
- **Principios relevantes:** A19 (referencia aprobada antes de iterar).
- **Sugerencia de enfoque:** al abrir la próxima sesión con las
  propuestas, evaluarlas contra los criterios del encargo (legibilidad
  del embudo de 6 etapas, legibilidad de rendimiento multi-prueba,
  comunicación de supresión de celdas, reconocimiento de familia SLEP)
  antes de aprobar una.
- **Criterio de éxito sugerido:** alternativa elegida (o híbrido) con
  aprobación explícita del titular, lista para convertirse en encargo de
  implementación a Claude Code.

### Pendiente 2 — Regenerar `33_generar_html.R` con datos reales
- **Descripción:** una vez elegida la interfaz, `33` debe leer
  `paes_cobertura_territorial.parquet` y
  `paes_rendimiento_territorial.parquet` (ya existen y están verificados)
  en vez de datos de andamiaje.
- **Tipo:** funcionalidad (bloqueante final para primer HTML real).
- **Dependencias:** Pendiente 1 (elección de interfaz).
- **Complejidad:** Alta (motor React completo, JSON columnar gzip+base64,
  navegación territorial con datos reales de ~10.945 establecimientos).
- **Sugerencia de enfoque:** encargo autónomo (patrón
  `encargo_autonomo_claude_code_v1.md`) una vez cerrado el Pendiente 1.

### Pendiente 3 (heredado de v01, sin avance esta sesión) — Egresados 2026
ausente
- Sin cambios respecto a v01. `egresados_em/2026/` sigue solo con
  `.DS_Store`.

### Pendiente 4 (heredado de v01, sin avance) — Normalización REG/INV en
nombres de archivo 2026
- Sin cambios respecto a v01. Cosmético, no bloqueante.

### Pendiente 5 (heredado de v01, sin avance) — Literatura adicional para
`contexto_paes.md`
- Parcialmente atendido esta sesión (Cambio 2 fue una revisión mayor),
  pero el titular podría tener material adicional más allá del ya usado.
  Mantener como pendiente abierto hasta confirmación explícita de que no
  queda material pendiente.

### Pendiente 6 (heredado de v01, sin avance) — CCEA fuera de alcance
activo
- Sin cambios. Nota: esta sesión SÍ agregó las escalas CCEA a
  `contexto_paes.md` como documentación de dominio (Cambio 2, adiciones
  A3/A4), pero el pipeline sigue sin consumir ArchivoK/L. Sigue diferido.

### Pendiente 7 (externo, ya delegado, heredado de v01) — Fuga de PII en
`slep_categoria_desempeno`
- Sin cambios respecto a v01. Sigue pendiente de ejecución en la sesión
  propia de ese proyecto.

### Nuevos pendientes de esta sesión (menores, no bloqueantes)
- **Tabla NEM exacta, fórmula lineal del Ranking, piso 458 (vigencia
  2028), escala PSU 150-850/σ=110, niveles de desempeño M2/Ciencias/
  Historia:** marcados como pendientes de cotejo oficial en el Cambio 2
  (no verificables con el material de esta sesión). Ninguno bloquea el
  pipeline actual.

### Evaluación de deuda técnica
- **Zona frágil (sin cambios respecto a v01):** el schema de
  ArchivoC/ArchivoD cambia año a año; `31` ya implementa validación de
  columnas por año (Cambio 4/5), mitigando el riesgo original.
- **Zona frágil nueva:** `32` decide territorializar ArchivoD vía join
  por `id_aux`; si en años futuros `id_aux` deja de ser una llave estable
  entre ArchivoB/C/D (cambio de metodología DEMRE no anunciado), el join
  fallaría silenciosamente en vez de abortar. No se implementó una
  guarda explícita de "0 duplicados de llave" como `stop()` en el
  pipeline productivo (solo se verificó una vez, ad hoc, en el
  diagnóstico). Sugerencia: agregar esa guarda a `32` en una sesión de
  endurecimiento, no bloqueante ahora.
- **Oportunidad de mejora:** ninguna urgente adicional a las ya
  señaladas.

### Auditoría de cierre (POLITICA §5.6, preguntas "Cierre")

| # | Pregunta | Respuesta |
|---|---|---|
| 5 | ¿Cada transformación crítica tiene check de validación? | Sí — `31` (`validar_columnas()`) y `32` (monotonicidad, supresión, denominador citado) ya lo tienen |
| 6 | ¿Los outputs son reproducibles e idempotentes? | Sí — `run_all(only=31)` y `run_all(only=32)` verificados reproducibles dos veces |
| 7 | ¿Decisiones metodológicas como constantes nombradas? | Sí — sin cambios de valor esta sesión, más el nuevo hallazgo Rasch documentado como texto (no es una constante numérica, es metodología) |
| 8 | ¿Nombres de archivos y carpetas sin tildes, ñ ni espacios? | Sí — sin desviaciones nuevas detectadas en el escáner de cierre |

Ítem pendiente derivado de esta auditoría: la guarda de "0 duplicados de
llave" en `32` (ver Evaluación de deuda técnica) se agrega como pendiente
menor, no bloqueante.

### Ruta sugerida para la próxima sesión

1. **Prioridad 1 — Evaluar alternativas UI/UX** (Pendiente 1): el titular
   trae las propuestas de Claude Design; se evalúan y se elige una (o
   híbrido).
2. **Prioridad 2 — Regenerar `33` con datos reales** (Pendiente 2):
   depende de la Prioridad 1.
3. **Diferir:** pendientes heredados 3-7 (egresados 2026, naming REG/INV,
   literatura adicional, CCEA, fuga PII hermano) — ninguno bloquea la
   ruta de UI/UX → `33`.

**Recomendación:** empezar por evaluar las alternativas de UI/UX antes
que cualquier otra cosa — es el único bloqueante real para completar el
pipeline de punta a punta (dato real → interfaz real).

## 12. Instrucciones específicas para la próxima sesión

- ⚠️ NO regenerar `33_generar_html.R` sin antes cerrar la elección de
  interfaz (Pendiente 1).
- ✅ ANTES de tocar `20_insumos/`, verificar que `SLEP_PAES_DATA_ROOT`
  resuelva (sin cambios desde v01).
- 🔒 Rama B es invariante (sin cambios desde v01).
- 🔒 Columnas de ArchivoB/C/D siempre por nombre, nunca por posición
  (sin cambios desde v01; ya implementado en `31`).
- 🔒 Modelo psicométrico es Rasch, no IRT 3PL — si algún cálculo o texto
  del motor asume 3PL (discriminación, azar), es un error heredado que
  debe corregirse contra este traspaso, no contra la memoria de sesión 1.
- ⚠️ NO dar por buena una decisión metodológica con impacto en
  resultados publicados solo por evidencia interna plausible; confirmar
  documentalmente antes de cerrar sesión (aprendizaje §7).
- ⚠️ En comandos de terminal a Claude Code, reafirmar la ruta completa
  desde la raíz del repo en cada bloque nuevo, incluso si la sesión ya
  viene posicionada (aprendizaje §7, error 1 de §15).

## 13. Fragmentos de código de referencia

### Parseo tolerante a separador decimal mixto (Bug 3)

```r
# parsear_numero_flex(): tolera notacion coma y punto en la misma columna.
# Usado en ArchivoD 2023 (bloque PACE mezcla ambas notaciones).
parsear_numero_flex <- function(x) {
  x <- trimws(as.character(x))
  con_coma <- grepl(",", x, fixed = TRUE)
  x[con_coma] <- gsub(".", "", x[con_coma], fixed = TRUE)
  x[con_coma] <- gsub(",", ".", x[con_coma], fixed = TRUE)
  as.numeric(x)
}
```

### Patrón de manifiesto de archivos por nombre (no por carpeta)

```r
# ArchivoD y ArchivoMatr conviven en postulacion_seleccion/: clasificar
# SIEMPRE por patron de nombre, nunca por ubicacion de carpeta unica.
clasificar_archivo <- function(nombre) {
  dplyr::case_when(
    grepl("^archivob_", nombre) ~ "B",
    grepl("^archivoc_", nombre) ~ "C",
    grepl("^archivod_", nombre) ~ "D",
    grepl("^archivomatr_", nombre) ~ "MATR",
    TRUE ~ NA_character_
  )
}
```

## 14. Reapertura

**Nombre del chat:** `slep_paes, sesión 3 (Claude Sonnet 5)`

**Mensaje de apertura pre-armado:**
> Tipo CONTINUATION. El protocolo (POLITICA_PROYECTO.md v5.2 +
> SETTINGS_Y_PROMPTS_OPERACIONALES.md v7) vive en la knowledge base de
> este Project; léelo desde ahí. Adjunto el traspaso `traspaso_cierre_v02.md`
> y el escáner `estructura_actual.md`. Traigo las alternativas de UI/UX
> de Claude Design.

**Documentos para la próxima sesión:**

1. *Protocolo en knowledge base* (NO se adjuntan, solo verificar que
   estén al día): `POLITICA_PROYECTO.md`, `SETTINGS_Y_PROMPTS_OPERACIONALES.md`.
2. *Opcionales según foco:* `CLAUDE.md` si la sesión correrá en Claude
   Code (probable, dado que el foco será evaluar UI/UX y luego
   regenerar `33`).
3. *Específicos de la sesión (SÍ se adjuntan):*
   - `traspaso_cierre_v02.md` (este documento)
   - `estructura_actual.md` (escaneo del cierre, 2026-07-01 17:32:34)
   - Las alternativas de interfaz que entregue Claude Design (HTML o
     capturas)
   - `motor_categoria.html` y `motor_idps.html` si se necesita
     recontrastar contra el patrón de familia durante la evaluación

**Nota final:** si `contexto_paes.md` recibe más actualizaciones del
titular (Pendiente 5 heredado), adjuntar la versión más reciente al
abrir.

## 15. Errores del asistente (registro obligatorio, POLITICA 0.5)

| Campo | Fila 1 | Fila 2 |
|---|---|---|
| `momento` | Comandos git tras el re-chequeo del Ponderado (push + commit de snapshots de escáner) | Primer intento del encargo de verificación de escala PDT/PAES, mensaje "te lo dejo pegado abajo completo" |
| `disparador` | Usuario lo señaló (comandos fallaron con "not a git repository") | Usuario lo señaló (Claude Code buscó el archivo en su filesystem y no lo encontró) |
| `que_paso` | Se dieron comandos `git`/`cd` sin reafirmar la ruta completa desde la raíz del repo; fallaron al ejecutarse desde `~` | Se dijo "te lo dejo pegado abajo completo" pero el contenido no se incrustó en el mensaje; se refirió a una ruta de sandbox (`/home/claude/...`) que no existe en la máquina del titular ni en el filesystem de Claude Code |
| `regla_violada` | userPreferences: "en comandos de terminal, siempre usar la ruta completa desde la raíz del proyecto; nunca asumir el directorio de trabajo actual" | `encargo_autonomo_claude_code_v1.md` §7 ("el archivo de referencia que no llega": lo que Claude Code necesita debe estar en su filesystem o incrustado en el texto) |
| `causa_raiz` | La sesión venía operando sobre contexto ya posicionado (turnos previos en la misma sesión de terminal del titular), y no se reafirmó la ruta en ese bloque puntual | Se generó el archivo en el sandbox de análisis (herramienta de archivos de Claude, no de Claude Code) y se asumió erróneamente que estaría accesible para Claude Code sin incrustar el contenido explícitamente en el mensaje |
| `salvaguarda_presente` | userPreferences | `encargo_autonomo_claude_code_v1.md` §7 (antipatrón ya documentado explícitamente en el instrumento canónico del proyecto) |
| `patron` | nuevo | reincidencia de un antipatrón ya documentado (no es la primera vez que se comete este tipo de error en la cartera; el propio instrumento §7 lo registra como lección de una sesión anterior a este proyecto) |
