# Backlog acumulativo — slep_paes

> Registro histórico vivo del proyecto (POLITICA §10 / SETTINGS §2.2.5). En cada
> cierre se copia íntegro y se agregan los cambios nuevos al final; jamás se
> reescriben, resumen ni renumeran entradas anteriores. Extraído del traspaso
> v01 en el primer cierre (sesión 1, 2026-07-01). Actualizado en sesión 7
> (2026-07-03) consolidando sesiones 2-6, con doble atraso resuelto.

## Objetivo del proyecto

slep_paes es el cuarto panorama nacional del Área de Monitoreo y Seguimiento de
Procesos y Resultados Educativos del SLEP Costa Central, construido con datos
100% públicos del DEMRE/MINEDUC sobre la PAES (Prueba de Acceso a la Educación
Superior), publicado como sitio HTML autocontenido en GitHub Pages, navegable por
territorio, leído desde dos focos pares (cobertura y rendimiento), hermano
arquitectónico de slep_categoria_desempeno, slep_idps y slep_simce_adecuado.

## Nota metodológica

Cuenta como "cambio" una solicitud distinguible del titular (no las acciones
técnicas que la implementan). No cuentan los errores del asistente corregidos de
inmediato dentro de la misma intervención; sí cuentan los bugfixes que el titular
reportó o que requirieron su decisión. Clasificación por intención primaria del
pedido. Fuente del conteo: la conversación completa de cada sesión, reconstruida
en sesión 7 desde el "Registro detallado de cambios" y "Bugs de la sesión" de
cada traspaso (v02-v06), aplicando la regla anterior a los "Cambio N" que solo
apuntan a bugs internos (no reportados por el titular): esos no cuentan como
entrada propia, ya están cubiertos por el Cambio que los contiene.

## Clasificación temática (a la sesión 1)

| Categoría | N° | % | Descripción |
|---|---|---|---|
| Scaffold y arquitectura | 3 | 21% | Estructura Rama A inicial, migración A→B, config de dos raíces |
| Gobernanza de datos | 4 | 29% | Compuerta PII, diagnóstico Fase 0, decisión Rama B, fuga PII hermano (delegada) |
| Reuso y patrón de familia | 1 | 7% | d3/pako/auxiliares/paleta |
| Dominio (contexto_paes) | 2 | 14% | Conversión inicial + transcripción manual de fórmulas |
| Organización de insumos | 3 | 21% | Estructura por etapa, renombrado snake_case, referencia/ |
| Pipeline (stubs) | 1 | 7% | 30-33 |

Taxonomía inicial (6 categorías); no refinada aún en sesiones 2-6 (queda como
pendiente de sesión 7 o posterior si alguna categoría nueva domina).

## Resumen estadístico por sesión

| Sesión | Traspasos generados | N° de cambios | Modelo | Foco |
|---|---|---|---|---|
| 1 | 1 (v01) | 14 | Claude (análisis) + Claude Code | Scaffold → migración A→B → insumos reales |
| 2 | 1 (v02) | 10 | Claude (análisis) + Claude Code | Dominio (contexto_paes, Rasch) → diseño y ejecución de `31`/`32` |
| 3 | 1 (v03) | 5 | Claude (análisis) + Claude Code | Motor `33` (Camino A), gobernanza de reidentificabilidad, 4 bugs internos |
| 4 | 1 (v04) | 6 | Claude (análisis) + Claude Code | Tipografía de familia, KPI de prioridad (Camino B), 2 bugs internos |
| 5 | 1 (v05) | 9 | Claude (análisis) + Claude Code | Suite `suitedoc`, interfaz (header/selector/cohorte/universo), fix >100% |
| 6 | 1 (v06) | 8 | Claude (análisis) + Claude Code | Auditoría pre-push (F1/F2/F3), rendimiento vigente ventana=4, push |
| — | — | **52 total** | — | — |

## Detalle cronológico (numeración global, permanente)

### Sesión 1

1. Scaffold Rama A completo (estructura, reuso, paleta) — pasos 1-2 del plan
   original.
2. Estructura de `20_insumos/` por etapa + `gobernanza_datos.md` +
   `manifiesto_insumos.md` + conversión inicial de `contexto_paes.md` — paso 3.
3. Reubicación de `Guía de uso de datos abiertos DEMRE.pdf` a ubicación canónica
   (detectado por Claude Code, no solicitado explícitamente, reportado y aceptado).
4. Diagnóstico y transcripción manual de las 6 fórmulas faltantes en
   `contexto_paes.md` (la transcripción la ejecutó el titular entre turnos; ver
   discrepancia en traspaso v01 §4 Cambio 2).
5. Confirmación de decisión React local sin CDN.
6. Delegación de la fuga de PII en `slep_categoria_desempeno` a sesión propia
   (encargo redactado y entregado).
7. Confirmación de remoto GitHub existente.
8. Primer encargo autónomo de Fase 0 (diagnóstico de bases reales) — redactado,
   luego corregido tras detectar que se había saltado.
