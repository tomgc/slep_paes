# Traspaso de cierre — slep_paes — v06

- **Versión:** v06
- **Fecha:** 2026-07-03
- **Sesión:** 6
- **Foco de la sesión:** auditoría de datos exhaustiva pre-push (encargo autónomo, 4 fases), corrección de 2 bloqueadores reales (F1: denominador `egresados` desalineado un año; F2: falso "0%" en 1.ª prioridad suprimida), diagnóstico y decisión formal de un residual marginal (F3: 1 persona, ruido inter-archivo), resolución de las 2 decisiones metodológicas heredadas de sesión 5 (conteo invierno/regular → hallazgo nuevo de mayor peso: implementación de "mejor puntaje vigente" por prueba con ventana=4, fidelidad literal a normativa DEMRE), revisión visual del titular, y autorización + ejecución de push.
- **Entorno:** Claude (análisis) + Claude Code (ejecución autónoma, `~/Projects/slep_paes`, R-only, macOS).
- **Archivos principales modificados:** `30_procesamiento/32_agregar_territorial.R`, `30_procesamiento/33_generar_html.R`, `30_procesamiento/33_motor_template.html`, `50_documentacion/andamios/auditoria_datos_pre_push/*` (nuevo), `50_documentacion/andamios/logs/20260703_*` (4 logs nuevos), `50_documentacion/activa/decisiones/20260703_decision_f3_margen_interarchivo.md` (nuevo), `CLAUDE.md`.

## 1. Resumen ejecutivo

La sesión abrió con el pendiente crítico de sesión 5: auditoría de datos exhaustiva como condición de push. Se redactó y ejecutó un encargo autónomo de 4 fases (recálculo independiente, aditividad territorial, barrido de %>100%, verificación DOM), que detectó una violación real del invariante "ningún %>100%" (29 celdas, máx 207%, cohorte "actual"), causada por un desalineamiento de un año entre el denominador `egresados` (indexado por año de egreso) y las demás etapas (indexadas por año de proceso de admisión). Autorizada la corrección (F1), junto con un hallazgo menor asociado (F2: 354 celdas mostraban "0%" falso en 1.ª prioridad por confundir supresión con cero genuino). Tras corregir y re-auditar, sobrevivió un residual de 1 persona (F3, Santo Domingo, 101%) por diferencia de identificadores entre ArchivoB (DEMRE) y el archivo de egresados (MINEDUC), sin clave de enlace disponible; se diagnosticó como infeasible de reconciliar persona-a-persona y se resolvió por decisión formal (aceptar el margen, documentado). Las 2 decisiones metodológicas pendientes de sesión 5 se resolvieron: la del conteo invierno/regular del embudo se mantuvo sin cambio (personas únicas, coherente con la documentación), pero el diagnóstico solicitado reveló un problema de mayor peso en el foco Rendimiento (se publicaba solo la convocatoria regular, ignorando la regla oficial DEMRE de "mejor puntaje vigente" entre las últimas 4 rendiciones), que se implementó con ventana=4 (fidelidad literal a la normativa) y se verificó con panel adversarial. La cohorte por defecto se confirmó como "Actual". El titular revisó visualmente el motor (Rendimiento·Comparar·Todas·nacional) y autorizó push, ejecutado con éxito. Se cometieron y corrigieron 4 errores del asistente durante la sesión (ver §15).

## 2. Estado al cierre

**Qué funciona (verificado con panel adversarial y DOM en cada etapa):**
- Auditoría pre-push completa: Fase 1 (recálculo independiente) MATCH TOTAL en las 4 rondas (original, post-F1/F2, post-reconciliación F3, post-rendimiento-vigente); Fase 2 (aditividad territorial) 0 excepciones en todas las rondas.
- F1 resuelto: `etapa_egresados` en `32` indexada correctamente en `anio_proceso = agno + 1`. Las 29 celdas sistémicas >100% desaparecieron. `anio_actual` avanzó de 2025 a 2026 automáticamente (efecto lateral correcto, verificado).
- F2 resuelto: `kpi_prioridad` distingue cero genuino de conteo suprimido; 354 celdas pasan de "0% (0)" a resguardo.
- F3 documentado: decisión formal `20260703_decision_f3_margen_interarchivo.md`, residual de 1 persona (0,00016% del universo) aceptado como ruido inter-archivo, sin cambio de código.
- Rendimiento "mejor puntaje vigente" implementado: `32` calcula `max(puntaje)` por persona-prueba sobre las 4 casillas (REG/INV × ACTUAL/ANTERIOR); `33` publica `tipo_rendicion=="vigente"`; motor con rótulos actualizados. Panel adversarial MATCH TOTAL (22.800 celdas). Embudo/cobertura intacto (verificado por diff).
- Revisión visual del titular: Rendimiento·Comparar·Todas·nacional confirmado sin objeciones (cifras no validadas de memoria por el titular, aceptado explícitamente).
- Push ejecutado (instruido a Claude Code; resultado pendiente de confirmación textual en este chat — ver Pendientes).

**Qué no funciona / queda pendiente de decisión:**
- **Confirmación textual del resultado del push:** el comando fue instruido y autorizado, pero esta sesión no recibió de vuelta el output de terminal ni la verificación en GitHub Pages antes del cierre.
- **`egresados_em` 2026 ausente:** bloqueante externo heredado, sin cambio.
- **Portabilidad cross-OS:** sin cambio, heredado de sesión 5.

