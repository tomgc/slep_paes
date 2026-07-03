# Traspaso de cierre — slep_paes — v03

## 1. Identificación

- **Proyecto:** slep_paes
- **Versión:** v03
- **Fecha:** 2026-07-02
- **Sesión 3, foco:** resolver la elección de interfaz (UI/UX) pendiente desde v02 y construir el motor `33` con datos reales; publicación a GitHub Pages.
- **Entorno:** Claude (análisis) + Claude Code (ejecución autónoma, `~/Projects/slep_paes`, R-only, macOS).
- **Archivos principales modificados:** `30_procesamiento/33_generar_html.R`, `30_procesamiento/33_motor_template.html`, `docs/index.html`, `CLAUDE.md`, `50_documentacion/andamios/logs/20260702_motor_33_datos_reales_log.md`.

## 2. Resumen ejecutivo

La sesión partió con el handoff de Claude Design (`design_handoff_ui_ux/`) ya en `50_documentacion/andamios/`, listo para convertirse en encargo a Claude Code. El primer encargo, redactado directamente desde el prototipo hi-fi, se detuvo correctamente en Fase 0 (regla de detención (a)): el prototipo asumía un contrato de datos que `32_agregar_territorial.R` no produce (7 etapas con matrícula, KPIs de prioridad de carrera, nivel establecimiento, strip plots por alumno con tooltip de microdato, mediana/sd, split rec/ant cruzado por territorio). Tras una discusión de gobernanza (el titular cuestionó si el id_aux anonimizado bastaba para justificar microdato; se sostuvo que no: reidentificabilidad por combinación de atributos, Política §6.4), el titular resolvió 4 decisiones y confirmó **Camino A** (adaptar el diseño al agregado real, no extender el pipeline). El encargo revisado se ejecutó de punta a cabo sin nuevas detenciones: motor construido, 6 combinaciones Foco×Vista×Período verificadas en navegador, panel adversarial con veredicto PASS en ambos ejes (cifras: 15/15 match; gobernanza: 0 identificadores, supresión n=NA más estricta que el mínimo exigido). Un bug real de sintaxis (paréntesis faltante) y uno de React (rules-of-hooks) se corrigieron durante la verificación. Un falso positivo de mojibake (reportado por el titular vía captura) resultó ser caché del preview en vivo, no un defecto del commit; se agregó una guarda de build igualmente, por disciplina defensiva. Push ejecutado tras visto bueno explícito del titular. Sitio publicado y verificado en GitHub Pages (`https://tomgc.github.io/slep_paes/`). Quedan pendientes: Camino B (KPIs de prioridad de carrera, requiere extender `32`), `egresados_em` 2026 ausente, y el registro formal de un error del asistente (encargo redactado desde el prototipo sin releer el contrato real de `32` primero).

## 3. Estado al cierre

**Qué funciona (última ejecución exitosa: 2026-07-02, `run_all()` completo, ~50 s):**
- `31_leer_normalizar.R` y `32_agregar_territorial.R`: sin cambios desde v02, verificados.
- `33_generar_html.R` + `33_motor_template.html`: motor completo, Camino A. Generan `docs/index.html` (1010 KB, JSON embebido 136 KB gzip+base64).
- Las 6 combinaciones Foco×Vista×Período renderizan sin error de consola.
- Modal de selección de territorio (nacional→región→SLEP→comuna, single/multi hasta 10, búsqueda con acentos).
- Exportadores SVG y XLSX (XLSX válido, abre en `readxl`).
- GitHub Pages sirviendo la versión publicada, confirmado visualmente por el titular.

**Qué no funciona / queda pendiente:**
- Etapa "Matriculado" y KPIs de prioridad de carrera: ausentes (Camino B diferido, requiere extender `32` con agregación territorio×prioridad×año).
- `egresados_em` 2026: sigue sin existir como insumo (hereda de v01/v02).

**Delta respecto a v02:** v02 cerró con `33` intencionalmente sin regenerar, a la espera de la elección de interfaz. v03 cierra con el motor completo, verificado y publicado.

## 4. Registro detallado de cambios

