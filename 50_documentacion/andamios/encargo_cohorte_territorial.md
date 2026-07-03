# Encargo autónomo — Cohorte por territorio real (RBD histórico) + toggle 3 estados

> Sigue `encargo_autonomo_claude_code_v1.md`. Cambio de alcance real sobre el
> pipeline (no solo interfaz): extiende `32_agregar_territorial.R`, luego
> `33_generar_html.R` + `33_motor_template.html`. Corrige un defecto de diseño
> de la Fase 3 anterior (commit `4c063e9`): el toggle solo mostraba/ocultaba
> un bucket nacional aparte; nunca filtró el embudo ni el rendimiento reales.

## Modo y disciplina

Autónomo, secuencial. Fase de pipeline (`32`) antes que la de interfaz (`33`):
sin el dato nuevo, `33` no tiene qué consumir. Rutas absolutas. R-only.

## Regla de detención

PARA y reporta solo si:
(a) el RBD de egreso histórico no está disponible como columna en el insumo
    que usa `32` para clasificar generaciones anteriores (verificar antes de
    asumir que existe con ese nombre exacto);
(b) un mismo `ID_aux` tiene más de un RBD de egreso histórico registrado
    (ambigüedad de asignación territorial, no resoluble sin regla adicional);
(c) el volumen de combinaciones territorio×año×etapa×cohorte excede lo que
    `UMBRAL_SUPRESION_CELDA=8` puede aplicar de forma consistente con el
    resto del pipeline (i.e., si aparece un patrón de supresión distinto al
    ya usado en `32` para la cohorte actual).

## Contexto mínimo suficiente

- Proyecto `slep_paes`, raíz `~/Projects/slep_paes` (Rama B).
- Estado actual: `COV` (estructura consumida por `33`) está indexado por
  `tipo|cod|anio|etapa`, **sin dimensión de cohorte**. El bucket
  "generaciones anteriores" hoy es una entidad territorial aparte
  (`REZ_ID = "rezagados:"+M.rezagados_label`), agregado **nacional único**,
  sin cruce con comuna/SLEP/región. Esto es lo que hay que cambiar.
- Fase 3 de la sesión anterior (commit `4c063e9`) ya corrigió un bug menor
  (el toggle no retiraba del DOM el bloque nacional aparte), pero ese fix
  **no resuelve** este encargo: el diseño de fondo cambia aquí.

## Invariantes (🔒)

- 🔒 `UMBRAL_SUPRESION_CELDA=8`: aplica igual a la cohorte "anteriores" y a
  la combinación "todas" que a la cohorte "actual" hoy. No relajar el umbral
  para compensar universos más chicos por comuna.
- 🔒 Llaves territoriales (RBD, códigos comunales) siempre `character`.
- 🔒 Columnas por nombre, nunca por posición.
- 🔒 "Generaciones anteriores" nunca "rezagados" en texto visible.
- 🔒 Sin nombres de establecimientos en ningún output (el RBD histórico se
  usa para territorializar, nunca se expone como nombre de colegio).
- 🔒 Rama B: el RBD histórico y su cruce viven en los parquets de
  `SLEP_PAES_DATA_ROOT`; nada de esto se versiona en el repo.
- 🔒 Un cambio conceptual por intervención: Fase A (pipeline) y Fase B
  (interfaz) son commits separados, no mezclar.

## Fase A — Extender `32_agregar_territorial.R`: cohorte por RBD histórico

### A0 — Lectura del estado real

1. Leer `32_agregar_territorial.R` completo: cómo se construye hoy el bucket
   `REZ_ID` (bucket nacional), qué columna usa para detectar "sin RBD de
   egreso vigente en el año", y si el dato crudo ya trae un RBD de egreso
   histórico distinto del RBD del año actual.
2. Verificar en los insumos (ArchivoB / egresados MINEDUC, según
   corresponda) si existe una columna de RBD de egreso histórico por
   persona/`ID_aux`. Si el nombre no es obvio, confirmar contra el schema
   real antes de asumir (mismo aprendizaje que `orden_pref` en sesión 4:
   no asumir nombre de columna sin verificar).
