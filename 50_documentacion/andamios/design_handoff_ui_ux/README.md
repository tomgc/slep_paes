# Handoff: slep_paes — Motor de resultados PAES (Cobertura y Rendimiento)

## Overview

`slep_paes` es el cuarto panorama nacional del **Área de Monitoreo y Seguimiento de Procesos y Resultados Educativos del SLEP Costa Central** (Chile), construido con datos públicos del DEMRE sobre la PAES (Prueba de Acceso a la Educación Superior). Se publica como un sitio HTML autocontenido navegable por territorio, hermano de `slep_categoria_desempeno`, `slep_idps` y `slep_simce_adecuado`.

Lo distintivo de este motor: reporta **dos focos pares**, ninguno subordinado al otro:

1. **Cobertura** — el embudo de participación (egresados → inscripción → rendición → resultados válidos → postulación → selección → matrícula).
2. **Rendimiento** — la distribución de puntajes PAES por prueba (escala 100–1000), con NEM y Ranking como contexto.

La solución de interfaz elegida hace que **el foco sea el modo primario** (dos pestañas grandes que recolorean toda la vista), y sobre él operan las dos vistas del patrón de familia: **Por territorio** y **Comparar territorios**.

## About the Design Files

El archivo de este bundle (`slep_paes - motor.dc.html`) es una **referencia de diseño creada en HTML** — un prototipo funcional que muestra el look & feel y el comportamiento buscados, **no código de producción para copiar tal cual**. Técnicamente es un "Design Component" (plantilla + una clase de lógica que renderiza con `React.createElement`); casi toda la visualización de datos está dibujada por código (SVG generado en JS).

La tarea es **recrear este diseño en el entorno del proyecto real** (el motor final `33_motor_template.html`, que en la familia usa **React local pre-transpilado + D3 + pako, sin CDN, JSON embebido comprimido**), respetando esa arquitectura autocontenida. Si se implementa en otro stack, usar sus patrones establecidos. No embarcar este HTML directamente.

## Fidelity

**Alta fidelidad (hi-fi).** Colores, tipografía, espaciados, estados y comportamiento son finales y deben recrearse con precisión. **Los datos son de maqueta** (cifras ilustrativas, claramente marcadas “Datos de maqueta”): la estructura de la interfaz es la propuesta real a evaluar; los números se reemplazan por los del pipeline DEMRE real.

---

## Design Tokens

Paleta institucional SLEP + **los dos colores del logo DEMRE**, que son predominantes y codifican el foco.

### Colores
| Token | Hex | Uso |
|---|---|---|
| Navy DEMRE (`--plum`) | `#153E5E` | Contenedor institucional: header, footer/notas, chip de territorio, **acento del foco Rendimiento** |
| Cyan DEMRE | `#0BA0DA` | **Acento del foco Cobertura** (pestaña, embudo, KPIs, bordes) |
| Cream (fondo página) | `#FFF6E0` | Fondo por defecto (nunca blanco puro a bleed) |
| Cream-50 | `#FFFBEF` | Franjas y sub-barras |
| Cream-200 | `#F4E9CC` | Fondo de segmented controls, pistas de barras |
| Paper | `#FFFFFF` | Tarjetas |
| Ink | `#1C1212` | Texto principal |
| Ink-2 | `#2E2230` | Texto secundario / números |
| Slate | `#747474` | Texto terciario, ejes, captions |
| Line | `#E7DFC9` | Divisores hairline |
| Line-2 | `#C8BDA0` | Bordes de énfasis |
| Ink strip (top bar) | `#1C1212` | Franja superior “Motor slep_paes” |
| Terracota (badge) | `#C45A3E` | Solo badge “Datos de maqueta” |

**Acento por foco (regla central):** Cobertura → `#0BA0DA` (cyan); Rendimiento → `#153E5E` (navy). Este acento tiñe pestaña activa, borde del embudo/KPIs, líneas de gráficos y marcas de mediana. Tinte suave del acento: Cobertura `#DCF0FA`, Rendimiento `#DEE5EC` (usado en franjas de nota y cards de generaciones anteriores).

