# Encargo autónomo — Auditoría de datos exhaustiva pre-push

> Estructura según `encargo_autonomo_claude_code_v1.md` §2. Gate de push
> del titular (traspaso_cierre_v05.md, pendiente 5, plan de 4 fases ya
> acordado con el titular; no se reinventa alcance).

## 2.1 Encabezado de contrato

- **Modo:** autónomo, secuencial, ejecuta todo en este turno.
- **Regla de detención:** PARA y reporta si (a) un invariante de
  gobernanza/datos se vería violado, (b) una cifra real contradice un
  supuesto de este encargo o del traspaso v05, (c) una discrepancia entre
  recálculo y motor no tiene causa raíz evidente en 1 iteración de
  diagnóstico.
- **Reglas heredadas (no se re-explican):** rutas absolutas siempre;
  R-only para todo cálculo (panel adversarial en R, nunca Python); `cd
  ~/Projects/slep_paes` explícito en cada bloque de terminal; snake_case
  sin tildes/ñ/espacios en cualquier archivo nuevo; commits atómicos por
  fase con mensaje descriptivo; NO push (gate del titular).

## 2.2 Contexto mínimo suficiente

Proyecto `slep_paes`, Rama B (código en `~/Projects/slep_paes`, datos en
`SLEP_PAES_DATA_ROOT`). Pipeline: `31_leer_normalizar.R` →
`32_agregar_territorial.R` → `33_generar_html.R` +
`33_motor_template.html`. Sesión 5 (cerrada, ver
`50_documentacion/traspasos/traspaso_cierre_v05.md`) introdujo la
dimensión `cohorte` (`actual`/`anterior`/`todas`) cruzada por RBD
histórico de egreso en `32`, un toggle de 3 estados en el motor, y corrigió
un bug de denominador (`baseCob()`, commit `175787b`). El motor tiene 13+
commits locales sin push. Esta auditoría es la condición pactada con el
titular para autorizar push, junto con revisión visual (aparte, no cubierta
por este encargo).

`ArchivoB` trae el RBD de egreso histórico (`rbd`, `anyo_egreso`).
`(id_aux, anio_proceso)` es 1:1 con `rbd`/`anyo_egreso` salvo 254/985.379
personas con 2 RBD entre años (ya resuelto en `32`, no reabrir criterio).

## 2.3 Invariantes (🔒)

- 🔒 `UMBRAL_SUPRESION_CELDA = 8`: cualquier celda con n < 8 debe estar
  suprimida (`n = NA`) en ambos caminos del recálculo.
- 🔒 Cohorte "actual" = `anyo_egreso == anio_proceso - 1`; "anterior" =
  `anyo_egreso <= anio_proceso - 2` (o NA). No redefinir.
- 🔒 Ningún porcentaje publicado puede superar 100% en ninguna
  combinación cohorte × vista × período × indicador.
- 🔒 No se modifica código de cálculo en este encargo. Este es un encargo
  de **verificación**, no de corrección. Si se encuentra una discrepancia,
  se documenta con causa raíz propuesta; NO se corrige sin autorización
  explícita del titular (POLITICA 0.3, gate estratégico).
- 🔒 No se accede ni se referencia el RBD, RUT o cualquier identificador a
  nivel de establecimiento/individuo en el reporte final ni en el log
  (gobernanza, POLITICA §6).

## 2.4 Fases en orden estricto

### Fase 0 — Lectura del estado real
- Leer `32_agregar_territorial.R`, `33_motor_template.html`,
  `33_generar_html.R` completos (versión actual en disco, no supuestos).
- Leer `traspaso_cierre_v05.md` completo, especialmente §3 Cambio 5
  (cohorte) y Cambio 9 (fix `baseCob`).
- Confirmar `run_all(only=33)` reproducible antes de tocar nada.

### Fase 1 — Recálculo independiente (alcance completo)
Para **todos** los indicadores publicados: embudo de cobertura,
rendimiento, KPI de 1.ª prioridad, serie histórica nueva
("Seleccionado en 1.ª preferencia (% de egresados)"), desglose filtrable
por comuna, supresión — cruzado por las 3 cohortes × 2 vistas
(Cobertura/Rendimiento, según aplique) × 2 períodos (actual/histórico).

- Script nuevo de solo lectura (no reusar funciones de `32`; recalcular
  desde los parquets crudos con código propio, panel adversarial real).
- Comparar contra el HTML/JSON generado por el pipeline (no contra el
  reporte de encargos previos).
- Cubre nacional + al menos 1 región + al menos 1 SLEP + 2 comunas
  (mínimo, ampliar si el tiempo lo permite).

### Fase 2 — Aditividad territorial post-supresión
Re-verificación completa (no reusar la del Cambio 5): comuna → región →
nacional, y comuna → SLEP donde aplique, para las 3 cohortes, confirmando
que la suma de celdas no suprimidas cuadra aritméticamente con el nivel
superior, y que la supresión (`n < 8`) se aplicó consistentemente en
ambos caminos.

### Fase 3 — Verificación de %>100%
Barrido programático (no muestreo manual) de **todo** valor porcentual
renderizado en el motor para las 3 cohortes × 2 vistas × 2 períodos:
ningún valor > 100%. Reportar cualquier hallazgo con la celda exacta
(territorio, año, cohorte, indicador) sin exponer RBD/RUT.

### Fase 4 — Verificación en navegador (autónoma, DOM real)
Automatizar la navegación del motor (headless) recorriendo las
combinaciones críticas: Foco × Vista × Período × Cohorte. Confirmar que
las cifras mostradas en el DOM coinciden con el recálculo de Fase 1 (no
solo que la página carga sin error de consola). Registrar 0 errores de
consola.

Commit atómico al cierre de cada fase con su script de auditoría (los
scripts de auditoría van a `50_documentacion/andamios/` como evidencia
congelada, no a `30_procesamiento/`).

## 2.5 Criterios de éxito verificables (B.4)

- Fase 1: cada indicador, cada combinación muestreada, MATCH exacto
  (mismo criterio que el panel del Cambio 5: 0 discrepancias o
  discrepancia con causa raíz documentada).
- Fase 2: aditividad exacta post-supresión, 0 excepciones no explicadas.
- Fase 3: 0 valores > 100% en el barrido completo.
- Fase 4: 0 errores de consola; cifras DOM = cifras Fase 1 en todas las
  combinaciones recorridas.

## 2.6 Mandato de auto-auditoría

Riesgo de datos real y alto (múltiples cambios acumulados sobre el mismo
pipeline sin verificación transversal previa). Panel adversarial
obligatorio en las 4 fases: código de recálculo propio, independiente de
`32`/`33`, nunca reutilizar funciones ya escritas por los encargos
previos de sesión 5.

## 2.7 Mandato del log y el cierre

Generar `50_documentacion/andamios/logs/20260703_auditoria_datos_pre_push_log.md`
según plantilla fija de `encargo_autonomo_claude_code_v1.md` §4. Incluir
tabla de invariantes (🔒 de §2.3) con PASA/FALLA y evidencia. No hacer
push. Commits locales quedan para revisión del titular.

## 2.8 Reporte final

Al chat: veredicto global (apto/no apto para push), tabla resumen por
fase (MATCH/discrepancias), cualquier hallazgo con causa raíz propuesta
(sin corregir), hashes de commits, ruta del log completo, y pendientes
`# REVISAR` si los hay.
