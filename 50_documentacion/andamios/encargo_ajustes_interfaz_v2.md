# Encargo autónomo — Ajustes de interfaz (post-cohorte territorial)

> Sigue `encargo_autonomo_claude_code_v1.md`. **Depende de**
> `encargo_cohorte_territorial.md` (ya enviado, Fases A/B): usa el esquema
> `cohorte` que ese encargo produce. Verificar que esas fases ya cerraron
> con commit antes de empezar (caso de detención si no).

## Modo y disciplina

Autónomo, secuencial, 4 fases independientes entre sí salvo la dependencia
de arriba. Commit atómico por fase.

## Regla de detención

PARA y reporta solo si:
(a) los commits de `encargo_cohorte_territorial.md` (Fases A/B) no están
    presentes en el historial del repo;
(b) el renombrado global "cohorte" genera colisión con un término ya
    reservado en el código (variable, función) de forma que renombrar
    rompe algo más allá de texto visible;
(c) la nueva serie "Seleccionado en 1ª preferencia" no tiene datos
    históricos disponibles para todos los años (2023-2026) en el parquet
    de `32` (verificar antes de asumir cobertura completa).

## Contexto mínimo suficiente

- Proyecto `slep_paes`, raíz `~/Projects/slep_paes` (Rama B).
- Archivo objetivo: `30_procesamiento/33_motor_template.html`
  (regenerar con `run_all(only=33)` tras cada fase).
- Este encargo asume que el control de 3 estados (Actual/Anteriores/Todas)
  y la dimensión `cohorte` en `COV`/`REN` ya existen (producidos por el
  encargo anterior).

## Invariantes (🔒)

- 🔒 "Generaciones anteriores" → renombrar a "Cohortes anteriores" /
  "Cohorte" en **toda la interfaz visible**: el control de 3 estados, notas
  explicativas (`viewMeta`), `ContextStrip`, exportación a Excel, y los 4
  HTML de la suite de documentación (`50_documentacion/suite/documentar.R`
  + regenerar). El identificador interno del dato (`REZ_ID` u otro nombre
  de variable en código) no necesita renombrarse si no aporta claridad;
  el invariante es sobre texto **visible**, no sobre nombres de variable.
- 🔒 `UMBRAL_SUPRESION_CELDA=8` sin cambio.
- 🔒 Sin nombres de establecimientos en ningún output.
- 🔒 Un cambio conceptual por intervención: 4 fases, 4 commits.

## Fase 1 — Retirar el chip "Territorio en pantalla" redundante

**Estado actual:** `ContextStrip` (vista `terr`) muestra un chip grande con
el nombre del territorio ya seleccionado en el selector de arriba
(`territoryBtn`), duplicando la información.

**Objetivo:** retirar el chip principal (el bloque `chip` en `ContextStrip`,
rama `else` de `s.vista==="comp"`). Conservar el desglose por comuna (Fase
2 lo modifica, no lo elimina) y el título "Territorio en pantalla" solo si
sigue aportando contexto sin el chip; si el desglose por comuna ya lo
provee, evaluar si el título también sobra (decidir con criterio, no es
invariante).

**Verificación (B.4):** vista `terr` sin el chip azul grande; el
desglose por comuna (si aplica al territorio) sigue visible; vista `comp`
sin cambios (no tiene este chip).

**Commit:** `style(33): retira chip territorio redundante en ContextStrip`.

## Fase 2 — Desglose por comuna: renombrar y hacer filtrable

**Estado actual:** "con desglose por comuna:" + chips no interactivos con
las comunas hijas del territorio (`childComunas`).

**Objetivo:**
1. Renombrar el label a "Desglose por comuna" (sentence case, sin
   minúscula inicial de conector).
