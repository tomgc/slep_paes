# Traspaso de cierre — slep_paes — v05

- **Versión:** v05
- **Fecha:** 2026-07-03
- **Sesión:** 5
- **Foco de la sesión:** Push del estado de sesión 4; generación de la suite de documentación (`suitedoc`); 7 encargos autónomos a Claude Code sobre el motor (`33_motor_template.html`) y el pipeline (`32_agregar_territorial.R`) para rediseño de interfaz, cohorte territorial por RBD histórico, y corrección de bug de porcentajes >100%.
- **Entorno:** Claude (análisis) + Claude Code (ejecución autónoma, `~/Projects/slep_paes`, R-only, macOS) + Claude Design (handoff visual).
- **Archivos principales modificados:** `30_procesamiento/32_agregar_territorial.R`, `30_procesamiento/33_motor_template.html`, `30_procesamiento/33_generar_html.R`, `50_documentacion/suite/*` (nuevo), `docs/index.html`, `CLAUDE.md`.

## 1. Resumen ejecutivo

La sesión abrió con el pendiente heredado de sesión 4 (push de 5 commits), que se autorizó y ejecutó de inmediato. A partir de ahí se generó la suite de documentación `suitedoc` (4 HTML standalone offline, aceptada como publicable). Luego, a solicitud del titular, se ejecutaron 7 encargos autónomos secuenciales sobre el motor: reorden de header, selector territorial con tabs (patrón `slep_simce_adecuado`), fix inicial del toggle de cohorte, extensión real del pipeline para cruzar "cohortes anteriores" por RBD de egreso histórico (hallazgo metodológico: la cohorte es recencia de egreso, no vigencia de RBD), toggle de 3 estados (Actual/Anteriores/Todas) integrado al embudo real, ajustes de interfaz v2 (chip redundante, desglose filtrable, rename "generaciones"→"cohortes", nueva serie histórica de Prioridad 1), rediseño visual completo de la columna "1.ª prioridad" vía handoff de Claude Design ("Universo de seleccionados"), y un fix de bug real (porcentajes >100% en cohorte "Todas" por denominador desalineado). Cada encargo de riesgo de datos usó panel adversarial con recálculo independiente; todos verificados en navegador contra DOM real, no solo capturas. 13+ commits locales, ninguno pusheado (gate del titular, pendiente para próxima sesión). Se detectó una detención real (Fase 3 de un encargo): el conteo de rendición colapsa invierno+regular intra-año por diseño original del código (no un bug), decisión pendiente del titular. Se cometieron y corrigieron 3 errores del asistente durante la sesión (ver §15). Pendiente crítico nuevo: auditoría de datos exhaustiva de todos los indicadores, acordada como Prioridad 1 de la próxima sesión, junto con revisión visual final antes de push.

## 2. Estado al cierre

**Qué funciona (última ejecución exitosa, verificada en navegador y panel adversarial):**
- Push de sesión 4 (tipografía `--fs-*` + KPI de prioridad) publicado en GitHub Pages.
- Suite `suitedoc` (4 HTML standalone offline), 0 referencias de red, 0 mojibake, aceptada como publicable por el titular.
- Selector de territorio con tabs (Comuna/SLEP/Región/Nacional), buscador acento-insensible, selección única/múltiple con cap 10.
- Cohorte por territorio real: dimensión `cohorte` (`actual`/`anterior`/`todas`) cruzada por RBD de egreso histórico en `32`, verificada con panel adversarial (21 celdas de inscripción + 6 de selección, aditividad territorial, medias de rendimiento).
- Toggle de 3 estados aplicado a las 4 combinaciones Cob/Ren × Por-territorio/Comparar, incluida vista histórica.
- Desglose por comuna filtrable (exacto para Región; SLEP display-only, decisión de alcance declarada).
- Nueva serie histórica "Seleccionado en 1.ª preferencia (% de egresados)".
- Bloque visual "Universo de seleccionados" (banda + marco + heatmap propio) implementado según handoff de Claude Design, reemplazando el tratamiento rechazado por el titular ("2/10").
- Fix de porcentajes >100% en cohorte "Todas": causa raíz (denominador `egresados` desalineado con numerador sumado) corregida en 3 vistas + export XLSX con un helper compartido (`baseCob`).
- Terminología "generaciones anteriores" → "cohortes anteriores"/"cohorte" en todo el texto visible (motor + suite), grep=0 confirmado.

**Qué no funciona / queda pendiente de decisión:**
- **Detención real, sin resolver:** el embudo cuenta personas únicas por año en las etapas de rendición/resultados (`distinct(id_aux, rbd, anio_proceso)` sin `tipo_rendicion`), colapsando invierno+regular intra-año (~19-22k personas/año). El propio comentario del código (L279 de `32`) sugiere que esto es diseño original intencional ("rindió al menos una prueba"), no un bug. Decisión pendiente: (A) documentar como "personas únicas" (cambio de texto, no de cálculo) o (B) cambiar a conteo de participaciones (cambio de cifras publicadas, requiere autorización explícita).
- **Push no ejecutado:** 13+ commits locales de esta sesión, sin autorización del titular.
- **Auditoría de datos pendiente:** acordada como Prioridad 1 de la próxima sesión (ver §11).

**Delta respecto a v04:** el motor pasó de un embudo/rendimiento sin distinción de cohorte real (bucket nacional aparte, con bug de toggle que solo afectaba opacidad) a un sistema de 3 cohortes territorializadas por RBD histórico, con interfaz rediseñada en 3 iteraciones (chip+selector, borde+flecha rechazado, banda+marco aceptado).

## 3. Registro detallado de cambios

