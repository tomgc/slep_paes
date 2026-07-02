# Log — motor `33` recreado con datos reales (Camino A)

- Fecha: 2026-07-02 (sesion 4)
- Modo: autonomo, secuencial, R-only + template HTML. Push NO ejecutado (espera visto bueno del titular).
- Archivos tocados: `30_procesamiento/33_generar_html.R`, `30_procesamiento/33_motor_template.html`,
  `docs/index.html` (regenerado), `CLAUDE.md`, este log. (`.claude/launch.json` local para preview; gitignoreado.)
- Antecedente — DETENCION previa: en la sesion anterior se detuvo correctamente (regla a) al detectar que el
  prototipo del handoff asumia un contrato que 32 no produce (7 etapas con matricula, KPIs de prioridad de
  carrera, nivel establecimiento, strip plots por alumno + tooltip con dependencia/puntaje individual =
  microdato reidentificable, mediana/sd, split rec/ant cruzado por territorio). El titular reviso, resolvio 4
  decisiones y confirmo **Camino A** (adaptar el diseno al agregado real). Este encargo ejecuta Camino A.

## Decisiones del titular aplicadas (las 4)

1. **Comparar territorios** = nivel comuna por defecto (4 comunas de Costa Central), ampliable a
   SLEP/region/nacional desde el modal; NUNCA establecimiento. → Implementado: `compSel` default =
   `comuna:5109/5103/5107/5105`; el modal ofrece nacional→region→SLEP→comuna, sin nivel establecimiento.
2. **Rendimiento·Actual sin microdato** = media por prueba y territorio (barra + n), metrica = mean.
   → Implementado en `RenActual` (barras de media con n) y `RenComp` (heatmap de media). Sin strip plots,
   sin jitter, sin tooltip por alumno.
3. **Matriculado + KPIs de prioridad**: FUERA de esta version (no existen en 32). → Embudo de 6 etapas;
   sin card de prioridad; sin UI stub esperandolo.
4. **Cohorte** = toggle de mostrar/ocultar la categoria "generaciones anteriores" (`tipo_entidad=="rezagados"`,
   bucket nacional agregado), siempre reportada. → Implementado: `genAntToggle` + `genAntSlab` (se atenua al
   ocultar, nunca desaparece; el toggle siempre visible).

## Contrato de datos (re-verificado, Fase 0)

- `paes_cobertura_territorial.parquet`: `cod_entidad, anio_proceso, n, tipo_entidad {nacional,region,slep,comuna,rezagados},
  suprimida, etapa {egresados,inscripcion,rendicion,resultados,postulacion,seleccion}, orden_etapa`. Anios 2023–2026.
- `paes_rendimiento_territorial.parquet`: `cod_entidad, anio_proceso, prueba {clec,mate1,mate2,cien,hcsoc,mate,nem,ranking},
  tipo_rendicion {reg,inv,NA}, vigencia {actual,anterior,NA}, n, media, tipo_entidad, suprimida`. NEM/Ranking con
  tipo_rendicion/vigencia = NA. El motor usa reg+actual para las 5 pruebas PAES + NEM/Ranking.
- `anio_actual` = 2025 (ultimo anio con denominador de egresados; 2026 trae inscripcion en adelante pero NO
  egresados — egresados_em 2026 ausente en 32).

## Inventario de commits

- `d8bc790` — feat(33): recrea el motor HTML con datos reales (Camino A, agregados). Generador (JSON columnar
  gzip+base64, fuentes embebidas, libs locales) + template completo (shell, controles, 6 vistas, modal,
  exportadores) + `docs/index.html` regenerado.
- `<este commit>` — docs(33): log de verificacion + actualizacion de CLAUDE.md (Estado, Pipeline, Ultimos cambios).

Nota de estructura de commits: el generador y el template son interdependientes (el generador falla si el
template no trae los placeholders correctos), por lo que Fases 1–5 se consolidaron en un commit funcional y
verificable en vez de commits parciales no ejecutables; el log/CLAUDE (Fase 6) va en un commit aparte.

## Verificacion de invariantes 🔒 (PASA/FALLA + evidencia)

| Invariante | Estado | Evidencia |
|---|---|---|
| Supresion n<8 respetada en render (no recalculada) | PASA | El motor lee `suprimida` de los parquets; celdas suprimidas muestran gris `#E7E1D2` + "resguardo"; no hay recomputo de umbral en el template. |
| Terminologia "generaciones anteriores" (no "rezagados" en texto visible) | PASA | grep de `docs/index.html`: "rezagados" solo aparece 2× y ambas en CODIGO (discriminador `p.tipo==="rezagados"` y un comentario); todo texto visible dice "Generaciones anteriores". |
| Modelo Rasch (no 3PL / azar / discriminacion) | PASA | Nota metodologica afirma modelo de Rasch y "no se asume azar ni discriminacion por item". Sin referencias a 3PL (el unico "3PL" es un fragmento incidental del blob base64). |
| Sentence case (salvo siglas) | PASA | Titulos y etiquetas en sentence case; siglas PAES/SLEP/NEM/CL/M1/M2/DEMRE respetadas. |
| Alineacion: metricas centradas, Territorio a la derecha | PASA | En `CobComp`/`RenComp` la col Territorio (`nameCell`) usa `textAlign:right`; columnas metricas `textAlign:center`. |
| SOLO agregados, nunca microdato | PASA | JSON embebido = agregados territorio×dimension con n+media/n y flag `suprimida`. Sin filas por persona. Panel adversarial B (abajo). |
| Nunca identificar establecimientos (POLITICA 6.4) | PASA | `establecimientos_chile.parquet` NO se carga; el arbol llega a comuna; sin nombres/RBD de establecimiento en JSON ni DOM. Panel adversarial B (abajo). |
| Datos reales, nunca inventados | PASA | Todas las cifras provienen de los parquets de 32; panel adversarial A recalculo 15 cifras (todas MATCH). |
| Sin dependencias externas (CDN) | PASA | React/ReactDOM/D3/pako inline; fuentes base64; grep de `docs/index.html` = 0 refs http(s) a CDN. |

