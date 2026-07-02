# Log — Bloque «Universo de seleccionados» en la tabla comparativa de Cobertura

**Fecha:** 2026-07-02
**Encargo:** autónomo — reemplazar el tratamiento visual de la Fase 2 anterior
(commit `1d22d44`: borde simple + flecha, rechazado por el titular «2/10») por el
bloque del handoff `Claude Design` (`CobComp`): banda de grupo + marco exterior.
**Archivo:** `30_procesamiento/33_motor_template.html` (+ `docs/index.html` regenerado).
**Commit:** `8a614c3` — `style(33): implementa bloque universo de seleccionados (banda + marco) segun handoff Claude Design`.

## Detención

**Ninguna.** Fase 0 verificada:

- **(a) Tokens:** `--plum:#153E5E`, `--line2:#C8BDA0`, `--fs-overline:12px`,
  `--fs-body:16px` **existen** en el `:root` (L10-16) con esos nombres/valores. No
  gatilla.
- **(b) Estructura de datos:** `covGet(id, anio, etapa, coh)` (L89) calza con la
  firma que el handoff asume; `gSel.pct1` y `gSel.np1` ya se consumen (la tabla los
  usaba antes). Helpers `nameCell`, `card`, `fmt`, `heatColor`, `SUP_SHORT`,
  `activeCohorte` existen con esos nombres exactos. No gatilla.

## Implementación

Se reemplazó por completo la función `CobComp` (y `supCell`) por la versión del
handoff, más las constantes `BRK`/`BRK_IN`. No quedó código muerto de la Fase 2
anterior (borde simple + flecha sin banda): fue sobrescrito íntegramente.

### Ajustes obligatorios aplicados

1. **`supCell` cambia de firma** `(key, leftBorder)` → `(key, bl, br)` (bordes izq/der
   como strings). Hay **un caller fuera de `CobComp`**: `RenComp` (L588,
   tabla de Rendimiento·Comparar), que pasaba un booleano. Se adaptó a
   `supCell(p.k, left?"1px solid var(--line2)":false)` para **preservar idéntico** su
   separador de columnas de contexto (1px var(--line2)). No se renombró ninguna
   función existente.
2. **Nota al pie — redacción de «Anteriores».** El handoff repetía la frase confusa
   «(sin egresados propios del año)». Se corrigió por la redacción ya validada:
   «(egresados en años previos al proceso actual, sin registro en la tabla de
   egresados de este año)». El resto del texto del handoff se mantuvo igual.
3. **Legend/footer:** el handoff sustituye el footer (heatLegend + swatch de
   supresión) por la nota explicativa única. `heatLegend` y `SUP_TXT` siguen
   usándose en otras vistas (`RenComp` L597, subtítulo L301, panel de info L772), así
   que no quedan como código muerto. La supresión se sigue explicando en el subtítulo
   de la card y el panel de info.

## Verificación en navegador (interfaz pura — mismo cálculo)

Preview sobre `docs/index.html` regenerado (Cobertura · Comparar territorios, 4
comunas Costa Central, admisión 2025). Medido por DOM/computed styles:

- **Banda de grupo** `colSpan=2` sobre Seleccionado + 1.ª prioridad; texto
  «UNIVERSO DE SELECCIONADOS · la 1.ª prioridad es % de este grupo»
  (`text-transform:uppercase`), color `rgb(21,62,94)` = `--plum`, fondo
  `rgba(21,62,94,0.05)`, `border-top` = `1.5px rgba(21,62,94,.42)` = `BRK`. ✓
- **Marco exterior `BRK`** cierra los cuatro lados: izq de Seleccionado
  (`1.5px rgba(21,62,94,.42)`), der de 1.ª prioridad (idem), arriba (banda), abajo en
  la última fila (Puchuncaví: `border-bottom` `1.5px rgba(21,62,94,.42)` en ambas
  celdas del grupo). ✓
- **Separación interna `BRK_IN`** entre las dos columnas: `1px rgb(200,189,160)` =
  `var(--line2)`, con flecha `→` (title «Se calcula sobre los seleccionados, no sobre
  egresados», color plum, `cursor:help`). ✓
- **Header «1.ª prioridad» en `--plum`** (`rgb(21,62,94)`). ✓
- **Heatmap P1 con rango propio (`rangoP1`)**, independiente de las demás columnas —
  confirmado con ≥2 territorios de `pct1` distinto:
  - Quintero `48%` → rojo `rgba(214,69,69,.45)` (mínimo del rango P1 = más alerta).
  - Puchuncaví `61%` → azul `rgba(13,130,190,.45)` (máximo del rango P1).
  - Viña `59%` / Concón `59%` → azul intermedio.
  El rango `[48, 61]` es exclusivo de P1 (los demás porcentajes del embudo son
  70-85%); si P1 compartiera rango con las otras columnas, 48-61% no mapearía a los
  extremos rojo/azul. ✓
- **Supresión:** la celda P1 suprimida usa `supCell("prioridad1", BRK_IN, BRK)`, con
  los mismos bordes de grupo (no rompe el marco). En esta vista no hubo filas P1
  suprimidas; verificado por código. ✓
- **0 errores de consola.** ✓
- **0 `fontSize` numéricos nuevos** — todo `var(--fs-overline)` / `var(--fs-body)` /
  `var(--fs-caption)`. ✓

Captura de referencia del handoff (banda + marco + flecha) reproducida: screenshot
tomado en sesión mostrando la banda «UNIVERSO DE SELECCIONADOS» y el marco plum
envolviendo Seleccionado + «→ 1.ª prioridad».

## Reproducción

- `run_all(only=33)` regenera `40_salidas/motor_paes.html` y `docs/index.html`.
- **No pusheado** — cambio local.