### Cambio 1 — Push del estado acumulado de sesión 4
- **Archivos:** todo el árbol (5 commits de sesión 4).
- **Categoría:** publicación / gate del titular.
- **Qué:** `git push origin main`, `ab20bcf..2d61ed2`.
- **Por qué:** commits ya verificados (panel adversarial, verificación visual) en sesión 4, autorización pendiente desde el cierre de esa sesión.
- **Cómo se verificó:** confirmación de push exitoso por el titular (output de terminal).
- **Dependencias:** ninguna otra tarea de esta sesión dependía de este push.

### Cambio 2 — Corrección del traspaso v04 (pendiente omitido)
- **Archivos:** `50_documentacion/traspasos/traspaso_cierre_v04.md`.
- **Categoría:** documentación / error del asistente.
- **Qué:** se agregó el pendiente 4 (suite de documentación con `suitedoc`), omitido en la redacción original de v04 pese a haber sido acordado explícitamente al cierre de sesión 4.
- **Por qué (C.11):** decisión conversacional de alcance tomada en el mismo turno que el cierre no se trasladó al inventario formal de pendientes.
- **Cómo se verificó:** el titular confirmó la corrección tras señalarla.
- **Registrado también en:** §15 (error del asistente).

### Cambio 3 — Suite de documentación `suitedoc` (standalone offline)
- **Archivos:** `50_documentacion/suite/documentar.R` (nuevo), 4 `*_standalone.html` (nuevos).
- **Categoría:** documentación / funcionalidad nueva.
- **Qué:** generación completa de la suite (arquitectura técnica, manual de proyecto, línea de producción general, guía breve general), con `standalone=TRUE` activado desde el inicio (no como migración posterior).
- **Por qué:** protocolo SETTINGS §4.6, pendiente heredado de sesión 4.
- **Cómo se verificó (B.4):** grep de red=0 en los 4 archivos (namespace SVG excluido correctamente), "3PL" solo en blobs base64 de fuentes (0 en texto visible), "rezagados" ausente, "EE" ausente como abreviatura visible, gobernanza con categoría real Ley 21.719, render en navegador sin errores de consola. Verificación independiente del asistente (no solo el reporte de Claude Code) confirmó las mismas cifras.
- **Decisión del titular:** aceptado como publicable sin revisión adicional de tono (voz institucional en primera persona plural ya configurada correctamente).
- **Commit:** `dfec49d` (log: `20260702_suitedoc_generacion_log.md`).

### Cambio 4 — Mejoras de interfaz: reorden header, selector con tabs, fix inicial de toggle
- **Archivos:** `30_procesamiento/33_motor_template.html`, `docs/index.html`.
- **Categoría:** interfaz.
- **Qué:** 3 fases — (1) fusión de las 2 filas de controles en 1 sola (Territorio·Vista·Período·Cohorte); (2) reemplazo del modal de árbol por selector con tabs (Comuna/SLEP/Región/Nacional, patrón `slep_simce_adecuado`, con `norm()` de normalización de acentos); (3) fix inicial del toggle "generaciones anteriores" (montaje condicional en vez de solo opacidad — luego superado por el Cambio 5, que rediseñó el concepto completo).
- **Por qué:** mockup explícito del titular (Fase 1); reutilización de patrón ya probado en proyecto hermano (Fase 2); bug reportado por el titular ("no pasa nada al apretarlo") (Fase 3).
- **Cómo se verificó (B.4):** 6 combinaciones Foco×Vista×Período sin layout roto; modal con buscador acento-insensible verificado con "Viña"/"vina"/"Puchuncaví"/"puchuncavi"; selección única y múltiple (cap 10) verificadas; `showRez` con 3 usos exactos, tercero condicionando montaje (confirmado por el asistente contra código real, no solo el log).
- **Nota de ancho declarada (B.1):** la fila de controles es 1 línea a ≥~1320px, hace wrap responsivo bajo eso — comportamiento estándar, no defecto.
- **Corrección de ruta aplicada durante el encargo:** el componente fuente era `slep_simce_adecuado`, no `slep_categoria_desempeno` como decía el encargo original (ver error del asistente §15).
- **Commits:** `e90edc4`, `15695ff`, `4c063e9`, `04978e5` (log: `20260702_mejoras_interfaz_log.md`).

### Cambio 5 — Cohorte por territorio real (RBD histórico) + toggle de 3 estados
- **Archivos:** `30_procesamiento/32_agregar_territorial.R`, `30_procesamiento/33_motor_template.html`, `30_procesamiento/33_generar_html.R`, `docs/index.html`.
- **Categoría:** pipeline (cambio de alcance real) + interfaz.
- **Qué:** el bucket "generaciones anteriores" (agregado nacional único, sin cruce territorial) se reemplazó por una dimensión `cohorte` (`actual`/`anterior`/`todas`) cruzada por el mismo árbol territorial que la cohorte actual, usando el RBD de egreso histórico ya presente en `ArchivoB` (`rbd`).
- **Hallazgo que reencuadró el encargo (no se asumió, se investigó):** el RBD histórico no requería insumo nuevo — ya estaba disponible. La variable real que define la cohorte es la recencia de egreso (`anyo_egreso`), no la vigencia del RBD: "actual" = egresó el año inmediatamente anterior al proceso; "anterior" = egresó 2+ años antes. `(id_aux, anio_proceso)` es 1:1 con `rbd` y `anyo_egreso` (0 duplicados relevantes; solo 254/985.379 personas con 2 RBD entre años, resoluble).
- **Por qué (C.11):** el titular pidió explícitamente el cruce por RBD real ("cada estudiante pertenece a un rbd, del cual salió egresado").
- **Cómo se verificó (B.4, panel adversarial obligatorio):** recálculo independiente desde parquets crudos (no desde las funciones de `32`) para nacional/región/SLEP/4 comunas, inscripción y selección 2025, actual/anterior/todas — 21+6 celdas, todas MATCH. Aditividad territorial (comuna→región→nacional) confirmada aritméticamente y post-supresión. Medias de rendimiento (CLEC, región 5) verificadas con media ponderada — señal real detectada: la cohorte anterior puntúa más alto que la actual (repitentes).
- **Verificación en navegador:** las 4 combinaciones (Cob/Ren × Por-territorio/Comparar) responden a los 3 estados del toggle con cifras idénticas al panel adversarial. `genAntSlab`/`REZ_ID`/`showRez` retirados sin dejar código muerto.
- **Fix de consistencia asociado:** `CobComp` (tabla comparativa) rebasa a inscritos=100% cuando no hay egresados propios de la cohorte (mismo patrón que `CobActual` ya usaba), evitando que "Anteriores" mostrara todo como "resguardo" (falso).
- **Aclaración declarada (B.1):** el comportamiento por defecto pre-encargo (mostrar todas las cohortes mezcladas) corresponde semánticamente al nuevo estado "Todas", no a "Actual". Se mantuvo "Actual" como default del control según lo pedido; el titular puede preferir "Todas" por defecto — señalado, no resuelto.
- **Commits:** `250d2fa` (pipeline), `92039e4` (interfaz) (log: `20260702_cohorte_territorial_log.md`).