**Delta respecto a v05:** el pipeline pasó de un estado con violación real de invariante de datos (%>100% sistémico) a un estado auditado, corregido y re-verificado en 4 rondas; el foco Rendimiento cambió de publicar solo la convocatoria regular a publicar el mejor puntaje vigente según normativa DEMRE (cambio de cifras publicadas, con delta nacional documentado, mayormente +2 a +15 puntos según prueba y año).

## 3. Registro detallado de cambios

### Cambio 1 — Auditoría de datos pre-push (Fases 1-4, ronda original)
- **Archivos:** `50_documentacion/andamios/auditoria_datos_pre_push/lib_auditoria.R`, `fase0_reproducibilidad.R`, `fase1_recalculo.R`, `fase2_aditividad.R`, `fase3_pct100.R`, `fase4_dom_evidencia.md` (todos nuevos).
- **Categoría:** verificación de riesgo de datos.
- **Qué:** panel adversarial completo con código propio, independiente de `32`/`33`, recalculando desde parquets crudos y comparando contra el JSON publicado en `docs/index.html`.
- **Por qué:** condición pactada explícitamente por el titular al cierre de sesión 5 para autorizar push.
- **Cómo se verificó (B.4):** Fase 1 MATCH TOTAL (25.131 celdas cobertura + 31.853 rendimiento, 0 discrepancias); Fase 2 aditividad exacta (comuna→región→nacional, cohorte todas=actual+anterior, supresión consistente, SLEP por partición); Fase 3 **FALLA** (29 celdas >100%, máx 207%); Fase 4 DOM==recálculo, violación confirmada visible (Cabo de Hornos, 207%).
- **Commits:** `e6caf6f`, `0e884ca`, `9c2dd89`, `a4d8cf0`, `6eba3d4`, `fa54197` (log: `20260703_auditoria_datos_pre_push_log.md`).

### Cambio 2 — F1: alineación del denominador `egresados`
- **Archivos:** `30_procesamiento/32_agregar_territorial.R`.
- **Categoría:** bug de datos (invariante violado) + corrección de pipeline.
- **Qué:** `etapa_egresados` pasa de indexarse en `anio_proceso = agno` a `anio_proceso = agno + 1L`, reflejando que el proceso de admisión P se nutre de la promoción que egresó en P-1.
- **Por qué (causa raíz, C.11):** el motor cruzaba `egresados` con las demás etapas por `anio_proceso` asumiendo igualdad, cuando la relación real tiene un desfase de un año.
- **Cómo se verificó (B.4):** nacional cohorte actual 2024=79,1%/2025=80,6%/2026=78,1% (a 1,1pp del hallazgo original, dentro del umbral de detención de 2pp); las 29 celdas sistémicas >100% desaparecen (Cabo de Hornos 207%→79%, DOM); `anio_actual` avanza automáticamente 2025→2026 (efecto lateral correcto, sin tocar `33`).
- **Corolario confirmado:** el "hueco de egresados 2026" documentado en sesión 5 (traspaso v05, pendiente 2) era artefacto del off-by-one, no un dato faltante real. Con la corrección, el hueco se mueve al proceso 2023 (el más antiguo, necesitaría egreso 2022).
- **Commit:** `35f7bd9`.

### Cambio 3 — F2: resguardo en 1.ª prioridad suprimida
- **Archivos:** `30_procesamiento/32_agregar_territorial.R`.
- **Categoría:** bug de datos (visualización engañosa) + corrección de pipeline.
- **Qué:** `kpi_prioridad_1` conserva la bandera `suprimida_p1`; `kpi_prioridad` distingue cero genuino (sin fila) de conteo suprimido (n<8), emitiendo resguardo (NA) en vez de `coalesce(., 0L)`.
- **Por qué (causa raíz, C.11):** el `coalesce` capturaba tanto el caso "sin ningún 1.ª prioridad" (cero real) como el caso "suprimido por k-anonimato" (1-7), mostrando ambos como "0%", inconsistente con la convención de resguardo del proyecto.
- **Cómo se verificó (B.4):** 354 celdas pasan de "0% (0)" a resguardo; 0 ceros falsos; rango no-NA verificado 8-74.941; DOM confirmado (Quemchi, resguardo con selección visible).
- **Commit:** `0a25277`.

### Cambio 4 — Re-auditoría post-F1/F2
- **Archivos:** `50_documentacion/andamios/auditoria_datos_pre_push/lib_reauditoria.R`, `reauditoria_post_fix.R`, `reauditoria_fase4_dom.md` (nuevos).
- **Categoría:** verificación de riesgo de datos.
- **Qué:** panel adversarial reajustado a la nueva indexación (no compara contra la definición vieja), Fases 1-4 completas.
- **Cómo se verificó:** Fase 1 MATCH TOTAL (nueva indexación); Fase 2 0 excepciones; Fase 3 **1 residual** (Santo Domingo, 101%, causa distinta a F1 — nace el hallazgo F3); Fase 4 DOM==recálculo, F1/F2 visibles, residual visible.
- **Commit:** `927cc1a` (log: `20260703_reauditoria_post_fix_f1_f2_log.md`).