2. Cada chip de comuna se vuelve clickable: alterna estado
   seleccionada/deseleccionada (checkbox visual o toggle de opacidad,
   consistente con el patrón ya usado en `genAntToggle`/tabs). Deseleccionar
   una comuna la excluye del cálculo agregado que se muestra para el
   territorio padre (si el resto de la interfaz ya soporta un subconjunto
   de comunas dentro de un SLEP/región, reusar esa lógica; si no existe,
   este es el primer punto donde se necesita — evaluar alcance real antes
   de implementar un filtro nuevo desde cero, y declarar la decisión).

**Verificación (B.4):** el label dice "Desglose por comuna"; clic en un
chip de comuna lo marca como excluido (visualmente distinto); el agregado
del territorio padre (embudo, rendimiento) refleja el subconjunto de
comunas activas; volver a hacer clic la reincluye.

**Commit:** `feat(33): desglose por comuna filtrable, renombra label`.

## Fase 3 — Cohorte también en vista histórica

**Estado actual:** el control de cohorte (post-encargo anterior) puede
seguir restringido a `modo==="actual"` si Fase B del encargo previo no lo
extendió a histórica explícitamente — verificar contra el resultado real
de ese encargo en la Fase 0 de este.

**Objetivo:** el control de 3 estados (Actual/Anteriores/Todas) aplica
también con `modo==="hist"`, en las 4 combinaciones Cob/Ren ×
Por-territorio/Comparar, ahora también cruzado con Actual/Histórica (8
combinaciones visualizables en total, aunque no todas simultáneas en
pantalla).

**Verificación (B.4):** en vista histórica, alternar Actual/Anteriores/
Todas cambia la serie mostrada (spot-check contra el parquet para al menos
un año).

**Commit:** `feat(33): control de cohorte tambien disponible en vista historica`.

## Fase 4 — Nueva serie histórica: "Seleccionado en 1ª preferencia (% de egresados)"

**Estado actual:** `Participación en el tiempo` (serie histórica de
Cobertura) muestra 2 series: "Rindió al menos una prueba" y "Seleccionado",
ambas como % de egresados.

**Objetivo:** agregar una tercera serie a ese mismo gráfico: "Seleccionado
en 1ª preferencia (% de egresados)". Fuente de dato: el KPI de prioridad ya
implementado en sesión 4 (`pct_prioridad_1`, `orden_pref==1` sobre
seleccionados), pero **expresado sobre el denominador de egresados** (no
sobre seleccionados, para que sea comparable en la misma escala que las
otras 2 series del gráfico) — es decir, `n_prioridad_1 / n_egresados`, no
`pct_prioridad_1` tal cual está en el parquet (que ya divide por
seleccionados). Verificar en `32` si ese cálculo derivado se puede hacer en
`33` a partir de columnas ya existentes (`n_prioridad_1` + el denominador
de egresados de la etapa `egresados`) o si requiere una columna nueva en
`32` (caso (c) de detención si el dato no alcanza para todos los años).

**Verificación (B.4):** la nueva serie aparece con su propio color y
leyenda; valores verificados contra cálculo manual para al menos 2
años/territorios; supresión respetada (si `n_prioridad_1` está suprimido
para algún año, la serie muestra el hueco, no un cero falso).

**Commit:** `feat(33): agrega serie seleccionado en 1ra preferencia al grafico historico de cobertura`.

## Mandato de auto-auditoría

Fase 4 deriva una cifra nueva (aunque a partir de columnas existentes):
verificar con al menos 2 spot-checks manuales contra el parquet, no solo
render sin errores. Fases 1-3 son interfaz pura: basta verificación en
navegador.

## Mandato del log y reporte final

Generar `50_documentacion/andamios/logs/20260702_ajustes_interfaz_v2_log.md`.
Reportar: 4 hashes de commit, confirmación de que "cohorte" reemplazó
"generaciones" en los lugares listados (grep de "generaciones anteriores"
en texto visible debe dar 0, salvo si quedó en algún identificador interno
no visible), spot-checks de Fase 4, y cualquier detención (a)/(b)/(c).
