# Backlog acumulativo — slep_paes

> Registro histórico vivo del proyecto (POLITICA §10 / SETTINGS §2.2.5). En cada
> cierre se copia íntegro y se agregan los cambios nuevos al final; jamás se
> reescriben, resumen ni renumeran entradas anteriores. Extraído del traspaso
> v01 en el primer cierre (sesión 1, 2026-07-01).

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
pedido. Fuente del conteo: la conversación completa de la sesión 1.

## Clasificación temática (a la sesión 1)

| Categoría | N° | % | Descripción |
|---|---|---|---|
| Scaffold y arquitectura | 3 | 21% | Estructura Rama A inicial, migración A→B, config de dos raíces |
| Gobernanza de datos | 4 | 29% | Compuerta PII, diagnóstico Fase 0, decisión Rama B, fuga PII hermano (delegada) |
| Reuso y patrón de familia | 1 | 7% | d3/pako/auxiliares/paleta |
| Dominio (contexto_paes) | 2 | 14% | Conversión inicial + transcripción manual de fórmulas |
| Organización de insumos | 3 | 21% | Estructura por etapa, renombrado snake_case, referencia/ |
| Pipeline (stubs) | 1 | 7% | 30-33 |

Taxonomía inicial (6 categorías); a refinar en sesiones futuras si alguna supera
el 25% o cae bajo el 2%.

## Resumen estadístico por sesión

| Sesión | Traspasos generados | N° de cambios | Modelo | Foco |
|---|---|---|---|---|
| 1 | 1 (v01) | 14 | Claude (análisis) + Claude Code | Scaffold → migración A→B → insumos reales |

## Detalle cronológico (numeración global, permanente)

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

## Delta del backlog

Primer cierre; no hay versión anterior. Taxonomía inicial propuesta (6 categorías).
