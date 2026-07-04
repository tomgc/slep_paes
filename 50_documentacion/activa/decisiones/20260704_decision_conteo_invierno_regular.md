# Decisión — Conteo invierno/regular en el embudo (Decisión 6): personas únicas

- **Fecha:** 2026-07-04
- **Estado:** vigente (cierra Decisión 6, abierta desde sesión 5)
- **Autoría:** Área de Monitoreo y Seguimiento de Procesos y Resultados
  Educativos, SLEP Costa Central.
- **Decisión tomada por:** el titular, sobre el diagnóstico de solo lectura
  realizado en sesión 6 (ver §Procedencia).
- **Alcance:** `30_procesamiento/32_agregar_territorial.R`, focus **Cobertura**
  (embudo). No implica cambio de código.

## Procedencia del diagnóstico (no se reinventa)

Esta decisión se apoya en el diagnóstico de solo lectura ejecutado en esta
sesión (código propio sobre los parquets crudos, sin tocar el pipeline). Las
citas de línea y las cifras provienen de ahí; no se fabrican valores nuevos.
Antecedente: la detención original del conteo invierno/regular quedó registrada
en `andamios/logs/20260702_rotulo_p1_convocatoria_log.md` (Cambio 7,
traspaso v05 §3) y el «mejor puntaje» de Rendimiento se resolvió aparte en
`andamios/logs/20260703_rendimiento_vigente_ventana4_log.md`.

## 1. Contexto

Decisión 6 quedó abierta desde la sesión 5: en `32_agregar_territorial.R`, las
etapas del embudo de Cobertura que consumen ArchivoC hacen
`distinct(id_aux, rbd, anio_proceso)` **sin** `tipo_rendicion`:

- `etapa_rendicion` — **L290** (`dplyr::distinct(id_aux, rbd, anio_proceso)`,
  precedido por `filter(vigencia == "actual")` en L289).
- `etapa_resultados` — **L305** (`dplyr::distinct(id_aux, rbd, anio_proceso)`,
  seguido de `inner_join(ids_obligatorias_ok)` en L306).

Como `tipo_rendicion` (invierno/regular, atributo de ArchivoC) no entra en el
`distinct`, una persona que rinde en **ambas** convocatorias el mismo año se
cuenta **una sola vez**. Magnitud del colapso (personas con rendición en ambas
convocatorias, vigencia==actual): **19.753 (2023), 19.352 (2024), 20.887
(2025), 21.779 (2026)** — **7,5–8,3% del universo por año**. En la etapa
`resultados` específicamente, **78.004** personas (2023–2026) tienen rendición
en ambas convocatorias y son colapsadas por el `distinct`.

El resto de las etapas **no** tiene este colapso: `etapa_inscripcion` (L282)
sale de ArchivoB (sin `tipo_rendicion`; `convocatoria_archivo` es inerte,
siempre "REGULAR"); `etapa_postulacion` (L318), `etapa_seleccion` (L327) y
`kpi_prioridad_1` (L338) salen de ArchivoD (sin `tipo_rendicion`).

## 2. Alternativas consideradas

| # | Alternativa | Efecto en cifras publicadas |
|---|---|---|
| **A** | **Personas únicas** — mantener el `distinct` sin `tipo_rendicion`: una persona cuenta una vez por año en el embudo, sin importar cuántas convocatorias rinda. | **Sin cambio.** Cifras del embudo intactas. |
| B | **Participaciones** — agregar `tipo_rendicion` al `distinct`: contar cada rendición (invierno y regular por separado). | Cambia las cifras publicadas de `rendicion`/`resultados` (~+19–22k «participaciones»/año); rompe la comparabilidad del embudo como *cobertura de personas*. |

## 3. Decisión

**Alternativa A — personas únicas.** El embudo de Cobertura queda **intacto**
(sin cambio de código en las etapas del embudo).

## 4. Justificación (evidencia empírica del diagnóstico)

- **Headcount determinista, sin pérdida de dato no-llave.** `distinct(id_aux,
  rbd, anio_proceso)` se llama **sin `.keep_all`** → devuelve solo esas tres
  columnas; `puntaje`, `prueba`, `tipo_rendicion` y `vigencia` se descartan por
  completo. No hay «fila que sobrevive con un valor»: el resultado es el
  conjunto de llaves únicas, independiente del orden de filas. No se elige
  arbitrariamente una convocatoria.
- **Cero pérdida de selección.** La selección **no es propiedad** de las filas
  de rendición: se calcula en `etapa_seleccion` desde ArchivoD, indexada solo
  por `(id_aux, anio_proceso)`, y es **única por persona** (verificado: **0**
  personas con más de un estado de selección distinto). Las 78.004 personas de
  «ambas convocatorias» en resultados tienen exactamente un resultado de
  selección cada una (tasa 89,2%). El colapso no puede descartar una selección
  diferente.
- **El colapso es necesario para acreditar completitud cruzada.** **3.028**
  personas pasan `resultados` **solo porque** el `distinct` (y el chequeo de
  obligatorias `ids_obligatorias_ok`, L300, que también ignora
  `tipo_rendicion`) no distingue convocatoria: rindieron **CLEC en una
  convocatoria y M1 en la otra**, sin tener ambas juntas en ninguna. Exigir la
  misma convocatoria las excluiría por error.
- **Postulación/selección no mezclan convocatorias por construcción.**
  ArchivoD no trae `tipo_rendicion`; en invierno **no hay selección** (solo
  alimenta los puntajes vigentes de la postulación regular; `contexto_paes.md`
  §«Aplicación de Invierno»). Hay un único proceso de postulación por año.
- **El «mejor puntaje» ya está resuelto, y en otro focus.**
  `rendimiento_vigente` (**L399–406**, ventana=4: `max(puntaje)` sobre las 4
  casillas REG/INV × ACTUAL/ANTERIOR) resuelve el mejor puntaje vigente
  **exclusivamente** para el focus Rendimiento; el comentario en **L399** lo
  declara: *«NO toca el embudo (Decision 6: personas unicas, intacta)»*.
  Verificado: `rendimiento_vigente` entra a `rendimiento` (L425) →
  `paes_rendimiento_territorial.parquet`, sin tocar ninguna `etapa_*` ni el df
  `cobertura`.

## 5. Implicancia

**Ninguna. Sin cambio de código.** El embudo de Cobertura conserva la semántica
de personas únicas; el focus Rendimiento ya publica el mejor puntaje vigente. Se
descarta la Alternativa B. **Decisión 6 queda cerrada.**

## 6. Distribución por convocatoria (vigencia == actual), 2023–2026

| año | solo regular | solo invierno | ambas | total | % ambas |
|---|---|---|---|---|---|
| 2023 | 220.837 | 9.863 | 19.753 | 250.453 | 7,9% |
| 2024 | 230.715 | 7.741 | 19.352 | 257.808 | 7,5% |
| 2025 | 233.525 | 7.199 | 20.887 | 261.611 | 8,0% |
| 2026 | 234.535 | 7.377 | 21.779 | 263.691 | 8,3% |

## 7. Reapertura

Reabrir esta decisión solo si: (a) el titular decide que el panorama debe
reportar **participaciones** en vez de personas únicas en el embudo (cambio de
criterio de negocio, altera cifras publicadas), o (b) una futura versión de las
bases DEMRE introduce selección en la aplicación de invierno (hoy inexistente),
lo que cambiaría la semántica de ArchivoD.
