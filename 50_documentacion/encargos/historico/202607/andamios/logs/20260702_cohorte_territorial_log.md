# Log — Cohorte por territorio real (RBD histórico) + toggle de 3 estados

- **Fecha:** 2026-07-02
- **Tipo:** CONTINUATION. Cambio de alcance real sobre el pipeline (`32`) + interfaz (`33`).
- **Entorno:** Claude Code, `~/Projects/slep_paes`, R-only, Rama B (parquets en `SLEP_PAES_DATA_ROOT`).

## 1. Commits (2, atómicos, sin push)

| Fase | Commit | Título |
|---|---|---|
| A (pipeline) | `250d2fa` | `feat(32): agrega cohorte anterior cruzada por RBD historico al arbol territorial completo` |
| B (interfaz) | `92039e4` | `feat(33): toggle de cohorte de 3 estados (actual/anteriores/todas) integrado al embudo y rendimiento` |

## 2. Fase A0 — Hallazgo que reencuadra el encargo (no se asumió)

El encargo temía que el RBD de egreso histórico no estuviera disponible (detención a). El diagnóstico de datos reales mostró lo contrario:

- **El RBD de egreso ES el `rbd` existente de ArchivoB.** ArchivoB conserva el RBD del establecimiento de egreso **aunque el egreso sea de años previos**: 1.209.572 filas con `rbd` válido mapean al catálogo, sin importar `anyo_egreso`. Solo 19.574 filas (mayoría `rbd=NA`) no mapean → siguen cayendo en la categoría residual "rezagados/sin RBD".
- **La cohorte es recencia de egreso, no vigencia del RBD.** En las bases DEMRE **nunca** hay `anyo_egreso == anio_proceso` (el proceso de admisión P corre a fines de P-1). Por eso "actual" (generación fresca) = `anyo_egreso == anio_proceso - 1`, y "anterior" = `anyo_egreso <= anio_proceso - 2` (o `anyo_egreso` NA).
- **`id_aux` es estable entre años** (overlaps 2023∩2024 = 69.346; 2023∩2025 = 20.673).
- **Detención (b) no aplica:** `(id_aux, anio_proceso)` es 1:1 con `rbd` y con `anyo_egreso` (0 duplicados) → sin fan-out; solo 254/985.379 personas tienen 2 RBD válidos entre años distintos (0,026%, resoluble con tiebreak, no bloqueante).
- **Detención (a) y (c) descartadas:** RBD disponible; supresión idéntica.

## 3. Fase A1 — Diseño implementado en `32`

- Dimensión `cohorte` (`actual`/`anterior`/`todas`) añadida a `paes_cobertura_territorial.parquet` y `paes_rendimiento_territorial.parquet`.
- Ambas cohortes se territorializan por el **mismo `rbd` de egreso** vía el mismo `agregar_conteo_territorial`/`agregar_promedio_territorial` (mismos catálogos de `30`, misma supresión k=8, mismas definiciones de etapa).
- **`"todas"` se computa aparte** (no se suma en cliente) para aplicar supresión sobre el conteo real de cada cohorte; reproduce EXACTO el agregado pre-cohorte (backward-compatible).
- Egresados (denominador): solo cohorte `"actual"` (`egresados_em` registra a cada persona solo en su año de egreso; no hay "egresado anterior"). `"todas"` egresados == `"actual"`.
- Helpers nuevos: `clasificar_cohorte()`, `agregar_conteo_cohorte()`, `agregar_promedio_cohorte()`. KPI de prioridad también por cohorte.
- Salida: cobertura 25.131 filas × 11 cols; rendimiento 67.876 × 10 cols.

## 4. Panel adversarial (recálculo independiente desde parquets crudos)

Código propio, sin llamar a las funciones de `32`. Todos **MATCH**.

**Contraste de conteos (inscripción 2025):**

| Entidad | actual | anterior | todas | indep==32 |
|---|---|---|---|---|
| nacional | 206.897 | 98.265 | 305.162 | MATCH |
| región 5 | 21.826 | 9.120 | 30.946 | MATCH |
| SLEP 503 (CC) | 882 | 242 | 1.124 | MATCH |
| comuna 5109 Viña | 3.533 | 1.670 | 5.203 | MATCH |
| comuna 5103 Concón | 538 | 195 | 733 | MATCH |
| comuna 5107 Quintero | 400 | 132 | 532 | MATCH |
| comuna 5105 Puchuncaví | 170 | 48 | 218 | MATCH |