3. Confirmar la regla de negocio: una persona "generación anterior" en el
   año X es quien rinde sin RBD de egreso vigente **ese año**, pero sí tiene
   un RBD de egreso registrado en un año anterior. Ese RBD histórico es la
   llave territorial a usar (regla ya confirmada por el titular: "cada
   estudiante pertenece a un RBD, del cual salió egresado").

### A1 — Cruzar generaciones anteriores al árbol territorial completo

- Construir el agregado de generaciones anteriores **por el mismo árbol**
  que ya usa la cohorte actual: RBD histórico → comuna → SLEP → región →
  nacional (reusar los catálogos de `30_construir_auxiliares.R`, no
  duplicar lógica de mapeo territorial).
- Aplicar exactamente las mismas reglas de cálculo que la cohorte actual
  para cada etapa del embudo (Cobertura) y cada prueba (Rendimiento):
  mismo umbral de supresión, misma definición de etapas, mismo cálculo de
  media.
- Salida: agregar una dimensión `cohorte` (valores: `"actual"`,
  `"anterior"`) a la estructura que `32` ya produce, en vez de mantener el
  bucket nacional como entidad territorial separada. Decidir el nombre de
  columna/estructura exacto según el esquema real de `32` (verificar en
  A0, no inventar un esquema paralelo).
- El bucket nacional-agregado-único (`REZ_ID`) queda deprecado por este
  cambio: las cifras de "generaciones anteriores, nacional" pasan a ser
  simplemente `tipo="nacional" & cohorte="anterior"`, coherente con el
  resto del árbol.

**Verificación (B.4):** para al menos 2 comunas de Costa Central, contraste
manual: suma de generaciones-anteriores por comuna agregadas hasta SLEP
coincide con el SLEP directo; suma de SLEPs hasta región coincide con
región; suma de regiones hasta nacional coincide con el valor que hoy
produce `REZ_ID` (mismo total, ahora desagregado). Panel adversarial:
recálculo independiente desde parquets crudos para al menos 3 combinaciones
territorio×año, cohorte="anterior", ambos focos (Cobertura y Rendimiento).

**Commit:** `feat(32): agrega cohorte anterior cruzada por RBD historico al arbol territorial completo`.

## Fase B — Toggle de 3 estados en `33`

### B0 — Lectura del estado real (post-Fase A)

Releer `32` regenerado y confirmar el esquema exacto de la nueva dimensión
`cohorte` antes de tocar `33` (no asumir el resultado de A1 de memoria).

### B1 — Reemplazar `genAntToggle` (checkbox binario) por control de 3 estados

- Reemplazar el checkbox "Generaciones anteriores" por un control con 3
  opciones: **Actual** (default), **Anteriores**, **Todas**. Sugerido:
  segmented control (mismo patrón visual que `seg()`, ya usado para
  Vista/Período) con label "Cohorte", no checkboxes — un control de 3
  estados mutuamente excluyentes no es una lista de checkboxes.
- Aplica a **las 4 combinaciones**: Cobertura×Por territorio,
  Cobertura×Comparar, Rendimiento×Por territorio, Rendimiento×Comparar
  (confirmado por el titular). Elimina la restricción actual de que el
  control solo aparecía en `vista==="terr" && modo==="actual"`.
- Semántica: "Actual" = filtra `cohorte="actual"` (comportamiento por
  defecto, igual a la interfaz previa a este encargo). "Anteriores" =
  filtra `cohorte="anterior"`. "Todas" = suma ambas cohortes en el mismo
  territorio (verificar si `32` debe producir el total pre-sumado o si
  `33` lo suma en cliente desde las dos filas; preferir que `33` sume en
  cliente si ambas filas están disponibles, para no triplicar columnas en
  el parquet — decisión técnica a confirmar en A0/B0 según el volumen
  real).

### B2 — Adaptar consumidores de `COV`/`REN`

- `funnelStages`, `covGet`, `renGet`, `CobActual`, `CobComp`, `RenActual`,
  `RenComp` y cualquier otro consumidor deben leer la dimensión `cohorte`
  nueva. Sustituir el consumo actual de `REZ_ID` como territorio aparte.
- `genAntSlab` (el bloque de la Fase 3 anterior) queda obsoleto con este
  cambio: sus cifras se integran directamente en el embudo/rendimiento del
  territorio seleccionado, no como bloque aparte. Retirarlo del render
  (`CobActual`), no dejarlo muerto en el código.
- `ContextStrip`, exportación a Excel y cualquier otro lugar que lea
  `REZ_ID` directamente: actualizar al nuevo esquema.

**Verificación (B.4):** las 4 combinaciones muestran cifras distintas y
correctas al alternar Actual/Anteriores/Todas (spot-check contra el
parquet regenerado en Fase A, para 2 territorios). "Todas" en un territorio
= suma verificable de "Actual" + "Anteriores" del mismo territorio (dentro
de la tolerancia de redondeo esperada). Supresión de celdas chicas se
respeta en los 3 estados. 0 errores de consola. 0 `fontSize` numéricos
nuevos.

**Commit:** `feat(33): toggle de cohorte de 3 estados (actual/anteriores/todas) integrado al embudo y rendimiento`.

## Mandato de auto-auditoría

**Riesgo de datos real** (cambia agregados publicados, no solo interfaz):
panel adversarial obligatorio para Fase A, re-derivando desde parquets
crudos, no desde el propio output de `32`. Fase B (consumo en `33`) basta
con verificación en navegador contra el parquet ya auditado en Fase A.

## Mandato del log y reporte final

Generar `50_documentacion/andamios/logs/20260702_cohorte_territorial_log.md`.
Reportar: 2 hashes de commit, tabla de contraste manual (comuna→SLEP→región→
nacional) de Fase A, resultados del panel adversarial, spot-check de las 4
combinaciones de Fase B, y cualquier detención (a)/(b)/(c) gatillada.
