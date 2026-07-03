# Re-auditoría Fase 4 — DOM real (post-fix F1+F2) · evidencia congelada

Motor servido desde `docs/index.html` committeado (F1+F2), server estático local.
DOM real (lectura de `textContent`), contrastado con el recálculo ajustado (Fase 1
de la re-auditoría). **0 errores de consola** en todas las combinaciones.

## Estado por defecto
- Subtítulo: **«admisión 2026»** (antes 2025) — confirma `anio_actual=2026` tras F1.

## Chequeo 1 — DOM == recálculo · SLEP Costa Central (503) · Actual · 2026
| etapa | DOM | recálculo |
|---|---|---|
| egresados | 100% (1.434) | 1434 |
| inscripción | 67,6% (969) | 969 |
| rindió | 47,6% (682) | 682 |
| válidos | 44,8% (642) | 642 |
| postuló | 18,4% (264) | 264 |
| selección | 15,3% (220) | 220 |

MATCH exacto.

## Chequeo 2 — F1 resuelto (Cabo de Hornos ya no >100%)
Cabo de Hornos (comuna 12201), cohorte Actual, admisión 2026 (DOM):
egresados 14 · inscritos **79% (11)** · rindió 79% (11) · válidos 79% (11) ·
postuló/seleccionado/1.ª prioridad = resguardo.
Antes del fix mostraba **207%** (proceso 2025, denominador desalineado). Ahora ≤100%.

## Chequeo 3 — F2 resuelto (resguardo, no «0%»)
Quemchi (comuna 10209), Actual, 2026 (DOM):
egresados 47 · inscritos 68% (32) · rindió 47% (22) · válidos 47% (22) ·
postuló 21% (10) · **seleccionado 19% (9)** · **1.ª prioridad = «resguardo»**.
La selección se muestra (9 ≥ 8) pero el conteo de 1.ª prioridad (1..7) va a
resguardo — antes se publicaba «0% (0)» engañoso.

## Chequeo 4 — Residual F3 (documentado, NO corregido)
Santo Domingo (comuna 5606), Actual, 2026 (DOM):
egresados 188 · inscritos **101% (189)** · rindió 91% (171) · válidos 89% (167) ·
postuló 60% (113) · seleccionado 55% (104) · 1.ª prioridad 44% (46).
Único >100% renderizado que sobrevive al fix: 189 inscritos (rbd de ArchivoB) vs
188 egresados (rbd MINEDUC) = 1 persona de diferencia por asignación de rbd de
egreso entre dos archivos distintos. Causa distinta de F1 (no es desalineación de
año); ver hallazgo F3 del log de re-auditoría.
