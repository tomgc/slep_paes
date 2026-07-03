# Log — Re-auditoría de datos post-fix F1 + F2

**Fecha:** 2026-07-03
**Encargo:** corrección autorizada de F1 y F2 del log
`20260703_auditoria_datos_pre_push_log.md` + re-auditoría completa (Fases 1-4).
**Modo:** panel adversarial ajustado a la NUEVA indexación (no compara contra la
definición vieja). Sin push.
**Evidencia congelada:** `50_documentacion/andamios/auditoria_datos_pre_push/`
(`lib_reauditoria.R`, `reauditoria_post_fix.R`, `reauditoria_fase4_dom.md`).

## Veredicto global

> **Los dos bloqueadores autorizados (F1 y F2) quedan RESUELTOS y verificados.**
> F1 elimina la desalineación **sistémica** del denominador (29 celdas >100% →
> 0 sistémicas); F2 elimina el «0% engañoso» (354 celdas → resguardo). El pipeline
> sigue **aritméticamente exacto** (Fase 1 MATCH TOTAL, Fase 2 aditividad exacta) y
> el motor renderiza fiel (Fase 4, 0 errores de consola).
>
> **Queda 1 residual, F3 (nuevo, causa distinta, NO autorizado a corregir):** una
> comuna (Santo Domingo) renderiza inscripción **101%** (189 inscritos vs 188
> egresados, 1 persona) por diferencia de asignación de rbd de egreso entre dos
> archivos fuente. El invariante 🔒 «0 %>100%» queda satisfecho **salvo** ese caso
> marginal. **Apto para push a criterio del titular sobre F3** (aceptar el margen,
> topar el % mostrado a 100, o reconciliar los archivos a nivel persona).

## Resumen por fase (re-auditoría)

| Fase | Resultado | Cifras |
|---|---|---|
| 1 — Recálculo independiente | ✅ **MATCH TOTAL** | cobertura 25.131 + rendimiento 31.853, **0 discrepancias** (con nueva indexación y F2) |
| 2 — Aditividad post-supresión | ✅ **0 excepciones** | comuna→nacional, comuna→región, cohorte todas=actual+anterior, supresión: todo exacto |
| 3 — Barrido %>100% | ⚠️ **1 residual** | 0 violaciones sistémicas; 1 comuna renderizada (Santo Domingo, 101%) + 2 rezagados no-navegables |
| 4 — DOM real | ✅ **PASA** | DOM == recálculo; F1/F2 visibles; residual F3 visible; 0 errores de consola |

## Tabla de invariantes (🔒)

| # | Invariante | Estado | Evidencia |
|---|---|---|---|
| 1 | UMBRAL=8 / supresión ambos caminos | ✅ PASA | Fase 2 re-audit: supresión 0 fallas, todos los niveles |
| 2 | Definición de cohortes | ✅ PASA | Fase 1 MATCH TOTAL con nueva indexación |
| 3 | Ningún % > 100% | ⚠️ **CASI** | 0 sistémicas (F1 resuelto); **1 residual** marginal (F3, Santo Domingo 101%) |
| 4 | No modificar código sin autorización | ✅ PASA | Solo F1/F2 (autorizados); F3 NO corregido |
| 5 | Sin RBD/RUT en reporte/log | ✅ PASA | Solo códigos territoriales públicos |

## F1 — RESUELTO: alineación del denominador egresados

- **Cambio (commit `35f7bd9`):** `etapa_egresados` en `32` pasa a
  `anio_proceso = as.integer(agno) + 1L`. El proceso de admisión P consume
  egresados de `agno = P-1`.
- **Verificación:**
  - `anio_actual` = `max(anios_egr)` pasa **2025 → 2026** automáticamente (33 sin
    tocar); el motor muestra «admisión 2026».
  - Nacional cohorte actual (inscritos/egresados con_rbd): 2024 = 79,1%,
    2025 = 80,6%, 2026 = 78,1% → a **1,1 pp** de lo documentado (80,2%/81,7%, que
    usaba totales con rezagados). Dentro del umbral de detención (2 pp) → sin
    detención.
  - Fase 3: las 29 celdas sistémicas >100% (máx 207%) desaparecen. Cabo de Hornos
    (12201), que mostraba 207% en 2025, ahora muestra **79%** (DOM, admisión 2026).
