# Decisión de esquema — `31_leer_normalizar.R` (Fase A: diagnóstico)

> Fase A únicamente: diagnóstico + propuesta. NO se ha escrito código de
> `31_leer_normalizar.R`. Evidencia extraída de los CSV reales en
> `SLEP_PAES_DATA_ROOT/20_insumos/demre/` y de los Libros de Códigos
> (`referencia/<AAAA>/libro_codigos_adm<AAAA>_archivo*.xlsx`). B.1: no se
> inventa nada no verificado; lo no verificable queda marcado como pendiente.

---

## DECISIÓN 1 — Mapeo wide→long de ArchivoD (Postulación y Selección)

### Evidencia

- **2023** (`archivod_adm2023.csv`, 186 columnas, confirmado con
  `libro_codigos_adm2023_archivod.xlsx`, hoja "Postulación y Selección"): para
  cada preferencia `NN` (01-20) y cada vía de postulación, hay un bloque
  repetido:
  - Vía **regular** (sin sufijo): `COD_CARRERA_PREF_NN`, `ESTADO_PREF_NN`,
    `PTJE_PREF_NN`.
  - Vía **BEA**: `COD_CARRERA_PREF_NN_BEA`, `ESTADO_PREF_NN_BEA`,
    `PTJE_PREF_NN_BEA`.
  - Vía **PACE**: `COD_CARRERA_PREF_NN_PACE`, `ESTADO_PREF_NN_PACE`,
    `PTJE_PREF_NN_PACE`.
  - Además, por vía (no por preferencia): `SITUACION_POSTULANTE` /
    `SITUACION_POSTULANTE_BEA` / `SITUACION_POSTULANTE_PACE` (el libro de
    códigos las llama `SIT_POSTULANTE_BEA/PACE`; el nombre real en el CSV es
    `SITUACION_POSTULANTE_BEA/PACE` — se usa el nombre literal del archivo, no
    el del libro de códigos, sin ambigüedad real) y los flags `BEA`, `PACE`.
- **2024-2026** (`archivod_adm<AAAA>.csv`, 6 columnas, confirmado con
  `libro_codigos_adm2024_archivod.xlsx`): `ID_aux, ORDEN_PREF, COD_CARRERA_PREF,
  ESTADO_PREF, TIPO_PREF, PTJE_PREF`. `TIPO_PREF` toma 4 valores (verificado en
  datos reales 2024 y 2025 con `sort -u`): `REGULAR, BEA, PACE, GENERO`.

### Mapeo propuesto (columna 2023 → esquema long 2024+)

| Columna 2023 (wide) | `orden_pref` | `tipo_pref` | Columna long destino | Certeza |
|---|---|---|---|---|
| `COD_CARRERA_PREF_NN` | NN | `REGULAR` | `cod_carrera_pref` | Cierta |
| `ESTADO_PREF_NN` | NN | `REGULAR` | `estado_pref` | Cierta |
| `PTJE_PREF_NN` | NN | `REGULAR` | `ptje_pref` | Cierta |
| `COD_CARRERA_PREF_NN_BEA` | NN | `BEA` | `cod_carrera_pref` | Cierta |
| `ESTADO_PREF_NN_BEA` | NN | `BEA` | `estado_pref` | Cierta |
| `PTJE_PREF_NN_BEA` | NN | `BEA` | `ptje_pref` | Cierta |
| `COD_CARRERA_PREF_NN_PACE` | NN | `PACE` | `cod_carrera_pref` | Cierta |
| `ESTADO_PREF_NN_PACE` | NN | `PACE` | `estado_pref` | Cierta |
| `PTJE_PREF_NN_PACE` | NN | `PACE` | `ptje_pref` | Cierta |
| — (no existe en 2023) | — | `GENERO` | — | **N/A**: vía inexistente en 2023, no se rellena |
| `SITUACION_POSTULANTE` | — | `REGULAR` | **sin destino en el esquema long** | **AMBIGUA / gap de esquema** |
| `SITUACION_POSTULANTE_BEA` | — | `BEA` | **sin destino en el esquema long** | **AMBIGUA / gap de esquema** |
| `SITUACION_POSTULANTE_PACE` | — | `PACE` | **sin destino en el esquema long** | **AMBIGUA / gap de esquema** |
| `BEA` (flag) | — | — | **sin destino en el esquema long** | **AMBIGUA / gap de esquema** |
| `PACE` (flag) | — | — | **sin destino en el esquema long** | **AMBIGUA / gap de esquema** |

**Filas 0/vacías se descartan en el pivot** (`ESTADO_PREF_NN == 0` /
`COD_CARRERA_PREF_NN == 0` = "preferencia no utilizada", código 0 del anexo
"Estado Preferencia" del libro de códigos 2023 — confirmado). Pivotar sin
filtrar produciría hasta 60 filas vacías por postulante 2023.

