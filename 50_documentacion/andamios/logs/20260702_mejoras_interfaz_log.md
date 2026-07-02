# Log — Mejoras de interfaz del motor `slep_paes` (Fases 1–3)

- **Fecha:** 2026-07-02
- **Tipo de sesión:** CONTINUATION (toca el motor, no la suite de documentación).
- **Archivo objetivo:** `30_procesamiento/33_motor_template.html` (regenerado con `run_all(only=33)` tras cada fase).
- **Entorno:** Claude Code, `~/Projects/slep_paes`, R-only, macOS. Datos reales desde `SLEP_PAES_DATA_ROOT` (Rama B).
- **Corrección de ruta aplicada:** el componente fuente de la Fase 2 (`AddEntityModal` / `SlepDisclaimer`) NO está en `slep_categoria_desempeno` (como decía el encargo) sino en **`slep_simce_adecuado`** (`33_motor_template.html`, líneas 2753–3174, que calzan exacto). Se usó esa fuente como referencia de patrón.

## 1. Commits (uno por fase, atómicos, sin push)

| Fase | Commit | Título |
|---|---|---|
| 1 | `e90edc4` | `style(33): fusiona fila de controles y cohorte en una sola linea` |
| 2 | `15695ff` | `feat(33): selector de territorio con tabs y buscador (patron ade)` |
| 3 | `4c063e9` | `fix(33): toggle generaciones anteriores ahora oculta el bloque, no solo atenua opacidad` |

Cada commit incluye el template y su `docs/index.html` regenerado. **NO push** (gate del titular).

## 2. Fase 0 — Lectura del estado real

Se leyó el template completo (696 líneas; usa `h(...)` hyperscript pre-transpilado, no JSX). Confirmadas las funciones ancla: `Controls`, `seg`, `FocoTabs`, `territoryBtn`, `genAntToggle`, `genAntSlab`, `CobActual`, `Modal`, y el estado (`showRez`, `compSel`, `modalOpen`, `modalQuery`, `terrSel`). Confirmado el modelo de datos territorial (`T.{nacional,regiones,sleps,comunas}`, `terrName/terrParse`, `CC`). Confirmado que **no** existía `norm()` (el buscador usaba `toLowerCase` sin normalizar acentos) y que **`T.sleps` no trae `anio_traspaso`** → la lógica de traspaso municipal (y por tanto `SlepDisclaimer`) **no aplica** en `slep_paes`.

## 3. Fase 1 — Reorden del header (una sola fila de controles)

- **Cambio:** `Controls()` fusiona las dos filas (`secondary` + `sub`) en una única fila bajo `FocoTabs`: Territorio, Vista, Período (solo `vista=terr`) y, a la derecha, Cohorte (solo `terr+actual`) o el rótulo de contexto (serie histórica / comparación) que antes vivía en `sub`. Se eliminó la franja `cream50` separada.
- **Sin divs vacíos:** los elementos opcionales se omiten con `s.vista==="terr" ? ... : null` (Período) y el ternario Cohorte/hint; no se generan contenedores vacíos.
- **Tipografía:** reusa `lbl()`/`seg()`/`genAntToggle()` existentes → 0 `fontSize`/`px` numéricos nuevos (solo `var(--fs-*)`).
- **Verificación (navegador):** las 4 disposiciones distintas de la fila (= 6 combos Foco×Vista×Período, el foco solo cambia color) sin layout roto ni errores de consola:
  - terr·actual → Territorio · Vista · Período · Cohorte.
  - terr·hist → Territorio · Vista · Período · rótulo "Serie …".
  - comp·(actual/hist) → Territorio · Vista · rótulo "Comparación …" (sin Período ni Cohorte).
- **Nota de ancho (declarada, B.1):** el ancho intrínseco de la fila es ~1305 px; el contenedor es `max-width:1320px`. A ancho desktop (≥~1320 px) es **una sola línea** con Cohorte a la derecha (verificado con zoom efectivo 1440 → `mismaLinea:true`). Bajo ~1300 px la fila **hace wrap** responsivo (Cohorte pasa a una segunda línea): comportamiento estándar de `flex-wrap`, sin espacios rotos, no un defecto. El preview de esta sesión topa en 1008 px, por eso se verificó el caso desktop vía zoom-out.

## 4. Fase 2 — Selector de territorio con tabs y buscador (patrón `ade`)

