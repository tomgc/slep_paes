# Decisión — Patrón común de los hermanos y paleta propia de slep_paes

- **Fecha:** 2026-06-30
- **Sesión:** 1 (NEW PROJECT, paso 2 del plan de apertura)
- **Estado:** vigente
- **Autoría:** Área de Monitoreo y Seguimiento de Procesos y Resultados
  Educativos (SLEP Costa Central)

Nota de extracción del patrón estético y de ETL común a los tres hermanos
publicados (`slep_categoria_desempeno`, `slep_idps`, `slep_simce_adecuado`) y de
las adaptaciones que slep_paes hereda, reusa o diverge. Insumo destilado por
lectura directa de los tres repos (motor, template, ETL, gobernanza, decisiones).

---

## 1. Patrón común detectado (el esqueleto de familia)

Los tres hermanos comparten una misma máquina, que slep_paes REUSA:

### 1.1 Pipeline

`00_*` (orquestador) → `30_construir_auxiliares.R` → `31_leer_normalizar.R` →
`32_agregar_*.R` → `33_generar_html.R` + `33_motor_template.html`.
(idps numera 31→35 por razones históricas; categoria y slep_paes usan 30→33.)

- Orquestador único (`run_all()` / `00_build.R`): solo orquesta, valida rutas,
  saltar pasos es decisión explícita.
- Normalización por **header** (`janitor::clean_names()` o
  `trimws(tolower(names))`), nunca por posición.
- **Llaves siempre `character`** (RBD, códigos comunales/regionales) — invariante
  duro de familia; un join con tipos mezclados falla en silencio.
- Escritura **atómica** de parquets (`.tmp` + `file_move`/rename).
- Catálogos territoriales (`comunas_chile`, `sleps_chile`,
  `establecimientos_chile`) construidos desde el **directorio oficial público** +
  `listado_slep_2026.xlsx`, con rama prospectiva de traspaso (ANIO+1).

### 1.2 Motor HTML autocontenido

- **Inyección de datos idéntica en los tres:**
  `jsonlite::toJSON(auto_unbox=TRUE, na="null", dataframe="rows", digits=NA)` →
  `memCompress(charToRaw(json), type="gzip")` → `jsonlite::base64_enc` (sin
  saltos de línea) → placeholder `__JSON_DATA__`.
  Cliente: `JSON.parse(pako.inflate(Uint8Array.from(atob(__JSON_DATA__),
  c=>c.charCodeAt(0)), {to:"string"}))`.
- **JSON columnar** (arrays paralelos + campo `rows`, no array de objetos) para
  compacidad. En datasets grandes (idps, ~1.5M filas), columnas **ordenadas por
  rbd** + índice de rangos `[inicio,fin)` en cliente para no materializar
  millones de objetos (decode ~340 ms).
- **Placeholders sustituidos con `sub(..., fixed=TRUE)`** y escritura final
  `writeBin(charToRaw(enc2utf8(html)))` (UTF-8, evita corrupción de locale C).
  Placeholders de familia: `__D3_INLINE__`, `__PAKO_INLINE__`, `__JSON_DATA__`
  (idps suma `__FONTS_CSS__`; los que usan React suman `__REACT_INLINE__` /
  `__REACTDOM_INLINE__`).
- **`d3.min.js` y `pako.min.js` locales** en `10_utils/` (byte-idénticos entre los
  tres; md5 verificado), inlineados al generar. El generador falla con pista de
  `curl` si falta una librería.
- **CSS único** en un `<style>` del `<head>`, basado en variables `:root`.
- **Encoding UTF-8 forzado** sobre etiquetas no-ASCII antes de serializar
  ("Bug 2" de locale C; gotcha de familia).

### 1.3 Publicación (GitHub Pages)

Modelo de archivo único: Pages sirve `docs/` en `main`; `docs/index.html` es copia
derivada de `40_salidas/motor_*.html`. Fuente de verdad en `40_salidas/`; `docs/`
no se edita a mano. Activar Pages (Settings → Pages → `main` `/docs`) es paso
manual del titular.

### 1.4 Gobernanza de familia

- Rama A (público): la unidad es el **establecimiento** como agregado público; el
  **nombre del establecimiento es público** y se muestra (la cláusula de
  no-identificación de la Agencia aplica solo a microdato por estudiante).
- El **directorio oficial crudo** trae `MRUN` y `RUT_SOSTENEDOR`: idps lo
  **depura** (`31_depurar_directorio_oficial.R` → `_publico.csv`) y NO versiona el
  crudo. Terminología "**establecimiento educacional**" (SETTINGS 4.6.3.6).