Selección 2025 (nacional/SLEP 503) actual/anterior/todas: MATCH. `todas == actual + anterior` en inscripción (305.162) y selección (155.916).

**Aditividad territorial (aritmética, pre-supresión), inscripción·anterior 2025:** nacional 98.265 = Σ todas las comunas (98.265); región 5 = 9.120 = Σ sus comunas (9.120). Post-supresión: nacional 98.265 ≥ Σ comunas visibles 98.170 (24 celdas suprimidas) — correcto.

**Rendimiento (media CLEC reg, región 5), indep vs 32:** actual n=19.118 media=576,799; anterior n=6.093 media=623,871; todas n=25.211 media=588,176 — MATCH (media ponderada verificada). Señal real: la cohorte anterior puntúa más alto (repitentes/mejora).

Nota metodológica (corregida en el propio panel): comuna **no** es subconjunto de SLEP (un SLEP es un subconjunto transversal de establecimientos, no la unión de comunas); la aditividad válida es comuna→región→nacional, no comuna→SLEP.

## 5. Fase B — Toggle de 3 estados en `33`

- Segmented `Actual/Anteriores/Todas` (patrón `seg()`), aplicado a las **4 combinaciones** Foco×Vista en modo actual (ya no solo terr+actual). En terr+hist el control se oculta y muestra el rótulo de contexto (la serie histórica queda en "todas"; el encargo 2 la extiende — `activeCohorte()` centraliza esta regla).
- `covGet/renGet` ganan parámetro `coh` (default `"todas"`, backward-compatible). Consumidores cohorte-aware: `funnelStages`, `CobActual`, `prioridadKpiCard`, `retencionComunas`, `CobComp`, `meanBars`/`RenActual`, `RenComp`, export XLSX.
- **`genAntSlab` y `REZ_ID` eliminados** (no dejados muertos): el bloque nacional aparte se retiró de `CobActual`, el `rezStrip` de `CobHist`, y las filas REZ del XLSX (ahora por cohorte activa).
- **Fix de consistencia (CobComp):** la cohorte "anterior" no tiene egresados propios del año → la tabla de comparación rebasa a inscritos=100% (igual que el embudo de `CobActual`), y la columna Egresados muestra "—" (N/A), no "resguardo". Sin este fix, Comparar·Anteriores mostraba todo como "resguardo" (falso).

**Verificación en navegador (datos reales), spot-check vs parquet auditado en Fase A:**

- Cobertura·Actual (funnel, SLEP CC): actual inscritos 882 / selección 230; anterior inscritos 242 (egresados "—", rebase a inscritos) / selección 128; todas inscritos 1.124 / selección 358, prioridad 57% (204). `todas` == cifras pre-encargo.
- Cobertura·Comparar·Anteriores: Viña 1.670, Concón 195, Quintero 132, Puchuncaví 48 (== panel), rebasadas a inscritos=100%.
- Rendimiento·Actual (SLEP CC, CLEC): actual 531 (n=673) / anterior 602 (n=156) / todas 544 (n=829); 673+156=829, media ponderada correcta.
- Rendimiento·Comparar responde a cohorte; Histórica oculta el control y queda en "todas".
- 0 errores de consola; 0 `fontSize` numéricos nuevos; supresión respetada (celdas "resguardo").

## 6. Detenciones y aclaraciones declaradas (B.1)

- **Ninguna detención (a)/(b)/(c) gatillada** (ver §2).
- **Aclaración sobre "Actual = comportamiento por defecto" (encargo B1):** el default previo mostraba TODAS las cohortes (fresca + previas). Con la cohorte semánticamente correcta, eso corresponde a **"Todas"**, no a "Actual". "Actual" (generación fresca, egreso P-1) es ~68% del universo previo. Se mantuvo "Actual" como estado por defecto del control (según B1), pero el titular puede querer "Todas" por defecto si prefiere las cifras previas; queda señalado. La verificación "Todas = Actual + Anteriores" del propio encargo confirma esta lectura (aditiva).
- **Egresados denominador:** se mantiene la alineación pre-existente `agno == anio_proceso` (fuera de alcance); la cohorte "anterior" no tiene egresados propios, por eso su embudo/tabla se rebasa a inscritos.
