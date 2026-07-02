# Log — Ajustes de interfaz v2 (post-cohorte territorial)

- **Fecha:** 2026-07-02
- **Tipo:** CONTINUATION (interfaz del motor `33` + rename en la suite). Depende del encargo `cohorte_territorial` (Fases A/B).
- **Archivo objetivo:** `30_procesamiento/33_motor_template.html` (+ `50_documentacion/suite/documentar.R` para el rename). Regenerado con `run_all(only=33)` tras cada fase.

## 0. Detención (a) — dependencia verificada

Los commits del encargo `cohorte_territorial` están en el historial: `250d2fa` (Fase A, `32`) y `92039e4` (Fase B, `33`). No se gatilla (a).

## 1. Commits (4 fases + 1 rename de invariante)

| Fase | Commit | Título |
|---|---|---|
| 1 | `c0133a0` | `style(33): retira chip territorio redundante en ContextStrip` |
| 2 | `18b2dbe` | `feat(33): desglose por comuna filtrable, renombra label` |
| 3 | `ecd38ba` | `feat(33): control de cohorte tambien disponible en vista historica` |
| 4 | `4baf854` | `feat(33): agrega serie seleccionado en 1ra preferencia al grafico historico de cobertura` |
| rename 🔒 | `81c8929` | `refactor(33,suite): renombra "generaciones anteriores" -> "cohortes anteriores"/"cohorte" en texto visible` |

El rename es el invariante de terminología (cruza motor + suite); se aisló en su propio commit atómico (un concepto por intervención), por eso son 5 hashes y no 4.

## 2. Fase 1 — Chip de territorio redundante retirado

`ContextStrip` (vista terr) ya no muestra el chip azul grande con el nombre del territorio (duplicaba `territoryBtn`). Queda solo el desglose por comuna; para territorios sin comunas hijas (comuna/nacional) la franja devuelve `null` (no se muestra vacía). Vista comp sin cambios. Verificado en navegador: SLEP Costa Central muestra el desglose (4 comunas) sin el chip.

## 3. Fase 2 — Desglose por comuna filtrable + rename del label

- Label `con desglose por comuna:` → **`Desglose por comuna`** (sentence case).
- Chips clicables (inclusión/exclusión con checkbox y tachado); al excluir, el embudo y la media de rendimiento se recomputan en cliente como suma / promedio-ponderado de las comunas incluidas (`covSel`/`renSel`); subtítulo `X de Y comunas`. La exclusión se limpia al cambiar de territorio.
- **Decisión de alcance declarada (el encargo pide evaluarla, B.1):** el filtro es EXACTO solo para **REGIÓN** (sus comunas la particionan; verificado en el panel de Fase A). Un **SLEP** es un subconjunto TRANSVERSAL de establecimientos (su total ≠ suma de comunas), así que ahí el desglose es **informativo** (chips no clicables); un filtro por comuna en SLEP requeriría una salida nueva de `32` (SLEP×comuna), fuera del alcance de interfaz de este encargo. Nacional no trae desglose. **Nota:** como el territorio por defecto es un SLEP, para probar el filtro hay que seleccionar una Región (p. ej. Valparaíso).
- Verificado (Región Valparaíso): excluir Algarrobo recomputa egresados 28.519→28.296 e inscritos 21.826→21.655 (exacto, sin comunas suprimidas en esas etapas); CLEC media 577, n 19.118→18.963 (media ponderada, == recomputo manual); re-incluir restaura.

## 4. Fase 3 — Cohorte en vista histórica

- El control de 3 estados (Actual/Anteriores/Todas) aplica también en `terr+hist` (y ya en comp). `activeCohorte()` devuelve siempre `s.cohorte`; `Controls` muestra siempre el segmented (se elimina el rótulo "Serie…").
- `CobHist`/`RenHist` consumen la cohorte vía `covSel`/`renSel` (respetan también el filtro de comunas). Base por año: egresados; en "Anteriores" (sin egresados propios) se rebasa a inscritos=100% (leyenda "% de inscritos"). Export XLSX histórico también por cohorte.
- Verificado (SLEP Costa Central, terr+hist): control visible; cohorte Anteriores cambia la leyenda a "% de inscritos" y la serie "rindió" a **[77,73,77,71]%** (== inscritos, spot-check vs índice); 2 polylines + 9 puntos.

## 5. Fase 4 — Nueva serie histórica "Seleccionado en 1.ª preferencia (% de egresados)"

- Tercera serie en "Participación en el tiempo", derivada de `n_prioridad_1` (de `32`) sobre el **mismo denominador** que las otras dos (egresados; inscritos en "anterior"), **no** de `pct_prioridad_1` (que divide por seleccionados). Color propio, sin rótulos por punto (nueva opción `noLabels` en `lineChart`). Si `n_prioridad_1` está suprimido o no hay denominador (2026 sin egresados en actual/todas), la serie deja **hueco**, no un cero falso.
- Fix asociado: el rebase a inscritos (Fase 3) se restringe a la cohorte "anterior"; en actual/todas un año sin egresados (2026) queda en hueco, sin mezclar bases entre años.
- **Detención (c) descartada:** `n_prioridad_1` disponible para 2023-2026 en todos los territorios (nacional/región/SLEP: no-NA los 4 años).
- **Auto-auditoría (2 spot-checks vs parquet, cohorte todas):**
  - SLEP Costa Central: `n_prioridad_1/egresados` = 136/933=**15%**, 148/1122=**13%**, 204/1434=**14%**, 2026 sin egresados → **hueco**. El chart muestra `[15,13,14, hueco]` (3 puntos). ✔
  - Nacional: 59.857/253.873=**24%**, 66.322/256.546=**26%**, 71.470/279.158=**26%**. ✔

## 6. Invariante 🔒 — rename de terminología (confirmación)

"Generaciones anteriores" → "Cohortes anteriores" / "Cohorte" en **texto visible**: control de 3 estados (ya usaba "Anteriores"/"Cohorte"), notas (`viewMeta`), `ContextStrip`, export XLSX y los 4 HTML de la suite (`documentar.R` + regenerar). Los identificadores internos no visibles no se tocan.

**Grep de confirmación (sobre los outputs generados):**
- `docs/index.html`: **0** "generaciones anteriores" en texto visible; 7 "cohortes anteriores".
- 4 `*_standalone.html` de la suite: **0** "generaciones anteriores" cada uno; siguen 100% offline (0 refs de red, 0 mojibake).

De paso se corrigió la nota metodológica del motor sobre "cohortes anteriores" (antes describía el bucket nacional obsoleto → ahora dice que se territorializan por el establecimiento de egreso, igual que la cohorte actual).

## 7. Detenciones

Ninguna de (a)/(b)/(c) gatillada: (a) commits del encargo previo presentes; (b) el rename no colisionó con identificadores de código; (c) `n_prioridad_1` disponible para todos los años.

## 8. Verificación transversal

`run_all(only=33)` sin abortar en las 4 fases; 0 errores de consola en las combinaciones probadas; 0 `fontSize` numéricos nuevos (todo `var(--fs-*)`). Sin push (gate del titular).