## Panel adversarial (auto-auditoria)

### (a) Recalculo independiente de cifras — Agente A (solo lectura, codigo propio, sin leer 33)

15/15 valores MATCH contra los parquets:
- Cobertura SLEP 503 (Costa Central) 2025: egresados 1434, inscripcion 1124 (78,4%), rendicion 866 (60,4%),
  resultados 807 (56,3%), postulacion 446 (31,1%), seleccion 358 (25,0%). Todos MATCH.
- Rendimiento SLEP 503 2025 reg+actual: clec media 544 (544,08) / n 829; mate1 media 548 (547,88) / n 798. MATCH.
- Cobertura comuna 5109 (Viña del Mar) 2025: egresados 4418, inscripcion 5203. MATCH.
  (inscripcion > egresados es esperado: los rezagados de cohortes previas inflan la inscripcion sobre el
  denominador de egresados del anio.)

### (b) Gobernanza / no-microdato — Agente B (solo lectura)

**VEREDICTO: PASS.** Decodifico el blob embebido (`/tmp/motor_data.json`, 933.018 chars) y audito:
- Estructura: top-level `meta, cobertura, rendimiento`; fact tables columnar.
- Arbol territorial: exactamente 4 niveles — nacional(1), regiones(16), sleps(36), comunas(332). **Sin nivel
  establecimiento** (no hay array `establecimientos`/`rbd`).
- `tipo_entidad` en ambas tablas ⊆ {comuna, nacional, region, rezagados, slep}. Sin establecimiento.
- **Sin fuga de identificadores**: `establecim/nom_rbd/cod_ense/mrun/liceo/colegio/escuela` = 0. Los hits de
  "rbd" (52 en JSON) son todos la etiqueta literal "Egresados de anios anteriores (sin RBD vigente)"; los de
  "rut" son la subcadena de la comuna "Frutillar"; en HTML, dentro de blobs base64 (fuentes/datos). Las 4
  apariciones legibles de "establecim" son texto metodologico ("No se identifica... ningun establecimiento").
- Campos: cobertura `cod_entidad, anio_proceso, etapa, orden_etapa, tipo_entidad, n, suprimida`; rendimiento
  `cod_entidad, anio_proceso, prueba, tipo_entidad, n, media, suprimida`. Todos agregados. 0 codigos
  desconocidos; longitud maxima de codigo = 5 digitos (comuna), sin codigos de 6+ digitos (no RBD).
- **Supresion**: 83 celdas suprimidas en cobertura, 116 en rendimiento. Para TODA celda suprimida, `n` es NA
  (y `media` NA en rendimiento) — el conteo pequeño NO se expone en el JSON. Minimo n no-suprimido = exactamente
  8 en ambas tablas (consistente con `meta.umbral=8` / POLITICA 6.4). La supresion es mas fuerte que el minimo
  exigido: el valor chico nunca sale del pipeline (no queda tras un flag de UI).

## Notas y detenciones de este encargo

- No se activo ninguna detencion (a/b/c) en este encargo: el contrato ya estaba resuelto y las 4 decisiones
  cubrian los puntos abiertos.
- Fixes durante la verificacion (resueltos autonomamente, una linea c/u):
  - Paren faltante en el `return` del `Modal` (SyntaxError) → corregido.
  - `React.useState` dentro de `Modal` (render condicional) violaba rules-of-hooks → React #310 al abrir el
    modal; movido el estado de busqueda a `App` (`modalQuery`). Los errores #310 en el buffer de consola son
    previos al fix (stale); tras el fix el modal abre/cierra y selecciona (single y multi) sin desmontar el arbol.
  - Literales `.R` con acentos/ñ salian mojibake bajo locale C (`enc2utf8` los doble-codificaba) → marcado
    UTF-8 recursivo (`marcar_utf8`) antes de serializar; verificado "Tarapacá/Valparaíso/Matemática/enseñanza"
    correctos, 0 mojibake.
  - Claves de catalogo: regiones/sleps pasaban `reg`/`slep` pero el cliente indexa por `cod` → estandarizadas a `cod`.
- Exportadores validados: SVG 6,4 KB (image/svg+xml); XLSX abre en `readxl` (firma PK, 4×12, datos correctos).
- `run_all()` completo corre sin abortar (30→31→32→33, ~50 s).