### Cambio 6 — Ajustes de interfaz v2
- **Archivos:** `30_procesamiento/33_motor_template.html`, `50_documentacion/suite/documentar.R`, 4 `*_standalone.html`, `docs/index.html`.
- **Categoría:** interfaz + rename transversal.
- **Qué:** 4 fases — (1) retiro del chip "Territorio en pantalla" redundante; (2) rename "con desglose por comuna:" → "Desglose por comuna" + filtro interactivo (exacto para Región, informativo para SLEP, decisión de alcance declarada: SLEP es subconjunto transversal de establecimientos, no partición de comunas); (3) extensión del control de cohorte a vista histórica; (4) nueva serie histórica "Seleccionado en 1.ª preferencia (% de egresados)", derivada de `n_prioridad_1/egresados` (no `pct_prioridad_1`, que divide por seleccionados) para mantener el mismo denominador que las otras series del gráfico.
- **Por qué:** solicitud explícita del titular sobre 3 capturas de referencia.
- **Cómo se verificó (B.4):** Fase 2 — recompute exacto en Región Valparaíso (excluir Algarrobo: egresados 28.519→28.296, inscritos 21.826→21.655, coincide con recálculo manual). Fase 4 — 2 spot-checks contra parquet (SLEP CC [15,13,14,hueco]%, Nacional [24,26,26]%); 2026 sin egresados muestra hueco, no cero falso.
- **Rename transversal:** "generaciones anteriores" → "cohortes anteriores"/"cohorte" en todo el texto visible del motor y la suite (grep=0 confirmado sobre outputs regenerados, no solo sobre el código fuente).
- **Commits:** `c0133a0`, `18b2dbe`, `ecd38ba`, `4baf854`, `81c8929` (rename) (log: `20260702_ajustes_interfaz_v2_log.md`).

### Cambio 7 — Rótulo "1.ª prioridad" + detención de conteo invierno/regular
- **Archivos:** `30_procesamiento/33_motor_template.html`, `docs/index.html`.
- **Categoría:** interfaz + detención real (pipeline).
- **Qué:** (1) rename "Prioridad 1" → "1.ª prioridad" en texto visible (identificadores de código intactos); (2) marca visual inicial (borde + flecha) para señalar cambio de base de la columna — **rechazada por el titular** ("2/10", ver Cambio 8); (3) verificación del criterio de conteo invierno/regular, que gatilló una detención real.
- **Detención (a) gatillada:** `convocatoria_archivo` es inerte (siempre "REGULAR" en los 3 archivos, todos los años); el invierno/regular real vive en `tipo_rendicion` de `ArchivoC`. `etapa_rendicion`/`etapa_resultados` en `32` hacen `distinct(id_aux, rbd, anio_proceso)` sin `tipo_rendicion`, colapsando personas que rinden ambas convocatorias el mismo año (~19-22k/año, cifra verificada). No se implementó cambio de cálculo ni se agregó una nota que hubiera sido falsa para el caso intra-año.
- **Decisión pendiente del titular:** documentar como "personas únicas por año" (cambio de texto) vs. cambiar a conteo de participaciones (cambio de cifras, requiere autorización).
- **Commits:** `363d55a`, `1d22d44` (log: `20260702_rotulo_p1_convocatoria_log.md`).

### Cambio 8 — "Universo de seleccionados" (handoff Claude Design)
- **Archivos:** `30_procesamiento/33_motor_template.html`, `docs/index.html`.
- **Categoría:** interfaz (iteración de diseño).
- **Qué:** reemplazo completo del tratamiento visual del Cambio 7 (rechazado) por el bloque "Universo de seleccionados": banda de grupo (`colSpan=2`), marco exterior (`BRK`), separación interna (`BRK_IN`) + flecha con tooltip, encabezado en color `--plum`, heatmap con rango propio para la columna "1.ª prioridad", según handoff verbatim de Claude Design (`design_handoff_slep_paes_produccion/index.html`, función `CobComp`).
- **Por qué:** el tratamiento anterior fue calificado 2/10 por el titular; se generó un mockup de alta fidelidad en Claude Design como referencia (aprendizaje A19: iteración visual con artefacto de referencia aprobado).
- **Ajuste no cubierto explícitamente por el encargo, detectado por Claude Code:** el caller de `supCell` en `RenComp` (L588 original) usaba la firma vieja de la función; se adaptó preservando su comportamiento (border 1px `var(--line2)`), evitando una regresión no solicitada pero real.
- **Cómo se verificó (B.4):** verificación por computed styles del DOM (no solo captura visual) — banda, marco en los 4 lados, separación interna, color de encabezado, heatmap con rango propio (`rangoP1=[48,61]` independiente del rango del resto del embudo) confirmados. **Verificación independiente del asistente** sobre el archivo real (post-commit): bloque completo coincide byte a byte con el handoff, `RenComp` correctamente migrado, nota al pie con redacción corregida.
- **Commit:** `8a614c3` (log: `20260702_universo_seleccionados_log.md`).