### Cambio 5 — F3: diagnóstico de infeasibilidad y decisión formal
- **Archivos:** `50_documentacion/andamios/auditoria_datos_pre_push/f3_fase0_diagnostico.R` (nuevo), `50_documentacion/activa/decisiones/20260703_decision_f3_margen_interarchivo.md` (nuevo).
- **Categoría:** decisión de diseño (gate estratégico) + documentación formal.
- **Qué:** diagnóstico de Fase 0 (obligatorio antes de codificar) confirmó que ArchivoB (`id_aux`, DEMRE) y el archivo de egresados (`mrun`/`mrun_ipe`, MINEDUC) no comparten identificador de persona (0 solapamiento) — la reconciliación persona-a-persona originalmente autorizada resultó infeasible. Magnitud real del desfase (excluyendo el hueco 2023, artefacto de F1): 1 persona = 0,00016% del universo.
- **Por qué (C.11):** antes de implementar cualquier corrección, se verificó la premisa (¿existe clave de enlace?) contra los datos reales, evitando fabricar una reconciliación que hubiera violado el invariante de doble conteo.
- **Alternativas consideradas:** A (aceptar, elegida), B (topar a 100%, cosmético, descartada), C (denominador `max()`/unión, descartada por violar el invariante de doble conteo), D (crosswalk DEMRE↔MINEDUC, fuera de alcance, requiere insumo inexistente).
- **Decisión tomada por el titular:** A — aceptar el margen como ruido inter-archivo documentado, sin cambio de código. Confirmado visualmente por el titular en el DOM (101%, Santo Domingo).
- **Commits:** `797b331` (diagnóstico), `20d4395` (decisión formal).

### Cambio 6 — Diagnóstico de Decisión 6 (conteo invierno/regular) contra normativa DEMRE
- **Archivos:** ninguno modificado (solo lectura/diagnóstico).
- **Categoría:** verificación metodológica.
- **Qué:** diagnóstico solicitado por el titular sobre la regla oficial DEMRE de "mejor puntaje vigente" (`contexto_paes.md`, sección 5, "Puntaje Bloque": mejor puntaje de cada prueba entre las últimas rendiciones consecutivas) contrastado contra el código real de `32`/`33`.
- **Hallazgo clave:** el embudo (conteo de personas únicas, colapsando invierno+regular del mismo año) es coherente con la documentación — no hay puntaje en juego en el conteo de cobertura. Pero el foco **Rendimiento** publicaba solo la convocatoria regular-actual, **ignorando** la regla del mejor puntaje vigente: invierno superaba a regular en 37-40% de los casos (hasta 713 puntos de diferencia en CLEC), y ~7.000-10.000 personas/año que rendían solo invierno quedaban excluidas de la publicación.
- **Por qué se investigó (C.11):** el titular pidió explícitamente aclarar qué se estaba contando antes de decidir, y ampliar la pesquisa a la documentación de referencia oficial.
- **Decisión 6 resultante (embudo/cobertura):** sin cambio — "personas únicas" documentado como comportamiento correcto y coherente, no un bug.

### Cambio 7 — Implementación de "mejor puntaje vigente" (ventana=4)
- **Archivos:** `30_procesamiento/32_agregar_territorial.R`, `30_procesamiento/33_generar_html.R`, `30_procesamiento/33_motor_template.html`.
- **Categoría:** cambio metodológico de cifras publicadas (foco Rendimiento).
- **Qué:** bloque nuevo `rendimiento_vigente` en `32`: `max(puntaje)` por `(id_aux, anio_proceso, rbd, prueba, cohorte)` sobre las 4 casillas (REG/INV × ACTUAL/ANTERIOR), agregado territorialmente con supresión, etiquetado `tipo_rendicion="vigente"`. `33` publica esta etapa en vez de `reg-actual`. Motor con 5 notas actualizadas explicando la métrica ("mejor puntaje vigente… últimas 4 rendiciones consecutivas… normativa DEMRE «puntaje bloque»").
- **Por qué (C.11):** fidelidad literal a la normativa DEMRE, decisión explícita del titular tras el diagnóstico del Cambio 6 (ventana=4 preferida sobre ventana=2 pese a la tensión de mezcla de cohortes advertida por el asistente).
- **Cómo se verificó (B.4):** panel adversarial MATCH TOTAL (22.800 celdas, 0 discrepancias); NEM/Ranking sin cambio (0 discrepancias); DOM==recálculo exacto (SLEP 503, 2026, actual); 0 errores de consola. Embudo/cobertura verificado intacto (`git diff` de `32` limitado al bloque de rendimiento).
- **Efecto en cifras nacionales (delta vigente − reg-actual, cohorte "todas"):** mayormente positivo (+2 a +15 puntos según prueba/año); dos deltas negativos (CLEC 2023 −0,2; M1 2023 −5,9) explicados por mezcla de cohortes (ventana=4 agrega ~18.000-27.000 personas/prueba-año que bajan el promedio agregado pese a que cada individuo mejora o iguala).
- **Commit:** `2163f69` (log: `20260703_rendimiento_vigente_ventana4_log.md`).

### Cambio 8 — Revisión visual y push
- **Archivos:** ninguno.
- **Categoría:** verificación / gate del titular / publicación.
- **Qué:** el titular revisó el motor en preview (combinación Rendimiento·Comparar·Todas·nacional confirmada sin objeciones visuales, sin validación numérica de memoria) y autorizó `git push origin main`.
- **Cómo se verificó:** confirmación explícita del titular; el resultado textual del push queda pendiente de confirmación en el historial de este chat (ver §10, pendiente 1).

## 4. Backlog acumulativo

**Nota:** el backlog acumulativo formal vive en `50_documentacion/activa/backlog_acumulativo.md`. Este traspaso no repite su contenido íntegro.

