# Traspaso de cierre — slep_paes — v04

## 1. Identificación

- **Proyecto:** slep_paes
- **Versión:** v04
- **Fecha:** 2026-07-02
- **Sesión 4, foco:** corregir deuda documental (nota Rama A/B), estandarizar escala tipográfica del motor, extender `32`/`33` con KPI de prioridad de carrera (Camino B).
- **Entorno:** Claude (análisis) + Claude Code (ejecución autónoma, `~/Projects/slep_paes`, R-only, macOS).
- **Archivos principales modificados:** `00_escanear_proyecto.R`, `30_procesamiento/33_motor_template.html`, `30_procesamiento/32_agregar_territorial.R`, `30_procesamiento/33_generar_html.R`, `docs/index.html`, `50_documentacion/activa/decisiones/20260702_decision_camino_a_motor_33.md`.

## 2. Resumen ejecutivo

Sesión abrió detectando una discrepancia real entre el escáner (afirmaba Rama A) y `CLAUDE.md`/historial (Rama B vigente desde sesión 1); confirmado con el titular, se corrigió la nota fija en `00_escanear_proyecto.R` (causa raíz: texto residual no actualizado tras la migración). Se replicó la decisión Camino A como archivo independiente en `decisiones/`. A pedido del titular se auditaron los `font-size` del motor (mínimo real 9px) y se comparó contra tres proyectos hermanos (`cat`, `idps`, `ade`), constatando que `ade` ya usa una escala con variables CSS nombradas (piso 12px); se migró `slep_paes` a esa escala (7 variables `--fs-*`) y se entregó al titular una instrucción portable para replicar la migración en `cat`/`idps` (ejecución fuera de esta sesión). Se abrió Camino B (diferido en v03): extensión de `32` con KPI de prioridad de carrera (% seleccionados en 1ª preferencia, sobre universo de seleccionados), con hallazgo no trivial en Fase 0 (columna real `orden_pref`, regla de precedencia `estado_pref==24` único vs. `26` siempre posterior) verificado con panel adversarial (11/11 match). Se extendió `33` para mostrar el KPI en Cobertura·Actual (card) y Cobertura·Comparar (columna), con supresión verificada. De paso se corrigió un bug pre-existente (medias sin redondear en `RenHist`). Push NO ejecutado (pendiente de visto bueno del titular sobre el conjunto de la sesión). Queda pendiente: `egresados_em` 2026 (bloqueante externo, sin cambios), migración tipográfica de `cat`/`idps` (delegada al titular).

## 3. Estado al cierre

**Qué funciona (última ejecución exitosa: 2026-07-02, `run_all()` completo):**
- Escáner corregido: nota de arquitectura refleja Rama B correctamente (verificado en `estructura_actual.md` de esta sesión, línea 6).
- Motor `33`: escala tipográfica con variables CSS (`--fs-overline` 12px … `--fs-h2` 28px), 0 `fontSize` numéricos sueltos, 6 combinaciones Foco×Vista×Período sin error de consola.
- `32`: KPI de prioridad de carrera (`n_seleccionados`, `n_prioridad_1`, `pct_prioridad_1`) en `paes_cobertura_territorial.parquet`, solo en `etapa=="seleccion"`, supresión respetada (38/38 filas suprimidas con las 3 columnas en NA).
- `33`: KPI renderizado en Cobertura·Actual (card) y Cobertura·Comparar (columna "Prioridad 1"), verificado contra parquet (SLEP Costa Central: 57% n=204; Viña del Mar: 57% n=1.631), supresión visual consistente (comuna 6308 Placilla).
- Bug `RenHist` corregido: medias ahora redondeadas (`Math.round`), 4/4 roces tick/rótulo resueltos.

**Qué no funciona / queda pendiente:**
- `egresados_em` 2026: sigue sin existir como insumo (heredado v01-v03).
- Migración tipográfica de `cat`/`idps`: instrucción entregada al titular, ejecución pendiente en sesiones de esos proyectos.

**Delta respecto a v03:** v03 cerró con el motor Camino A publicado y sin Camino B. v04 cierra con: (a) deuda documental de arquitectura corregida, (b) escala tipográfica estandarizada, (c) Camino B implementado y verificado end-to-end (pipeline + motor).

## 4. Registro detallado de cambios

