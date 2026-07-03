# Encargo autónomo — Mejoras de interfaz del motor `slep_paes`

> Sigue el patrón de `encargo_autonomo_claude_code_v1.md`. Sesión CONTINUATION
> (no BIBLIOTECA): toca el pipeline/motor de `slep_paes`, no la suite de
> documentación.

## Modo y disciplina

Autónomo, secuencial, ejecuta las 3 fases en este turno, en el orden dado
(el reorden del header puede tocar el layout donde vive el toggle de
generaciones anteriores; verificar el bug después del reorden, no antes).
Rutas absolutas. R-only. Sin asumir `cd` previo.

## Regla de detención

PARA y reporta solo si:
(a) el mockup de la Fase 1 admite más de una interpretación de layout tras
    leer el CSS existente (no adivinar disposición exacta de píxeles);
(b) adaptar el modal de `ade` (Fase 2) exige decidir algo no cubierto por
    los invariantes de abajo (p. ej. cómo tratar "Nacional" si el límite de
    selección múltiple choca con la regla de "Comparar territorios");
(c) el fix del bug (Fase 3) revela que `showRez` se usa en otro lugar no
    detectado en este encargo, cambiando el diagnóstico.
En estos casos, reporta y espera.

## Contexto mínimo suficiente

- Proyecto: `slep_paes`, raíz `~/Projects/slep_paes` (Rama B).
- Archivo objetivo de las 3 fases: `30_procesamiento/33_motor_template.html`.
- Regenerar tras cada fase: `run_all(only = 33)` (o el paso equivalente que
  regenera `docs/index.html` desde el template).
- Componente fuente del selector (Fase 2): adjunto a continuación, extraído
  del motor de `slep_categoria_desempeno` (`ade`), función `AddEntityModal`
  (líneas 2768-3174 de su `33_motor_template.html`) y `SlepDisclaimer`
  (líneas 2753-2766). Referencia de estilo, no código a copiar literal:
  `slep_paes` no tiene nivel Establecimiento ni Grupo personalizado.

## Invariantes (🔒)

- 🔒 Sin nivel Establecimiento en el selector de `slep_paes` (política §6.4:
  no identificar establecimientos; el motor solo expone hasta comuna en la
  jerarquía de comparación, según `20260702_decision_camino_a_motor_33.md`).
  Los tabs a implementar son: **Comuna, SLEP, Región, Nacional** — nunca
  "Establecimiento" ni "Grupo personalizado" (esos dos son específicos de
  `ade`, fuera de alcance).
- 🔒 Escala tipográfica `--fs-*` (sesión 4): cualquier elemento nuevo del
  selector usa las variables existentes, mapeado por rol (ver patrón en
  `traspaso_cierre_v04.md` §13), nunca `px` sueltos.
- 🔒 `UMBRAL_SUPRESION_CELDA=8` y demás invariantes de gobernanza sin cambio;
  esta tarea es de interfaz, no toca `31`/`32` ni recalcula agregados.
- 🔒 "Generaciones anteriores" nunca "rezagados" en texto visible (el fix de
  Fase 3 no debe tocar el texto, solo el montaje condicional).
- 🔒 Un cambio conceptual por intervención: las 3 fases son independientes;
  commit atómico por fase, no mezclar.

## Fases en orden estricto

### Fase 0 — Lectura del estado real

1. Leer `30_procesamiento/33_motor_template.html` completo (no asumir
   contenido de memoria de sesiones previas).
2. Confirmar que las funciones referenciadas abajo (`Controls`, `seg`,
   `territoryBtn`, `genAntToggle`, `genAntSlab`, `CobActual`) existen con
   los nombres y líneas aproximadas citadas aquí; si el archivo cambió,
   releer antes de editar (no editar sobre memoria).

### Fase 1 — Reorden del header (Cobertura/Rendimiento + controles)

**Estado actual** (`Controls()`, función que arma `secondary` y `sub`):
fila `secondary` = Vista + Período (si vista=terr) + spacer + Territorio.
Fila `sub` = Cohorte (checkbox "Generaciones anteriores"), en fila aparte,
solo visible si `vista==="terr" && modo==="actual"`.