- **Total acumulado:** 51 cambios al cierre de v05 + los 8 cambios de esta sesión (§3) = **59 cambios** acumulados, 6 sesiones cerradas.
- **Categorías dominantes de sesión 6:** Verificación de datos / auditoría (cambios 1, 4, 6), corrección de pipeline (cambios 2, 3), decisión de diseño formal (cambio 5), cambio metodológico de cifras publicadas (cambio 7), gate de publicación (cambio 8).
- **Acción pendiente heredada de v05, aún sin resolver:** actualizar `backlog_acumulativo.md` con las entradas de sesión 5 (9 cambios) **y** sesión 6 (8 cambios) — **no se realizó dentro de esta sesión tampoco**. Queda como pendiente crítico de apertura de sesión 7, ahora con doble atraso (POLITICA §10: obligatorio desde la segunda sesión, se actualiza en cada cierre; esta es la segunda sesión consecutiva que lo aplaza).

## 5. Bugs de la sesión

### Bug 3 — Denominador `egresados` desalineado un año (F1)
- **Síntoma observable:** 29 celdas renderizadas con porcentaje >100% en cohorte "actual" (máx 207%, Cabo de Hornos).
- **Causa raíz:** `etapa_egresados` en `32` indexada por año de egreso (`agno`) directamente en `anio_proceso`, cuando el proceso de admisión P consume la promoción que egresó en P-1.
- **Solución exacta:** `anio_proceso = agno + 1L`. Archivo: `32_agregar_territorial.R`, commit `35f7bd9`.
- **Criterio de verificación:** 0 celdas sistémicas >100% tras el fix (Fase 3 re-auditoría); nacional dentro de 1,1pp de la cifra documentada en el diagnóstico original.
- **Patrón general aprendido:** cuando dos etapas de un pipeline se indexan por conceptos de tiempo distintos (año de egreso vs. año de proceso), un cruce por igualdad de la variable de tiempo puede parecer correcto sin serlo — verificar explícitamente la relación semántica entre ambos calendarios, no solo que ambos tengan una columna de año.
- **Principios aplicados:** C.11, B.4.
- **Estado:** resuelto.

### Bug 4 — "0%" engañoso en 1.ª prioridad suprimida (F2)
- **Síntoma observable:** 354 celdas de comuna mostraban "0% (0)" en 1.ª prioridad con `n_seleccionados` visible, cuando el conteo real era 1-7 (suprimido).
- **Causa raíz:** `coalesce(n_prioridad_1, 0L)` no distinguía "sin ningún 1.ª prioridad" (cero genuino) de "suprimido por k-anonimato" (NA tras supresión).
- **Solución exacta:** conservar la bandera de supresión (`suprimida_p1`) y emitir resguardo (NA) en vez de coalescer a 0 cuando corresponde. Archivo: `32_agregar_territorial.R`, commit `0a25277`.
- **Criterio de verificación:** 0 celdas "0%" mostrado tras el fix; rango no-NA de `n_prioridad_1` confirmado 8-74.941 (ningún valor suprimido se filtra).
- **Patrón general aprendido:** un `coalesce()` que reemplaza NA por un valor "neutro" (0) puede estar ocultando dos semánticas distintas (ausencia real vs. dato protegido); antes de coalescer, verificar si el NA tiene una causa que merece su propia representación visual.
- **Principios aplicados:** C.11, B.4.
- **Estado:** resuelto.

## 6. Aprendizajes y restricciones descubiertas

- **Un invariante de "0 %>100%" puede sobrevivir en estado casi-satisfecho de forma legítima** (contexto: F3). Cuando la causa raíz de un residual es la ausencia de una clave de enlace entre fuentes de agencias distintas (no un error de cálculo), forzar el cumplimiento estricto del invariante (ej. `max()`/unión) puede violar un invariante más fundamental (sin doble conteo). Regla: ante un residual marginal con causa estructural documentada, la decisión correcta puede ser aceptar y documentar, no forzar el cumplimiento cosmético.
- **Verificar la existencia de una clave de enlace ANTES de autorizar una reconciliación persona-a-persona** (contexto: F3, Fase 0). Autorizar una implementación sin verificar la premisa (¿comparten identificador los dos archivos?) puede resultar en un encargo infeasible; la Fase 0 obligatoria de diagnóstico existe precisamente para detectar esto antes de codificar.
- **Un "bug" de conteo puede coexistir con un problema real de mayor magnitud en un área adyacente** (contexto: Decisión 6 / Cambio 6). El diagnóstico solicitado sobre invierno/regular confirmó que el embudo estaba bien, pero reveló que el foco Rendimiento violaba la normativa oficial de forma más significativa. Regla: al diagnosticar una pregunta puntual del titular, verificar también las áreas adyacentes que comparten la misma fuente de datos o el mismo concepto temporal.
- **Cuando existe un dato canónico ya disponible en la documentación del proyecto, no se pregunta al titular por la decisión: se aplica directamente** (contexto: ventana temporal de "mejor puntaje vigente", error del asistente registrado en §15). La pregunta al titular es apropiada ante ambigüedad genuina, no cuando la norma ya está documentada y solo falta leerla.

## 7. Decisiones de diseño