**Cambio 1 — Primer encargo a Claude Code (redactado desde el prototipo) y detención legítima.**
- Archivo: ninguno modificado (detención en Fase 0, sin commits).
- Categoría: Diseño de interfaz / gobernanza de datos.
- Qué se hizo: se redactó un encargo orientado a meta (estructura de `encargo_autonomo_claude_code_v1.md`) asumiendo que `32` producía 7 etapas, KPIs de prioridad, nivel establecimiento y split rec/ant. Claude Code, en su Fase 0 (lectura del estado real antes de codificar), inspeccionó el esquema real de `paes_cobertura_territorial.parquet` y `paes_rendimiento_territorial.parquet` y encontró que ninguno de esos supuestos se sostenía.
- Por qué (C.11): el encargo se diseñó desde el artefacto de referencia (el prototipo hi-fi de Claude Design) sin releer primero el contrato de salida real de `32`. Es el error del asistente registrado en la sección 15.
- Cómo se verificó (B.4): Claude Code corrió inspección de schema (`arrow::read_parquet`) sobre ambos parquets y catálogos territoriales, comparó contra los supuestos del encargo, y produjo una tabla de 9 discrepancias antes de escribir ninguna línea de código o motor.
- Dependencias afectadas: bloqueó Fases 1-6 del encargo original hasta resolución.

**Cambio 2 — Discusión de gobernanza sobre reidentificabilidad (id_aux anonimizado).**
- Archivo: ninguno (decisión de gobernanza, no de código).
- Categoría: Gobernanza de datos.
- Qué se hizo: el titular cuestionó si el id_aux anonimizado ya resolvía el problema de microdato en los strip plots del prototipo ("no absolutamente no" a la afirmación de reidentificabilidad). Se sostuvo la posición: el id_aux resuelve identidad de persona, no reidentificación por combinación de atributos (establecimiento + comuna + puntaje exacto reduce el universo, especialmente en grupos con n<20); Política §6.4 (Condiciones de Uso Agencia de Calidad) prohíbe identificar establecimientos por nombre en cualquier output, exactamente lo que el tooltip del prototipo haría.
- Por qué: gate de gobernanza explícito antes de proceder con cualquier camino que publicara microdato.
- Cómo se verificó: no aplica cómputo; es una decisión de interpretación normativa, resuelta por referencia directa al texto de la política, no por deducción del asistente.
- Tensión: autonomía (B.3) vs. gobernanza (Política §6, que prevalece siempre sobre la autonomía, regla 0.3).

**Cambio 3 — Resolución de las 4 decisiones de Camino A (gate del titular).**
- Archivo: ninguno (decisión, luego trasladada al encargo revisado).
- Categoría: Diseño de interfaz.
- Qué se hizo: (1) "Comparar territorios" a nivel comuna por defecto (4 comunas de Costa Central); (2) Rendimiento·Actual sin microdato = media por prueba y territorio (barra/punto + n), sin strip-plot; (3) KPIs de prioridad de carrera diferidos a Camino B (extender `32`); (4) control "Cohorte" reinterpretado como toggle de mostrar/ocultar el bucket "generaciones anteriores".
- Por qué: cada decisión resuelve una discrepancia entre el prototipo y el contrato real de `32`, sin fabricar datos ni publicar microdato.
- Cómo se verificó: implementadas y confirmadas en el motor final (ver Cambio 4).

**Cambio 4 — Implementación completa del motor `33` (Camino A).**
- Archivos: `30_procesamiento/33_generar_html.R`, `30_procesamiento/33_motor_template.html`, `docs/index.html`.
- Categoría: Pipeline (implementación).
- Qué se hizo: JSON columnar gzip+base64 (árbol territorial nacional→región→SLEP→comuna + bucket rezagados); shell y controles (tabs de foco, segmented vista/período, toggle generaciones anteriores); 6 vistas (embudo de 6 etapas, serie histórica, barras de media por prueba, small multiples, heatmaps de comparación); modal de selección de territorio; exportadores SVG/XLSX sin librerías.
- Por qué: ejecución del encargo revisado (Camino A), fases 1-5.
- Cómo se verificó (B.4): `run_all(only=33)` sin abortar; render en navegador de las 6 combinaciones sin error de consola; panel adversarial (Agente A: recálculo independiente de 15 cifras, 15/15 match; Agente B: auditoría de gobernanza, veredicto PASS, 0 identificadores de establecimiento/persona, supresión con `n=NA` más estricta que el mínimo exigido).
- Commits: `d8bc790` (motor completo), `c9041ad` (log + CLAUDE.md).