### Ambigüedades a resolver por el titular (no se infieren)

1. **`SITUACION_POSTULANTE[_BEA|_PACE]` y los flags `BEA`/`PACE` (solo 2023)
   no tienen columna equivalente en el esquema long 2024-2026** (el ArchivoD
   2024+ no trae esas variables en absoluto). Verificado: no aparecen en
   `archivod_adm2024.csv` ni en su libro de códigos. Alternativas:
   - (a) Se descartan explícitamente del esquema unificado de 31 (no se
     fabrica un equivalente); se documenta como pérdida de granularidad
     2023-only.
   - (b) Se preservan como atributo aparte, **solo poblado para 2023**, NA
     para 2024+, marcado explícitamente como "no comparable entre años".
   - No hay evidencia en las glosas de un archivo alternativo (ArchivoMatr no
     trae `SITUACION_POSTULANTE`) que las reconstruya para 2024+.
2. **`GENERO` como vía de preferencia es una categoría nueva desde 2024**
   (confirmada en el libro de códigos 2024 y ausente del libro 2023). No es
   ambigüedad de mapeo — es evolución real de esquema — pero implica que
   cualquier comparación 2023 vs 2024+ por vía de postulación subestima
   sistemáticamente 2023 en una categoría que no existía.

---

## DECISIÓN 2 — Esquema REG/INV (ArchivoC y el sufijo de archivo 2026)

Hay **dos fenómenos REG/INV distintos** en los datos, y es importante no
confundirlos:

### 2.1 REG/INV a nivel de columna (ArchivoC, todos los años 2023-2026)

Patrón `<PRUEBA>_<REG|INV>_<ACTUAL|ANTERIOR>`. Esto **no es ambiguo**: `REG` =
puntaje obtenido en la aplicación **Regular** (fin de año); `INV` = puntaje
obtenido en la aplicación de **Invierno** (junio, cupo 50.000, sin selección —
confirmado en `contexto_paes.md` §"Aplicación de Invierno"). `ACTUAL` = proceso
del año de la base; `ANTERIOR` = proceso del año previo (puntaje vigente
combinable). Evolución confirmada por año (evidencia literal de los CSV):

| Año | N columnas | Particularidad |
|---|---|---|
| 2023 | 28 | `MATE_INV_ACTUAL` sin split M1/M2; sin bloque `*_INV_ANTERIOR` en absoluto |
| 2024 | 35 | `MATE1/MATE2_INV_ACTUAL` (ya separado); aparece bloque `*_INV_ANTERIOR` (con `MATE_INV_ANTERIOR` sin split) |
| 2025 | 36 | `*_INV_ANTERIOR` gana el split `MATE1/MATE2` |
| 2026 | 38 | agrega `RINDIO_PROCESO_ANTERIOR`, `RINDIO_PROCESO_ACTUAL` |

### 2.2 REG/INV a nivel de archivo (solo 2026: `archivo{b,c,d}_adm2026_reg.csv`)

Esto es un fenómeno **distinto**: el sufijo `_reg` en el nombre del archivo
2026 indica la **convocatoria/proceso de inscripción** (Regular vs Invierno
como procesos de admisión separados, cada uno con su propio archivo de
postulantes), no la columna REG/INV de arriba. Evidencia:

- `archivoc_adm2026_reg.csv` **ya contiene** las columnas `*_REG_*` y `*_INV_*`
  igual que los años anteriores — el sufijo del nombre de archivo no colapsa
  esas columnas.
- No existe todavía ningún `archivo{b,c,d}_adm2026_inv.csv` en el data root
  (solo hay un archivo de referencia, `percentiles_adm2026_inv.csv`, sin el
  archivo base correspondiente). Es decir, **el archivo complementario de
  Invierno 2026 está pendiente de publicación/depósito**, consistente con que
  hoy (2026-07-01) la aplicación de Invierno 2026 recién está en curso.
  `contexto_paes.md` confirma que desde 2022 el DEMRE publica "archivos
  separados que dicen 'Inscritos PAES de Invierno Proceso X' e 'Inscritos PAES
  Regular Proceso X'".
- Para 2023-2025 existe un único archivo por año y por etapa, que ya trae
  población mixta (quienes solo rindieron Invierno también aparecen, con
  `*_REG_*` en 0 y `*_INV_*` poblado) — es decir, **2023-2025 consolidan ambas
  convocatorias en un solo archivo**; 2026 es el primer año en que el DEMRE
  separa el archivo por convocatoria.

### Recomendación: **LONG**, en dos dimensiones separadas

Se recomienda un esquema **long** para el pivot de puntajes de ArchivoC, con
dos columnas de tipo (no una tabla ancha `CLEC_REG_ACTUAL, CLEC_INV_ACTUAL,
CLEC_REG_ANTERIOR, ...`):