### Decisión 5 — F3: aceptar el margen inter-archivo de 1 persona
- **Alternativas consideradas:** A (aceptar, elegida), B (topar a 100%, cosmético), C (denominador max/unión, descartada por invariante), D (crosswalk DEMRE↔MINEDUC, fuera de alcance).
- **Justificación:** desfase real de 1 persona (0,00016% del universo); la vía correcta (D) requiere un insumo inexistente; las vías que fuerzan ≤100% sin ese insumo son cosméticas (B) o violan el invariante de doble conteo (C).
- **Tensión resuelta:** rigor del invariante "0 %>100%" vs. imposibilidad técnica de reconciliar sin clave de enlace. Se documentó como límite conocido de la fuente en vez de forzar una solución que introduce un artefacto nuevo.
- **Implicancia:** sin cambio de código; decisión formal en `50_documentacion/activa/decisiones/20260703_decision_f3_margen_interarchivo.md`.
- **Reapertura:** si aparece un crosswalk DEMRE↔MINEDUC, si el desfase supera 0,1% del universo en un proceso futuro, o si el titular prioriza el cumplimiento estricto y opta por el tope de display (B).

### Decisión 6 — Conteo invierno/regular en el embudo: sin cambio (personas únicas)
- **Alternativas consideradas:** A (documentar como texto, "personas únicas", elegida), B (cambiar a conteo de participaciones).
- **Justificación:** el conteo de personas únicas en el embudo/cobertura es coherente con la documentación oficial (el embudo no maneja puntajes, solo headcount de "¿rindió al menos una prueba?").
- **Implicancia:** sin cambio de código en el embudo. El diagnóstico solicitado para esta decisión reveló, como hallazgo colateral, el problema real de mayor peso (Decisión 7 / Cambio 7).

### Decisión 7 — Rendimiento: publicar "mejor puntaje vigente", ventana=4
- **Alternativas consideradas:** ventana=2 (solo convocatorias del proceso actual, recomendada inicialmente por el asistente por evitar mezcla de cohortes) vs. ventana=4 (fidelidad literal a la normativa DEMRE, incluye la convocatoria del proceso anterior).
- **Decisión tomada por el titular:** ventana=4, fidelidad literal a la normativa. El titular indicó explícitamente que ante un dato canónico documentado, no se pregunta — se aplica directo.
- **Justificación:** la normativa DEMRE define el "puntaje vigente" sobre las últimas 4 rendiciones consecutivas (2 procesos × regular/invierno); ventana=2 habría sido una interpretación restrictiva no respaldada por la fuente oficial.
- **Tensión resuelta:** fidelidad normativa vs. pureza de cohorte (ventana=4 mezcla año actual y anterior, produciendo 2 deltas nacionales negativos por dilución del promedio agregado, aunque cada individuo mejora o iguala). Se optó por fidelidad normativa; la mezcla de cohortes quedó documentada y cuantificada, no oculta.
- **Implicancia:** cambio de cifras publicadas en el foco Rendimiento (delta documentado en Cambio 7); las filas `reg`/`inv`/`anterior` se conservan en el parquet (no se pierde información, reversible).

### Decisión 8 — Cohorte por defecto: "Actual" (ratificación)
- **Contexto:** pendiente heredado de sesión 5 (Decisión 3, traspaso v05 §7), donde "Actual" ya era el default pero quedaba una aclaración sin resolver sobre si el titular preferiría "Todas".
- **Decisión tomada por el titular:** "Actual" confirmado explícitamente esta sesión. Sin cambio de código (ya era el comportamiento vigente).

## 8. Constantes y parámetros vigentes

| Constante | Valor | Archivo | Nota |
|---|---|---|---|
| `UMBRAL_SUPRESION_CELDA` | 8 | `32_agregar_territorial.R` | Sin cambio. |
| `etapa_egresados` indexación | `anio_proceso = agno + 1L` | `32_agregar_territorial.R` | **Cambiado esta sesión** (F1). Antes: `anio_proceso = agno`. |
| `anio_actual` (motor) | `max(anios_egr)` = 2026 | `33_generar_html.R` | **Cambiado esta sesión** (efecto lateral de F1, antes 2025). Fórmula sin cambio. |
| Umbral de detención (delta nacional aceptable) | 2 pp | (criterio de sesión, no constante de código) | Definido ad-hoc en la instrucción a Claude Code para F1; no está en ningún archivo del proyecto — considerar si merece quedar como constante nombrada si se repite el patrón. |
| Umbral de magnitud para F3 | 0,1% del universo | (criterio de sesión, no constante de código) | Definido ad-hoc; mismo comentario que arriba. |
| `rendimiento_vigente` — ventana | 4 casillas (REG/INV × ACTUAL/ANTERIOR) | `32_agregar_territorial.R` | Nuevo esta sesión. |
| `tipo_rendicion` (valores posibles) | `reg`, `inv`, `anterior`, `vigente` | `32_agregar_territorial.R` | `vigente` es nuevo esta sesión; los demás se conservan sin pérdida. |

## 9. Arquitectura de archivos

Referencia: `estructura_actual.md`, snapshot `2026-07-03 12:45:20`, 20 carpetas / 109 archivos (crecimiento de 91→109 archivos respecto a sesión 5, principalmente por la evidencia congelada de auditoría en `andamios/auditoria_datos_pre_push/` y los 4 logs nuevos).

**Cambios de estructura:**
- Nuevo `50_documentacion/andamios/auditoria_datos_pre_push/` (11 archivos: libs, scripts de fase, evidencia DOM).
- `50_documentacion/andamios/logs/` ganó 4 logs nuevos (auditoría original, re-auditoría F1/F2, reconciliación F3, rendimiento vigente).
- `50_documentacion/activa/decisiones/` ganó 1 archivo (`20260703_decision_f3_margen_interarchivo.md`).
- `CLAUDE.md` se editó recurrentemente (retiro de ítems antiguos en "Últimos cambios") en cada encargo de esta sesión, de forma autónoma por Claude Code, confirmado por el titular como comportamiento aceptable (ver §15, no se marca como error, pero se registró la falta de verificación de alcance como error propio).
- Sin desviaciones nuevas respecto a la política (decenas, naming, ubicación).