### Colores de comuna (swatches de territorio)
- Viña del Mar `#0062A0` · Concón `#75924E` · Quintero `#4A2746` · Puchuncaví `#BCA493`

### Heatmap (comparación) — NO semáforo
Escala divergente de dos extremos, interpolada en 3 paradas: **rojo = valor bajo (más alerta)** → pálido → **azul = valor alto (bueno)**.
- Rojo `rgb(214,69,69)` → Pálido `rgb(236,228,208)` → Azul `rgb(13,130,190)`, todo a `alpha 0.45`.
- Normalización **por columna** (min–max de la columna); `t=0` peor (rojo), `t=1` mejor (azul). Interpolación: `t≤0.5` mezcla rojo→pálido, `t>0.5` pálido→azul.

### Supresión de celdas (n < 10)
- Fondo **gris plano `#E7E1D2`** que ocupa **toda la celda** (sin patrón diagonal, sin recuadro interno), texto `n<10` en slate centrado. Nunca celda vacía ni error visual.

### Tipografía
- **Display: gobCL Heavy** (`.otf` incluido). Titulares y números destacados. **Sentence case** — NO ALL CAPS (regla explícita del cliente), salvo siglas (PAES, SLEP, NEM, CL, M1, M2, DEMRE).
- **gobCL Regular**: subtítulos/eyebrows.
- **Body/UI: Museo Sans** 300 / 500 / 700 (`.otf` incluidos).
- gobCL solo trae pesos 400 y 900 → evitar `font-weight:700` sobre gobCL (renderiza 900, se ve muy negro). **Uso moderado de negrita**: números de tablas y embudo en Museo Sans 500–600; gobCL Heavy reservado a títulos y KPIs grandes.
- Escalas: h1 header 30px / subtítulo 22px; h2 sección 23px; título de card 15px; eyebrow 11px; body 12–13px; captions/ejes 9–11px.

### Espaciado / radios / sombras
- Padding de página: 40px horizontal en franjas de contenido; header 26–28px.
- Radios: cards 8px, inputs/segmented 3–4px, chips 4px. **Casi cuadrado, nunca pill** (salvo puntos del scatter, que son círculos).
- Sombras plum-tinted: card `0 2px 8px rgba(74,39,70,.08)`; tooltip `0 6px 20px rgba(21,62,94,.18)`.

---

## Screens / Views

Es una sola pantalla con conmutación de estado. Estructura vertical fija:

1. **Franja superior (ink):** “Motor slep_paes” + descripción + badge “Datos de maqueta”.
2. **Header (navy):** eyebrow “Área de Monitoreo…”, H1 “Resultados Prueba de Acceso a la Educación Superior (PAES)” con subtítulo “Participación y desempeño”, línea “Datos públicos del DEMRE · cobertura nacional”, y párrafo introductorio de los dos focos. (Sin logo — retirado a pedido.)
3. **Barra de FOCO (pestañas primarias):** dos tabs grandes `Cobertura` / `Rendimiento`; la activa lleva subrayado de 3px del color de acento y recolorea la vista.
4. **Barra de controles (secundaria):** `Vista` [Por territorio | Comparar territorios] · (cuando Vista=Por territorio) `Período` [Actual | Histórica] a la derecha de Vista · a la derecha del todo el selector de `Territorio` (botón que abriría un modal).
5. **Sub-barra (solo Por territorio):** `Cohorte` (checkboxes) en modo Actual, o la nota “Serie 2020–2024” en modo Histórica.
6. **Franja “Territorio en pantalla”:** contexto del territorio (SLEP + desglose por comuna en Por territorio; lista de territorios comparados en Comparar).
7. **Sección Resultados:** eyebrow + H2 dinámico + subtítulo + nota metodológica contextual (franja con borde-izq de acento) + **barra de exportación icon-only (SVG / XLSX)** alineada a la derecha del eyebrow + el gráfico/tabla.
8. **Notas metodológicas:** bloque colapsable (cerrado por defecto) con Fuente, Cobertura temporal, Generaciones anteriores, Supresión de celdas, Cohortes, Rendimiento, Maqueta.