---

## 2. Qué REUSA slep_paes (sin reconstruir)

- **`d3.min.js` y `pako.min.js`** copiados verbatim a `10_utils/` (md5 idénticos a
  los tres hermanos).
- **Auxiliares territoriales** copiados a `20_insumos/auxiliares/` desde
  `slep_idps`: `directorio_oficial_ee_publico.csv` (depurado, **sin RUT/MRUN**),
  `diccionario_territorios.xlsx`, `caracterizacion_establecimientos.xlsx`,
  `listado_slep_2026.xlsx`, `glosas_directorio_oficial_ee.pdf`. Fuente canónica
  RBD → comuna → SLEP → región → nacional.
- **El esqueleto de pipeline y de motor** descrito en §1 (stubs en el paso 4).
- **Constantes territoriales** (`COMUNAS_SLEP_CC`, `NOMBRES_REGION`) verbatim de
  idps.

### Decisión de gobernanza (divergencia respecto de un hermano)

slep_paes reusa el directorio **público depurado**, NO el crudo. `slep_idps` sigue
este patrón correcto (gitignora el crudo, versiona solo `_publico`).
**`slep_categoria_desempeno`, en cambio, tiene el `directorio_oficial_ee.csv`
crudo —con columnas `RUT_SOSTENEDOR` y `MRUN`— commiteado en su repo público**
(confirmado por `git ls-files` + header). Es una fuga de PII que ese hermano
debería sanear (limpiar historial). slep_paes NO la replica: versiona solo el
depurado y blinda el nombre del crudo en `.gitignore` (defensa en profundidad).

---

## 3. Qué ADAPTA o DIVERGE slep_paes

| Aspecto | Hermanos | slep_paes | Por qué |
|---|---|---|---|
| **Unidad de dato cruda** | Agregado por establecimiento (público) | **Microdato por postulante** (DEMRE) que se agrega a territorio | La PAES nace en la persona; el establecimiento es el RBD de egreso |
| **Supresión de celdas chicas** | NO suprimen (decisión explícita; unidad = EE público) | **SÍ suprime** (`UMBRAL_SUPRESION_CELDA`, constante nombrada) | Al agregar desde microdato, una celda territorial chica puede individualizar a un postulante (brief §5; POLITICA §6) |
| **Modelo de medición** | Un indicador por EE-año | **Dos focos PARES**: cobertura (embudo) y rendimiento (puntajes) | Naturaleza de embudo de la PAES (brief §3) |
| **Agregación** | categoria = conteo; simce = ponderado por `nalu`; idps = sin agregación | **Ambas**: conteo para el embudo, media ponderada por nº de rendidos para puntajes | El embudo son headcounts (aditivos); los puntajes admiten media ponderada (PAES SÍ tiene ponderador válido, a diferencia de idps) |
| **Dónde agrega** | simce agrega comuna→nacional en JS (runtime) | **Todo en R** (estilo categoria: parquets largos por entidad) | Más testable; habilita auditoría de doble cálculo |
| **Categoría especial** | categoria: "sin categoría vigente" en sección aparte | **Rezagados sin RBD vigente** (egresados de años anteriores), etiquetados y visibles | Información, no hueco (brief §3-4) |
| **Copia a `docs/`** | categoria automatiza en `33`; idps/simce manual | **Automatizar en `33`** | Deploy reproducible |
| **Fuentes** | idps embebe gobCL/MuseoSans base64; categoria/simce usan fallback system | **Embeber base64** (estilo idps) | Autocontención total (brief: fuentes embebidas) |
| **React/CDN** | simce e idps usan Babel por **CDN** (no 100% offline); categoria transpiló a `React.createElement` (offline) | **Seguir categoria** (React local pre-transpilado, sin CDN) o vanilla D3 | Prohibición de dependencias web externas (brief §9) |

**Recomendación React/JS:** seguir el patrón **offline de `slep_categoria_desempeno`**
(React + ReactDOM locales en `10_utils/`, JSX pre-transpilado a
`React.createElement`, sin Babel ni CDN). Conserva la ergonomía de familia y logra
autocontención total. Se decide y materializa en el paso 4; las librerías React se
copian entonces, no ahora.

---

## 4. Paleta propia de slep_paes (v1, a validar en revisión visual del paso 4)