## 10. Pendientes y ruta sugerida

### Inventario

1. **Confirmación textual del resultado del push.** Contexto: el titular autorizó y Claude Code recibió la instrucción `git push origin main`, pero esta sesión no recibió de vuelta el output de terminal ni verificación en GitHub Pages antes del cierre. Tipo: verificación / gate del titular. Impacto: no se puede confirmar en este traspaso si el push llegó a `origin/main` sin error. Complejidad: baja (mecánica, requiere solo pegar el output). Precaución: si el push falló silenciosamente o quedó a medias, sesión 7 debe verificarlo como primer paso, antes de cualquier otro trabajo. Criterio de éxito: output de `git push` visible en el historial + verificación en `https://tomgc.github.io/slep_paes/`.

2. **`backlog_acumulativo.md` sin actualizar — segunda sesión consecutiva.** Ver §4. Tipo: documentación, obligatoria según POLITICA §10. Complejidad: baja (mecánica), pero el atraso ya cubre 17 cambios (9 de sesión 5 + 8 de sesión 6) sin consolidar en el archivo canónico. Precaución: si se sigue posponiendo, el riesgo de error de numeración correlativa aumenta.

3. **`egresados_em` 2026 ausente.** Bloqueante externo, sin acción disponible hasta que el dato exista. Sin cambio respecto a sesión 5 (nota: el corolario de F1 aclaró que el "hueco 2026" documentado en sesión 5 era en realidad artefacto del off-by-one, ya corregido; el hueco real ahora es el proceso 2023, y este pendiente sigue vigente para cuando corresponda el próximo año de egreso).

4. **Portabilidad cross-OS (Windows + macOS).** Sin cambio respecto a sesión 5. Ver traspaso v05 §10 pendiente 3 para contexto completo.

5. **Umbrales de decisión ad-hoc sin formalizar como constantes.** Contexto: esta sesión usó dos umbrales (2pp para delta nacional aceptable en F1, 0,1% del universo para magnitud de F3) definidos en instrucciones puntuales a Claude Code, no en ningún archivo del proyecto. Tipo: deuda técnica / transparencia del cambio (C.10, decisiones metodológicas como constantes nombradas). Complejidad: baja. Precaución: si estos umbrales se van a reutilizar en futuras auditorías, conviene nombrarlos explícitamente (ej. en `contexto_paes.md` o en un futuro protocolo de auditoría).

6. **CLAUDE.md: verificar si la edición recurrente y autónoma debe formalizarse.** Contexto: Claude Code editó CLAUDE.md en cada uno de los últimos 3 encargos (retiro de ítems antiguos de "Últimos cambios"), sin instrucción explícita en el encargo. El titular confirmó que está bien que continúe así. Tipo: deuda de proceso, baja prioridad. Complejidad: baja (ya resuelto por confirmación del titular; este ítem es solo para que quede trazado en el traspaso, no requiere acción).

### Evaluación de deuda técnica

- **Zona frágil confirmada y ahora corregida:** la relación entre `egresados` (indexado por año de egreso) y las demás etapas (indexadas por año de proceso) era una fuente de error silencioso real (F1), no solo una hipótesis de riesgo. Vigilar si se agrega una tercera fuente de datos con un tercer calendario (ej. un archivo de matrícula con año lectivo) — el mismo patrón de desalineamiento puede repetirse.
- **Oportunidad de mejora:** el patrón de "Fase 0 obligatoria antes de codificar" (usado en F3) evitó una implementación infeasible o que hubiera violado el invariante de doble conteo. Vale la pena mantenerlo como práctica estándar en cualquier encargo de reconciliación de datos entre fuentes.

### Auditoría de cierre (POLITICA 5.6, preguntas "Cierre")

| # | Pregunta | Respuesta |
|---|---|---|
| 5 | ¿Cada transformación crítica tiene check de validación? | Sí — panel adversarial en las 4 rondas de auditoría de esta sesión (original, post-F1/F2, post-F3-diagnóstico, post-rendimiento-vigente). |
| 6 | ¿Los outputs son reproducibles e idempotentes? | Sí — `run_all(only=c(32,33))` verificado reproducible en cada ronda; Fase 0 de la auditoría original confirmó no-staleness del artefacto committeado. |
| 7 | ¿Decisiones metodológicas como constantes nombradas? | **Parcial** — la indexación de `egresados` y la ventana de `rendimiento_vigente` sí quedaron como código explícito comentado; los umbrales de decisión ad-hoc (2pp, 0,1%) NO quedaron como constantes nombradas (ver pendiente 5). |
| 8 | ¿Nombres de archivos y carpetas sin tildes, ñ ni espacios? | Sí, sin desviaciones nuevas. |

**Un "no parcial"** en esta auditoría de cierre (pregunta 7) — genera el pendiente 5 ya listado arriba.

### Ruta sugerida para la próxima sesión (criterios de 1.2.4)

