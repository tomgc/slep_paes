# Fase 4 — Verificación en navegador (DOM real) · evidencia congelada

Motor servido desde `docs/index.html` committeado (server estático local, puerto 8747).
Navegación automatizada vía DOM (lectura de `textContent`/computed styles, no solo
"carga sin error"). Cifras DOM contrastadas contra el recálculo independiente de Fase 1.

## Consola
- **0 errores de consola** en todas las combinaciones recorridas.

## Chequeo 1 — DOM == recálculo (Fase 1), combos normales

### CobActual · SLEP Costa Central (503) · cohorte Actual · admisión 2025
Funnel renderizado (DOM) vs recálculo independiente:

| etapa | DOM | recálculo | ¿MATCH? |
|---|---|---|---|
| egresados | 100% (1.434) | 1434 (100%) | ✓ |
| inscripción | 61,5% (882) | 882 (61,5%) | ✓ |
| rindió | 47,4% (680) | 680 (47,4%) | ✓ |
| válidos | 44,8% (642) | 642 (44,8%) | ✓ |
| postuló | 19,5% (280) | 280 (19,5%) | ✓ |
| selección | 16,0% (230) | 230 (16,0%) | ✓ |

### CobComp · comunas Costa Central · cohorte Actual · 2025 (DOM)
Viña del Mar 4.418 → 80%(3.533)/73%(3.204)/71%(3.128)/48%(2.132)/41%(1.808);
Concón 636 → 85%/78%/77%/52%/46%; Quintero 407 → 98%/83%/80%/44%/37%;
Puchuncaví 235 → 72%/58%/56%/20%/19%. Todos coinciden con Fase 1 (MATCH TOTAL).

## Chequeo 2 — VIOLACIÓN 🔒 %>100% visible en el DOM

Se agregó **Cabo de Hornos** (comuna 12201, Magallanes) a la comparación,
cohorte **Actual**, admisión 2025. Fila renderizada (DOM):

| Territorio | Egresados | Inscritos | Rindió | Válidos | Postuló | Seleccionado |
|---|---|---|---|---|---|---|
| Cabo de Hornos | 14 | **207% (29)** | **207% (29)** | **207% (29)** | **114% (16)** | 100% (14) |

Coincide EXACTO con el recálculo (inscripción 29/egresados 14 = 207,1%;
postulación 16/14 = 114,3%). Confirma que:
1. El DOM renderiza fielmente lo que produce el pipeline (== Fase 1).
2. La violación del invariante 🔒 (%>100%) es **visible al usuario** cuando navega
   a comunas afectadas en cohorte "actual" (no solo un artefacto interno del JSON).

La misma comuna en cohorte **Todas** rinde ≤100% (egresados "—", inscritos 100% (36),
etapas 94/94/61/56%): confirma que el defecto es exclusivo de la cohorte "actual"
(denominador egresados desalineado), no de "todas"/"anterior" (Cambio 9 ya resuelto).

## Herramienta
Preview MCP (`preview_start`/`preview_eval`/`preview_console_logs`/`preview_screenshot`)
sobre `.claude/launch.json` config `docs-preview` (python http.server, dir `docs`).