**Regla de familia (SETTINGS / brief):** la identidad compartida es tipografía
(gobCL / Museo Sans), layout, componentes y motor autocontenido. **Las paletas NO
son transversales**: cada proyecto define la suya. Por eso slep_paes NO hereda la
de ningún hermano, ni siquiera el *chrome* (los tres comparten
`#0A3A5C`/`#FFF6E0`/`#E88663`/`#0062A0`/`#4A2746`; slep_paes se distingue).

**Paletas de datos a NO reusar** (verificado por lectura):
`slep_idps` `#3858A3 #61BDC6 #4BA560 #AACB58`; `slep_categoria_desempeno`
`#EE2D49 #E88663 #2A8FD9 #0062A0`; `slep_simce_adecuado` `#0C4682 #6BA0CE #79204F`
(+ marks `#EE2D49 #F8A0AE #FFC92E #9BC93E #2A8FD9`).

**Concepto PAES:** el embudo y el puntaje. Sello cromático propio = **uva
(cobertura)** + **terracota/teal (rendimiento)**, sobre marfil cálido gobCL.
Fuente única en runtime (constante `PALETA_PAES` en `10_utils/10_configuracion.R`,
espejo de `INDICADOR_COLORS` de idps).

### 4.1 Chrome / identidad

| Token | HEX | Uso |
|---|---|---|
| `--paper` | `#FBF7EF` | Fondo marfil (gobCL, propio, distinto del cream de hermanos) |
| `--tinta` | `#241B2E` | Texto base (tinta uva) |
| `--header` | `#3B1D5E` | Header / barra superior (uva profunda, sello PAES) |
| `--acento` | `#C2410C` | Acento / subrayado activo (terracota PAES) |
| `--linea` | `#E6DECB` | Bordes y separadores |

### 4.2 Foco COBERTURA — secuencial uva (atenuación del embudo)

Rampa monocroma clara→oscura; cada etapa más "estrecha" del embudo, más saturada.

| Etapa | HEX |
|---|---|
| Egresados (denominador) | `#EFE9F5` |
| Inscripción | `#D2C0E4` |
| Rendición | `#AE92CE` |
| Resultados válidos | `#8A65B5` |
| Postulación | `#653F99` |
| Selección | `#412072` |

Categoría **rezagados (sin RBD vigente)**: neutro diferenciado `#9A8FA6` con borde
punteado — no es una etapa, es elegibilidad alterna; se distingue del embudo sin
desaparecer (análogo al gris "sin vigente" de categoria, en clave uva).

### 4.3 Foco RENDIMIENTO — categórico por prueba + divergente por tramo

Categórico (5 pruebas), cualitativo accesible sobre marfil, sin colisión con
hermanos:

| Prueba | HEX |
|---|---|
| Competencia Lectora | `#B45309` (ámbar terroso) |
| Matemática 1 (M1) | `#1F5C54` (teal profundo) |
| Matemática 2 (M2) | `#5B3A9E` (uva media) |
| Ciencias (incl. TP) | `#4D7C0F` (oliva oscuro) |
| Historia y Cs. Sociales | `#B91C5C` (frambuesa-burdeos) |

Divergente para tramos de puntaje (escala 100-1000, bajo→alto), neutro al centro:
`#B45309` → `#D9A441` → `#E6DECB` → `#4C8C7D` → `#1F5C54`.

> **Validación pendiente (paso 4):** contraste AA sobre `--paper`, prueba de
> daltonismo y revisión visual del titular, igual que los hermanos iteraron sus
> paletas (idps P-PALETA). Esta es la v1 de trabajo, no congelada.

---

## 5. Implicancias para los stubs (paso 4)

- `30_construir_auxiliares.R`: catálogos territoriales desde el directorio público
  reusado (patrón de familia, character).
- `31_leer_normalizar.R`: una rama de lectura por etapa (inscripción, rendición,
  resultados, postulación, selección) + caracterización de egresados; homologación
  por glosas DEMRE (no congelar columnas hasta ver las bases).
- `32_agregar_territorial.R`: dos salidas paralelas — cobertura (conteo del embudo
  vs. denominador de egresados, con la categoría de rezagados) y rendimiento (media
  ponderada por nº de rendidos por prueba), ambas RBD→comuna→SLEP→región→nacional,
  con `UMBRAL_SUPRESION_CELDA` aplicado.
- `33_generar_html.R` + `33_motor_template.html`: motor con doble foco y `PALETA_PAES`
  como fuente única; copia automática a `docs/index.html`; fuentes base64.