1. **Bug activo:** ninguno pendiente (Bug 3 y Bug 4 resueltos esta sesión).
2. **Bloqueante:** pendiente 1 (confirmación del push) es el más urgente — sin confirmarlo, no se sabe si el trabajo de 2 sesiones (5 y 6) está publicado.
3. **Instrucciones explícitas del traspaso (⚠️/✅/🔒):** ver §11.
4. **Deuda heredada:** ninguna nueva detectada esta sesión.
5. **Deuda técnica acumulada:** pendiente 5 (umbrales sin formalizar).
6. **Alta complejidad al inicio:** ninguna pendiente de alta complejidad quedó abierta esta sesión.
7. **Funcionalidad nueva:** ninguna solicitada, no proponer.
8. **Cosmética/documentación al final:** pendiente 2 (backlog), pendiente 6 (ya resuelto, solo trazabilidad).

**Recomendación:** Prioridad 1 de sesión 7 = confirmar el resultado del push (pendiente 1) y verificar GitHub Pages — es lo único que podría requerir acción correctiva inmediata si algo falló. Prioridad 2 = actualizar `backlog_acumulativo.md` (pendiente 2, ya con doble atraso, mecánico pero no debe seguir posponiéndose). Prioridad 3 = formalizar los umbrales de decisión como constantes nombradas (pendiente 5) si se anticipa una próxima auditoría similar.

## 11. Instrucciones específicas para la próxima sesión

- ⚠️ NO asumir que el push de esta sesión se completó sin error — verificar el output real antes de continuar cualquier otro trabajo.
- ⚠️ NO posponer `backlog_acumulativo.md` una tercera sesión consecutiva — actualizarlo es la primera tarea mecánica de apertura de sesión 7.
- ✅ ANTES de cualquier futura auditoría de datos, considerar formalizar los umbrales de decisión (2pp, 0,1%) como constantes nombradas si el patrón se repite.
- 🔒 `etapa_egresados` indexada en `anio_proceso = agno + 1L` — invariante corregido esta sesión (F1), no revertir sin nueva evidencia.
- 🔒 `rendimiento_vigente` (ventana=4, máximo entre las 4 casillas REG/INV×ACTUAL/ANTERIOR) es la fuente publicada del foco Rendimiento — no revertir a `reg-actual` sin autorización explícita del titular.
- 🔒 F3 (margen de 1 persona, Santo Domingo) es una decisión formal aceptada — no re-abrir sin nueva evidencia (crosswalk DEMRE↔MINEDUC, o desfase que supere 0,1% del universo).
- 🔒 Cohorte por defecto = "Actual" — ratificado explícitamente esta sesión, no cambiar sin nueva autorización.
- 🔒 `UMBRAL_SUPRESION_CELDA=8`, Rasch (nunca "IRT 3PL"), sentence case, sin nombres de establecimiento — sin cambio.

## 12. Fragmentos de código de referencia

**Indexación correcta de `etapa_egresados` (F1, la forma correcta desde esta sesión):**

```r
etapa_egresados <- egresados_em |>
  dplyr::filter(marca_egreso == 1L) |>
  dplyr::mutate(
    anio_proceso = as.integer(agno) + 1L  # el proceso P consume egreso P-1
  )
```

**Patrón de "mejor puntaje vigente" (ventana=4, la forma correcta desde esta sesión):**

```r
rendimiento_vigente <- rend_largo |>
  dplyr::summarise(
    puntaje = max(puntaje, na.rm = TRUE),
    .by = c(id_aux, anio_proceso, rbd, prueba, cohorte)
  ) |>
  dplyr::mutate(tipo_rendicion = "vigente", vigencia = "actual")
```

Cualquier cálculo futuro de rendimiento que necesite representar "cómo le fue a la gente en la admisión" (no solo en una convocatoria específica) debe usar `tipo_rendicion=="vigente"`, no `"reg"` directamente.

## 13. Reapertura

**Nombre del chat:** `slep_paes, sesión 7 (Claude Sonnet 5)`

**Mensaje de apertura pre-armado:**

Adjunto los documentos de protocolo y los específicos de la sesión. Tipo CONTINUATION. El protocolo (`POLITICA_PROYECTO.md` + `SETTINGS_Y_PROMPTS_OPERACIONALES.md`) vive en la knowledge base del Project y se lee desde ahí.

**Documentos para la próxima sesión:**

1. *Protocolo en knowledge base (NO adjuntar, solo verificar vigencia):* `POLITICA_PROYECTO.md`, `SETTINGS_Y_PROMPTS_OPERACIONALES.md`.
2. *Opcionales según foco real:* `CLAUDE.md` (si la sesión correrá en Claude Code).
3. *Específicos de la sesión (SÍ adjuntar):* `traspaso_cierre_v06.md` (este documento); `estructura_actual.md` (regenerar al abrir sesión 7); output de terminal del `git push` de esta sesión si el titular lo tiene disponible (para cerrar el pendiente 1 de inmediato).

**Nota final:** si el push de esta sesión no se completó o falló, avisarlo explícitamente en el mensaje de apertura de sesión 7 para que sea la primera acción, antes de cualquier otro trabajo.

## 14. Reapertura (bloque replicado para copiar sin abrir el archivo)

```
slep_paes, sesión 7 (Claude Sonnet 5)

Adjunto los documentos de protocolo y los específicos de la sesión.
Tipo CONTINUATION. El protocolo (POLITICA_PROYECTO.md + SETTINGS_Y_PROMPTS_OPERACIONALES.md)
vive en la knowledge base del Project y se lee desde ahí.

Documentos:
1. Protocolo (knowledge base, no adjuntar): POLITICA_PROYECTO.md, SETTINGS_Y_PROMPTS_OPERACIONALES.md.
2. Opcionales: CLAUDE.md si corre en Claude Code.
3. Específicos (sí adjuntar): traspaso_cierre_v06.md; estructura_actual.md (regenerar
   al abrir); output del git push de sesión 6 si está disponible (cierra pendiente 1
   de inmediato).
```

