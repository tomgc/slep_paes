# Log — Rendimiento «mejor puntaje vigente» (ventana=4)

- **Fecha:** 2026-07-03
- **Encargo:** Decisión 6 / foco Rendimiento — publicar el **mejor puntaje vigente
  por prueba** (regla oficial DEMRE «puntaje bloque»), **ventana=4** aprobada por el
  titular. Embudo/cobertura NO se toca (Decisión 6: personas únicas, cerrada).
- **Fase 0:** reportada y aprobada (ventana=4; `PROCEDENCIA_*` no existe en
  ArchivoC → se calcula `max`).
- **Evidencia congelada:** `andamios/auditoria_datos_pre_push/reauditoria_rendimiento_vigente.R`.
- **Sin push.**

## Veredicto global

> **Implementado y verificado.** El foco Rendimiento publica ahora el **mejor
> puntaje vigente por prueba** = `max(puntaje)` sobre las **4 casillas** REG/INV ×
> ACTUAL/ANTERIOR (últimas 4 rendiciones consecutivas, normativa DEMRE). Panel
> adversarial **MATCH TOTAL** (22.800 celdas, 0 discrepancias); NEM/Ranking sin
> cambio; DOM == recálculo; 0 errores de consola. El embudo/cobertura quedó
> **intacto** (`git diff` de `32` solo en el bloque de rendimiento).

## Cambios (commit atómico)

1. **`32_agregar_territorial.R`** — bloque nuevo `rendimiento_vigente`: colapsa a
   `max(puntaje)` por `(id_aux, anio_proceso, rbd, prueba, cohorte)` sobre las 4
   casillas (sin filtrar vigencia → ventana=4), agrega territorialmente con
   supresión, etiqueta `tipo_rendicion="vigente", vigencia="actual"`, y se
   `bind_rows` **preservando** las filas `reg`/`inv`/`actual`/`anterior` existentes
   (sin pérdida, reversible). Excluye `"mate"` (INV sin split, B.1). NEM/Ranking sin
   cambios. **El embudo (`etapa_*`) no se tocó.**
2. **`33_generar_html.R`** — `ren_f` pasa de `(tipo_rendicion=="reg" & vigencia=="actual")`
   a `(tipo_rendicion=="vigente" & vigencia=="actual")` (+ nem/ranking). Publica el
   vigente en vez de reg-actual; las demás filas siguen en el parquet, no publicadas.
3. **`33_motor_template.html`** — rótulos/notas del foco Rendimiento (5 notas: por
   territorio, comparar, histórica, pie de tabla comparativa, panel de info) pasan a
   «media del **mejor puntaje vigente** por prueba (mejor de las últimas 4
   rendiciones consecutivas —invierno/regular × actual/anterior—, normativa DEMRE
   "puntaje bloque")». Sin cambio de lógica (el motor lee la media por prueba igual).

## Verificación

- **Panel adversarial (recálculo independiente del max-vigente ventana=4):**
  `[VIGENTE 5 pruebas]` 22.800 filas, **0 discrepancias** en n, supresión y media
  → **MATCH TOTAL**. `[NEM/RANKING]` 0 discrepancias (sin cambio).
- **DOM:** foco Rendimiento, SLEP Costa Central (503), 2026, cohorte actual:
  DOM = recálculo exacto (clec 538, mate1 544, mate2 389, cien 403, hcsoc 443,
  nem 719, ranking 734). Nota nueva renderiza. **0 errores de consola.**

## Efecto en cifras nacionales (delta vigente − reg-actual, cohorte «todas»)

Ventana=4 **mezcla cohortes** (agrega personas solo-invierno y solo-anterior): el
delta de media puede ser **±** aunque cada individuo con reg-actual mejora o iguala.

| prueba | 2023 | 2024 | 2025 | 2026 |
|---|---|---|---|---|
| CLEC | **−0,2** | **+15,0** | +8,0 | +6,1 |
| M1 | **−5,9** | +0,5 | +5,0 | +6,9 |
| M2 | 0,0 | +7,4 | +3,1 | +2,5 |
| Ciencias | +1,5 | +6,4 | +3,4 | +5,6 |
| Historia | +3,0 | +4,3 | +2,9 | +2,1 |

Personas agregadas por ventana=4: **~18k–27k por prueba-año** (solo-invierno +
solo-anterior). Los pocos deltas negativos (CLEC 2023, M1 2023) son el efecto de la
mezcla de cohortes advertido: las personas agregadas —repitentes / arrastre del
proceso anterior— bajan el promedio agregado, no un error del cálculo (cada persona
con reg-actual tiene vigente ≥ su reg-actual, verificado). MATE2 2023 delta 0 / +0
personas: en el primer proceso PAES no hay casillas ANTERIOR ni INV split para M2.

## Pendientes `# REVISAR`

- Ninguno bloqueante. La media publicada del foco Rendimiento cambió (efecto arriba)
  por decisión aprobada (ventana=4). Las filas reg/inv/anterior siguen en el parquet
  si en el futuro se quiere una vista alternativa.
- No hacer push. Commit local para revisión del titular.