### Cambio 9 — Fix: cohorte "Todas" sobre 100%
- **Archivos:** `30_procesamiento/33_motor_template.html`, `docs/index.html`.
- **Categoría:** bug de código (interfaz, sin cambio de datos subyacentes).
- **Qué:** en cohorte "Todas", el denominador (`egresados`, solo cohorte actual) quedaba desalineado con el numerador (suma actual+anterior de cada etapa), produciendo porcentajes >100% (ej. Viña del Mar 118%, 5.203/4.418). Fix: rebasar a `inscripcion` como denominador cuando `coh!=="actual"`, con un helper compartido `baseCob()`.
- **Por qué (causa raíz, C.11):** `baseN()`/`baseY()` en `CobComp`/`CobHist`/`funnelStages` (`CobActual`) usaban `egresados` como denominador válido para "todas" sin verificar que el numerador ya sumaba ambas cohortes.
- **Alcance ampliado, justificado (misma causa raíz):** el bug estaba duplicado en 3 vistas (`CobComp`, `CobActual`, `CobHist`) y en las 3 ramas del export XLSX; corregir solo la vista visible habría dejado el archivo exportado con >100% mientras la pantalla mostraba ≤100% — inconsistencia peor que no arreglar nada.
- **Cómo se verificó (B.4):** spot-check en las 3 vistas + regresión en "Actual"/"Anteriores" (sin cambios, comportamiento intacto); ningún % >100% tras el fix; notas explicativas actualizadas para no contradecir la tabla (mencionan "sobre inscritos" cuando corresponde).
- **Commit:** `175787b` (log: `20260702_fix_base_todas_log.md`).

## 4. Backlog acumulativo

**Nota:** el backlog acumulativo formal vive en `50_documentacion/activa/backlog_acumulativo.md` (extraído desde el segundo cierre, según POLITICA §10). Este traspaso no repite su contenido íntegro; referencia su estado.

- **Total acumulado:** 42 cambios al cierre de v04 + los 9 cambios de esta sesión (§3) = **51 cambios** acumulados, 5 sesiones cerradas.
- **Categorías dominantes de sesión 5:** Pipeline (extensión real, cambio 5), Interfaz (cambios 4, 6, 7, 8, 9), Documentación (cambio 3), Gobernanza/proceso (cambio 2).
- **Acción pendiente:** actualizar `backlog_acumulativo.md` con las entradas de sesión 5 (correlativo global, no reiniciar numeración) — no se realizó dentro de esta sesión: **queda como pendiente de apertura de sesión 6**, primera tarea antes de cualquier otro trabajo (regla POLITICA §10: obligatorio desde la segunda sesión, se actualiza en cada cierre).

## 5. Bugs de la sesión

### Bug 1 — Toggle "generaciones anteriores" no filtraba (heredado, reportado por el titular)
- **Síntoma observable:** clic en el toggle no producía cambio perceptible en el embudo/rendimiento.
- **Causa raíz:** `genAntSlab()` se montaba siempre en el DOM; `showRez` solo controlaba opacidad (1↔0.55), nunca retiraba el bloque. El bloque, además, era un agregado nacional aparte, no un filtro sobre los datos del territorio mostrado.
- **Solución exacta:** superada en dos etapas. Fix inicial (Cambio 4, commit `4c063e9`): montaje condicional del bloque. Fix real (Cambio 5): rediseño completo — la cohorte pasó a cruzarse por RBD histórico en el árbol territorial, con toggle de 3 estados que sí filtra el embudo real.
- **Criterio de verificación:** las 4 combinaciones responden con cifras distintas y correctas al alternar Actual/Anteriores/Todas, verificado con panel adversarial.
- **Patrón general aprendido:** un fix de "presencia en el DOM" no es lo mismo que un fix de "el dato está filtrado correctamente" — verificar siempre contra el dato subyacente, no solo contra el comportamiento visual del toggle.
- **Principios aplicados:** C.11 (causa raíz antes de corregir), B.4 (criterio de éxito verificable).
- **Estado:** resuelto (Cambio 5).

### Bug 2 — Porcentajes >100% en cohorte "Todas"
- **Síntoma observable:** capturas del titular mostrando 118%, 131% en columnas del embudo bajo cohorte "Todas".
- **Causa raíz:** denominador (`egresados`, solo cohorte actual) desalineado con numerador (suma actual+anterior) en 3 vistas + export.
- **Solución exacta:** helper `baseCob()` compartido, rebasa a `inscripcion` cuando `coh!=="actual"`. Archivo: `33_motor_template.html`, commit `175787b`.
- **Criterio de verificación:** ningún % >100% en ninguna combinación tras el fix; regresión verificada en "Actual"/"Anteriores".
- **Patrón general aprendido:** al introducir una dimensión nueva que cambia la semántica de un agregado (cohorte "todas" = suma), **todo** cálculo derivado que asumía un denominador de una sola cohorte debe re-auditarse explícitamente, no solo el punto donde se reportó el síntoma.
- **Principios aplicados:** C.11, B.4.
- **Estado:** resuelto.

## 6. Aprendizajes y restricciones descubiertas

