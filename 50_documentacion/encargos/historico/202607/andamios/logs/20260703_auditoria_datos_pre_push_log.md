# Log — Auditoría de datos exhaustiva pre-push

**Fecha:** 2026-07-03
**Encargo:** `50_documentacion/andamios/encargo_auditoria_datos_pre_push.md`
**Modo:** autónomo, secuencial, 4 fases. Panel adversarial en R (código propio,
independiente de `32`/`33`). Sin push, sin corrección de código (🔒 verificación).
**Evidencia congelada:** `50_documentacion/andamios/auditoria_datos_pre_push/`
(`lib_auditoria.R`, `fase0..fase3_*.R`, `fase4_dom_evidencia.md`).

## Veredicto global

> **NO APTO PARA PUSH.** El invariante 🔒 «ningún porcentaje publicado > 100%» está
> **violado**: 29 celdas renderizadas superan 100% en la cohorte **«actual»** (máx
> **207%**, visible en el DOM). Causa raíz: el denominador `egresados` está
> **desalineado un año** respecto de las demás etapas. Es una **detención (b)**
> (contradice el criterio del Bug 2 del traspaso v05: «0 %>100% en ninguna
> combinación»). No se corrigió (🔒 gate estratégico, POLITICA 0.3): requiere
> decisión del titular. El resto del pipeline es aritméticamente exacto (Fase 1
> MATCH TOTAL, Fase 2 aditividad exacta).

## Resumen por fase

| Fase | Alcance | Resultado |
|---|---|---|
| 0 — Estado real | invariante umbral; extracción JSON publicado; reproducibilidad | **PASA**. umbral audit=config=8. `run_all(only=33)` reproducible; artefacto committeado NO stale (payload idéntico a regenerar). |
| 1 — Recálculo independiente | 25.131 celdas cobertura + 31.853 rendimiento vs JSON publicado | **MATCH TOTAL** (0 discrepancias en n, supresión, n_seleccionados, n_prioridad_1, pct_prioridad_1, media). + Hallazgo F2. |
| 2 — Aditividad post-supresión | comuna→región→nacional; cohorte todas=actual+anterior; supresión todos los niveles; SLEP por establecimiento | **0 excepciones**. comuna→nacional 66/66, comuna→región 1056/1056, región→nacional 66/66, cohorte 8778/8778, supresión 25.131/25.131, SLEP 503 66/66. |
| 3 — Barrido %>100% | todo porcentaje renderizado (baseCob/baseY), 3 cohortes × vistas × períodos | **FALLA**. 29 celdas round(pct)>100% (todas cohorte «actual»). Hallazgo F1 (bloqueante). |
| 4 — DOM real | navegación headless; cifras DOM vs Fase 1; consola | **PASA (metodología)**. DOM == recálculo (SLEP 503, comunas CC, Cabo de Hornos). 0 errores de consola. Confirma que la violación %>100% es **visible al usuario**. |

## Tabla de invariantes (🔒 §2.3)

| # | Invariante | Estado | Evidencia |
|---|---|---|---|
| 1 | `UMBRAL_SUPRESION_CELDA = 8`; n<8 suprimida en ambos caminos | **PASA** | Fase 0 (audit=config=8) + Fase 2 (25.131 celdas, regla n∈[1,7]⟺suprimida y valor, 0 fallas, todos los niveles). |
| 2 | cohorte «actual»=`anyo_egreso==P-1`; «anterior»=`≤P-2`/NA | **PASA** | Recálculo usa esta definición; Fase 1 MATCH TOTAL la confirma end-to-end. |
| 3 | Ningún % publicado > 100% en ninguna combinación | **FALLA** | Fase 3: 29 celdas round(pct)>100% (cohorte «actual», máx 207%); Fase 4: visible en DOM (Cabo de Hornos 207%). Ver F1. |
| 4 | No se modifica código de cálculo (solo verificación) | **PASA** | Solo se agregaron scripts de auditoría a `andamios/`; `32`/`33`/template intactos (git: sin cambios en `30_procesamiento/`). |
| 5 | Sin RBD/RUT/identificador de establecimiento en reporte ni log | **PASA** | Solo se usan códigos territoriales públicos (comuna/región/SLEP/nacional). Ningún RBD/RUT/nombre de establecimiento. |

## Hallazgos (documentados, NO corregidos — 🔒 gate del titular)

### F1 — BLOQUEANTE: denominador `egresados` desalineado un año → %>100% en «actual»

- **Síntoma:** 29 celdas renderizadas con `round(pct) > 100%`, **todas en cohorte
  «actual»**: inscripción 9, rindió 16, resultados 3, postulación 1 (26 a nivel
  comuna + 3 en el bucket `rezagados`, este último no navegable en el motor
  post-Cambio 5). Máx **207%** (comuna 12201 Cabo de Hornos, admisión 2025:
  inscritos 29 sobre egresados 14). Selección y 1.ª prioridad nunca >100%.