**Cambio 1 — Corrección de nota de arquitectura en el escáner (Rama A→B).**
- Archivo: `00_escanear_proyecto.R`.
- Categoría: Documentación / deuda técnica.
- Qué se hizo: la nota fija del escáner afirmaba "todos los datos son públicos... se versionan en el repo" (Rama A), contradiciendo la migración a Rama B de sesión 1. Corregida en 3 puntos (comentario, salida `.txt`, salida `.md`) a texto factual de Rama B, verificado contra el árbol real (`20_insumos/`/`40_salidas/` solo con `README.md`).
- Por qué (C.11): residuo no actualizado tras la migración A→B de sesión 1 (o copiado de un hermano en Rama A al hacer scaffold inicial).
- Cómo se verificó (B.4): regeneración del snapshot, `grep -n "Nota"` confirmando el texto corregido en ambos formatos, sin mojibake.
- Decisión técnica: texto en ASCII deliberado (evita el mismo trap de `enc2utf8()` bajo locale C del Bug 3 de v03).
- Commit: `6f8cad9`.

**Cambio 2 — Réplica de la decisión Camino A como archivo.**
- Archivo: `50_documentacion/activa/decisiones/20260702_decision_camino_a_motor_33.md`.
- Categoría: Documentación.
- Qué se hizo: extraído el contenido de §8 del traspaso v03 a archivo independiente, según exige Política §10 para decisiones de peso arquitectónico.
- Cómo se verificó: presente en el escáner de esta sesión.

**Cambio 3 — Auditoría de fuentes tipográficas (4 proyectos) y migración de `slep_paes`.**
- Archivo: `30_procesamiento/33_motor_template.html`.
- Categoría: Pipeline (implementación) / patrón de familia.
- Qué se hizo: inventario de 82 usos de `fontSize` en `slep_paes` (mínimo 9px, sin variables nombradas). Comparación contra `cat` (`--fs-*`, piso 10px), `idps` (`--fs-*`, piso 11px) y `ade` (`--fs-*`, piso 12px, 7 niveles). Se adoptó la escala de `ade` como estándar nuevo de familia. Migración de los 83 `fontSize` de `slep_paes` a `var(--fs-XXX)`, mapeados por rol (no por rango numérico ciego); un override documentado (cardTitle 15px → `--fs-h4`, no `--fs-body-lg`, por función de card-title).
- Por qué: pedido explícito del titular ("hay fuentes muy pequeñas"); extendido a estandarización de familia a pedido del titular.
- Cómo se verificó (B.4): 0 `fontSize` numéricos restantes; sintaxis JS limpia; `run_all(only=33)` sin abortar; verificación visual de las 6 combinaciones (chips, tablas comparativas y gráficos compactos con foco especial, mayor riesgo de roce); 0 errores de consola.
- Efecto colateral menor: 5 roces tick/rótulo detectados en gráficos de línea compactos (piso 12px acorta el margen); documentado, no bloqueante.
- Commit: `0d7977f`.

**Cambio 4 — Instrucción portable de migración tipográfica para `cat`/`idps`.**
- Archivo: ninguno (entregado como texto al titular, para llevar a las sesiones de esos proyectos).
- Categoría: Patrón de familia / documentación.
- Qué se hizo: redactada una instrucción genérica (mismo patrón que Cambio 3, aplicable a cualquier proyecto de la familia) para que el titular la ejecute en `cat` e `idps` en sesiones aparte.
- Por qué: evita mezclar cambios en repos ajenos a `slep_paes` dentro de esta sesión (B.3, gestión de alcance).

**Cambio 5 — Bug pre-existente: medias sin redondear en `RenHist`.**
- Archivo: `30_procesamiento/33_motor_template.html`.
- Ver sección 6 (Bugs de la sesión).
- Commit: `a90f2cc`.