- **La cohorte es recencia de egreso, no vigencia de RBD** (C.11, contexto: encargo Cambio 5). Si se asume lo contrario, se rediseña el pipeline sin necesidad — el dato ya existía. Regla: antes de asumir que falta un insumo, verificar contra el schema real con una consulta directa, no contra la intuición del nombre de columna.
- **Un SLEP no es la unión de sus comunas** (contexto: Cambio 6, Fase 2). Es un subconjunto transversal de establecimientos. Un filtro de exclusión que suma/resta comunas solo es matemáticamente válido para Región (partición real), nunca para SLEP. Regla: antes de implementar un filtro de "incluir/excluir" sobre una jerarquía territorial, confirmar que el nivel superior es efectivamente una partición del nivel inferior.
- **Cambiar el denominador de un cálculo exige re-auditar todos los consumidores del mismo dato, no solo el punto reportado** (contexto: Bug 2). Aplica cada vez que se introduce una dimensión nueva (cohorte, período, etc.) sobre un pipeline ya maduro.
- **Un fix que solo cambia comportamiento visual (montaje/opacidad) no es lo mismo que un fix que corrige el dato subyacente** (contexto: Bug 1). Regla: cuando un titular reporta "no funciona", diagnosticar primero si el problema es de renderizado o de cálculo, antes de proponer un fix.
- **El propio comentario del código puede revelar que un "bug" es diseño intencional** (contexto: detención Cambio 7). El comentario "rindió al menos una prueba" en `32` sugiere que contar personas únicas fue decisión de diseño, no descuido. Regla: antes de calificar algo como bug, leer los comentarios existentes que documenten la intención original.

## 7. Decisiones de diseño

### Decisión 1 — Cohorte cruzada por RBD histórico (no bucket nacional aparte)
- **Alternativas consideradas:** mantener el bucket nacional único (statu quo); cruzar por RBD histórico en todo el árbol territorial (elegida).
- **Justificación:** el titular pidió explícitamente el cruce territorial real; el dato ya estaba disponible sin insumo nuevo.
- **Tensión resuelta:** fidelidad al alcance original del pipeline (Camino A, decisión de sesión 3) vs. necesidad real de un filtro territorial funcional. Se extendió el pipeline (cambio de alcance autorizado explícitamente por el titular en esta sesión) sin violar los invariantes de gobernanza ya establecidos.
- **Implicancia:** `32` gana una dimensión `cohorte`; el bucket `REZ_ID` queda deprecado y retirado.
- **Registrado como decisión formal:** pendiente crear `50_documentacion/activa/decisiones/20260703_decision_cohorte_territorial_rbd_historico.md` (no se generó dentro de esta sesión — **pendiente de sesión 6**, dado el peso arquitectónico del cambio, POLITICA §2.2.8).

### Decisión 2 — Filtro de comuna solo exacto para Región, informativo para SLEP
- **Alternativas:** extender `32` para producir agregados SLEP×comuna (fuera de alcance de un encargo de interfaz); limitar el filtro interactivo a Región y dejar SLEP display-only (elegida).
- **Justificación:** matemáticamente correcta (SLEP no particiona en comunas); evita implementar un filtro que produciría cifras incorrectas.
- **Implicancia:** si se quiere filtro interactivo también en SLEP, requiere un encargo de pipeline nuevo (`32`), no de interfaz.

### Decisión 3 — "Actual" como cohorte por defecto (no "Todas")
- **Alternativas:** "Actual" por defecto (comportamiento nuevo, generación fresca ~68% del universo previo); "Todas" por defecto (reproduce las cifras que el motor mostraba antes de esta sesión).
- **Decisión tomada:** "Actual" (según especificación literal del encargo original).
- **Aclaración declarada, no resuelta:** el comportamiento visual previo a esta sesión corresponde semánticamente a "Todas", no a "Actual" — el titular puede preferir cambiar el default. **Queda como pendiente de decisión explícita en sesión 6** (no se tocó sin autorización, POLITICA 0.3).

### Decisión 4 — Rediseño visual completo en vez de iterar sobre el tratamiento rechazado
- **Alternativas:** iterar el borde+flecha original vía CSS a ciegas; generar un mockup de alta fidelidad en Claude Design y usarlo como referencia exacta (elegida).
- **Justificación:** el titular calificó el primer intento 2/10; iterar a ciegas sobre algo ya rechazado tiene alto riesgo de repetir el mismo error. Un artefacto de referencia aprobado permite implementación de alta fidelidad (aprendizaje A19).
- **Implicancia:** el segundo tratamiento fue aceptado sin objeciones visuales.

## 8. Constantes y parámetros vigentes

| Constante | Valor | Archivo | Nota |
|---|---|---|---|
| `UMBRAL_SUPRESION_CELDA` | 8 | `32_agregar_territorial.R` | Sin cambio, aplicado igual a los 3 cohortes. |
| Cohorte "actual" | `anyo_egreso == anio_proceso - 1` | `32_agregar_territorial.R` | Nuevo esta sesión. |
| Cohorte "anterior" | `anyo_egreso <= anio_proceso - 2` (o NA) | `32_agregar_territorial.R` | Nuevo esta sesión. |
| `BRK` (marco exterior universo seleccionados) | `1.5px solid rgba(21,62,94,.42)` | `33_motor_template.html` | Nuevo esta sesión (handoff Claude Design). |
| `BRK_IN` (separación interna) | `1px solid var(--line2)` | `33_motor_template.html` | Nuevo esta sesión. |
| Cap de selección múltiple (Comparar territorios) | 10 | `33_motor_template.html` | Sin cambio (ya existía, reusado en el nuevo selector). |
| `--fs-*` (escala tipográfica) | piso 12px, 7 niveles | `33_motor_template.html` | Sin cambio (sesión 4). |

## 9. Arquitectura de archivos

Referencia: `estructura_actual.md`, snapshot `2026-07-03 07:31:55`, 19 carpetas / 91 archivos (crecimiento de 63→91 archivos respecto a sesión 4, principalmente por la suite `suitedoc` y los logs/encargos de andamios).

