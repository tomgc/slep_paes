# Decisión — F3: aceptar el margen inter-archivo de 1 persona (Santo Domingo)

- **Fecha:** 2026-07-03
- **Estado:** vigente
- **Autoría:** Área de Monitoreo y Seguimiento de Procesos y Resultados
  Educativos, SLEP Costa Central.
- **Decisión tomada por:** el titular (autorización explícita, opción A).
- **Contexto:** cierre de la auditoría de datos pre-push (hallazgo F3), tras los
  fixes F1 (alineación del denominador egresados) y F2 (resguardo en 1.ª
  prioridad). Logs relacionados: `logs/20260703_auditoria_datos_pre_push_log.md`,
  `logs/20260703_reauditoria_post_fix_f1_f2_log.md`,
  `logs/20260703_reconciliacion_f3_log.md`. Diagnóstico congelado:
  `andamios/auditoria_datos_pre_push/f3_fase0_diagnostico.R`.

## 1. El caso

En la cohorte «actual», el denominador del embudo son las y los **egresados de
enseñanza media** (archivo MINEDUC, `marca_egreso==1`, rbd del archivo MINEDUC), y
el numerador de inscripción son las y los **inscritos** que declaran ese año de
egreso (ArchivoB, rbd de ArchivoB). Tras el fix F1 (denominador alineado a
`agno + 1`), sobrevive **una sola celda** renderizada por encima de 100%:

| comuna | proceso | egresados | inscritos | % | exceso |
|---|---|---|---|---|---|
| 5606 (Santo Domingo) | 2026 | 188 | 189 | 101% | **1 persona** |

## 2. Causa raíz

El numerador (inscritos) y el denominador (egresados) provienen de **dos archivos
de agencias distintas** con **rbd de egreso asignado de forma independiente**:

- ArchivoB (DEMRE) identifica a la persona con `id_aux`.
- Egresados (MINEDUC) la identifica con `mrun` / `mrun_ipe`.

**No comparten identificador** (0 solapamiento sobre 1.000.625 `id_aux`; el
ArchivoB crudo solo trae `ID_aux`). Por eso el rbd de egreso de una persona puede
diferir —o faltar— entre ambos archivos, y a nivel comuna el numerador puede
exceder al denominador por una o pocas personas. Es **ruido administrativo
inter-archivo**, no un defecto de cálculo del pipeline.

**Magnitud (diagnóstico de Fase 0):** excluyendo el hueco del proceso 2023
(`egresados=0` por diseño tras F1, ya rebasado a inscritos=100%), el desfase real
es de **1 persona = 0,00016% del universo** (procesos 2024–2026: nacional 79,3%,
≤100%). Muy por debajo del umbral de 0,1% que habría indicado un problema
sistémico.

## 3. Alternativas consideradas

| # | Alternativa | ¿≤100%? | Invariante 🔒 (sin doble conteo ni pérdida) | Resultado |
|---|---|---|---|---|
| **A** | **Aceptar** el margen de 1 persona como ruido inter-archivo documentado, sin cambio de código | Casi (1 celda marginal) | ✅ respeta | **ELEGIDA** |
| B | Topar el % mostrado a 100% en el motor (1 línea, cosmético) | ✅ | ✅ respeta | Descartada: cosmética; enmascara el dato real sin corregir la causa |
| C | Denominador `max(egresados, inscritos)` / unión por comuna | ✅ | ❌ **viola** | **Descartada por el invariante** (ver §4) |
| D | Conseguir un crosswalk DEMRE↔MINEDUC y reconciliar persona-a-persona | ✅ | ✅ | Fuera de alcance: requiere un insumo (identificador común) que hoy no existe |

La reconciliación **persona-a-persona** originalmente autorizada resultó
**infeasible**: sin clave común entre los dos archivos, no se puede elegir «un
único rbd de egreso por persona», porque no se puede identificar a la misma
persona en ambos.

## 4. Por qué C queda descartada (invariante de doble conteo)

Tomar `max(egresados_MINEDUC, inscritos)` por comuna forzaría el denominador de
Santo Domingo de 188 a 189. Pero esa persona extra **ya está contada** en el
archivo MINEDUC —en su comuna de egreso MINEDUC— o **no figura** como egresada
MINEDUC. Sumarla a Santo Domingo la **duplica** (o la **inventa**), violando el
invariante 🔒 del encargo de auditoría: *«la reconciliación no puede introducir
doble conteo ni pérdida de personas del universo ya validado (Fase 1 MATCH TOTAL
debe seguir MATCH TOTAL)»* y el principio B.1 («no inventar conteos»). Por eso C
no es implementable bajo las reglas del propio proyecto.

## 5. Justificación de la decisión (A)

- El desfase es de **1 persona** (0,00016%), no sistémico.
- La vía correcta (persona-a-persona, opción D) exige un identificador común
  DEMRE↔MINEDUC que el proyecto **no posee** hoy; fabricar un enlace violaría B.1.
- Las vías que fuerzan ≤100% sin ese enlace son cosméticas (B) o violan el
  invariante (C).
- Aceptar y **documentar** el margen es la respuesta **proporcional** al tamaño
  del fenómeno y **fiel al dato real** (no lo enmascara ni lo inventa).

## 6. Implicancia

- **Sin cambio de código.** `32_agregar_territorial.R`, `33_generar_html.R`,
  `33_motor_template.html` y `docs/index.html` quedan **intactos** respecto del
  estado post-F1/F2.
- El invariante 🔒 «ningún porcentaje publicado > 100%» queda **satisfecho salvo
  este único caso marginal documentado** (Santo Domingo, proceso 2026,
  inscripción 101%, por diferencia inter-archivo de rbd de egreso, 1 persona).
- Si en el futuro se obtiene un crosswalk DEMRE↔MINEDUC (opción D), este caso
  puede reconciliarse de raíz; hasta entonces, se acepta como límite conocido de
  la fuente.

## 7. Reapertura

Reabrir esta decisión si: (a) aparece un identificador común entre ArchivoB y el
archivo de egresados MINEDUC (habilita D); (b) el desfase inter-archivo supera el
umbral de 0,1% del universo en un proceso futuro (dejaría de ser marginal); o
(c) el titular resuelve priorizar el estricto «0 %>100%» y opta por el tope de
display (B).