**Cambio 6 — Camino B: KPI de prioridad de carrera en `32`.**
- Archivo: `30_procesamiento/32_agregar_territorial.R`.
- Categoría: Pipeline (extensión de alcance, gate del titular).
- Qué se hizo: 3 preguntas bloqueantes resueltas con el titular (definición del KPI = % seleccionados con `prioridad==1`; universo = solo seleccionados `estado_pref` 24/26; nivel territorial = igual al resto). Fase 0 de Claude Code encontró que la columna real es `orden_pref` (no "PREFERENCIA" como se especuló en el encargo) y descubrió una regla de precedencia no trivial: toda persona seleccionada tiene exactamente una fila `estado_pref==24` (0 huérfanos, 0 duplicados sobre 610.871 personas-año); cuando también existe `estado_pref==26`, su `orden_pref` es siempre ≥ el de la fila 24 (confirma que 24 = colocación activa real, 26 = marca posterior de menor prioridad). La prioridad real se toma exclusivamente de la fila `estado_pref==24`.
- Por qué (C.11): usar `26` habría atribuido prioridades incorrectas (más bajas); la regla se verificó empíricamente antes de codificar, no se asumió.
- Cómo se verificó (B.4): 3 columnas nuevas (`n_seleccionados`, `n_prioridad_1`, `pct_prioridad_1`) pobladas solo en `etapa=="seleccion"`; denominador reusado de `etapa_seleccion` (consistencia por construcción); supresión aplicada (38/38 filas suprimidas con las 3 columnas en NA); panel adversarial con recálculo independiente desde parquets crudos: 11/11 combinaciones territorio-año match (2 comunas, 1 SLEP, 1 región×2 años, nacional×4 años), incluida verificación de celdas suprimidas.
- Commit: `919c286`.

**Cambio 7 — Camino B: KPI de prioridad de carrera renderizado en `33`.**
- Archivos: `30_procesamiento/33_generar_html.R`, `30_procesamiento/33_motor_template.html`, `docs/index.html`.
- Categoría: Pipeline (implementación).
- Qué se hizo: 2 preguntas resueltas con el titular (ubicación = ambas vistas, Actual y Comparar; formato = "% (n)"). Fase 0 confirmó que el `select()` de `cob_f` excluía las 3 columnas nuevas de `32` (corregido). Card nueva en Cobertura·Actual (`prioridadKpiCard()`); columna nueva "Prioridad 1" en Cobertura·Comparar (heatmap propio). Supresión: ambas vistas reusan el mismo flag `suprimida` de la fila `etapa=="seleccion"` (no se inventó umbral aparte). Confirmado que Rendimiento no muestra el KPI (`hasPrioridad: false`, sin fuga de alcance).
- Cómo se verificó (B.4): spot-check visual/numérico contra el parquet (Costa Central: "57% (n=204)"; Viña del Mar: "57% (1.631)"); caso suprimido (comuna 6308 Placilla, n crudo=5): "sin dato (resguardo estadístico)" en ambas vistas, mismo estilo que el resto de la app; 0 errores de consola.
- Commit: `2d61ed2` (nota: el mensaje del commit perdió la palabra "sup" por interpretación de backticks del shell; cosmético, diff intacto, no se hizo amend).

## 5. Backlog acumulativo

Ver `50_documentacion/activa/backlog_acumulativo.md` (a actualizar por la próxima sesión con el contenido íntegro de v03 más lo siguiente).

**Clasificación temática — delta v04:**

| Categoría | Cambios de esta sesión |
|---|---|
| Documentación / deuda técnica | Corrección nota Rama A/B, réplica decisión Camino A |
| Patrón de familia | Auditoría tipográfica 4 proyectos, migración slep_paes, instrucción portable cat/idps |
| Pipeline (implementación) | Fix RenHist, KPI prioridad en 32, KPI prioridad en 33 |
| Gobernanza de datos | Verificación de supresión en KPI nuevo (dos ejes: pipeline y motor) |

**Detalle cronológico (continuación desde 31):**

32. Corrección de nota Rama A→B en `00_escanear_proyecto.R` (deuda documental detectada en apertura de sesión).
33. Réplica de la decisión Camino A como archivo independiente en `decisiones/`.
34. Auditoría de fuentes tipográficas del motor (pedido del titular): mínimo real 9px, sin variables nombradas.
35. Comparación de escalas tipográficas entre 4 proyectos hermanos (`cat`, `idps`, `ade`, `slep_paes`); adopción de la escala de `ade` (piso 12px) como estándar de familia.
36. Migración de `slep_paes` a variables CSS `--fs-*` (83 usos migrados, 1 override por rol documentado).
37. Instrucción portable entregada al titular para migrar `cat`/`idps` a la misma escala (ejecución fuera de esta sesión).
38. Fix de bug pre-existente: medias sin redondear en `RenHist` (rótulos con decimales crudos), causa raíz en `lineChart()` compartida con `CobHist`.
39. Apertura de Camino B: 3 decisiones de gate con el titular (definición de KPI, universo, nivel territorial).
40. Implementación de KPI de prioridad de carrera en `32` (Fase 0 con hallazgo no trivial: `orden_pref`, regla de precedencia `estado_pref` 24 vs. 26). Panel adversarial 11/11 match.
41. 2 decisiones de gate con el titular para la UI del KPI (ubicación, formato).
42. Implementación del KPI en `33` (card + columna de tabla), verificado con spot-check y caso de supresión.