- **Cambio:** se reemplazó el modal de árbol (radio buttons indentados Chile→Región→SLEP→Comuna) por el patrón de `AddEntityModal`: 4 tabs por nivel + buscador con normalización de acentos + checklist.
- **Tabs:** Comuna, SLEP, Región, Nacional. **Sin** Establecimiento ni Grupo personalizado (POLÍTICA 6.4 / decisión Camino A: el motor no baja de comuna). Esos dos tabs de `ade` quedaron deliberadamente fuera.
- **`norm()`** nueva (global): `String(s).normalize("NFD").replace(/[̀-ͯ]/g,"").toLowerCase()`. En el tab Comuna filtra por nombre y por región.
- **Selección:** única (radio/círculo) en "Por territorio" → fija `terrSel` y cierra; múltiple (checkbox/cuadrado) en "Comparar territorios" reusando `compSel`, con el **mismo límite de 10** que respetaba el modal viejo (las filas no seleccionadas se deshabilitan al llegar a 10).
- **`SlepDisclaimer` OMITIDO** (no se copió por inercia): `slep_paes` no maneja lógica de traspaso municipal (`T.sleps` sin `anio_traspaso`).
- **Estado nuevo:** `modalTab` (default `"comuna"`); `territoryBtn` abre en el tab del nivel actualmente seleccionado y resetea `modalQuery`; cambiar de tab resetea la búsqueda.
- **Universo verificado (no asumido):** el motor expone **332 comunas** (nacional), no solo las 4 de Costa Central. Región del catálogo resuelta vía `terrName("region:"+cod)`.
- **Verificación (navegador):**
  - Abre con 4 tabs; abre en el tab del nivel seleccionado (SLEP por defecto, porque `terrSel` inicial es un SLEP).
  - Buscador acento-insensible: `vina`→Viña del Mar; `Viña`→Viña del Mar; `puchuncavi`→Puchuncaví; `PUCHUNCAVÍ`→Puchuncaví.
  - Selección única: clic en Puchuncaví fija el territorio y cierra el modal (el botón pasa a "Puchuncaví").
  - Selección múltiple: se agregaron comunas hasta 10; al llegar a 10, las 322 filas no seleccionadas quedan deshabilitadas y las 10 seleccionadas siguen clicables (para deseleccionar). El botón muestra "Comparar 10 territorios".
  - Reapertura conserva la selección (10 elegidos tras cerrar/reabrir).
  - 0 errores de consola.

## 5. Fase 3 — Fix del toggle "Generaciones anteriores"

- **Causa raíz (confirmada contra el código real):** `genAntSlab(ctx)` era un elemento fijo del array `out` de `CobActual` (`h("div",{key:"rz",...}, genAntSlab(ctx))`), montado **siempre**; `showRez` dentro de `genAntSlab` solo controlaba `opacity` (1 vs 0.55) y el texto. El bloque nunca salía del DOM; el propio texto del estado off ("Categoría oculta del detalle") contradecía el comportamiento real.
- **Fix (solo montaje condicional):**
  1. `CobActual`: el bloque se monta con `if(ctx.state.showRez) out.push(h("div",{key:"rz",...}, genAntSlab(ctx)))`, con el **mismo patrón condicional que `ret`** (`if(ret) out.push(...)`), preservando el orden de `key`s.
  2. `genAntSlab`: deja de leer `showRez` (se retira la `opacity` constante y la rama de texto inalcanzable del estado off). La **copia visible del estado visible se conserva verbatim**; no se renombra "generaciones anteriores" a "rezagados".
- **Decisión de diseño (B.1, declarada):** cuando `showRez=false` el bloque **desaparece del todo** (opción simple que pide el encargo), no se reemplaza por un indicador colapsado. Queda a criterio del titular si prefiere lo contrario.
- **Interpretación del invariante 🔒 "no tocar el texto, solo el montaje condicional":** se leyó como "el fix es el montaje condicional y no reescribe la copia visible". Se cumplen ambas cosas: el arreglo es el montaje, y la copia del estado visible queda intacta. El único texto retirado es la rama `else` inalcanzable (que el propio encargo señaló como contradictoria). Esta lectura es la única que satisface también el criterio de verificación "grep muestra los 3 usos, el tercero condicionando montaje, no opacidad".
- **Grep final de `showRez` (código, excluye comentarios):** 3 usos conceptuales — init (`showRez:true`), toggle (`var on=ctx.state.showRez` + `ctx.upd({showRez:!on})`), y montaje en `CobActual` (`if(ctx.state.showRez)`). `genAntSlab` ya **no** consume `showRez`. Ningún consumo huérfano.
- **Verificación (navegador):** `showRez=true` (default) → bloque en el DOM; clic en el toggle (`showRez=false`) → bloque **retirado del DOM** (comprobado por ausencia del nodo, no por opacidad); alternar repetido (on/off/on/off) consistente; 0 errores de consola.

## 6. Reglas de detención

Ninguna de (a)/(b)/(c) se gatilló:
- (a) mockup Fase 1: layout suficientemente determinado (una fila; se declaró la nota de ancho/wrap como supuesto razonable, no como ambigüedad bloqueante).
- (b) modal `ade`: el límite de "Comparar territorios" (10) ya existía → no hubo que inventar número; "Nacional" es una entidad más dentro del límite, sin conflicto.
- (c) `showRez`: todos sus usos estaban previstos por el encargo; no apareció un consumo oculto.

Sí se corrigió, fuera de las reglas de detención, la **ruta de la fuente** de la Fase 2 (`slep_simce_adecuado`, no `slep_categoria_desempeno`), verificada por coincidencia exacta de líneas.

## 7. Criterios de éxito (consolidado)

- Fase 1: 1 sola fila de controles bajo los tabs de foco (a ancho desktop), 6 combos sin layout roto. ✅
- Fase 2: modal con 4 tabs (Comuna/SLEP/Región/Nacional), buscador acento-insensible, selección única/múltiple con cap 10. ✅
- Fase 3: `showRez=false` retira el bloque del DOM; `showRez=true` lo restaura. ✅
- Las 3 fases: `run_all(only=33)` sin abortar, 0 errores de consola, 0 `fontSize` numéricos nuevos (solo `var(--fs-*)`). ✅