- **Causa raíz (verificada, C.11):** la etapa `egresados` se indexa por **año de
  egreso** (`agno` de la base MINEDUC), mientras `inscripción..selección` se indexan
  por **año del proceso de admisión** (ArchivoB). El motor cruza ambos por
  `anio_proceso` con igualdad, pero el proceso de admisión P se nutre de quienes
  egresaron en **P-1** (`anyo_egreso==P-1`). Por tanto el denominador en el proceso P
  es la promoción de egreso P, cuando debería ser la de egreso P-1. Verificación
  nacional (inscritos «actual» / egresados):

  | proceso P | inscritos actual (egresó P-1) | egresados agno=P [motor] | egresados agno=P-1 [alineado] | % motor | % alineado |
  |---|---|---|---|---|---|
  | 2024 | 204.320 | 257.261 | 254.750 | 79,4% | 80,2% |
  | 2025 | 210.208 | 281.356 | 257.261 | 74,7% | **81,7%** |

  Nacionalmente ambos ≤100% (promociones de tamaño similar y creciente, que
  *entierran* el defecto y de hecho **subestiman** la cobertura «actual» ~1–7 pp).
  A nivel comuna, donde la promoción fluctúa año a año, el numerador (promoción P-1)
  supera al denominador (promoción P) → >100%.
- **Corolario:** el «hueco de egresados 2026» documentado como pendiente 2 del
  traspaso v05 (dato faltante) es en realidad un **artefacto del off-by-one**: la
  promoción que nutre el proceso 2026 es egreso 2025 (`agno=2025`, que **sí existe**);
  con la alineación correcta (egresados `agno=P-1` en el proceso P), el proceso 2026
  tendría denominador y sería el proceso 2023 el que quedaría sin egresados.
- **Contradice:** criterio de verificación del Bug 2 (traspaso v05 §5: «ningún % >100%
  en ninguna combinación tras el fix») y el invariante 🔒 #3. **Distinto** del Bug 2
  (Cambio 9), que corrigió la mezcla de cohortes en «todas»/«anterior» (denominador
  → inscritos); esta desalineación de año en «actual» quedó fuera de ese fix.
- **Propuesta de corrección (NO implementada, requiere autorización):** en
  `32_agregar_territorial.R`, `etapa_egresados` debe colocarse en
  `anio_proceso = agno + 1` (o, equivalente, el denominador «actual» del proceso P
  debe referenciar `egresados` de `agno = P-1`). Revisar el impacto en
  `33_generar_html.R` (`anio_actual = max(anios_egr)` pasaría a implicar proceso
  `agno+1`) y en todas las vistas. Re-auditar tras el cambio (mismo patrón «cambiar
  el denominador exige re-auditar a todos los consumidores», aprendizaje del Bug 2).

### F2 — MENOR: «0%» engañoso en 1.ª prioridad de celdas chicas

- **Síntoma:** 354 celdas de comuna (actual 94 / anterior 198 / todas 62) publican
  `pct_prioridad_1 = 0%` y `n_prioridad_1 = 0` cuando el conteo real de 1.ª prioridad
  es **1–7**. Como `n_seleccionados` sí se muestra (≥8), el motor renderiza
  **«0% (0)»** en la columna «1.ª prioridad», indistinguible de un cero genuino.
- **Causa raíz:** `32` suprime `n_prioridad_1` por k-anonimato (n<8 → NA, correcto) y
  luego `coalesce(n_prioridad_1, 0L)` en `kpi_prioridad` lo convierte en 0. El
  `coalesce` estaba pensado para el caso «sin ningún 1.ª prioridad» (cero genuino),
  pero también captura el conteo suprimido, conflagrando «suprimido» con «cero».
  Inconsistente con la convención del proyecto (suprimido = «resguardo», nunca un
  valor numérico falso).
- **Propuesta (NO implementada):** cuando `n_prioridad_1` esté suprimido pero
  `n_seleccionados` se muestre, exhibir la marca de resguardo en la celda de 1.ª
  prioridad (no «0% (0)»). Decisión del titular (afecta cifras mostradas).

## Reproducibilidad y hashes

Scripts (frozen evidence, `andamios/auditoria_datos_pre_push/`); cada fase corre con
`Rscript` desde `~/Projects/slep_paes`, leyendo parquets crudos vía
`SLEP_PAES_DATA_ROOT` y el JSON de `docs/index.html`.

| commit | fase |
|---|---|
| `e6caf6f` | Fase 0 — lib panel adversarial + reproducibilidad/staleness |
| `0e884ca` | Fase 1 — recálculo independiente MATCH TOTAL + hallazgo F2 |
| `9c2dd89` | Fase 2 — aditividad y supresión exactas |
| `a4d8cf0` | Fase 3 — FALLA: 29 %>100% + causa raíz (F1) |
| `6eba3d4` | Fase 4 — DOM real: MATCH + violación visible |

## Pendientes `# REVISAR`

- **# REVISAR (bloqueante):** decisión del titular sobre F1 (alineación del
  denominador `egresados`). Hasta resolverlo, **el push queda bloqueado** por el
  invariante 🔒 #3. Registrar como decisión formal en `activa/decisiones/`.
- **# REVISAR (menor):** decisión sobre F2 (mostrar resguardo vs «0%» en 1.ª
  prioridad de celdas chicas).
- No hacer push. Commits locales para revisión del titular.