### Combinaciones Foco × Vista × Período (6 estados de contenido)

**Cobertura · Por territorio · Actual**
- Card “Embudo de participación”: **embudo trapezoidal centrado**, 7 etapas (Egresados de enseñanza media → Inscritos en la PAES → Rindió al menos una prueba → Resultados válidos → Postuló a educación superior → Seleccionado en alguna carrera → **Matriculado en educación superior**). Barras de más claro (arriba) a más oscuro (abajo). Rótulo por etapa a la derecha en formato **`% (n)`** (decimal con coma, gris `--ink-2`), miles con punto.
- Card/bloque **Generaciones anteriores** (antes “rezagados” — término prohibido): categoría siempre visible, borde punteado del acento, fondo tinte suave, total + desglose por comuna. Copy: “Personas que rinden la PAES sin establecimiento de egreso vigente en 2024…”.
- 4 **KPI de matriculados por prioridad de carrera** (1.ª / 2.ª / 3.ª / 4.ª o inferior): tarjeta con borde-top de acento, % grande + `(n)` + barra proporcional.
- Card “Retención por comuna”: sparklines por comuna (egresados 100% → matriculados).

**Cobertura · Por territorio · Histórica**
- Card “Participación en el tiempo” (2020–2024): **leyenda arriba**, gráfico de líneas con 2 series — “Rindió al menos una prueba (% de egresados)” (línea sólida, etiquetas arriba) y “Matriculado en educación superior (% de egresados)” (línea punteada, etiquetas abajo). **Todos los puntos etiquetados**, puntos grandes (r≈4.5). Debajo, strip “Generaciones anteriores por año”.

**Cobertura · Comparar territorios**
- Tabla **heatmap** de 10 establecimientos + fila Total. Columnas: Establecimiento · Egresados · Inscritos · Rindió · Válidos · Postuló · Seleccionado · Matriculado. Celdas de proporción = `% (n)` con **heatmap por columna** (rojo bajo → azul alto). Egresados sin heatmap. Leyenda **arriba** de la tabla (incluye barra de gradiente “menor % (más alerta) → mayor” y muestra de “dato suprimido”).

**Rendimiento · Por territorio · Actual**
- Card “Distribución de puntajes por prueba”: **strip plots apilados, uno por prueba** (CL, M1, M2, Ciencias, Historia y Ciencias Sociales), **anchos y bajos**. Eje X = puntaje 100–1000; cada punto es un estudiante con jitter vertical; color por comuna. **Generaciones anteriores = mismo símbolo (círculo)** en color de acento (NO otro símbolo). Marca de **mediana**: línea vertical con etiqueta “mediana XXX” **por encima** de la línea. Contexto (NEM, Ranking) como strips atenuados bajo un divisor. Leyenda **arriba**.
- **Hover en un punto:** tooltip con Establecimiento de egreso · Comuna · Dependencia (Municipal (traspaso a SLEP) / Particular subvencionado / Servicio Local (SLEP)), la prueba, el puntaje + posición vs. mediana (“+13 sobre la mediana 535”), y la cohorte. Generaciones anteriores → “Sin establecimiento de egreso vigente · Cohorte previa”. El punto se agranda (r 2.7→5) como feedback.

**Rendimiento · Por territorio · Histórica**
- Small multiples: una mini línea por prueba (mediana 2020–2024), escala Y acotada 480–600, todos los puntos etiquetados. Nota **arriba** de la grilla.

**Rendimiento · Comparar territorios**
- Tabla **heatmap** de 10 establecimientos. Columnas: CL · M1 · M2 · Ciencias · Historia (con heatmap por columna, **menor mediana = más rojo**) · NEM · Ranking (contexto, sin heatmap). Celda = `mediana (n)`. Suprimidas (`n<10` o sin dato) en gris plano. Leyenda arriba.

---

## Interactions & Behavior