**Cambio 5 — Bugs de implementación corregidos durante la verificación (autónomos, dentro del mismo encargo).**
- Ver sección 6 (Bugs de la sesión).

**Cambio 6 — Falso positivo de mojibake y guarda de build.**
- Archivo: `30_procesamiento/33_generar_html.R`, `docs/index.html`.
- Categoría: Pipeline (implementación) / verificación.
- Qué se hizo: el titular reportó mojibake visible ("Matem<c3><a1>tica") en captura de pantalla. Claude Code verificó a nivel de bytes que el commit `d8bc790` no contenía la secuencia mojibake (`c3 83`) en ningún punto del archivo; la causa fue caché del preview en vivo sobre un estado anterior al fix de `marcar_utf8`. Se agregó de todos modos una guarda de build que aborta si el HTML final contiene la secuencia mojibake, para blindar contra recurrencia.
- Por qué: disciplina defensiva ante un reporte del titular, incluso cuando la causa raíz resultó no ser el código committeado.
- Cómo se verificó: conteo de bytes `c3 83` en el archivo completo (0), decodificación del JSON embebido confirmando bytes UTF-8 correctos, render limpio en las 6 vistas + modal + notas, y confirmación final del titular ("carga bien") sobre el archivo descargado directamente.
- Commit: `ab20bcf`.

## 5. Backlog acumulativo

Ver `50_documentacion/activa/backlog_acumulativo.md` (archivo independiente desde el segundo cierre). Esta sección resume el delta de v03; el archivo se actualiza con el contenido íntegro copiado de v02 más lo siguiente.

**Nota metodológica:** sin cambios respecto a v01/v02.

**Clasificación temática — delta v03 (cambios nuevos, ver tabla acumulada en el archivo):**

| Categoría | Cambios de esta sesión |
|---|---|
| Diseño de interfaz | Detención Fase 0 (encargo v1), discusión de gobernanza id_aux, 4 decisiones de Camino A |
| Pipeline (implementación) | Motor `33` completo (Camino A), fix mojibake/guarda de build |
| Gobernanza de datos | Discusión reidentificabilidad, verificación panel adversarial (Agente B) |
| Publicación | Push a `origin/main`, verificación GitHub Pages |

**Resumen estadístico — fila sesión 3:**

| Sesión | Traspasos generados | N° de cambios | Modelo | Foco |
|---|---|---|---|---|
| 3 | 1 (v03, este) | 8 | Claude (análisis) + Claude Code | Resolver elección de interfaz → motor `33` real (Camino A) → publicación |

**Detalle cronológico (continuación desde 23):**