**Delta del backlog:** 11 entradas nuevas (32-42). Sin refinamientos de taxonomía ni reclasificaciones.

## 6. Bugs de la sesión

**Bug 1 — Nota de arquitectura desactualizada en el escáner (Rama A residual tras migración a Rama B).**
- Síntoma: `estructura_actual.md` afirmaba "todos los datos son públicos... se versionan en el repo", contradiciendo `CLAUDE.md` y el historial real (migración a Rama B en sesión 1).
- Causa raíz: texto fijo en `00_escanear_proyecto.R` no actualizado tras la migración de arquitectura, o residuo de scaffold copiado de un hermano en Rama A.
- Solución exacta: reemplazo del texto fijo en 3 puntos (comentario, salida `.txt`, salida `.md`) por nota factual de Rama B, verificada contra el árbol real.
- Criterio de verificación: regeneración del snapshot, nota corregida presente sin mojibake.
- Patrón general aprendido: al migrar la arquitectura de un proyecto (Rama A↔B), auditar también los textos fijos/plantillas de scripts de infraestructura (escáner, generadores), no solo el código funcional del pipeline.
- Principios: POLITICA 0.2 (no deducir estructura; el escáner es la fuente de verdad y debe ser correcto).
- Estado: resuelto.

**Bug 2 — `RenHist` (small multiples de rendimiento histórico) no redondeaba `media`.**
- Síntoma: rótulos de dato con decimales crudos ("582.2849" en vez de "582"), agravado por el piso tipográfico de 12px (Cambio 3), generando roces con ticks de eje.
- Causa raíz: `lineChart()` (función compartida por `CobHist` y `RenHist`) empujaba el valor de la serie sin redondear al texto del rótulo (línea 349, `v+(unit||"")`). Invisible en `CobHist` porque sus series (`pctSerie`) ya llegan como enteros vía `Math.round()`; `RenHist` pasa `media` cruda del parquet sin ese paso previo.
- Solución exacta: `Math.round(v)+(unit||"")` en el punto de renderizado del rótulo.
- Criterio de verificación: extracción del `textContent` real de los nodos `<text>` del SVG tras regenerar (["390","368","371","393"], coincide con redondeo esperado incluyendo el caso 392.73→393); re-chequeo del detector de colisión: 4/4 roces de `RenHist` desaparecidos.
- Patrón general aprendido: cuando dos vistas comparten una función de render (`lineChart` para `CobHist`/`RenHist`), verificar que el pre-procesamiento (redondeo, formato) sea uniforme entre las series que la alimentan, no asumir que un formato correcto en una vista se traslada a la otra.
- Principios: C.8 (validación de integridad).
- Estado: resuelto.

## 7. Aprendizajes y restricciones descubiertas

- **Regla:** al migrar la arquitectura de datos de un proyecto (Rama A↔B), verificar y actualizar también los textos fijos de scripts de infraestructura (escáner, generadores de reportes), no solo la lógica del pipeline. Principio relacionado: POLITICA 0.2. Contexto: un texto desactualizado en el escáner socava su función como fuente de verdad para futuras sesiones.
- **Regla:** al mapear valores numéricos a una escala/variable nombrada, priorizar el rol funcional del elemento sobre el rango numérico en que cae el valor original. Principio relacionado: B.1 (sin supuestos implícitos), C.10 (constantes nombradas). Ejemplo de la sesión: `cardTitle` (15px) mapeó a `--fs-h4` (18px), no a `--fs-body-lg` (su rango numérico "natural"), porque funcionalmente es un título de card.
- **Regla:** cuando dos vistas comparten una función de render, el pre-procesamiento de los datos que la alimentan debe verificarse para cada vista por separado; un formato correcto en una serie no garantiza que otra serie que pasa por la misma función también lo tenga. Principio relacionado: C.8. Ejemplo: `pctSerie` (redondeado en origen) ocultó que `lineChart()` no redondeaba, hasta que `media` (sin redondear en origen) lo expuso.
- **Regla:** ante un contrato de columna incierto (ej. "columna de prioridad", nombre no confirmado), la Fase 0 debe verificar tanto el nombre real como las reglas de negocio no documentadas que afectan la interpretación correcta del dato (ej. precedencia entre `estado_pref` 24 y 26), no solo la existencia de la columna. Principio relacionado: B.1. Ejemplo: la regla de precedencia (26 siempre posterior a 24) no estaba en ninguna glosa; se infirió empíricamente y se verificó con 0 excepciones antes de usarla.

