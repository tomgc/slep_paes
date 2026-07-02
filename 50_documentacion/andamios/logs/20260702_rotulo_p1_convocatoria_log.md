# Log — Rótulo «1.ª prioridad», marca visual de cambio de base, y conteo invierno/regular

**Fecha:** 2026-07-02
**Encargo:** autónomo, 3 fases independientes (rótulo + marca visual + criterio de conteo).
**Archivos tocados:** `30_procesamiento/33_motor_template.html`, `docs/index.html` (regenerado por `run_all(only=33)`).

## Resumen ejecutivo

- **Fase 1 (rótulo):** hecha. Commit `363d55a`.
- **Fase 2 (marca visual):** hecha y verificada (B.4). Commit `1d22d44`.
- **Fase 3 (conteo invierno/regular):** **DETENCIÓN (a) gatillada.** No se implementó
  cambio de cálculo ni se agregó la nota de «participaciones» (habría sido falsa).
  Sin commit. Se reporta con cifras y se espera decisión del titular.

## Hashes

| commit | fase | descripción |
|--------|------|-------------|
| `363d55a` | 1 | `style(33): renombra Prioridad 1 a 1.ra prioridad en texto visible` |
| `1d22d44` | 2 | `style(33): marca visual de cambio de base en columna 1ra prioridad` |
| — | 3 | sin commit — detención (a) |

## Fase 1 — Rótulo «1.ª prioridad»

Grep exhaustivo (case-insensitive) sobre el template: solo **dos** ocurrencias de
texto visible con «Prioridad 1»:

- Header de la tabla comparativa (`heads`, L481).
- Nota metodológica de Cobertura·Comparar (L518).

Ambas reemplazadas por «1.ª prioridad». No se tocó:
- `n_prioridad_1` / `pct_prioridad_1` (identificadores de código y del JSON).
- Comentarios `.R`/`.html` internos (no son texto visible).
- El título de card «Prioridad de la carrera seleccionada» (L394), que es otro rótulo,
  no «Prioridad 1».

Verificado en `docs/index.html`: 2 ocurrencias visibles de «1.ª prioridad», 0 de
«Prioridad 1» como header/nota.

## Fase 2 — Marca visual de cambio de base

Objetivo: señalar que «1.ª prioridad» cambia de denominador (seleccionados, no
egresados) sin depender solo de la nota.

Implementado en `CobComp` (tabla de Cobertura·Comparar):