24. Primer encargo a Claude Code redactado desde el prototipo hi-fi — detención legítima en Fase 0 (regla a): 9 discrepancias entre el prototipo y el contrato real de `32`.
25. Discusión de gobernanza sobre reidentificabilidad del id_aux anonimizado — se sostuvo que no exime de la prohibición de microdato (Política §6.4).
26. Resolución de las 4 decisiones de Camino A (gate del titular): nivel comuna en comparación, media sin microdato en Rendimiento·Actual, KPIs de prioridad diferidos a Camino B, toggle de generaciones anteriores.
27. Implementación completa del motor `33` (Camino A): JSON columnar, shell/controles, 6 vistas, modal, exportadores. Verificado con panel adversarial (cifras + gobernanza, ambos PASS).
28. Bugs de implementación corregidos durante verificación: paréntesis faltante en Modal (SyntaxError), `useState` dentro de render condicional (React #310), mojibake UTF-8 por locale C en literales `.R`, claves de catálogo inconsistentes (`reg`/`slep` vs. `cod`).
29. Falso positivo de mojibake reportado por el titular (caché de preview) — verificado a nivel de bytes que el commit no lo contenía; guarda de build agregada por disciplina defensiva.
30. Push a `origin/main` tras visto bueno explícito del titular (3 commits: `d8bc790`, `c9041ad`, `ab20bcf`).
31. Verificación de publicación en GitHub Pages (`https://tomgc.github.io/slep_paes/`), confirmada visualmente por el titular.

**Delta del backlog:** 8 entradas nuevas (24-31). Sin refinamientos de taxonomía ni reclasificaciones.

## 6. Bugs de la sesión

**Bug 1 — Paréntesis faltante en el `return` del componente `Modal`.**
- Síntoma: `SyntaxError` al cargar el motor; `App`/`DATA` indefinidos globalmente (el bloque `<script>` completo fallaba sin hoisting).
- Causa raíz: el `<div>` exterior del modal (línea ~529 del template) nunca se cerraba; faltaba un paréntesis de cierre en la cadena de `React.createElement` anidados.
- Solución exacta: agregado el paréntesis de cierre correspondiente en `30_procesamiento/33_motor_template.html`.
- Criterio de verificación: `node --check` sobre el script principal extraído del HTML, limpio; render en navegador con `#root` poblado.
- Patrón general aprendido: verificar sintaxis con `node --check` antes de depender del render en navegador para detectar errores de balanceo en árboles `React.createElement` profundamente anidados escritos a mano.
- Principios: C.8 (validación de integridad tras transformaciones críticas).
- Estado: resuelto.

**Bug 2 — `React.useState` dentro de un componente renderizado condicionalmente (`Modal`).**
- Síntoma: `React error #310` al abrir el modal; la app se desmontaba (root vacío) en cada apertura.
- Causa raíz: violación de rules-of-hooks — el conteo de hooks cambia entre renders cuando un componente con `useState` se monta/desmonta condicionalmente.
- Solución exacta: estado de búsqueda (`modalQuery`) elevado a `App` (nivel superior, siempre montado); `Modal` pasó a ser un componente sin hooks propios.
- Criterio de verificación: `grep -n "useState"` confirmando un único uso (en `App`); apertura/cierre repetido del modal sin desmontaje del árbol (`root` permanece poblado).
- Patrón general aprendido: en componentes React escritos a mano sin linter, cualquier hook debe vivir en el componente de nivel más alto que siempre está montado; nunca en un componente que aparece/desaparece condicionalmente.
- Principios: C.8.
- Estado: resuelto.

**Bug 3 — Mojibake UTF-8 en literales `.R` bajo locale C (`enc2utf8` doble-codificaba).**
- Síntoma: nombres de región y prueba (`Tarapacá`, `Matemática`) se veían como `Tarapac<c3><a1>` en el preview en vivo.
- Causa raíz: bajo `Sys.getlocale("LC_CTYPE")=="C"`, los literales de string en el código R (no las cadenas provenientes de Arrow/parquet) quedan con `Encoding()=="unknown"`; aplicar `enc2utf8()` sobre esos literales los doble-codifica en vez de solo marcarlos.
- Solución exacta: función `marcar_utf8()` recursiva que relabela (no re-codifica) todos los literales antes de `jsonlite::toJSON`.
- Criterio de verificación: conteo de bytes `c3 83` (firma de mojibake) en el archivo final = 0; verificación de términos acentuados específicos con sus bytes UTF-8 correctos.
- Patrón general aprendido: bajo locale C, `enc2utf8()` no es la operación correcta para literales de código fuente ya escritos en UTF-8; se necesita `Encoding(x) <- "UTF-8"` (relabelado) en vez de conversión.
- Principios: C.7 (portabilidad total, UTF-8 explícito).
- Estado: resuelto.

**Bug 4 — Claves de catálogo inconsistentes (`reg`/`slep` vs. `cod`).**
- Síntoma: chip de territorio mostraba `slep:503` en vez de `Costa Central` (fallo silencioso de lookup).
- Causa raíz: las tibbles de R usaban las claves `slep`/`reg` mientras el cliente JS indexaba por `cod`.
- Solución exacta: estandarización de claves a `cod` en la estructura de datos exportada por el generador.
- Criterio de verificación: chip de territorio renderiza "Costa Central" correctamente; verificado también con SLEP 503 y comuna 5109 vía panel adversarial.
- Patrón general aprendido: cuando el generador R y el template JS comparten un contrato de nombres de clave, declarar y verificar ese contrato explícitamente en vez de asumir que los nombres de columna de R se trasladan igual al JSON consumido por JS.
- Principios: C.6 (rigor de nomenclatura y tipado).
- Estado: resuelto.

## 7. Aprendizajes y restricciones descubiertas

- **Regla:** un encargo a Claude Code que reutiliza un prototipo de referencia debe redactarse después de releer el contrato de salida real de la etapa de pipeline anterior, no solo desde el prototipo. Principio relacionado: B.1 (sin supuestos implícitos). Contexto: si se viola, la Fase 0 de Claude Code detecta la discrepancia (correcto), pero cuesta un ciclo completo de detención y re-encargo. Ejemplo de la sesión: el primer encargo asumió 7 etapas y microdato porque se redactó desde `slep_paes - motor.dc.html`, no desde el schema de `32`.
- **Regla:** anonimización de identidad (id_aux) no exime de la prohibición de microdato reidentificable por combinación de atributos. Principio relacionado: Política §6.4. Contexto: aplica a cualquier futura vista que muestre puntos individuales con más de un atributo territorial/categórico cruzado.
- **Regla:** bajo locale C, usar `Encoding(x) <- "UTF-8"` (relabelado) para literales de código fuente ya en UTF-8, nunca `enc2utf8()` (que asume que el string no está marcado y lo re-codifica, produciendo doble-encode sobre texto que ya era válido). Principio relacionado: C.7.
- **Regla:** ante un reporte de bug del titular basado en una captura de un preview en vivo, verificar primero el estado del archivo committeado a nivel de bytes antes de asumir que el defecto vive en el código; el preview en vivo puede mostrar estados intermedios cacheados que no reflejan el commit final.

## 8. Decisiones de diseño

**Decisión: Camino A (adaptar el diseño al agregado real) sobre Camino B (extender el pipeline) o Camino C (híbrido).**
- Alternativas consideradas: A (recrear el lenguaje visual del prototipo sobre los agregados que `32` ya produce); B (extender `31`/`32` para generar agregados a nivel establecimiento, mediana/sd, y join de dependencia antes de reproducir el prototipo con mayor fidelidad); C (A ahora, B como tarea aparte después).
- Justificación: A no requiere tocar una entrada que el encargo fijó como inmutable (`32` ya verificado y pusheado en v02), respeta todos los invariantes de gobernanza sin ambigüedad, y produce un motor embarcable en la misma sesión. B habría exigido reabrir el pipeline (cambio de alcance no aprobado) y aun así no habría resuelto los strip plots por alumno (imposibles sin publicar microdato, independientemente de qué agregue `32`).
- Tensión resuelta: fidelidad visual al prototipo vs. gobernanza de datos — gobernanza prevalece (Política §6, regla 0.3).
- Implicancia: el motor publicado usa 6 etapas (no 7), media (no mediana), y no tiene nivel establecimiento ni KPIs de prioridad de carrera. Documentado como decisión de arquitectura.
- Réplica en `50_documentacion/activa/decisiones/`: pendiente de crear como archivo `20260702_decision_camino_a_motor_33.md` (ver Pendientes, ítem 3).

**Decisión: control "Cohorte" reinterpretado como toggle de "generaciones anteriores" en vez de split rec/ant cruzado.**
- Alternativas consideradas: eliminar el control completamente; mantenerlo pero deshabilitado; reinterpretarlo sobre la dimensión real disponible (bucket territorial `rezagados`).
- Justificación: preserva la intención original del control (dar visibilidad/control sobre generaciones anteriores) sin fabricar una dimensión rec/ant por territorio que `32` no produce.
- Implicancia: el toggle nunca oculta permanentemente "generaciones anteriores" como categoría (sigue siendo un invariante 🔒 vigente desde v01/v02); solo controla si se incluye en el embudo/vistas específicas.

## 9. Constantes y parámetros vigentes

| Constante | Valor | Archivo | Nota |
|---|---|---|---|
| `UMBRAL_SUPRESION_CELDA` | 8 | `10_utils/10_configuracion.R` | Sin cambio. Confirmado en el motor: mínimo n no-suprimido = exactamente 8 en ambos parquets. |
| `anio_actual` (motor `33`) | 2025 | `30_procesamiento/33_generar_html.R` | Nuevo esta sesión. 2026 no trae `egresados_em`, por lo que el embudo usa el último año con denominador completo. |
| Nivel por defecto, Comparar territorios | comuna (4 comunas Costa Central) | `33_generar_html.R` / `33_motor_template.html` | Nuevo esta sesión (decisión de Camino A). |
| Métrica de rendimiento | media (`mean`) | `33_generar_html.R` | Nuevo esta sesión. `32` no produce mediana/sd. |
| Etapas del embudo | 6 (sin matrícula) | `33_generar_html.R` | Nuevo esta sesión, confirma contrato real de `32`. |

## 10. Arquitectura de archivos

Referencia: `50_documentacion/estructura/estructura_actual.md`, snapshot `2026-07-02 07:24:02` (16 carpetas, 61 archivos). Cambios respecto al snapshot de v02: `33_generar_html.R` creció de 6,91K a 15,3K; `33_motor_template.html` de 7,45K a 57,7K; `docs/index.html` de vacío/stub a 1009K; nuevo `50_documentacion/andamios/design_handoff_ui_ux/` (handoff de Claude Design, README + prototipo + fuentes); nuevo log `20260702_motor_33_datos_reales_log.md`; `.claude/launch.json` local (gitignored, infraestructura de preview). Sin desviaciones respecto a la política.

**Registro de ejecución detallado:** `50_documentacion/andamios/logs/20260702_motor_33_datos_reales_log.md` (log de la sesión de Claude Code; detalle paso a paso no reproducido aquí).

## 11. Pendientes y ruta sugerida

**Inventario:**

1. **Camino B — extender `32` para KPIs de prioridad de carrera.** Contexto: diferido explícitamente en esta sesión (Cambio 3). Tipo: funcionalidad. Impacto: agrega una card de KPIs al foco Cobertura·Actual. Dependencias: requiere microdato de preferencia de postulación (ArchivoD/Matr), agregación nueva territorio×prioridad×año en `32`. Complejidad: media-alta (cambio de alcance de pipeline). Principios relevantes: B.3 (un cambio conceptual por intervención — no mezclar con ajustes de `33`). Precauciones: verificar que el agregado de prioridad no reintroduzca microdato. Criterio de éxito sugerido: nueva columna/tabla en `32` con n≥8 por celda, KPI renderizado en `33` con supresión respetada.

2. **`egresados_em` 2026 ausente.** Contexto: heredado de v01/v02, sin cambios. Tipo: deuda de datos (bloqueante externo, no del titular). Impacto: el motor usa `anio_actual=2025` como mitigación; cuando el dato llegue, revisar si `anio_actual` debe avanzar a 2026. Complejidad: baja (una vez llegue el dato, es una constante a actualizar + regenerar). Criterio de éxito: `egresados_em` 2026 disponible en insumos, `anio_actual` recalculado, motor regenerado y verificado.

3. **Réplica de la decisión Camino A como archivo de decisión.** Contexto: la sección 8 documenta la decisión en el traspaso, pero la política (§10) exige réplica en `50_documentacion/activa/decisiones/` para decisiones de peso arquitectónico. Tipo: documentación. Impacto: ninguno en el pipeline; cierra deuda de gobernanza documental. Complejidad: baja. Criterio de éxito: archivo `20260702_decision_camino_a_motor_33.md` creado con alternativas y justificación (contenido ya redactado en sección 8, solo falta extraerlo).

**Evaluación de deuda técnica:** ninguna zona fresca detectada como frágil esta sesión. El motor `33` es nuevo pero fue verificado con panel adversarial en ambos ejes (cifras y gobernanza); no se identifica deuda oculta.

**Auditoría de cierre (política 5.6):**
- ¿Datos crudos aislados e inmutables? → Sí, sin cambios en `31`/`32` (Rama B intacta, código en Git, no aplica en `slep_paes` porque es Rama A con datos 100% públicos — confirmado por la nota del escáner).
- ¿Pipeline corre de cero sin intervención manual? → Sí, `run_all()` completo verificado end-to-end.
- ¿Outputs reproducibles e idempotentes? → Sí, confirmado por regeneración repetida durante la sesión sin cambios de contenido salvo los fixes deliberados.
- ¿Decisiones metodológicas como constantes nombradas? → Sí (`anio_actual`, nivel por defecto de comparación, métrica de rendimiento — todas documentadas en sección 9).
- ¿Nombres de archivos/carpetas sin tildes, ñ, espacios? → Una excepción: `slep_paes - motor.dc.html` (nombre heredado del export de Claude Design, con espacios y guion). Vive en `andamios/` (congelado, no se toca). No requiere acción.

**Ruta sugerida para la próxima sesión (criterios de 1.2.4):**
1. Prioridad 1 — Réplica de la decisión Camino A como archivo (bajo, rápido, cierra deuda documental).
2. Prioridad 2 — Evaluar si procede abrir Camino B (extender `32`) como sesión de pipeline dedicada, o si se difiere más.
3. Diferir: nueva literatura para `contexto_paes.md` (heredado de sesión 1, sin urgencia).

## 12. Instrucciones específicas para la próxima sesión

- 🔒 Motor `33` publicado usa Camino A: 6 etapas, media (no mediana), sin nivel establecimiento, sin KPIs de prioridad. No revertir a los supuestos del prototipo original sin repetir el gate de gobernanza.
- 🔒 Nunca identificar establecimientos por nombre en ningún output (Política §6.4) — vigente, reforzado esta sesión con verificación empírica (panel adversarial Agente B).
- ⚠️ ANTES de redactar cualquier encargo a Claude Code que use un prototipo/handoff externo como referencia, releer el contrato de salida real de la etapa de pipeline anterior (no solo el prototipo). Aprendizaje de esta sesión (Bug/error registrado en sección 15).
- ⚠️ NO fabricar dimensión rec/ant cruzada por territorio: `32` no la produce; "generaciones anteriores" es únicamente un bucket territorial agregado (`tipo_entidad=="rezagados"`).
- ✅ ANTES de dar por válido un reporte de bug visual del titular basado en una captura de preview en vivo, verificar el estado del commit a nivel de bytes primero.

## 13. Fragmentos de código de referencia

**Patrón correcto de marcado UTF-8 antes de serializar (evita doble-encode bajo locale C):**

```r
marcar_utf8 <- function(x) {
  if (is.character(x)) {
    Encoding(x) <- "UTF-8"
    return(x)
  }
  if (is.list(x)) return(lapply(x, marcar_utf8))
  x
}
# Uso: aplicar sobre la estructura completa ANTES de jsonlite::toJSON()
json_root <- marcar_utf8(json_root)
```

**Patrón correcto de hooks en componentes React condicionales (evita error #310):**

```javascript
// INCORRECTO: useState dentro de un componente que se monta/desmonta condicionalmente
function Modal({ open }) {
  const [query, setQuery] = React.useState(''); // rompe si Modal aparece/desaparece
  ...
}

// CORRECTO: el estado vive en el componente de nivel superior, siempre montado
function App() {
  const [modalQuery, setModalQuery] = React.useState('');
  return open ? Modal({ query: modalQuery, onChange: setModalQuery }) : null;
}
```

## 14. Reapertura

- **Nombre del chat:** `slep_paes, sesión 4 (Claude Sonnet 5)`
- **Mensaje de apertura pre-armado:**

  Tipo CONTINUATION. El protocolo (POLITICA_PROYECTO.md + SETTINGS_Y_PROMPTS_OPERACIONALES.md) vive en la knowledge base del Project y se lee desde ahí. Adjunto el traspaso `traspaso_cierre_v03.md` y el escáner `estructura_actual.md` de esta sesión.

- **Documentos para la próxima sesión:**

  1. *Protocolo en knowledge base (NO se adjuntan; verificar que estén al día):* `POLITICA_PROYECTO.md`, `SETTINGS_Y_PROMPTS_OPERACIONALES.md`.
  2. *Opcionales según el foco real:* `CLAUDE.md` si la sesión correrá en Claude Code; `encargo_autonomo_claude_code_v1.md` si se abre Camino B como encargo a Claude Code.
  3. *Específicos de la sesión (SÍ se adjuntan):* `traspaso_cierre_v03.md`; `estructura_actual.md` (a regenerar al abrir la próxima sesión); `20260702_motor_33_datos_reales_log.md` si la próxima sesión necesita el detalle de ejecución del motor.

- **Nota final:** si `POLITICA_PROYECTO.md` o `SETTINGS_Y_PROMPTS_OPERACIONALES.md` cambiaron de versión entre sesiones, adjuntar la versión más actualizada al abrir y avisarlo en el mensaje de apertura.

## 15. Errores del asistente

| Campo | Contenido |
|---|---|
| `momento` | Al redactar el primer encargo a Claude Code para construir el motor `33` a partir del handoff de Claude Design, antes de que Claude Code ejecutara su Fase 0. |
| `disparador` | Usuario lo señaló sin nombrarlo error explícitamente: pidió el encargo directamente tras compartir el HTML/README del prototipo; el asistente no verificó el contrato real de `32` antes de redactar. El error se hizo visible cuando Claude Code (no el usuario) detectó la discrepancia en su propia Fase 0 de lectura del estado real. |
| `que_paso` | El encargo asumió 7 etapas del embudo (con matrícula), KPIs de prioridad de carrera, nivel establecimiento en comparación, strip plots por alumno con tooltip de microdato, mediana/sd por prueba, y split rec/ant cruzado por territorio — ninguno de los cuales existe en el contrato real de salida de `32_agregar_territorial.R`. |
| `regla_violada` | SETTINGS_Y_PROMPTS_OPERACIONALES.md §4.6.2 (paso 1, "Leer todos los insumos de principio a fin. No resumir prematuramente" — aplicable por analogía a cualquier encargo que dependa de un contrato de datos existente) y, más directamente, `encargo_autonomo_claude_code_v1.md` §1.2 (punto 2: "Hacer el análisis y la metodología que Claude Code NO hace" — el análisis de contrato de datos real era responsabilidad del redactor del encargo, no de quien lo ejecuta). |
| `causa_raiz` | El artefacto de referencia (prototipo hi-fi de Claude Design) estaba completo, detallado y recién leído, lo que generó una falsa sensación de tener contexto suficiente; no se contrastó activamente contra el schema real de los parquets de `32` (que sí estaban disponibles y ya verificados en v02) antes de fijar las fases y criterios de éxito del encargo. |
| `salvaguarda_presente` | `encargo_autonomo_claude_code_v1.md` (reparto dual-Claude, sección 1.4: el análisis es responsabilidad del redactor, no de Claude Code) y el propio patrón de "Fase 0 — Lectura del estado real" que el mismo documento prescribe para Claude Code, que terminó haciendo de red de seguridad. |
| `patron` | Nuevo (primer registro de este patrón en `slep_paes`). Patrón a vigilar en próximas sesiones: redactar un encargo desde un artefacto de referencia externo sin releer primero el contrato de datos real de la etapa de pipeline anterior. |

**Nota:** la detención de Claude Code en Fase 0 fue el mecanismo correcto que evitó que este error se propagara a código o datos publicados; no hubo impacto en el output final. Se registra igual porque la regla 0.5 no distingue por impacto, solo por desviación de regla canónica.

---

**Fin del traspaso v03.**