- **Foco (tabs):** cambia `foco` (cob|ren) → recolorea acento y cambia todo el contenido.
- **Vista (segmented):** `terr` | `comp`.
- **Período (segmented, solo terr):** `actual` | `hist`.
- **Cohorte (checkboxes, solo terr+actual):** `Generación más reciente` (egresados 2024) y `Generaciones anteriores` (cohortes previas). Debe quedar **al menos una** marcada. Afecta al embudo (suma de cohortes seleccionadas), a los KPIs y a los strip plots (muestra/oculta los círculos de cada cohorte). Las Generaciones anteriores **siempre siguen visibles como categoría** aunque se excluyan del embudo (se indica en la nota).
- **Territorio:** botón que abre un modal de selección (no implementado en la maqueta). La comparación **admite hasta 10 territorios**; “territorio” es genérico (establecimiento, comuna, SLEP, región, nacional) — en la maqueta se muestra a nivel establecimiento.
- **Exportar SVG:** serializa los `<svg>` del área de resultados (`#paesWork`) apilados en un único SVG (con fondo cream y tokens embebidos) y lo descarga. 100% offline.
- **Exportar XLSX:** genera un `.xlsx` real **sin librerías** (arma el ZIP con CRC32 propio + XML de OOXML) con los datos de la vista activa. Botones **icon-only** que se expanden mostrando su etiqueta al hover (patrón del proyecto hermano).
- **Notas metodológicas:** colapsable, cerrado por defecto.
- **Regla de alineación canónica:** el contenido de cada columna sigue el alineamiento de su título. En las tablas de comparación: columnas métricas **centradas** (título y valores); columna “Establecimiento” **a la derecha** (título y nombres).
- **Motion:** 120–240ms ease-out; sin bounces ni parallax.

## State Management

Estado del componente:
- `foco`: `'cob' | 'ren'` (default `'cob'`)
- `vista`: `'terr' | 'comp'` (default `'terr'`)
- `modo` (período): `'actual' | 'hist'` (default `'actual'`)
- `cohorts`: `{ rec: boolean, ant: boolean }` (default ambos true; nunca ambos false)
- `notesOpen`: boolean (default false)
- `hoverExp`: `'svg' | 'xlsx' | null` (expansión de botones de exportación)
- Tooltip del scatter: manejado por DOM directo (elemento `#paesTip` `position:fixed`), sin estado React, para no re-renderizar en cada hover.

Props tweakables expuestas: `initialFoco`, `initialModo`, `showContext` (mostrar/ocultar contexto NEM/Ranking).

### Datos (reemplazar por DEMRE real)
- Embudo por comuna con split `rec` (generación reciente) / `ant` (cohortes previas) por etapa; SLEP = suma.
- Pruebas: `{sigla, name, n, ant, mean, median, sd}` para CL/M1/M2/Ciencias/Historia; contexto NEM/Ranking igual.
- 10 establecimientos con conteos de embudo y medianas por prueba (algunos con `null`/`n<10` para ejercitar la supresión).
- Series históricas 2020–2024 (cobertura: % rindió, % matriculado, generaciones anteriores; rendimiento: mediana por prueba).

## Assets
- **Fuentes** (incluidas en `fonts/`): `gobCL_Heavy.otf`, `gobCL_Regular.otf`, `MuseoSans-300.otf`, `MuseoSans_500.otf`, `MuseoSans_700.otf`. Familia tipográfica del Gobierno de Chile + Museo Sans (secundaria).
- **Sin dependencia de iconos externos**: los íconos de exportación son SVG inline (rect+circle+línea para imagen; grilla para hoja de cálculo), stroke 2px `currentColor`.
- El logo institucional fue **retirado** del header por decisión del cliente.

## Files
- `slep_paes - motor.dc.html` — prototipo completo (plantilla + lógica). Toda la lógica de datos, visualizaciones (SVG), heatmap, exportadores SVG/XLSX y tooltip están en la clase `Component` dentro del `<script data-dc-script>`.
- `fonts/` — tipografías necesarias.
