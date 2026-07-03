# Log — Fix: cohorte «Todas» con porcentajes >100% en cobertura

**Fecha:** 2026-07-02
**Encargo:** autónomo — bug en `CobComp` (commit `8a614c3`): en cohorte «Todas» el %
se calculaba sobre `egresados` (solo cohorte actual) con numerador actual+anterior →
valores >100% (ej. Viña 118%, 5.203 sobre 4.418 egresados).
**Archivo:** `30_procesamiento/33_motor_template.html` (+ `docs/index.html` regenerado).
**Commit:** `175787b` — `fix(33): rebasa a inscritos el denominador de cohorte todas, evita porcentajes sobre 100`.

## Detención

**Ninguna.** El criterio de rebase para «Todas» es el mismo que «Anteriores» (rebasar
a inscritos), por analogía directa: en ambas cohortes el numerador de cada etapa
mezcla generaciones (más personas que los egresados del año), así que `egresados` no
es un denominador válido. No aplica la regla de detención.

## Causa raíz

El denominador de cobertura (`baseN`/`baseY`/base del embudo) tomaba `egresados` como
base siempre que existiera. Para «actual» es correcto. Para «anterior» ya se rebasaba
a inscritos. Para «todas», `egresados` sigue existiendo (= cohorte actual, ~4.418 en
Viña) y se usaba como base, pero cada etapa en «todas» suma actual+anterior (~5.203) →
denominador (solo actual) < numerador (mixto) → % >100%.

## Alcance real del fix (más de una función → log)

El mismo patrón de bug estaba **duplicado** en las tres vistas de cobertura y en el
export XLSX. Todas comparten la causa raíz, así que se corrigen en el mismo commit.

Helper compartido nuevo (tras `covSel`):

```js
function baseCob(id, anio, coh){
  if(coh==="actual"){ var eg=covGet(id,anio,"egresados",coh);
    if(eg&&!eg.sup&&eg.n) return eg.n; }
  var ins=covGet(id,anio,"inscripcion",coh);
  return (ins&&!ins.sup&&ins.n) ? ins.n : null;
}
```

Sitios corregidos:

1. **`CobComp` (tabla comparativa).** `baseN(id)` → delega en `baseCob`. La columna
   **«Egresados» muestra «—»** cuando `coh!=="actual"` (no hay cifra única de
   egresados para un universo mixto).
2. **`CobActual` (embudo de un territorio).** `funnelStages` neutraliza el stage
   `egresados` (n=null, present=false) cuando `coh!=="actual"`, de modo que
   `funnelSvg` toma como base el primer stage no nulo = inscritos (100%) y el slab de
   egresados se rotula «—». Espeja cómo «anterior» ya funcionaba (donde
   egresados-anterior es naturalmente ausente).
3. **`CobHist` (serie histórica).** `baseY(y)` inline: «actual» conserva
   egresados-o-hueco por año (sin mezclar bases entre años; 2026 sin egresados queda
   en hueco); «anterior»/«todas» rebasan a inscritos. `baseLbl` pasa a
   `coh==="actual" ? "% de egresados" : "% de inscritos"`.
4. **Export XLSX** (`comp`/`hist`/`actual`): los tres modos dividían por egresados
   (`st.n/eg.n`, base `eg?..:ins`, `g.n/eg2.n`). Ahora usan `baseCob`; la columna/fila
   de egresados muestra «—» en cohorte mixta y las etiquetas de base se adaptan. Se
   corrige para que el archivo descargado no contradiga la pantalla.
5. **Notas cohorte-conscientes** (consecuencia del cambio de base, para no mostrar
   «% sobre egresados» junto a «—»):
   - Subtítulo comparativo: `sobre "+(activeCohorte(s)==="actual"?"egresados":"inscritos")`.
   - Nota histórica: «en «Anteriores» y «Todas», sin una cifra única de egresados del
     año, la serie se expresa sobre inscritos».
   - Nota al pie de `CobComp`: se **preserva** la redacción aprobada de «Anteriores» y
     se añade «—y en «Todas», que la incluye—».

`CobHist` (pantalla) usa `covSel` (respeta exclusión de comunas) y difiere de
`CobComp`/export (`covGet`) en el caso «actual» sin egresados: en pantalla deja hueco;
por eso su `baseY` es inline y no usa `baseCob`. Sin cambios de cálculo en `32`
(`pct_prioridad_1` intacto): interfaz pura.

## Verificación en navegador (B.4)

Preview sobre `docs/index.html` regenerado, 4 comunas Costa Central, admisión 2025.

**Cohorte «Todas» — `CobComp` (tabla):**

| Territorio | Egresados | Inscritos | Rindió | Válidos | Postuló | Seleccionado | 1.ª prioridad | >100% |
|---|---|---|---|---|---|---|---|---|
| Viña del Mar | — | 100% (5.203) | 86% | 82% | 65% | 55% | 57% | no |
| Concón | — | 100% (733) | 89% | 85% | 65% | 57% | 58% | no |
| Quintero | — | 100% (532) | 82% | 78% | 51% | 42% | 49% | no |
| Puchuncaví | — | 100% (218) | 80% | 77% | 39% | 34% | 59% | no |

Viña: 5.203 pasó de ser numerador con 118% a ser la base (100%). Ningún % >100%.

**Cohorte «Todas» — `CobActual` (embudo):** Egresados «—»; Inscritos 100% (1.124);
Rindió 77,0% → Seleccionado 31,9%; ningún >100%.

**Cohorte «Todas» — `CobHist` (serie):** máximo 78% (antes rindió-todas/egresados-
actual daba >100%); ningún >100%.

**Regresión (sin cambios):**
- «Actual»: Egresados con cifra (Viña 4.418), Inscritos 80% (% de egresados), ≤100%.
- «Anteriores»: Egresados «—», Inscritos 100%, ≤100%.

**Notas:** subtítulo bajo «Todas» = «Comparación en porcentaje sobre **inscritos**…».
**0 errores de consola.**

## Reproducción

- `run_all(only=33)` regenera `40_salidas/motor_paes.html` y `docs/index.html`.
- **No pusheado** — cambio local.