**Objetivo** (mockup del titular): eliminar la fila `sub` como fila
separada. Una sola fila con Territorio + Vista + Período + Cohorte, todos
en la misma línea. Layout: `Territorio` primero (dropdown/botón), luego
`Vista` (segmented "Por territorio"/"Comparar territorios"), luego
`Período` (segmented "Actual"/"Histórica", solo si vista=terr), luego
`Cohorte` (checkbox "Generaciones anteriores"), alineado a la derecha,
solo visible si vista=terr && modo=actual (misma condición que hoy).

Implementación: fusionar `secondary` y `sub` en un único `div` de
`Controls()`. Mantener `FocoTabs(ctx)` (la fila de Cobertura/Rendimiento)
sin cambios: el reorden es solo de la fila de controles, no de los tabs de
foco. Verificar que en `vista==="comp"` (donde no hay Período ni Cohorte)
la fila no quede con espacios rotos: usar el mismo patrón de
`s.vista==="terr" ? ... : null` que ya existe para omitir elementos, no
generar `div` vacíos.

**Verificación (B.4):** captura visual de las 6 combinaciones
Foco×Vista×Período; una sola fila de controles bajo los tabs de foco, sin
la franja `cream50` separada de antes; el toggle de Cohorte sigue
funcionando visualmente (aunque su bug de fondo se arregla en Fase 3).

**Commit:** `style(33): fusiona fila de controles y cohorte en una sola linea`.

### Fase 2 — Selector de territorio con patrón `ade`/`idps`

**Estado actual:** `territoryBtn(ctx)` abre `ctx.upd({modalOpen:true})`; el
modal resultante (buscar en el archivo la función que consume
`modalOpen`) usa jerarquía de radio buttons de selección única (ver
captura de referencia del titular: "Elegir territorio", lista indentada
Chile→Región→SLEP→Comuna con radio buttons).

**Objetivo:** reemplazar ese modal por el patrón de `AddEntityModal` de
`ade` (adjunto arriba): tabs por nivel territorial, buscador con
normalización de acentos (`norm()`, ya presente en `ade`, replicar función
si `slep_paes` no la tiene), checklist con multiselección cuando aplique
(`ade` limita por `slotsLibres`; en `slep_paes` aplicar el límite
equivalente que ya exista para "Comparar territorios", si existe uno; si
no existe un límite hoy, preguntar — no inventar un número, caso (b) de
regla de detención).

**Adaptación de tabs** (Comuna, SLEP, Región, Nacional — sin
Establecimiento ni Grupo):
- Tab Comuna: buscador + lista filtrada (patrón `filteredComunas` de
  `ade`, adaptado a los territorios reales de `slep_paes`: las 4 comunas
  de Costa Central más las demás comunas del país si el motor las expone;
  verificar contra los datos reales antes de asumir el universo).
- Tab SLEP: buscador + lista con nombre y comunas asociadas (sin el
  `SlepDisclaimer` de traspaso si `slep_paes` no maneja esa lógica de
  traspaso — verificar en Fase 0 si aplica; si no aplica, omitir el
  disclaimer, no copiarlo por inercia).
- Tab Región: buscador + lista.
- Tab Nacional: opción única "Chile".
- Selección única para "Por territorio" (como hoy); selección múltiple
  para "Comparar territorios" (ya existe `compSel` en el estado, según
  `ContextStrip` visto en Fase 0 — reusar esa estructura, no crear una
  paralela).

**Estilo visual:** reusar las clases CSS que ya trae `slep_paes` si las
tiene (buscar `modal`, `check-row`, `comuna-checklist` u equivalentes en
el `<style>` del archivo); si no existen, tomarlas del bloque de estilos
de `ade` (no adjunto aquí — si hace falta el CSS completo, es caso (b) de
detención: reportar y pedirlo, no inventar valores).

**Verificación (B.4):** modal abre con tabs, buscador filtra en vivo
(probar con "Viña", "Puchuncaví" con tilde y sin tilde), selección única
funciona en "Por territorio", selección múltiple funciona en "Comparar
territorios" con el mismo límite que el modal viejo respetaba, cierre sin
perder la selección previa al reabrir.