## 8. Decisiones de diseño

**Decisión: adoptar la escala tipográfica de `slep_categoria_desempeno` (ade) como estándar de familia.**
- Alternativas consideradas: escala de `cat` (piso 10px, 8 niveles); escala de `idps` (piso 11px, 7 niveles); escala de `ade` (piso 12px, 7 niveles); definir una escala nueva no basada en ningún hermano existente.
- Justificación: `ade` es el hermano más reciente, ya usa variables CSS nombradas, y tiene el piso más alto (mejor legibilidad) de los tres. Adoptar un patrón ya vigente en la familia es preferible a inventar uno nuevo.
- Tensión resuelta: ninguna divergencia real entre gobernanza/pipeline; decisión puramente de patrón visual de familia.
- Implicancia: `slep_paes` migrado en esta sesión; `cat`/`idps` quedan con instrucción entregada, pendiente de ejecución por el titular en sus propias sesiones.

**Decisión: KPI de prioridad de carrera = % seleccionados con `orden_pref==1`, sobre universo de seleccionados (`estado_pref` 24/26), mismo nivel territorial que el resto.**
- Alternativas consideradas para la definición: (a) % seleccionados en 1ª preferencia; (b) distribución de selección por rango de prioridad (1ª, 2ª-3ª, 4ª+); (c) otro. Para el universo: (a) solo seleccionados; (b) todos los postulantes con preferencia registrada; (c) ambos como métricas separadas.
- Justificación: el titular eligió la definición más simple y directamente interpretable (a/a), evitando la complejidad de una distribución multi-rango o un segundo universo que no aporta al foco Cobertura actual.
- Implicancia: la columna `n_prioridad_1`/`pct_prioridad_1` solo existe en `etapa=="seleccion"`; no hay KPI de prioridad para postulantes no seleccionados en esta versión.

## 9. Constantes y parámetros vigentes

| Constante | Valor | Archivo | Nota |
|---|---|---|---|
| `UMBRAL_SUPRESION_CELDA` | 8 | `10_utils/10_configuracion.R` | Sin cambio. Aplicado también al nuevo KPI de prioridad (mismo umbral, sin excepción). |
| Escala tipográfica (`--fs-*`) | overline 12px … h2 28px (7 niveles) | `30_procesamiento/33_motor_template.html` (`:root`) | Nuevo esta sesión. Patrón de familia (ade). |
| KPI prioridad — definición | `orden_pref==1` sobre seleccionados (`estado_pref` 24/26) | `30_procesamiento/32_agregar_territorial.R` | Nuevo esta sesión. |
| KPI prioridad — columna real | `orden_pref` (no "PREFERENCIA") | `30_procesamiento/32_agregar_territorial.R` | Hallazgo de Fase 0, esta sesión. |

## 10. Arquitectura de archivos

Referencia: `50_documentacion/estructura/estructura_actual.md`, snapshot `2026-07-02 09:48:36` (16 carpetas, 63 archivos). Cambios respecto al snapshot de v03: `00_escanear_proyecto.R` corregido (nota Rama B); `32_agregar_territorial.R` de 16,2K a 19,3K; `33_generar_html.R` de 15,3K a 15,5K; `33_motor_template.html` de 57,7K a 61,7K; `docs/index.html` de 1009K a ~1M; nuevo `decisiones/20260702_decision_camino_a_motor_33.md`. Sin desviaciones respecto a la política. Nota de arquitectura del escáner ahora correcta (Rama B, verificado en el snapshot adjunto de esta sesión).

**Registro de ejecución detallado:** commits `6f8cad9`, `0d7977f`, `a90f2cc`, `919c286`, `2d61ed2` (ver sección 4 para detalle por commit; sin logs de Claude Code adicionales generados esta sesión más allá de los reportes en el chat).

## 11. Pendientes y ruta sugerida

**Inventario:**

