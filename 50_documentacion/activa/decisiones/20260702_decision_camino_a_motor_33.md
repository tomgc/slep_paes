# Decisión: Camino A para el motor `33` (adaptar el diseño al agregado real)

- **Fecha:** 2026-07-02
- **Sesión:** 3
- **Documento origen:** `traspaso_cierre_v03.md`, §8

## Contexto

El handoff de Claude Design (`slep_paes - motor.dc.html`) asumía un contrato
de datos que `32_agregar_territorial.R` no produce: 7 etapas del embudo (con
matrícula), KPIs de prioridad de carrera, nivel establecimiento en
comparación, strip plots por alumno con tooltip de microdato, mediana/sd por
prueba, y split rec/ant cruzado por territorio. Claude Code detectó la
discrepancia en su Fase 0 (lectura del estado real antes de codificar) al
redactarse el primer encargo, y se detuvo correctamente (regla de detención
a, `encargo_autonomo_claude_code_v1.md` §1.3).

## Alternativas consideradas

- **A — Adaptar el diseño al agregado real.** Recrear el lenguaje visual del
  prototipo (tokens, chrome, comportamiento) sobre los agregados que `32` ya
  produce, sin extender el pipeline.
- **B — Extender el pipeline.** Modificar `31`/`32` para generar agregados a
  nivel establecimiento, mediana/sd, y join de dependencia, antes de
  reproducir el prototipo con mayor fidelidad.
- **C — Híbrido.** A ahora, B como tarea aparte después.

## Justificación

A no requiere tocar una entrada que el encargo fijó como inmutable (`32` ya
verificado y pusheado en v02), respeta todos los invariantes de gobernanza
sin ambigüedad, y produce un motor embarcable en la misma sesión. B habría
exigido reabrir el pipeline (cambio de alcance no aprobado) y aun así no
habría resuelto los strip plots por alumno (imposibles sin publicar
microdato, independientemente de qué agregue `32`): un tooltip con
establecimiento + puntaje individual es reidentificable por combinación de
atributos incluso con `id_aux` anonimizado, y viola Política §6.4
(Condiciones de Uso Agencia de Calidad: no identificar establecimientos por
nombre en ningún output).

## Tensión resuelta

Fidelidad visual al prototipo vs. gobernanza de datos. Gobernanza prevalece
(Política §6; regla 0.3: "la gobernanza de datos prevalece siempre sobre la
autonomía").

## Implicancia

El motor publicado (`docs/index.html`, commit `d8bc790`) usa:

- **6 etapas** en el embudo de Cobertura (sin matrícula), no 7.
- **Media** (`mean`) como métrica de Rendimiento·Actual, no mediana/SD
  (`32` no las produce).
- **Sin nivel establecimiento**: "Comparar territorios" llega hasta comuna;
  el modal ofrece nacional→región→SLEP→comuna.
- **Sin KPIs de prioridad de carrera**: diferidos a Camino B (extensión de
  pipeline, distinto de "Rama B" de arquitectura de datos; ver pendiente 1
  de `traspaso_cierre_v03.md` §11).
- **Control "Cohorte" reinterpretado** como toggle de mostrar/ocultar el
  bucket territorial "generaciones anteriores" (`tipo_entidad=="rezagados"`),
  nunca un split rec/ant cruzado por territorio (`32` no lo produce).

Verificado con panel adversarial en ambos ejes: Agente A (recálculo
independiente de 15 cifras, 15/15 match); Agente B (auditoría de gobernanza,
veredicto PASS — 0 identificadores de establecimiento/persona, supresión con
`n=NA` más estricta que el mínimo exigido de `UMBRAL_SUPRESION_CELDA=8`).

## Decisiones de detalle asociadas (mismo gate del titular)

1. "Comparar territorios" → nivel comuna por defecto (4 comunas de Costa
   Central), ampliable a SLEP/región/nacional desde el modal.
2. Rendimiento·Actual → media por prueba y territorio (barra/punto + n),
   sin strip plot.
3. Matrícula y KPIs de prioridad de carrera → fuera de esta versión.
4. "Cohorte" → toggle de generaciones anteriores (ver implicancia arriba).