**Commit:** `feat(33): selector de territorio con tabs y buscador (patron ade)`.

### Fase 3 — Fix: toggle "Generaciones anteriores" no filtra

**Causa raíz (ya diagnosticada, no re-diagnosticar desde cero):**
`genAntSlab(ctx)` se renderiza siempre dentro de `CobActual()`
(`h("div",{key:"rz",...}, genAntSlab(ctx))`, sin condicional de montaje).
El único efecto de `ctx.state.showRez` dentro de `genAntSlab` es opacidad
(1 vs 0.55) y el texto explicativo; el bloque nunca se retira del DOM. El
propio texto generado cuando `showRez=false` dice "Categoría oculta del
detalle" (contradice el comportamiento real: nunca se oculta).

**Fix:** en `CobActual(ctx)`, condicionar el montaje del bloque
`genAntSlab` a `ctx.state.showRez`:

```js
// Antes:
h("div",{key:"rz",style:{marginTop:"14px"}}, genAntSlab(ctx))
// Después:
ctx.state.showRez ? h("div",{key:"rz",style:{marginTop:"14px"}}, genAntSlab(ctx)) : null
```

Insertar en el array `out` de `CobActual` con el mismo patrón condicional
que ya usa `ret` (`if(ret) out.push(...)`) para no romper el orden de
`key`s del array.

Decisión de diseño a verificar con el resultado, no a priori: cuando
`showRez=false`, ¿el bloque desaparece completamente (comportamiento del
fix arriba) o se reemplaza por un indicador colapsado (p. ej. una línea
"Generaciones anteriores: oculto, [mostrar]")? El texto actual promete
"oculto" pero el toggle vive en el header (Fase 1), así que un usuario que
oculte el bloque y no recuerde dónde está el toggle podría confundirse.
**Usar la opción simple (desaparece del todo)** salvo que el titular pida
lo contrario al revisar — no es invariante, es supuesto razonable
declarado aquí explícitamente (B.1).

**Verificación (B.4):** con `showRez=true` (default), el bloque de
generaciones anteriores aparece en Cobertura·Actual, igual que antes. Con
`showRez=false` (clic en el toggle), el bloque desaparece del DOM
(inspeccionar, no solo mirar opacidad). Alternar el toggle repetidamente
sin recargar: el bloque aparece/desaparece de forma consistente. Ningún
otro consumo de `showRez` en el archivo queda huérfano (grep final debe
mostrar los mismos 3 usos de antes, ahora con el tercero condicionando
montaje, no opacidad).

**Commit:** `fix(33): toggle generaciones anteriores ahora oculta el bloque, no solo atenua opacidad`.

## Criterios de éxito verificables (B.4) — consolidado

- Fase 1: 1 sola fila de controles bajo los tabs de foco, verificado en las
  6 combinaciones Foco×Vista×Período, sin franja separada de Cohorte.
- Fase 2: modal con 4 tabs (Comuna/SLEP/Región/Nacional), buscador con
  normalización de acentos operativo, selección única/múltiple según vista.
- Fase 3: `showRez=false` retira el bloque del DOM (no solo opacidad
  reducida); `showRez=true` lo restaura.
- Las 3 fases: `run_all(only=33)` sin abortar, 0 errores de consola, 0
  `fontSize` numéricos nuevos introducidos (Fase 1/2 deben usar `--fs-*`).

## Mandato de auto-auditoría

Sin riesgo de datos (interfaz pura, no recalcula agregados ni toca
gobernanza de datos): basta el principio general (verificar en navegador
las 3 fases, no reportar sobre supuesto). No se requiere panel adversarial.

## Mandato del log y reporte final

Generar `50_documentacion/andamios/logs/20260702_mejoras_interfaz_log.md`
(plantilla fija). Reportar en el chat: 3 hashes de commit (uno por fase),
capturas o descripción verificada de las 6 combinaciones tras Fase 1,
confirmación de que el grep de `showRez` muestra el tercer uso corregido,
y cualquier caso (a)/(b)/(c) de detención que se haya gatillado.