- **Corolario del hueco confirmado:** con la nueva indexación, la etapa egresados
  existe en procesos **2024, 2025, 2026**. El proceso **2026 SÍ tiene denominador**
  (egreso 2025); el proceso **2023** (el más antiguo, necesitaría egreso 2022) queda
  sin egresados. El «hueco 2026» documentado como dato faltante era artefacto del
  off-by-one; ahora el hueco es el proceso más antiguo, como se predijo.

## F2 — RESUELTO: resguardo (no «0%») en 1.ª prioridad suprimida

- **Cambio (commit `0a25277`):** `kpi_prioridad_1` conserva `suprimida`
  (`suprimida_p1`); `kpi_prioridad` distingue cero genuino (sin fila) de conteo
  suprimido (fila con n<8). Cuando `n_prioridad_1` está suprimido y
  `n_seleccionados` se muestra, emite resguardo (NA/NA) en vez de `coalesce(., 0L)`.
- **Verificación:** 354 celdas pasan de «0% (0)» a resguardo; **0 celdas con «0%»
  mostrado** en 1.ª prioridad; ningún `n_prioridad_1` en 1..7 se filtra como valor
  (rango no-NA 8–74.941). DOM: Quemchi (10209) muestra «resguardo» en 1.ª prioridad
  con selección visible (19%, 9). 0 errores de consola (el motor ya trataba
  `pct1==null` como resguardo; el fix solo alimenta ese camino correctamente).

## F3 — RESIDUAL NUEVO (documentado, NO corregido — requiere decisión)

- **Síntoma:** tras F1, sobrevive **1 celda renderizada >100%**: comuna 5606
  (Santo Domingo), proceso 2026, cohorte actual, inscripción **101%** (189 sobre
  188). Rindió/válidos/postuló ≤100% en esa comuna. Además 2 celdas del bucket
  `rezagados` (>100%) que **no son navegables** en el motor (no renderizadas).
- **Causa raíz (distinta de F1):** el numerador (inscritos, con `rbd` de ArchivoB)
  y el denominador (egresados, con `rbd` del archivo MINEDUC) provienen de **dos
  archivos fuente distintos**; el rbd de egreso de una persona puede diferir entre
  ambos (o faltar en uno), de modo que a nivel comuna el numerador puede exceder al
  denominador por una o pocas personas. La alineación de año (F1) NO puede eliminar
  esta diferencia inter-archivo. Es marginal (1 persona en el caso observado) y NO
  sistémica.
- **Opciones (para decisión del titular):** (a) aceptar el margen como ruido
  administrativo conocido; (b) topar el porcentaje mostrado a 100% en el motor
  (cambio de una línea, cosmético, satisface 🔒 #3 pero enmascara el dato);
  (c) reconciliar egresados/inscripción a nivel persona (cambio mayor de pipeline).
  No implementado (no autorizado).

## Hashes

| commit | qué |
|---|---|
| `35f7bd9` | F1 — egresados agno+1 (+ comentario CobHist) + docs |
| `0a25277` | F2 — resguardo en 1.ª prioridad suprimida + docs |
| *(este commit)* | re-auditoría — lib_reauditoria + script + evidencia DOM + este log |

## Pendientes `# REVISAR`

- **# REVISAR (F3):** decisión del titular sobre el residual de 1 comuna (Santo
  Domingo, 101%) por diferencia inter-archivo de rbd de egreso. Hasta entonces, el
  invariante 🔒 #3 queda satisfecho salvo ese caso marginal.
- **Confirmar `anio_actual=2026` como default deseado** (F1 lo movió de 2025 a 2026;
  es correcto — proceso más reciente con denominador — pero conviene ratificarlo).
- No hacer push. Commits locales para revisión del titular.
