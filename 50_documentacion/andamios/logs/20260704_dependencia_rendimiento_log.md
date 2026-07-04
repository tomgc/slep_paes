# Log — Desglose por dependencia en el focus Rendimiento

- **Fecha:** 2026-07-04
- **Encargo:** añadir `grupo_dependencia` (PP/PS/Mun./sin_dato) como corte
  transversal EXCLUSIVO del focus Rendimiento. Embudo de Cobertura intacto
  (Decisión 6; el denominador egresados/`cod_depe` no es homologable a
  `grupo_dependencia`, diagnóstico de esta sesión).
- **Modo:** autónomo, secuencial. Sin push.
- **Evidencia congelada del panel adversarial:** `andamios/auditoria_datos_pre_push/`
  (lib reusada) + este log.

## Veredicto global

> **Implementado y verificado en 3 fases.** El focus Rendimiento gana un corte por
> dependencia del establecimiento (mapeo DEMRE 1=PP, 2=PS, 3-4=Mun, NA=«sin dato»).
> El **embudo de Cobertura quedó byte-idéntico** (md5 del parquet de cobertura sin
> cambio) y el default `dependencia="todas"` reproduce el render histórico. Panel
> adversarial: rama «todas» idéntica al baseline; supresión k=8 aplicada sola;
> 0 errores de consola.

## Regla de detención — ninguna gatillada

- **(a)** El corte NO obliga a tocar el denominador de Cobertura ni el embudo: se
  aplica solo a las agregaciones de rendimiento. ✓
- **(b)** `grupo_dependencia` SÍ está en el parquet de rendición (valores 1/2/3/4 +
  NA), mapeo confirmado (1=PP, 2=PS, 3&4=Mun). Además es **constante por
  (id_aux, anio)** (0 personas con >1 valor) → entra directo al grouping sin split
  espurio. ✓
- **(c)** La supresión k=8 se aplica automáticamente al nuevo grouping vía
  `aplicar_supresion()` dentro de `agregar_promedio_territorial` (3.215 celdas
  por-dependencia suprimidas, media enmascarada). ✓

## Invariantes (🔒)

| Invariante | Estado | Evidencia |
|---|---|---|
| Embudo de Cobertura sin cambios (byte-idéntico) | ✅ | md5 `paes_cobertura_territorial.parquet` = `659e40b35b1bc680c2a08d1b809ba647` antes (M0), tras re-run sin cambios (M1) y tras Fase 1/3 |
| `rendimiento_vigente` (ventana=4) intacto en su rama «todas» | ✅ | rama `grupo_dependencia=="todas"` (90.676 filas) `all.equal` TRUE vs baseline |
| UMBRAL_SUPRESION_CELDA=8 en el cruce dependencia×territorio | ✅ | 3.215 celdas por-dep suprimidas (n→NA, media→NA) |
| Mapeo 1=PP, 2=PS, 3-4=Mun, NA=sin_dato (colapsa 3+4) | ✅ | `dep_lbl()` en 32; valores en parquet: PP/PS/Mun/sin_dato/todas |

## Fases

### Fase 1 — `32_agregar_territorial.R` (commit `4703415`)
Bloque de rendimiento reescrito: `dep_lbl()` colapsa `grupo_dependencia` a
PP/PS/Mun/sin_dato. `rendimiento_vigente` y NEM/Ranking (lo publicado) ganan el
split por dependencia + una rama `"todas"` (agregado sin corte, byte-idéntico).
`rendimiento_puntajes` (raw reg/inv/anterior, no publicado) queda solo `"todas"`.
El parquet pasa de 90.676 → 151.313 filas y gana la columna `grupo_dependencia`.
**Cobertura no se toca** (se escribe antes, md5 idéntico). Auto-audit: rama todas
== baseline (all.equal TRUE); supresión aplicada.

### Fase 2 — `33_generar_html.R` (commit `601e34d`)
`ren_f` gana `grupo_dependencia` en el `select`; el filtro (vigente+actual |
nem/ranking) captura todas las ramas de dependencia. JSON verificado: rendimiento
tiene la columna (Mun/PP/PS/sin_dato/todas), cobertura NO. `docs/index.html` no se
committeó en esta fase (el motor debía indexar por dependencia antes; se regeneró
en Fase 3).

### Fase 3 — `33_motor_template.html` (commit `0f19762`)
- Índice `REN` keyea por `...|cohorte|grupo_dependencia`; `renGet(…, dep)` default
  `"todas"` (backward-compatible). `renSel`/`RenComp`/export pasan `s.dep`.
- Control «Dependencia» (Todas/Municipal/P.Subv./P.Pagado/Sin dato) VISIBLE SOLO
  con `foco==="ren"`; en Cobertura se omite (`? … : null`).
- Estado gana `dep:"todas"`; subtítulos ganan `depSub()`; notas de Rendimiento
  aclaran el mapeo DEMRE y que «Sin dato» ≈ 1,3%.

## Panel adversarial y verificación en navegador

- **Determinismo de `write_parquet`:** confirmado (re-run sin cambios → md5
  idéntico), lo que valida el invariante md5.
- **Cobertura byte-idéntica:** md5 `659e40b3…` estable en todo el flujo.
- **Rama «todas» == baseline:** `all.equal` TRUE (90.676 filas).
- **Corte real (DOM):** comuna Viña del Mar (5109), CLEC 2026 actual —
  todas 617 (3.177) / Municipal 544 (466) / P.Subv. 593 (1.869) / P.Pagado 711
  (842) — coincide exacto con el parquet.
- **Default byte-idéntico (DOM):** SLEP Costa Central, dep=Todas → 538/544/389/
  403/443/719/734 (idéntico al render pre-dependencia).
- **Cobertura sin control de dependencia** (verificado); **Rendimiento con las 5
  opciones**; **0 errores de consola**.

## Pendientes `# REVISAR`

- **# REVISAR (nota de diseño, no bug):** los **SLEP** contienen solo
  establecimientos **públicos/municipales** (los privados no pertenecen al SLEP),
  así que a nivel SLEP `dependencia="Municipal"` == `"Todas"` (ej. Costa Central,
  n=673 en ambos). El corte por dependencia es informativo a nivel **comuna /
  región / nacional** (donde coexisten PP/PS/Mun), no a nivel SLEP. Conviene que el
  titular decida si el default territorial (SLEP) debería advertirlo, o si el corte
  se ofrece más prominentemente en comuna/nacional.
- **# REVISAR (menor):** «sin dato» (~1,3%) es una categoría chica; a niveles
  agregados a veces se suprime (n<8). Es esperado y está resguardado.
- No hacer push. Commits locales para revisión del titular.