1. **`egresados_em` 2026 ausente.** Contexto: heredado de v01-v03, sin cambios. Tipo: deuda de datos (bloqueante externo, no del titular). Impacto: el motor sigue usando `anio_actual=2025`. Complejidad: baja una vez llegue el dato (constante a actualizar + regenerar). Criterio de éxito: `egresados_em` 2026 disponible en insumos, `anio_actual` recalculado, motor regenerado y verificado.

2. **Migración tipográfica de `cat`/`idps` a la escala de `ade`.** Contexto: instrucción portable entregada al titular esta sesión (Cambio 4); ejecución delegada a las sesiones de trabajo de esos proyectos, no a `slep_paes`. Tipo: mejora visual / patrón de familia. Impacto: ninguno sobre `slep_paes`. Complejidad: media (dos repos). Precaución: mapear por rol, no por rango numérico ciego (aprendizaje de esta sesión, sección 7). Criterio de éxito: los 4 templates de la familia con la misma escala `--fs-*` nombrada y mismos valores px.

3. **Push del estado acumulado de la sesión 4.** Contexto: 5 commits locales (`6f8cad9`, `0d7977f`, `a90f2cc`, `919c286`, `2d61ed2`), ninguno pusheado. Tipo: publicación (gate del titular). Impacto: el motor con KPI de prioridad y escala tipográfica nueva no está aún en GitHub Pages. Complejidad: baja (mecánica, solo requiere visto bueno). Criterio de éxito: `git push`, verificación visual en GitHub Pages.

4. **Generar la documentación del proyecto con `suitedoc`.** Contexto: al cierre de esta sesión el titular pidió aplicar el protocolo de `asistente_documentar_suite_cc_v4.md` (herramientas_dev) para generar los 4 HTML de la suite (`arquitectura_*`, `documentacion_proyecto_*`, `arquitectura_general_*`, `documentacion_general_*`) de `slep_paes`. No se ejecutó: se decidió cerrar `slep_paes` primero por ser pivote de dominio (BIBLIOTECA vs. CONTINUATION de pipeline). Tipo: documentación (BIBLIOTECA, no continuación del pipeline). Impacto: ninguno sobre el pipeline; produce material publicable para gobernanza/comunidad. Dependencias: `suitedoc` instalado (≥0.3.0), `suitedoc_recolectar.R` disponible bajo `~`, copia vigente de `SETTINGS_Y_PROMPTS_OPERACIONALES.md` (§4.6) en `50_documentacion/activa/`. Complejidad: media (recolección + clasificación + checkpoint de gobernanza obligatorio, dado que el proyecto es Rama B con datos de NNA). Precaución: el checkpoint de gobernanza (paso 5 del prompt) es ineludible en este proyecto; verificar que la cfg no contenga nombres de establecimientos, RUT ni datos individuales antes de dar por lista la suite. Criterio de éxito: 4 HTML generados en `50_documentacion/suite/`, cfg sin residuo del ejemplo de fábrica, checkpoint de gobernanza confirmado por el titular, sin push (gate de publicación separado).

**Evaluación de deuda técnica:** ninguna zona nueva detectada como frágil. Los cambios de esta sesión (tipografía, KPI de prioridad) fueron verificados con panel adversarial (KPI) o verificación visual exhaustiva (tipografía) antes de commitear.

**Auditoría de cierre (política 5.6):**
- ¿Datos crudos aislados e inmutables? → Sí. Rama B confirmada y corregida en el escáner esta sesión; sin cambios en datos crudos.
- ¿Pipeline corre de cero sin intervención manual? → Sí, `run_all()` completo verificado end-to-end tras cada cambio de esta sesión.
- ¿Outputs reproducibles e idempotentes? → Sí, confirmado por regeneración repetida (4 veces esta sesión) sin cambios de contenido salvo los fixes deliberados.
- ¿Decisiones metodológicas como constantes nombradas? → Sí (escala tipográfica, definición de KPI de prioridad — documentadas en sección 9).
- ¿Nombres de archivos/carpetas sin tildes, ñ, espacios? → Sin cambios respecto a v03 (misma excepción documentada: `slep_paes - motor.dc.html`, congelado en `andamios/`).