9. Reencargo con diagnóstico ampliado tras feedback del titular sobre la
   estructura real depositada (CCEA, referencia/, REG/INV, filtro PAES/PDT,
   snake_case sin excepción).
10. Tres decisiones de arquitectura (Rama B, agregación en pipeline no
    pre-agregación, renombrado diferido a una sola pasada) resueltas vía preguntas
    de opción.
11. Ejecución de Fase A (código de migración A→B) — commit `0e90fe5`.
12. Ejecución de Fase B/C (movimiento físico de datos + variable de entorno) —
    manual del titular; dos incidentes menores (conteo 71 vs 74 del asistente;
    variable no aplicada en el primer intento del titular).
13. Ejecución de Fase D (validación + renombrado + reorganización referencia/) —
    commits `9b2e8f3` y `37e4a20`.
14. Cierre de sesión con traspaso v01 y este backlog.

### Sesión 2

15. Diagnóstico de escala PDT/PAES (pendiente 2 de v01): confirma que
    `*_ANTERIOR` de ArchivoC 2023 ya viene en escala PAES (100-1000), no PDT.
    Commit `4609ccd`.
16. Revisión completa de `contexto_paes.md` contra 23 documentos oficiales
    DEMRE. Corrige modelo psicométrico (Rasch, no IRT 3PL), ejes M1, Vía
    Pedagogía (Ley 21.490), universidades adscritas, sentinela de ausencia,
    origen de la escala 100-1000. Commit `2033d01`.
17. Re-chequeo del ejemplo de Puntaje Ponderado (848,75): confirmado sin
    corrección. Commit `f554424`.
18. Diseño y aprobación del schema de `31_leer_normalizar.R` (mapeo wide→long
    ArchivoD 2023, esquema LONG para ArchivoC), gate del titular.
19. Implementación y verificación de `31_leer_normalizar.R`, incluido bugfix de
    separador decimal mixto en ArchivoD 2023 PACE. Commits `4fed022`, `119e5b1`.
20. Limpieza de columnas `modulo_*` redundantes (hallazgo colateral). Commit
    `119e5b1`.
21. Diagnóstico del contrato real de `31` previo a diseñar `32` (detecta que
    ArchivoD/Matr no traen `rbd` propio).
22. Implementación y verificación de `32_agregar_territorial.R` (embudo de 6
    etapas, foco Rendimiento, territorialización de ArchivoD). Commit `9b74caf`.
23. Confirmación documental de `marca_egreso==1` contra Libro de Códigos oficial.
    Commit `e478392`.
24. Encargo de alternativas UI/UX a Claude Design (2 propuestas sobre referencia
    de motores hermanos).

### Sesión 3

25. Primer encargo a Claude Code desde el prototipo, detención legítima en Fase
    0 (esquema real de `32` no coincidía con los supuestos del encargo; error
    del asistente registrado en v03 §15).
26. Discusión de gobernanza sobre reidentificabilidad del `id_aux` anonimizado
    (gate de gobernanza, Política §6.4).
27. Resolución de las 4 decisiones de Camino A (nivel comuna por defecto,
    Rendimiento sin microdato, KPIs de prioridad diferidos, control Cohorte
    reinterpretado como toggle).
28. Implementación completa del motor `33` (Camino A): JSON columnar, 6 vistas,
    modal de territorio, exportadores. Verificado con panel adversarial (15/15
    match, auditoría de gobernanza PASS). Commits `d8bc790`, `c9041ad`.
29. Falso positivo de mojibake reportado por el titular; verificado a nivel de
    bytes que el commit no lo contenía (causa: caché del preview); guarda de
    build agregada de todos modos. Commit `ab20bcf`.

*(4 bugs internos de esta sesión — paréntesis faltante en `Modal`, `useState`
condicional, mojibake bajo locale C, claves de catálogo inconsistentes — no
cuentan como entradas propias: detectados y resueltos por el asistente durante
la verificación del Cambio 28, no reportados por el titular. Detalle completo
en traspaso v03 §6.)*

### Sesión 4

30. Corrección de nota de arquitectura Rama A→B residual en el escáner
    (`00_escanear_proyecto.R`). Commit `6f8cad9`.
31. Réplica de la decisión Camino A como archivo independiente
    (`20260702_decision_camino_a_motor_33.md`), exigido por Política §10.
32. Auditoría de fuentes tipográficas (4 proyectos hermanos) y migración de
    `slep_paes` a `--fs-*` (escala de `ade`, piso 12px, 7 niveles). Commit
    `0d7977f`.
33. Instrucción portable de migración tipográfica redactada para `cat`/`idps`
    (a ejecutar en sesiones propias de esos proyectos).
34. Camino B: KPI de prioridad de carrera en `32` (definición, universo,
    descubrimiento de la regla de precedencia `estado_pref` 24 vs. 26). Commit
    `919c286`.
35. Camino B: KPI de prioridad de carrera renderizado en `33` (card en Actual,
    columna en Comparar). Commit `2d61ed2`.

*(1 bug interno de esta sesión — medias sin redondear en `RenHist` — no cuenta
como entrada propia: detectado durante la verificación del Cambio 32, no
reportado por el titular. Detalle en traspaso v04 §6.)*