**Cambios de estructura:**
- Nuevo `50_documentacion/suite/` (documentación `suitedoc`, standalone).
- `50_documentacion/andamios/logs/` ganó 7 logs nuevos (uno por encargo).
- `50_documentacion/andamios/` ganó 4 archivos de encargo (`encargo_*.md`) — **quedan ahí como registro de instrucciones ejecutadas**, consistente con el uso que el titular decidió darles (dejar los encargos como andamios, no como archivos efímeros).
- `50_documentacion/activa/ESTADO.md` apareció en el escáner (954 bytes) — **no generado por esta sesión**; su origen no está documentado en el historial de este chat. Verificar en sesión 6 si corresponde al estándar Fase 2 (SETTINGS §2.1bis) y si su contenido está sincronizado con este traspaso.
- Sin desviaciones nuevas respecto a la política (decenas, naming, ubicación).

## 10. Pendientes y ruta sugerida

### Inventario

1. **Push de 13+ commits locales de esta sesión.** Contexto: suite `suitedoc` + 7 encargos de motor/pipeline, todos verificados (paneles adversariales, DOM, grep). Tipo: publicación (gate del titular). Impacto: ninguno de los cambios de esta sesión está en GitHub Pages. Complejidad: baja (mecánica). Principios: POLITICA 0.3. Precaución: requiere que la revisión visual (pendiente 4) y la auditoría de datos (pendiente 5) se completen primero, según lo acordado con el titular al cierre de esta sesión. Criterio de éxito: `git push`, verificación en GitHub Pages.

2. **`egresados_em` 2026 ausente.** Bloqueante externo, sin acción disponible hasta que el dato exista. Tipo: bloqueante. Impacto: el año 2026 queda con hueco en egresados (ya manejado correctamente por el fix del Cambio 9 — no un bug, un hueco real de dato).

3. **Portabilidad cross-OS (Windows + macOS).** Contexto: `slep_paes` ya implementa el patrón de dos raíces (`SLEP_PAES_DATA_ROOT`), configurado solo en la Mac actual del titular. Es Caso C de `prompt_portabilidad_cross_os.md` (setup de máquina nueva), no Caso B. Riesgo específico: NBSP en rutas OneDrive, redirección de `HOME` en Windows corporativo. Tipo: funcionalidad / configuración. Complejidad: baja-media (checklist ya existe). Precaución: requiere pasos manuales del titular frente al computador de trabajo (no delegable a Claude Code de forma autónoma). Criterio de éxito: `obtener_data_root_proyecto()` resuelve en ambas máquinas, pipeline corre end-to-end en Windows.

4. **Revisión visual completa del motor.** Contexto: 7 encargos ejecutados sobre la interfaz en una sola sesión; el titular quiere confirmar el render real antes de autorizar push. Tipo: verificación / gate del titular. Complejidad: baja. Criterio de éxito: el titular confirma visualmente cada combinación relevante (Foco×Vista×Período×Cohorte) sin objeciones.

5. **Auditoría de datos exhaustiva de todos los indicadores.** Contexto: acordada explícitamente por el titular al cierre de esta sesión, como complemento a la revisión visual, antes de autorizar push. Alcance: recálculo independiente desde parquets crudos (no reusar los checks ya hechos por los 7 encargos) para embudo de cobertura, rendimiento, KPI de 1.ª prioridad, serie histórica nueva, desglose filtrable, supresión — cruzado por las 3 cohortes, 2 vistas, 2 períodos. Tipo: verificación de riesgo de datos. Complejidad: alta (requiere panel adversarial nuevo, no repetir el ya hecho por cada encargo individual). Principios: mandato de auto-auditoría reforzado (riesgo de datos real, múltiples cambios acumulados sin una verificación transversal única). Precaución: el plan ya fue presentado al titular (4 fases: recálculo independiente, aditividad territorial, verificación de ningún % >100% en ningún indicador, verificación en navegador de combinaciones críticas) — **falta redactar el encargo formal y ejecutarlo**, quedó interrumpido por la solicitud de cierre de sesión. Criterio de éxito: cada indicador publicado verificado por al menos 2 caminos independientes, sin discrepancias.

6. **Decisión pendiente: conteo invierno/regular en rendición/resultados.** Contexto: detención real (Cambio 7). Tipo: decisión metodológica (gate estratégico, cambia cifras publicadas si se opta por participaciones). Impacto: ~19-22k personas/año en la etapa "Rindió"/"Válidos" si se cambia a conteo de participaciones. Complejidad: media (cambio de una línea de código si se decide, pero cambia cifras ya publicadas). Precaución: NO implementar sin autorización explícita del titular, dado que altera cifras. Criterio de éxito: decisión documentada como decisión formal (`50_documentacion/activa/decisiones/`), implementada si corresponde.

7. **Decisión pendiente: cohorte por defecto ("Actual" vs. "Todas").** Ver Decisión 3 (§7). Tipo: decisión de producto. Complejidad: baja (cambio de un valor default) pero requiere decisión explícita porque cambia lo que ve cualquier usuario nuevo del motor.

8. **Backlog acumulativo sin actualizar.** Ver §4. Tipo: documentación, obligatoria según POLITICA §10. Complejidad: baja (mecánica, consolidar los 9 cambios de esta sesión con numeración correlativa global).

9. **Decisión formal de arquitectura sin generar (Decisión 1, cohorte por RBD histórico).** Ver §7. Tipo: documentación de peso arquitectónico. Complejidad: baja (redactar el archivo de decisión ya está justificado en este traspaso, falta solo el archivo formal).

10. **`ESTADO.md` de origen no documentado.** Ver §9. Tipo: deuda heredada / verificación. Complejidad: baja. Precaución: confirmar que no quedó desincronizado del traspaso real.

### Evaluación de deuda técnica