## 15. Errores del asistente

| Campo | Contenido |
|---|---|
| `momento` | Al redactar el encargo de reconciliación de F3, ofreciendo una recomendación entre las opciones A/B/D. |
| `disparador` | Usuario lo señaló explícitamente. |
| `que_paso` | El asistente recomendó la opción más conveniente (aceptar el margen sin cambio) antes de que el diagnóstico de causa raíz completo (Fase 0) estuviera disponible, priorizando cierre rápido sobre exhaustividad metodológica. |
| `regla_violada` | SETTINGS §2.3.2 (especificidad sobre generalidad, causa raíz antes de conclusión). |
| `causa_raiz` | Se trató "magnitud marginal" (1 persona) como equivalente a "sin importancia metodológica" sin haber verificado aún si el patrón se repetía en otras comunas o procesos. |
| `salvaguarda_presente` | SETTINGS (C.11, causa raíz antes de corregir); userPreferences (recomendación obligatoria, que exige rigor, no conveniencia). |
| `patron` | Nuevo. |

| Campo | Contenido |
|---|---|
| `momento` | Al presentar la pregunta sobre la ventana temporal (2 vs. 4) para "mejor puntaje vigente". |
| `disparador` | Usuario lo señaló explícitamente ("nunca me vuelvas a preguntar algo si tienes el dato canónico"). |
| `que_paso` | El asistente formuló como pregunta de decisión algo que ya estaba resuelto por una norma documentada y citada por el propio asistente en el mismo turno (`contexto_paes.md`, regla DEMRE de 4 casillas). |
| `regla_violada` | POLITICA B.1 (sin supuestos implícitos — aplicado de forma inversa: existía un dato explícito y se trató como si fuera ambiguo); principio general de la sesión de "usar el dato canónico cuando existe, no preguntar". |
| `causa_raiz` | El asistente identificó una tensión de diseño real (ventana=4 mezcla cohortes) y, al ver una tensión, activó el reflejo de "presentar como decisión al titular" sin distinguir entre una tensión de diseño abierta (sí amerita pregunta) y una que la normativa ya resuelve (no amerita pregunta, solo aplicación). |
| `salvaguarda_presente` | userPreferences (ninguna regla explícita previa sobre este caso específico; la corrección estableció una regla nueva para la sesión). |
| `patron` | Distinto del anterior (ese fue sobre rigor vs. conveniencia en una recomendación; este es sobre preguntar innecesariamente cuando existe un dato canónico). Ambos comparten la raíz de no haber usado toda la información ya disponible antes de involucrar al titular. |

| Campo | Contenido |
|---|---|
| `momento` | Redacción de la pregunta sobre alcance del diagnóstico de invierno/regular (Decisión 6), antes de que el titular aclarara la pregunta base ("¿qué estamos contando?"). |
| `disparador` | Usuario lo señaló indirectamente (pidió aclaración antes de poder decidir, revelando que la pregunta original asumía comprensión que el titular no tenía todavía). |
| `que_paso` | El asistente presentó una decisión A/B (documentar vs. cambiar cifras) sin antes confirmar que el titular tenía clara la mecánica actual del conteo, forzando una vuelta adicional. |
| `regla_violada` | SETTINGS §1.2.4 (una decisión bien presentada debe ser autocontenida; si requiere contexto que el titular no tiene, se lo da primero). |
| `causa_raiz` | El asistente asumió que "qué se cuenta hoy" ya estaba claro por haber sido discutido en sesión 5 (traspaso v05), sin considerar que retomar el tema en una sesión nueva requiere recapitular brevemente antes de pedir una decisión. |
| `salvaguarda_presente` | SETTINGS §1.2.4. |
| `patron` | Nuevo — variante del patrón general "no dar por sentado que el contexto de una sesión anterior sigue fresco para el titular". |

| Campo | Contenido |
|---|---|
| `momento` | Verificación de alcance de CLAUDE.md tras el encargo de rendimiento vigente. |
| `disparador` | El asistente lo señaló espontáneamente (auditoría propia). |
| `que_paso` | No se verificó, en los encargos de F1/F2 ni en el de rendimiento vigente, si la edición recurrente y autónoma de `CLAUDE.md` por parte de Claude Code estaba dentro del alcance explícitamente autorizado de cada encargo puntual. |
| `regla_violada` | POLITICA 0.3 (autonomía con interrupciones mínimas: los cambios menores se resuelven autónomamente, pero deben quedar visibles/reportados, no pasar inadvertidos en la auditoría del asistente). |
| `causa_raiz` | El foco de auditoría de cada encargo estuvo puesto en el cambio de datos (el objetivo explícito), no en el conjunto completo de archivos tocados por Claude Code. |
| `salvaguarda_presente` | POLITICA 0.3. |
| `patron` | Nuevo. Nota: tras señalarlo, el titular confirmó que está bien que Claude Code mantenga CLAUDE.md autónomamente — no requiere corrección de comportamiento futuro de Claude Code, solo del hábito de auditoría del asistente. |

**Nota adicional (no tabulada, sin acción correctiva requerida):** el titular indicó al inicio de esta sub-sesión "no vuelvas a hablar de cierres ni traspasos, acabamos de empezar" — instrucción respetada durante el resto del trabajo activo; el cierre se generó recién cuando el titular lo solicitó explícitamente ("cierre de sesion mientras tanto").
