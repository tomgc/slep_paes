# Log — Reconciliación F3 (residual %>100%) · DETENCIÓN en Fase 0

**Fecha:** 2026-07-03
**Encargo:** reconciliar F3 a nivel persona (autorizado por el titular, «cambio
mayor, no cosmético»).
**Modo:** Fase 0 obligatoria antes de codificar. Solo lectura; **no se modificó el
pipeline** (la implementación autorizada resultó infeasible — ver veredicto).
**Evidencia congelada:** `50_documentacion/andamios/auditoria_datos_pre_push/f3_fase0_diagnostico.R`.

## Veredicto global

> **DETENCIÓN en Fase 0.** La reconciliación **persona-a-persona** especificada
> («usar un único rbd de egreso por persona como fuente de verdad para ambas
> etapas») es **infeasible con los datos disponibles**: ArchivoB (inscripción) y el
> archivo MINEDUC (egresados) **no comparten identificador de persona**, así que no
> existe forma de saber «el rbd de egreso de una persona» en ambos archivos.
> Adicionalmente, el desfase inter-archivo **real** es de **1 persona** (Santo
> Domingo 2026), 0,00016% del universo — muy por debajo del umbral de 0,1%. Se
> requiere **decisión revisada del titular**: las únicas opciones que respetan el
> invariante 🔒 (sin doble conteo ni pérdida) son aceptar el margen o topar el
> display; la reconciliación por agregado (max/unión) violaría el invariante.

## Fase 0 — Diagnóstico (obligatorio, «reportar antes de decidir»)

### (1) ¿Existe clave para enlazar una persona entre los dos archivos?

| Archivo | Columna(s) de identidad | Ejemplo |
|---|---|---|
| ArchivoB (inscripción, DEMRE) | `id_aux` | `id_9265592376510` |
| Egresados (MINEDUC) | `mrun`, `mrun_ipe` | `7250679` |

- **Solapamiento `id_aux` ∩ `mrun` = 0; `id_aux` ∩ `mrun_ipe` = 0** (de 1.000.625
  `id_aux` únicos).
- El ArchivoB **crudo** (`archivob_adm2026_reg.csv`) trae **solo `ID_aux`** (sin
  MRUN). Son esquemas de anonimización de **agencias distintas** (DEMRE vs MINEDUC),
  sin crosswalk en el proyecto. El pipeline `32` nunca une egresados a las demás
  etapas por persona — **no puede**, porque no hay clave.
- **Consecuencia:** «el rbd de egreso de una persona difiere o falta entre ambos»
  no es medible ni corregible a nivel persona. La premisa del encargo no se sostiene
  con los datos actuales.

### (2) Magnitud real del desfase (agregado, sin necesidad de enlace)

Primero, una corrección al hallazgo previo: una medición ingenua da «104% nacional»,
pero es **artefacto del hueco 2023**. Tras F1, el proceso 2023 no tiene egresados
(`agno=2022` inexistente) → `egresados=0` en todas las comunas de 2023; ahí el funnel
**ya rebasa a inscritos = 100%** (caso hueco documentado, NO un >100%). Ese hueco
aporta 195.535 «excesos» espurios.

Excluyendo el hueco (solo celdas con `egresados > 0`, procesos 2024–2026):

- Nacional: egresados 789.577 vs inscritos-actual 625.754 → **79,3%** (≤100%).
- Celdas comuna con `egresados > 0` **e** `inscritos > egresados`: **1**.
- Exceso real total: **1 persona** = **0,00016%** del universo (umbral titular: 0,1%).

| comuna | proceso | egresados | inscritos | exceso |
|---|---|---|---|---|
| 5606 (Santo Domingo) | 2026 | 188 | 189 | 1 |

Es decir: el residual F3 es **una sola persona** que inscribió declarando egreso
2025 desde un establecimiento de Santo Domingo (rbd de ArchivoB), a quien el archivo
MINEDUC no cuenta como egresado 2025 en Santo Domingo (contado en otra comuna o
`marca_egreso≠1`). No es un patrón sistémico.

## Por qué no se implementó (invariante 🔒 y B.1)

- **Método autorizado (persona-a-persona):** infeasible (sin clave). No se puede
  «elegir un único rbd por persona» si no se puede identificar a la persona en ambos
  archivos.
- **Alternativa por agregado — denominador = `max(egresados_MINEDUC, inscritos)` por
  comuna:** garantizaría ≤100%, pero la persona extra ya está contada en su comuna
  MINEDUC (o no es egresada MINEDUC); sumarla a Santo Domingo la **duplica** (o la
  **inventa**) → viola el invariante 🔒 «sin doble conteo ni pérdida» y B.1 («no
  inventar»). Rechazada.
- Por eso **no se tocó `32`** ni se generó commit de código.

## Opciones para la decisión del titular (revisada)

| # | Opción | ≤100%? | Invariante 🔒 | Nota |
|---|---|---|---|---|
| A | Aceptar el margen (1 persona) como ruido inter-archivo conocido, documentado | casi (1 celda) | ✅ respeta | 0 cambios; F3 queda como nota metodológica |
| B | Topar el % mostrado a 100% en el motor (1 línea) | ✅ | ✅ respeta | Cosmético (el titular lo había descartado); satisface 🔒 #3 estricto |
| C | Denominador `max()`/unión por comuna | ✅ | ❌ **viola** (doble conteo) | No implementable bajo el invariante |
| D | Conseguir crosswalk DEMRE↔MINEDUC (dato nuevo) y reconciliar persona-a-persona | ✅ | ✅ | Requiere insumo que hoy no existe |

Recomendación: dado que el desfase es **1 persona** y la vía persona-a-persona es
infeasible, **A** (aceptar y documentar) es proporcional; si se exige el estricto
«0 >100%», **B** es el único cambio invariant-clean disponible hoy. **C** queda
descartada por el propio invariante del encargo.

## Pendientes `# REVISAR`

- **# REVISAR (F3):** decisión del titular entre A / B / D (C descartada). No hay
  vía persona-a-persona sin un crosswalk DEMRE↔MINEDUC.
- No se hizo push. No se modificó el pipeline en este paso.