- **Borde izquierdo más oscuro** `2px solid var(--line2)` (#C8BDA0) en la celda de
  cabecera y en las celdas del body de la columna «1.ª prioridad» (suprimida y no
  suprimida). Se reutilizó el parámetro `leftBorder` de `supCell` (existía y no se
  usaba con `true` en ningún llamado; se reforzó 1px→2px, sin efecto sobre los
  llamados actuales que pasan `false`).
- **Flecha `→`** al inicio de la cabecera «1.ª prioridad» (lectura «Seleccionado →
  1.ª prioridad»), con `title="% sobre seleccionados, no sobre egresados"` y
  `cursor:help` al hover.
- Heatmap y lógica de cálculo intactos: solo señal visual.

**Verificación (B.4)** vía preview sobre `docs/index.html` regenerado (Cobertura ·
Comparar territorios):

- Cabecera renderiza `→1.ª prioridad`; `span[title]` = «% sobre seleccionados, no
  sobre egresados».
- `border-left` cabecera = `2px solid rgb(200,189,160)` = `#C8BDA0` = `var(--line2)`.
- `border-left` celda body = `2px solid rgb(200,189,160)`; celda muestra
  `59% (1.060)` (heatmap presente).
- 0 `fontSize` numéricos nuevos (la flecha hereda `var(--fs-overline)` de la `th`).
- 0 errores de consola.
- Captura visual tomada: separación vertical visible entre «Seleccionado» y
  «→ 1.ª prioridad».

## Fase 3 — Conteo invierno/regular: **DETENCIÓN (a)**

### Fase 0 — Verificación (no asumir)

Se releyeron las etapas del embudo en `32_agregar_territorial.R` y se contrastó con
los parquets intermedios reales (`ruta_int(...)` sobre el data root).

**Hallazgo 1 — `convocatoria_archivo` NO distingue invierno/regular.**
En los tres archivos (`paes_inscripcion`, `paes_rendicion_resultados`,
`paes_postulacion_seleccion`) la columna `convocatoria_archivo` vale **siempre
`"REGULAR"`**, en todos los años (2023–2026). El supuesto del encargo («2026 único
año con `convocatoria_archivo` poblada») no se cumple: está poblada en todos los años
pero nunca marca invierno. `convocatoria_archivo` NO entra en ningún `distinct()` ni
filtro de las etapas — es inerte para el conteo.

**Hallazgo 2 — el invierno/regular real vive en `tipo_rendicion` (ArchivoC).**
La distinción está en `paes_rendicion_resultados$tipo_rendicion` (`reg` / `inv`):

| año | filas `inv` | filas `reg` |
|-----|-------------|-------------|
| 2023 | 85.790 | 1.056.922 |
| 2024 | 105.318 | 1.118.682 |
| 2025 | 106.349 | 1.137.012 |
| 2026 | 107.764 | 1.127.733 |

`paes_inscripcion` (ArchivoB) NO tiene invierno (todo REGULAR, una fila por persona/año).
`paes_postulacion_seleccion` (ArchivoD) tampoco: 2026 solo cargó
`archivod_adm2026_reg.csv` (el `_inv` no está en el parquet), `convocatoria_archivo`
todo REGULAR.

**Hallazgo 3 — DETENCIÓN (a): las etapas deduplican por `id_aux` colapsando
invierno+regular.** `etapa_rendicion` (L280-282) y `etapa_resultados` (L296-298) hacen
`dplyr::distinct(id_aux, rbd, anio_proceso)` **sin** `tipo_rendicion`. Una persona que
rinde invierno **Y** regular el mismo `anio_proceso` se cuenta **una sola vez**.

Cifra concreta (vigencia == "actual", etapa rendición):

| año | personas que rinden inv+reg | filas pre-distinct (con `tipo_rendicion`) | post-distinct (sin `tipo_rendicion`) | colapsadas |
|-----|------|------|------|------|
| 2023 | 19.753 | 270.206 | 250.453 | 19.753 |
| 2024 | 19.352 | 277.160 | 257.808 | 19.352 |
| 2025 | 20.887 | 282.498 | 261.611 | 20.887 |
| 2026 | 21.779 | 285.470 | 263.691 | 21.779 |

`etapa_resultados` aplica el mismo `distinct(id_aux, rbd, anio_proceso)`, por lo que
también colapsa (subconjunto de los anteriores: quienes rinden CLEC+M1).

### Por qué es detención (a) y no Fase 3a

El criterio real del código en las etapas de rendición/resultados es **personas únicas
por año**, no «participaciones». La nota que la Fase 3a pedía agregar afirma lo
contrario para el caso intra-año:

> «…una persona que rinde en convocatoria regular e invierno del mismo año … se cuenta
> una vez por cada participación.»

Eso sería **falso**: el código la cuenta **una sola vez** (no una por convocatoria).
Publicar esa nota describiría mal el dato. La regla de detención (a) del encargo
apunta exactamente a este escenario, así que **no** se agregó la nota ni se cambió el
cálculo.

Matiz — la parte inter-año de esa misma nota **sí** es correcta: como cada
`anio_proceso` se agrega por separado, un rezagado que rinde en más de un año aparece
en el agregado de cada año (una participación por año). El problema es solo el caso
intra-año invierno+regular.

### Decisión pendiente del titular (gate estratégico)

Dos caminos, ninguno implementado aquí:

1. **Corregir la nota, no el cálculo:** documentar que el embudo cuenta **estudiantes
   únicos por año** en las etapas de rendición/resultados (una persona que rinde
   invierno y regular cuenta una vez). Semánticamente razonable para un embudo de
   cobertura («cuántas personas distintas llegaron a cada etapa»). Cambio menor de
   texto.
2. **Cambiar el cálculo a participaciones:** incluir `tipo_rendicion` en el `distinct`
   de `etapa_rendicion`/`etapa_resultados` para contar cada rendición (invierno y
   regular por separado). Cambia el criterio de negocio y las cifras del embudo
   (~+19k–22k por año en rendición). Requiere decisión explícita del titular.

## Notas de reproducción

- Scripts de verificación efímeros en el scratchpad de la sesión (`check_convoc.R`,
  `check_invierno.R`), leyendo `ruta_int(...)` desde `SLEP_PAES_DATA_ROOT`.
- `run_all(only=33)` regenera `40_salidas/motor_paes.html` y `docs/index.html`
  (Fases 1 y 2 ya reflejadas en `docs/index.html`).