```
id_aux | prueba | tipo_rendicion (REG|INV) | vigencia (ACTUAL|ANTERIOR) | puntaje
```

más una columna `convocatoria_archivo` (REGULAR|INVIERNO), derivada del
**nombre del archivo** (no de una columna del CSV), para el fenómeno 2.2,
poblada `REGULAR` por defecto en 2023-2025 (único archivo disponible) y
tomada del sufijo `_reg`/`_inv` desde 2026.

**Justificación:**

1. **El esquema de columnas de ArchivoC varía por año** (28→38 columnas,
   aparición de `INV_ANTERIOR`, split `MATE`→`MATE1/MATE2`). En wide, cada
   consumidor posterior (`32_agregar_territorial.R`, el motor) tendría que
   saber qué columnas existen en qué año. En long, esa variabilidad se
   resuelve una sola vez en el pivot de 31; los años con menos columnas
   simplemente producen menos filas, no columnas ausentes que rompan un
   `select()` corriente abajo.
2. **Los dos focos PARES del proyecto son, literalmente, group-by sobre
   `(prueba, tipo_rendicion)`:** cobertura necesita "¿rindió esta prueba (REG
   o INV) este año?" (un filtro/`any()` sobre `tipo_rendicion`); rendimiento
   necesita "distribución de puntaje por prueba" (un `group_by(prueba)`). Wide
   obliga a repetir esa lógica columna por columna (hasta 12 columnas de
   puntaje por postulante); long la resuelve con un solo `group_by`.
3. **El sentinela 0 = no rindió** es más limpio en long: una fila ausente (o
   `puntaje == 0` filtrado en el pivot) es inequívocamente "no rindió esa
   prueba en esa vía/vigencia", sin conflicto de interpretación entre 12
   columnas wide que mezclan NA reales con el 0 sentinela.
4. **El motor (doble foco, navegación territorial)** ya centra su diseño en
   alternar entre cobertura y rendimiento sobre la misma data; un JSON
   columnar largo (prueba/tipo_rendicion como dimensiones) es más directo de
   filtrar en d3 que pivotar wide→long en JavaScript en el cliente.

**Contras a mitigar (explícitos, no ocultos):**

- Long multiplica filas (~10-12 combinaciones prueba×tipo_rendicion×vigencia
  por postulante). Mitigación: **descartar en el pivot las filas sentinela
  (puntaje 0 / vacío)** — solo se materializan intentos reales de rendición,
  igual que en la Decisión 1. El parquet resultante debiera ser
  significativamente más liviano que 12 columnas wide con muchos ceros.
- Al descartar filas sentinela, "no rindió" deja de ser una fila con 0 y pasa
  a ser "ausencia de fila". **`32_agregar_territorial.R` debe calcular el
  denominador de "no rindió" contra ArchivoB/egresados (quién estaba
  inscrito/elegible), nunca contando filas ausentes de ArchivoC como si fueran
  el universo** — se deja como nota explícita para el diseño de 32, no se
  resuelve aquí.
- La deduplicación de postulantes que aparezcan en **ambos** archivos 2026
  (`_reg` y `_inv`) si comparten `ID_aux` **no se resuelve en esta fase**: no
  hay evidencia (glosa o dato) de la regla de precedencia del DEMRE entre
  ambas publicaciones. Se recomienda que 31 los apile (`bind_rows`) taggeados
  por `convocatoria_archivo` sin fusionar, dejando la reconciliación (si es
  necesaria) para 32, una vez el titular confirme la regla con el DEMRE o con
  el libro de códigos 2026 cuando el archivo `_inv` esté disponible.

---

## Validación de columnas esperadas por año (base para el `stop()` de columnas faltantes en 31)

### ArchivoB (Inscripción) — 22 columnas todos los años, orden distinto

| Columna | 2023 | 2024 | 2025 | 2026 |
|---|---|---|---|---|
| `ID_aux`, `ANYO_PROCESO`, `SEXO`, `RBD`, `COD_ENS`, `REGIMEN`, `RAMA_EDUCACIONAL`, `GRUPO_DEPENDENCIA`, `FECHA_NACIMIENTO`, `ANYO_EGRESO`, `CODIGO_REGION`, `CODIGO_PROVINCIA`, `CODIGO_COMUNA`, `CODIGO_REGION_D`, `CODIGO_COMUNA_D`, `SITUACION_EGRESO`, `RINDIO_PROCESO_ANTERIOR`, `RINDIO_PROCESO_ACTUAL`, `BEA`, `PACE`, `PAIS_NACIMIENTO`, `INGRESO_PERCAPITA_GRUPO_FA` | ✅ (22) | ✅ (22) | ✅ (22) | ✅ (22) |