- **Zona frágil:** la lógica de "base de cálculo" (`baseCob`/`baseN`/`baseY`) ahora está duplicada conceptualmente en 3 vistas + export, aunque unificada por un helper compartido tras el Cambio 9. Si se agrega una cuarta dimensión de cálculo en el futuro (ej. otra convocatoria), el mismo patrón de "re-auditar todos los consumidores" volverá a aplicar — vigilar.
- **Oportunidad de mejora:** los 7 encargos de esta sesión se ejecutaron secuencialmente sobre el mismo archivo (`33_motor_template.html`, ahora 69.4K, creció de 61.7K en sesión 4). Sin señales de que necesite modularización aún, pero es una tendencia a monitorear en sesiones futuras (principio 5.3.5, modularidad con responsabilidad única).

### Auditoría de cierre (POLITICA 5.6, preguntas "Cierre")

| # | Pregunta | Respuesta |
|---|---|---|
| 5 | ¿Cada transformación crítica tiene check de validación? | Sí — paneles adversariales en los 2 cambios de pipeline (Cambio 5), grep exhaustivo en renames, verificación DOM en cambios de interfaz. |
| 6 | ¿Los outputs son reproducibles e idempotentes? | Sí — `run_all(only=33)` regenera consistentemente; sin cambios en esta sesión que rompan idempotencia. |
| 7 | ¿Decisiones metodológicas como constantes nombradas? | Sí — `UMBRAL_SUPRESION_CELDA`, definiciones de cohorte documentadas como constantes en `32`. |
| 8 | ¿Nombres de archivos y carpetas sin tildes, ñ ni espacios? | Sí, sin desviaciones nuevas. |

**Ningún "no"** en esta auditoría de cierre — no se generan pendientes nuevos por esta vía (los pendientes 1-10 ya cubiertos arriba tienen otro origen).

### Ruta sugerida para la próxima sesión (criterios de 1.2.4)

1. **Bug activo:** ninguno pendiente (Bug 1 y Bug 2 resueltos esta sesión).
2. **Bloqueante:** pendiente 6 (decisión invierno/regular) es el más urgente si afecta interpretación de cifras ya mostradas al equipo del titular.
3. **Instrucciones explícitas del traspaso (⚠️/✅/🔒):** ver §11.
4. **Deuda heredada:** pendiente 10 (`ESTADO.md`).
5. **Deuda técnica acumulada:** ver evaluación arriba (sin acción inmediata requerida).
6. **Alta complejidad al inicio:** pendiente 5 (auditoría de datos) — proponer como Prioridad 1 de sesión 6, tal como ya se acordó con el titular.
7. **Funcionalidad nueva:** ninguna solicitada, no proponer.
8. **Cosmética/documentación al final:** pendientes 8, 9, 10.

**Recomendación:** Prioridad 1 de sesión 6 = completar la auditoría de datos (pendiente 5, plan ya presentado) + revisión visual (pendiente 4) → gate de push (pendiente 1). Prioridad 2 = decisiones pendientes 6 y 7 (ambas requieren al titular, pueden resolverse en paralelo a la auditoría). Prioridad 3 = documentación (8, 9, 10).

## 11. Instrucciones específicas para la próxima sesión

- ⚠️ NO hacer push sin que el titular confirme explícitamente haber revisado visualmente el motor Y sin que la auditoría de datos (pendiente 5) esté completa.
- ⚠️ NO cambiar el conteo de invierno/regular (pendiente 6) sin autorización explícita — altera cifras ya calculadas y potencialmente comunicadas.
- ⚠️ NO cambiar la cohorte por defecto (pendiente 7) sin confirmación explícita del titular.
- ✅ ANTES de generar el encargo de auditoría de datos, releer este traspaso completo (§10, pendiente 5) — el plan de 4 fases ya fue acordado con el titular, no reinventar el alcance.
- ✅ ANTES de asumir el origen de `ESTADO.md` (pendiente 10), verificar si corresponde al estándar SETTINGS §2.1bis o si fue generado fuera de esta cadena de sesiones.
- 🔒 Cohorte "actual"/"anterior" definida por recencia de egreso (`anyo_egreso` vs. `anio_proceso`), no por vigencia de RBD — invariante confirmado con panel adversarial, no reabrir sin nueva evidencia.
- 🔒 Filtro de comuna solo exacto para Región; SLEP permanece display-only salvo nuevo encargo de pipeline.
- 🔒 `UMBRAL_SUPRESION_CELDA=8`, Rasch (nunca "IRT 3PL"), sentence case, sin nombres de establecimiento — sin cambio.

## 12. Fragmentos de código de referencia

**Patrón `baseCob()` (denominador cohorte-consciente, la forma correcta en este proyecto desde el Cambio 9):**

```js
function baseCob(id, anio, coh){
  if(coh==="actual"){
    var eg=covGet(id,anio,"egresados",coh);
    if(eg&&!eg.sup&&eg.n) return eg.n;
  }
  var ins=covGet(id,anio,"inscripcion",coh);
  return (ins&&!ins.sup&&ins.n) ? ins.n : null;
}
```

Cualquier cálculo de porcentaje sobre `COV`/`REN` que dependa de un denominador debe usar este helper, no reimplementar la lógica de "¿hay egresados o rebaso a inscritos?" localmente.

## 13. Reapertura

**Nombre del chat:** `slep_paes, sesión 6 (Claude Sonnet 5)`

**Mensaje de apertura pre-armado:**

Adjunto los documentos de protocolo y los específicos de la sesión. Tipo CONTINUATION. El protocolo (`POLITICA_PROYECTO.md` + `SETTINGS_Y_PROMPTS_OPERACIONALES.md`) vive en la knowledge base del Project y se lee desde ahí.

**Documentos para la próxima sesión:**