**Ruta sugerida para la próxima sesión (criterios de 1.2.4):**
1. **Prioridad 1 — Generar la suite de documentación con `suitedoc` (pendiente 4).** Motivo explícito del cierre de esta sesión (pivote de dominio deliberado); no es un ítem más del inventario. Checkpoint de gobernanza obligatorio dado que el proyecto es Rama B con datos de NNA.
2. Prioridad 2 — Push del estado acumulado (pendiente 3), previo visto bueno explícito del titular sobre el conjunto (tipografía + KPI de prioridad).
3. Prioridad 3 — Verificar si `egresados_em` 2026 ya está disponible (pendiente 1, bloqueante externo).
4. Diferir — migración tipográfica de `cat`/`idps` (pendiente 2, ya delegada, no requiere sesión de `slep_paes`).

## 12. Instrucciones específicas para la próxima sesión

- 🔒 KPI de prioridad de carrera = `orden_pref==1` sobre seleccionados (`estado_pref` 24/26) exclusivamente; nunca usar `estado_pref==26` para determinar prioridad (su `orden_pref` es sistemáticamente posterior/menor prioridad que el de la fila 24 real).
- 🔒 Escala tipográfica del motor: variables `--fs-*` (`:root` de `33_motor_template.html`), piso 12px. No reintroducir valores `fontSize` numéricos sueltos; mapear por rol si se agrega un elemento nuevo.
- ⚠️ NO hacer push sin visto bueno explícito del titular sobre el conjunto de 5 commits de esta sesión (tipografía + KPI de prioridad + fix RenHist).
- ⚠️ Si se retoma la migración tipográfica de `cat`/`idps`, usar la instrucción entregada en esta sesión (Cambio 4), mapeando por rol, no por rango numérico ciego.
- ✅ ANTES de asumir el nombre de una columna de un archivo DEMRE no leído aún en el contrato vigente, verificar el schema real (Fase 0), incluso si el nombre parece obvio por el dominio (aprendizaje: "PREFERENCIA" asumido, `orden_pref` real).

## 13. Fragmentos de código de referencia

**Patrón correcto de mapeo rol→variable en migración de escala (prioriza función sobre rango numérico):**

```r
# En vez de mapear solo por rango numérico:
# if (14 <= n && n <= 15) return("body-lg")
#
# Verificar primero si el CONTEXTO/ROL del elemento indica otra variable,
# y solo usar el rango numérico como fallback:
var_for <- function(valor_px, rol) {
  # Override por rol conocido, antes que por rango
  if (rol == "titulo_de_card") return("h4")
  # Fallback: rango numérico
  if (valor_px >= 9  && valor_px <= 10.5) return("overline")
  if (valor_px >= 11 && valor_px <= 11.5) return("caption")
  if (valor_px >= 12 && valor_px <= 13)   return("body")
  if (valor_px >= 14 && valor_px <= 15)   return("body-lg")
  if (valor_px >= 16 && valor_px <= 18)   return("h4")
  if (valor_px >= 22 && valor_px <= 23)   return("h3")
  if (valor_px >= 30 && valor_px <= 34)   return("h2")
  stop("valor sin mapeo: ", valor_px)
}
```

**Patrón correcto de denominador reusado (evita inconsistencia por doble cálculo):**

```r
# En vez de recalcular el denominador del KPI nuevo desde cero:
# n_seleccionados_v2 <- postulacion |> filter(estado_pref %in% c(24,26)) |> ...
#
# Reusar el n/suprimida YA calculado por la etapa existente:
kpi_prioridad <- etapa_seleccion |>
  select(cod_entidad, anio_proceso, tipo_entidad, n_seleccionados = n, suprimida) |>
  left_join(conteo_prioridad_1, by = c("cod_entidad", "anio_proceso", "tipo_entidad")) |>
  mutate(
    pct_prioridad_1 = dplyr::if_else(suprimida, NA_real_, n_prioridad_1 / n_seleccionados),
    n_prioridad_1 = dplyr::if_else(suprimida, NA_integer_, n_prioridad_1)
  )
# Garantiza consistencia con el embudo por construcción, no por coincidencia.
```

## 14. Reapertura

- **Nombre del chat:** `slep_paes, sesión 5 (Claude Sonnet 5)`
- **Mensaje de apertura pre-armado:**

  Tipo CONTINUATION. El protocolo (POLITICA_PROYECTO.md + SETTINGS_Y_PROMPTS_OPERACIONALES.md) vive en la knowledge base del Project y se lee desde ahí. Adjunto el traspaso `traspaso_cierre_v04.md` y el escáner `estructura_actual.md` de esta sesión.