Confirmado: mismas 22 columnas los 4 años, solo cambia el orden. **31 debe
leer siempre por nombre** (ya establecido en el proyecto).

### ArchivoC (Rendición + Resultados) — crece de 28 a 38 columnas

| Bloque de columnas | 2023 | 2024 | 2025 | 2026 |
|---|---|---|---|---|
| Identificación/territorio/NEM/Ranking (12 col fijas) | ✅ | ✅ | ✅ | ✅ |
| `*_REG_ACTUAL` (6 pruebas, `MATE1`+`MATE2`) | ✅ | ✅ | ✅ | ✅ |
| `*_INV_ACTUAL` | ✅ pero `MATE` sin split M1/M2 (5 col) | ✅ con split (6 col) | ✅ | ✅ |
| `*_REG_ANTERIOR` | ✅ | ✅ | ✅ | ✅ |
| `*_INV_ANTERIOR` | ❌ **ausente** | ✅ `MATE` sin split (5 col) | ✅ con split (6 col) | ✅ |
| `RINDIO_PROCESO_ANTERIOR/ACTUAL` | ❌ | ❌ | ❌ | ✅ (nuevas 2026) |

**Implicancia para el `stop()` de 31:** el chequeo de columnas críticas no
puede exigir un set fijo de columnas para todos los años. Debe:
- Exigir siempre las 12 columnas fijas + `*_REG_ACTUAL` (presentes los 4
  años) — su ausencia sí debe abortar.
- Tratar `*_INV_ANTERIOR` y `RINDIO_PROCESO_*` como **opcionales por año**
  (presentes solo desde 2024 y 2026 respectivamente) — su ausencia es
  esperada en años anteriores, no debe abortar.
- Tratar el split `MATE` vs `MATE1/MATE2` como una normalización de nombre de
  prueba en el pivot long (Decisión 2), no como columna faltante.

### ArchivoD (Postulación y Selección) — cambia de forma, no solo de tamaño

| Columna/bloque | 2023 | 2024 | 2025 | 2026 |
|---|---|---|---|---|
| `ID_aux` | ✅ | ✅ | ✅ | ✅ |
| `ORDEN_PREF`, `TIPO_PREF` (esquema long) | ❌ | ✅ | ✅ | ✅ |
| `COD_CARRERA_PREF_NN[_BEA\|_PACE]` (esquema wide) | ✅ (186 col) | ❌ | ❌ | ❌ |
| Vía `GENERO` en `TIPO_PREF` | ❌ (no existe la vía) | ✅ | ✅ | ✅ |
| `SITUACION_POSTULANTE[_BEA\|_PACE]`, flags `BEA`/`PACE` | ✅ | ❌ | ❌ | ❌ |

**Implicancia:** 31 necesita una rama de lectura explícita por forma
(`ncol == 186` → wide 2023; `ncol == 6` → long 2024+), no un único
`read_delim` + `clean_names` genérico como el stub actual.

### ArchivoMatr — estable, no requiere rama especial

`ID_aux, CODIGO_UNIV, CODIGO, VIA, PREFERENCIA, PTJE_POND, TIPO_MATRICULA` —
idénticas en 2023 y 2024 (verificado); se asume estable 2025-2026 dado que
forma parte del mismo patrón que ArchivoD long.

---

## Preguntas explícitas para el titular (gate de decisión — no se avanza a Fase B sin esto)

1. **¿Qué hacer con `SITUACION_POSTULANTE[_BEA|_PACE]` y los flags `BEA`/`PACE`
   de ArchivoD 2023?** Son variables sin equivalente en el esquema long
   2024-2026 (no existen esas columnas en esos archivos). ¿Se descartan del
   esquema unificado (documentando la pérdida), o se preservan como atributo
   `solo-2023` explícitamente marcado como no comparable entre años?

2. **¿Se aprueba el esquema LONG propuesto para el pivot de ArchivoC**
   (`id_aux, prueba, tipo_rendicion, vigencia, puntaje` + `convocatoria_archivo`
   derivada del nombre de archivo), incluyendo:
   - descartar filas sentinela (puntaje 0) en el pivot de 31, y
   - **no** fusionar automáticamente los postulantes que puedan repetirse
     entre `archivo{b,c,d}_adm2026_reg.csv` y el futuro `..._inv.csv` (se
     apilan taggeados, la fusión queda pendiente para 32 hasta confirmar la
     regla de precedencia del DEMRE)?

Si ambas se resuelven, Fase B puede implementar `31_leer_normalizar.R` con
ramas explícitas por año/forma para ArchivoD (wide 2023 / long 2024+), pivot
long para ArchivoC, y el `stop()` de columnas críticas diferenciado por bloque
(fijo vs. opcional-por-año) descrito arriba.