1. *Protocolo en knowledge base (NO adjuntar, solo verificar vigencia):* `POLITICA_PROYECTO.md`, `SETTINGS_Y_PROMPTS_OPERACIONALES.md`.
2. *Opcionales según foco real:* `CLAUDE.md` (si la sesión correrá en Claude Code); `encargo_autonomo_claude_code_v1.md` (si se abre nuevo encargo autónomo, altamente probable dado el pendiente 5).
3. *Específicos de la sesión (SÍ adjuntar):* `traspaso_cierre_v05.md` (este documento); `estructura_actual.md` (regenerar al abrir sesión 6, el snapshot de esta sesión quedará desactualizado); `32_agregar_territorial.R` y `33_motor_template.html` actuales (si se va a auditar o modificar código directamente en el chat, no solo vía Claude Code).

**Nota final:** si algún archivo listado cambió entre sesiones (especialmente `32`/`33`, que tuvieron 13+ commits esta sesión), adjuntar la versión más actualizada al abrir y avisarlo en el mensaje de apertura.

## 14. Reapertura (bloque replicado para copiar sin abrir el archivo)

```
slep_paes, sesión 6 (Claude Sonnet 5)

Adjunto los documentos de protocolo y los específicos de la sesión.
Tipo CONTINUATION. El protocolo (POLITICA_PROYECTO.md + SETTINGS_Y_PROMPTS_OPERACIONALES.md)
vive en la knowledge base del Project y se lee desde ahí.

Documentos:
1. Protocolo (knowledge base, no adjuntar): POLITICA_PROYECTO.md, SETTINGS_Y_PROMPTS_OPERACIONALES.md.
2. Opcionales: CLAUDE.md si corre en Claude Code; encargo_autonomo_claude_code_v1.md
   (probable, dado que el pendiente 1 de la sesión es una auditoría de datos vía encargo autónomo).
3. Específicos (sí adjuntar): traspaso_cierre_v05.md; estructura_actual.md (regenerar
   al abrir); 32_agregar_territorial.R y 33_motor_template.html si se auditará código
   directamente en el chat.
```

## 15. Errores del asistente

| Campo | Contenido |
|---|---|
| `momento` | Redacción del encargo autónomo de mejoras de interfaz (Fase 2, selector territorial), y en la instrucción a Claude Code que lo acompañó. |
| `disparador` | Claude Code lo detectó al leer el estado real (Fase 0 del propio encargo); el titular lo trasladó al chat. |
| `que_paso` | El asistente identificó el proyecto fuente del componente selector como `slep_categoria_desempeno` sin verificarlo contra la única referencia que el titular dio (la URL `https://tomgc.github.io/slep_simce_adecuado/`). El nombre incorrecto se arrastró al encargo escrito y a la instrucción operativa enviada a Claude Code. |
| `regla_violada` | SETTINGS §1.2.6 ("no asumir el contenido de un archivo ni su ubicación"); POLITICA B.1 (sin supuestos implícitos). |
| `causa_raiz` | El asistente etiquetó mentalmente el archivo recibido como "ade" (alias usado en sesión 4 para la escala tipográfica) sin volver a la URL explícita del titular para confirmar que el alias correspondía al mismo repositorio; asumió continuidad entre dos temas de sesiones distintas que resultaron ser proyectos diferentes. |
| `salvaguarda_presente` | SETTINGS_Y_PROMPTS_OPERACIONALES.md (§1.2.6); `encargo_autonomo_claude_code_v1.md` §7 (antipatrón de fuente no verificada). |
| `patron` | Variante del patrón "dato no verificado arrastrado a artefacto formal" (comparable en mecanismo al error de v04, pendiente omitido). |

| Campo | Contenido |
|---|---|
| `momento` | Instrucciones a Claude Code durante la Fase 2 del encargo de mejoras de interfaz (previas a la corrección del nombre de proyecto). |
| `disparador` | Usuario lo señaló explícitamente. |
| `que_paso` | Al menos una instrucción operativa dirigida a Claude Code dentro de esta tarea no se presentó con el formato obligatorio "→ Claude Code:" en bloque de código, pese a que `userPreferences` lo marca como no negociable, sin excepciones. |
| `regla_violada` | `userPreferences`, sección "Claude Code messages — format non-negotiable". |
| `causa_raiz` | El formato se aplicó de forma inconsistente entre turnos de una misma tarea multi-paso: la instrucción inicial del encargo completo sí llevó el formato; una instrucción de seguimiento correctiva, más corta, se redactó como prosa directa sin el bloque. |
| `salvaguarda_presente` | `userPreferences` (única fuente de esta regla). |
| `patron` | Nuevo (primera vez que se registra una desviación de esta regla específica en este proyecto). |

| Campo | Contenido |
|---|---|
| `momento` | Al registrar los 2 errores anteriores de esta misma tabla. |
| `disparador` | Usuario lo corrigió ("tiene que ir en el traspaso de la sesion actual no de la anterior"). |
| `que_paso` | El asistente escribió los 2 errores de sesión 5 dentro de `traspaso_cierre_v04.md` §15 (documento de cierre de sesión 4, ya cerrado y con reapertura ya redactada), en vez de un borrador o el futuro `traspaso_cierre_v05.md`. |
| `regla_violada` | POLITICA 0.5 / SETTINGS §2.2.15 (el registro pertenece al traspaso de la sesión en que el error ocurre). |
| `causa_raiz` | `v04.md` era el único traspaso con estructura de tabla de errores ya presente y editable en el sandbox de la sesión; el asistente reusó ese archivo como contenedor disponible sin verificar que semánticamente correspondía a la sesión equivocada. |
| `salvaguarda_presente` | POLITICA 0.5; SETTINGS §2.2.15. |
| `patron` | Distinto de los dos anteriores: error sobre el propio mecanismo de registro de errores, no sobre el trabajo técnico de la sesión. |

**Nota adicional (no tabulada, contexto de esta misma sesión, sin acción correctiva requerida):** en un turno posterior, el usuario pegó contenido ajeno al proyecto (consulta de un dataset externo de fútbol) por error propio ("ignora, error mio"), confirmado por el titular como error suyo, no del asistente — no se registra como error del asistente.