- **Documentos para la próxima sesión:**

  1. *Protocolo en knowledge base (NO se adjuntan; verificar que estén al día):* `POLITICA_PROYECTO.md`, `SETTINGS_Y_PROMPTS_OPERACIONALES.md`.
  2. *Opcionales según el foco real:* `CLAUDE.md` si la sesión correrá en Claude Code; `encargo_autonomo_claude_code_v1.md` si se abre un nuevo encargo autónomo.
  3. *Específicos de la sesión (SÍ se adjuntan):* `traspaso_cierre_v04.md`; `estructura_actual.md` (regenerar al abrir la próxima sesión); `20260702_decision_camino_a_motor_33.md` si se necesita el detalle de la decisión Camino A; si se retoma el pendiente 4 (suite de documentación), adjuntar además `asistente_documentar_suite_cc_v4.md`, `suitedoc_recolectar.R`, `GUIA_PUESTA_EN_MARCHA.md` y `prompt_activar_suite_standalone_v1.md` (todos ya provistos por el titular en el cierre de esta sesión, sin usar).

- **Nota final:** si `POLITICA_PROYECTO.md` o `SETTINGS_Y_PROMPTS_OPERACIONALES.md` cambiaron de versión entre sesiones, adjuntar la versión más actualizada al abrir y avisarlo en el mensaje de apertura. Antes de hacer push del estado de esta sesión, confirmar visto bueno explícito del titular sobre el conjunto (tipografía + KPI de prioridad + fix RenHist).

## 15. Errores del asistente

| Campo | Contenido |
|---|---|
| `momento` | Al redactar el traspaso v04, tras el pivote de dominio hacia la suite de documentación (`suitedoc`). |
| `disparador` | Usuario lo señaló explícitamente ("era la prioridad número 1 de la siguiente sesión, lo más importante que teníamos que hacer y motivo por el cual cerramos esta"). |
| `que_paso` | El pendiente de generar la suite de documentación con `suitedoc` se agregó al traspaso v04 como "Pendiente 4" en un inventario de 4 ítems, y se ubicó como Prioridad 2 en la ruta sugerida (detrás del push del código). El asistente no reflejó que este pendiente era el motivo explícito por el cual se cerró la sesión (el usuario pivotó de dominio precisamente para abrirlo en una sesión dedicada), lo que debía traducirse en Prioridad 1 inequívoca, no en un ítem más de una lista. |
| `regla_violada` | SETTINGS_Y_PROMPTS_OPERACIONALES.md §2.2 punto 11 ("Los pendientes son el mapa de la próxima ruta") y §1.2.4 (criterios de priorización: las instrucciones explícitas y el contexto inmediato de la sesión deben pesar en el orden, no solo la taxonomía genérica bug/bloqueante/funcionalidad). |
| `causa_raiz` | Al generar el traspaso, el asistente aplicó la plantilla de inventario de pendientes de forma mecánica (orden de aparición cronológica: `egresados_em`, tipografía cat/idps, push, suite) en vez de ponderar explícitamente cuál pendiente tenía la señal más fuerte de prioridad real dada por el propio usuario en el turno inmediatamente anterior al cierre (el pivote de dominio + la decisión explícita de cerrar `slep_paes` primero para abrir `suitedoc` después). |
| `salvaguarda_presente` | SETTINGS_Y_PROMPTS_OPERACIONALES.md §1.2.4 (criterios de priorización explícitos) y el propio hilo de la conversación, donde el usuario declaró la secuencia intencionalmente ("cierro `slep_paes` primero, `suitedoc` en sesión aparte"). |
| `patron` | Nuevo (primer registro de este patrón en `slep_paes`). Patrón a vigilar: al redactar la sección de pendientes de un traspaso, verificar si el cierre de la sesión estuvo motivado por un pivote hacia una tarea específica, y si es así, esa tarea es Prioridad 1 explícita, no un ítem más del inventario ordenado cronológicamente. |

**Corrección aplicada:** Prioridad 1 de la sección 11 reordenada — la suite de documentación (`suitedoc`) pasa a ser el primer punto de la ruta sugerida, antes del push del código. El usuario indicó que dará la instrucción de `suitedoc` directamente en la próxima sesión; este traspaso no necesita reescritura adicional, solo esta corrección de prioridad queda registrada aquí para que la próxima sesión la lea correctamente si se usa este documento como referencia.

---

**Fin del traspaso v04.**