### Sesión 5

36. Push del estado acumulado de sesión 4 (`ab20bcf..2d61ed2`).
37. Corrección del traspaso v04 (pendiente de `suitedoc` omitido en la
    redacción original; error del asistente registrado en v05 §15).
38. Suite de documentación `suitedoc`, standalone offline desde el inicio.
    Commit `dfec49d`.
39. Mejoras de interfaz: reorden de header a fila única, selector de territorio
    con tabs (patrón `slep_simce_adecuado`), fix inicial del toggle de
    generaciones anteriores. Commits `e90edc4`, `15695ff`, `4c063e9`, `04978e5`.
40. Cohorte por territorio real (RBD histórico) + toggle de 3 estados
    (actual/anterior/todas), reemplazando el bucket nacional único. Commits
    `250d2fa`, `92039e4`.
41. Ajustes de interfaz v2: retiro de chip redundante, filtro interactivo de
    desglose por comuna, extensión de cohorte a vista histórica, nueva serie
    "seleccionado en 1.ª preferencia". Commits `c0133a0`, `18b2dbe`, `ecd38ba`,
    `4baf854`, `81c8929`.
42. Rótulo "1.ª prioridad" + detención real sobre conteo invierno/regular
    (`convocatoria_archivo` inerte; decisión de conteo diferida al titular).
    Commits `363d55a`, `1d22d44`.
43. "Universo de seleccionados" (handoff Claude Design, iteración tras
    calificación 2/10 del tratamiento anterior). Commit `8a614c3`.
44. Fix: cohorte "Todas" mostraba porcentajes >100% (denominador desalineado
    en 3 vistas + export XLSX). Commit `175787b`.

### Sesión 6

45. Auditoría de datos pre-push (4 fases, panel adversarial): detecta violación
    real del invariante ">100%" (29 celdas, máx 207%). Commits `e6caf6f`,
    `0e884ca`, `9c2dd89`, `a4d8cf0`, `6eba3d4`, `fa54197`.
46. F1: alineación del denominador `egresados` (`anio_proceso = agno + 1L`).
    Commit `35f7bd9`.
47. F2: resguardo en 1.ª prioridad suprimida (distingue cero genuino de
    supresión). Commit `0a25277`.
48. Re-auditoría post-F1/F2 (panel adversarial reajustado). Commit `927cc1a`.
49. F3: diagnóstico de infeasibilidad de reconciliación persona-a-persona y
    decisión formal de aceptar el margen (1 persona, Santo Domingo). Commits
    `797b331`, `20d4395`.
50. Diagnóstico de Decisión 6 (conteo invierno/regular) contra normativa DEMRE:
    embudo confirmado correcto, pero revela problema real en Rendimiento.
51. Implementación de "mejor puntaje vigente" (ventana=4), fidelidad literal a
    normativa DEMRE. Commit `2163f69`.
52. Revisión visual del titular y autorización + ejecución de
    `git push origin main`.

## Delta del backlog

**Consolidación de sesión 7 (doble atraso resuelto):** este backlog estaba
extraído solo hasta sesión 1 (14 cambios). Se reconstruyeron las sesiones 2-6
desde el "Registro detallado de cambios" y "Bugs de la sesión" de cada traspaso
(v02-v06), aplicando la nota metodológica de forma estricta: los "Cambio N" que
en los traspasos originales solo apuntan a bugs internos no reportados por el
titular (v03 Cambio 5, v04 Cambio 5) no se cuentan como entradas propias del
backlog, ya que están cubiertos por el Cambio que los contiene.

**Total resultante: 52 cambios acumulados** (14 sesión 1 + 10 sesión 2 + 5
sesión 3 + 6 sesión 4 + 9 sesión 5 + 8 sesión 6).

**Discrepancia sin resolver (declarada, no fabricada):** el traspaso v06 §4
declara "51 cambios al cierre de v05" y "59 acumulados" tras sumar los 8 de
sesión 6. El conteo reconstruido en esta consolidación da 46 al cierre de v05
(14+10+5+6+9) y 52 tras sesión 6. Diferencia de 5 (a v05) / 7 (total) sin
explicación verificable desde el contenido de los traspasos v02-v06: puede
deberse a un criterio distinto usado en su momento (p. ej. contar aparte algún
bug reportado por el titular que esta reconstrucción no aisló, o un error de
suma en v06 mismo). **No se fuerza el número a 59** para no fabricar
trazabilidad inexistente (POLITICA B.1). Queda como pendiente de sesión 7 (ver
traspaso v06 §15, patrón de errores del asistente): si el titular recuerda o
localiza el criterio de conteo usado al cierre de sesión 5 que sustente 51,
corregir esta entrada con una nueva entrada de delta (nunca reescribiendo el
detalle cronológico ya escrito arriba).

Taxonomía sin refinar desde sesión 1 (6 categorías originales); no se
reclasificaron los cambios 15-52 por categoría en esta consolidación
(quedaría fuera de alcance de "cerrar el atraso mecánico"; considerar en
sesión dedicada si se necesita el desglose por categoría actualizado).
