# Traspaso de cierre — slep_paes — v01

## 1. Identificación

- **Proyecto:** slep_paes
- **Versión:** v01 (primer cierre formal)
- **Fecha:** 2026-07-01
- **Sesión:** 1 (única, con foco en scaffold Rama A → migración a Rama B y
  fundación completa de insumos)
- **Entorno:** conversación con Claude (análisis) + Claude Code (ejecución
  autónoma en `~/Projects/slep_paes`)
- **Archivos principales modificados:** `10_utils/10_configuracion.R`,
  `.gitignore`, `.Renviron.example`, `README.md`, `CLAUDE.md`,
  `gobernanza_datos.md`, `manifiesto_insumos.md`, `contexto_paes.md`,
  `30_procesamiento/{30,31,32,33}*`, `20260701_renombrado_insumos_datos.md`

- **Commits locales por fase (hashes exactos, sin push):** completado por Claude
  Code, no reflejado en el resumen de análisis.

  | Hash | Fase / paso | Contenido |
  |---|---|---|
  | `cadf34f` | Paso 1 | Scaffold Rama A: estructura canónica, `00_run_all.R`, escáner, `10_utils`, contrato, README/CLAUDE/LICENSE, `.Rproj` |
  | `30ff4b1` | Paso 2 | Reuso d3/pako + auxiliares territoriales; nota de patrón común; `PALETA_PAES` |
  | `ebc1502` | Paso 2 (bookkeeping) | Actualización de `CLAUDE.md` |
  | `8ba5921` | Paso 3 | `20_insumos/` por etapa, `gobernanza_datos.md`, `manifiesto_insumos.md`, `contexto_paes.md` (conversión inicial) |
  | `9dfa084` | Paso 4 | Stubs `30/31/32/33` + `33_motor_template.html`; fix del bug 1 |
  | `0e90fe5` | Migración Fase A | Rama A→B (código): dos raíces, `.gitignore` blindado, `git rm --cached` de `20_insumos/`+`40_salidas/` |
  | `9b2e8f3` | Fase D (renombrado) | 74 archivos a snake_case + `glosas/`→`referencia/`; `manifiesto` real; log auditable |
  | `37e4a20` | Cierre reencargo | Origen del repo vaciado (tras OK del titular), escaneo limpio |

  Fases B (movimiento de datos a OneDrive) y C (`~/.Renviron`) fueron manuales del
  titular, sin commit (los datos no se versionan).

## 2. Resumen ejecutivo

Sesión 1 completó los cuatro pasos del plan de scaffold (estructura Rama A,
reuso de librerías y auxiliares, insumos + gobernanza + reseña de dominio,
stubs de pipeline) y luego una migración estructural mayor no prevista en el
plan original: al depositar las bases reales del DEMRE/MINEDUC (74 archivos,
~953 MB), el diagnóstico detectó PII (MRUN en egresados, FECHA_NACIMIENTO en
ArchivoB) y volumen sobre el límite de GitHub, lo que forzó migrar el proyecto
de Rama A (raíz unificada) a Rama B (dos raíces, dato en OneDrive). La
migración se ejecutó completa y se verificó en cada fase (validación 8.3.7,
`run_all(only=30)` desde la raíz de datos). Los 74 archivos quedaron
renombrados a snake_case y reorganizados (`glosas/` → `referencia/`). El
`contexto_paes.md` se completó con las fórmulas (IRT, NEM, Ranking,
Ponderado) que la conversión automática del `.docx` había perdido por venir
embebidas como imágenes. Quedan pendientes: decisión de esquema para
`31_leer_normalizar.R` (REG/INV, wide→long de ArchivoD), confirmación de
escala PDT en columnas `*_ANTERIOR` de 2023, egresados 2026 ausente, y
actualización de `contexto_paes.md` con literatura adicional. Estado general:
fundación sólida y verificada; pipeline de datos reales (`31`/`32`) aún sin
diseñar.

## 3. Estado al cierre

**Qué funciona (última ejecución exitosa):**
- `run_all(only=30)` corre end-to-end leyendo desde la raíz de datos en
  OneDrive vía `SLEP_PAES_DATA_ROOT`, genera catálogos territoriales
  (10.945 establecimientos, 345 comunas).
- `33_generar_html.R` genera un motor HTML autocontenido (React/d3/pako
  locales, 0 referencias de red, JSON gzip+base64+pako) con datos de
  andamiaje (sin datos reales de cobertura/rendimiento aún).
- Validación 8.3.7 en verde: `obtener_data_root()`, `dir.exists(ruta_insumos())`,
  `dir.exists(ruta_salidas())`.
- Compuerta de gobernanza verificada: 0 archivos con PII directa en el
  repo Git (`git ls-files` confirma solo `20_insumos/README.md` trackeado).

**Qué no funciona / no está construido:**
- `31_leer_normalizar.R` y `32_agregar_territorial.R` son stubs con
  compuerta: omiten limpio, no leen los datos reales todavía (diseño de
  schema pendiente, ver §11).
- El motor (`docs/index.html`) no refleja datos reales de cobertura ni
  rendimiento.

**Delta respecto a v00 (no hubo v00; primer cierre):** N/A.

## 4. Registro detallado de cambios

### Cambio 1 — Scaffold Rama A (pasos 1-3 del plan original)
- **Archivos:** estructura completa por decenas, `10_utils/`, `20_insumos/`
  (estructura por etapa), `gobernanza_datos.md`, `manifiesto_insumos.md`,
  `contexto_paes.md` (conversión inicial), `decisiones/20260630_decision_patron_comun_y_paleta.md`.
- **Categoría:** fundacional / andamiaje.
- **Qué:** estructura canónica, reuso verbatim de d3/pako y auxiliares
  territoriales (md5 idénticos a los hermanos), `PALETA_PAES` propia
  (uva/terracota, no colisiona con ningún hermano).
- **Por qué:** cumplir POLITICA §1 y §8.2 (Rama A inicial, luego migrada);
  no reinventar lo que ya existe en los hermanos (C.1 simplicidad).
- **Cómo se verificó:** md5 idénticos verificados; config parsea; escáner
  limpio en cada paso.
- **Dependencias:** base de todo lo posterior.

### Cambio 2 — Transcripción manual de fórmulas en contexto_paes.md
- **Archivos:** `contexto_paes.md`.
- **Categoría:** dominio / documentación.
- **Qué:** la conversión automática `.docx → md` perdió 6 zonas (fórmula
  IRT 3PL, tabla NEM de 4 pares, parámetros y condiciones lineales del
  Ranking, fórmula del Ponderado con ejemplo verificado, símbolo PPP,
  piso de Pedagogía 567,5) porque el `.docx` (originado en Google Docs)
  incrusta las fórmulas como imágenes PNG, no como texto ni OMML.
- **Por qué:** ninguna extracción de texto puede recuperarlas; se requirió
  inspección visual directa (rasterizado página por página) del `.docx`
  original.
- **Cómo se verificó:** ejemplo numérico del Ponderado recalculado a mano
  (825×0,15+870×0,20+700×0,10+900×0,35+820×0,10+840×0,10 = 848,75) y
  cuadra exacto con el valor consolidado del documento fuente. Escaneo
  sistemático post-edición confirmó 0 huecos residuales en el archivo
  completo.
- **Dependencias:** insumo de dominio para el motor (33) y para el diseño
  futuro de 31/32 (reglas de Ranking, NEM, ponderado).
- **⚠️ Discrepancia con la ejecución de Claude Code:** este cambio describe una
  transcripción manual y una verificación (recálculo del ponderado 848,75, escaneo
  post-edición) que **Claude Code NO ejecutó**. En el log de ejecución de Claude
  Code: en el paso 3 (`8ba5921`) se hizo la conversión inicial `.docx → md` con
  Python de librería estándar (`zipfile` + `word/document.xml`), porque `pandoc`
  y `extract-text` no estaban disponibles en el entorno; el resultado (47.586
  caracteres, 275 líneas) se guardó con una nota de procedencia que **marcaba
  explícitamente las fórmulas/tablas perdidas y NO las rellenaba** (B.1). La
  transcripción manual de las fórmulas apareció después como una **edición del
  titular entre turnos** (`contexto_paes.md` con el campo `formulas_transcritas`
  en el front matter), que Claude Code detectó y preservó. El diagnóstico "PNG
  embebido desde Google Docs" y el recálculo 848,75 provienen del lado de análisis
  de la conversación, no de la ejecución de Claude Code; Claude Code no puede
  verificarlos como propios.

### Cambio 3 — Diagnóstico de bases reales depositadas (Fase 0)
- **Archivos:** ninguno modificado; solo lectura (`20_insumos/` recursivo).
- **Categoría:** gobernanza / diagnóstico.
- **Qué:** inventario exhaustivo de 74 archivos reales (~953 MB) del
  DEMRE/MINEDUC depositados por el titular. Detección de PII (MRUN+MRUN_IPE
  en egresados_em, FECHA_NACIMIENTO en ArchivoB), anomalía de esquema
  (ArchivoD wide 186 columnas en 2023 → long 6 columnas en 2024+), y patrón
  REG/INV confirmado en columnas de ArchivoC.
- **Por qué:** POLITICA 0.2 (no deducir estructura) y gobernanza_datos.md
  §5.1 (compuerta obligatoria antes de mover/versionar cualquier base).
- **Cómo se verificó:** headers completos leídos, valores de muestra
  inspeccionados, conteo de columnas por año y por archivo.
- **Dependencias:** disparó el cambio 4 (migración A→B).

### Cambio 4 — Migración Rama A → Rama B (dos raíces)
- **Archivos:** `10_utils/10_configuracion.R`, `.gitignore`,
  `.Renviron.example`, `README.md`, `CLAUDE.md`, `gobernanza_datos.md`,
  `30_procesamiento/{30,31,32,33}*` (rutas vía `ruta_insumos()`/`ruta_salidas()`).
- **Categoría:** arquitectura / gobernanza.
- **Qué:** proyecto pasó de raíz unificada (Rama A, POLITICA §8.2) a dos
  raíces (Rama B, POLITICA §8.3 / §6.2): código en el repo, datos en
  `~/Library/CloudStorage/OneDrive-SLEP/Proyectos/slep_paes/`, conectados
  vía `SLEP_PAES_DATA_ROOT` en `~/.Renviron`.
- **Por qué:** PII directa (MRUN de NNA, FECHA_NACIMIENTO) no puede entrar
  a un repo público (POLITICA §6.1, prevalece sobre autonomía); además
  `ArchivoD_Adm2023.csv` (104 MB) supera el límite duro de GitHub (100 MB).
  Rama A estricta ya no era viable con datos reales.
- **Cómo se verificó (cadena exacta ejecutada por Claude Code, en orden):**
  1. `git rm -r --cached 20_insumos 40_salidas` + compuerta: 0 datos con
     estado A/M en el índice (solo `D`=borrados del índice) — commit `0e90fe5`.
  2. Fase D paso 1 — validación 8.3.7: **falló la primera vez** (variable
     `SLEP_PAES_DATA_ROOT` ausente en `~/.Renviron`; diagnóstico read-only
     confirmó `grep` vacío, HOME correcto, raíz de datos existente); tras
     corregir el titular, **verde**: `obtener_data_root()` resuelve,
     `dir.exists(ruta_insumos())` y `dir.exists(ruta_salidas())` = TRUE.
  3. Fase D paso 2: `run_all(only=30)` escribe los 3 catálogos en
     `<data_root>/40_salidas/intermedios/`, no en el repo.
  4. Comparación **1:1 por nombre** origen↔OneDrive (74/74 idénticos) —
     hecha en el turno del "74 vs 71" (pre-renombrado).
  5. Tras el renombrado, verificación de **integridad por tamaño**
     (repo con nombres viejos ↔ OneDrive con nombres nuevos, emparejados
     por la función `to_snake`): 74/74 existen y mismo tamaño, 0 faltantes,
     0 tamaños distintos.
  6. **Safety-check inmediato antes del borrado:** recuento OneDrive = 74
     (guarda `if != 74 -> abort`); tras borrar, repo `20_insumos/` = solo
     `README.md`, OneDrive intacto (74).
  7. `git ls-files` final: 0 archivos de datos trackeados.
- **Tensión resuelta:** autonomía (0.3) vs. gobernanza de datos (0.3 in
  fine: "la gobernanza de datos prevalece siempre sobre la autonomía") —
  se escaló como decisión estratégica (gate de usuario) antes de ejecutar
  cualquier movimiento de datos.
- **Dependencias:** todo el pipeline (30-33) y la documentación de
  gobernanza dependen de esta arquitectura.

### Cambio 5 — Renombrado a snake_case y reorganización de referencia
- **Archivos:** 74 archivos de datos en la raíz de OneDrive; carpeta
  `demre/glosas/` → `demre/referencia/`; `manifiesto_insumos.md`.
- **Categoría:** naming / estructura.
- **Qué:** todos los archivos con espacios, tildes, ñ dentro de
  `20_insumos/` renombrados a snake_case puro (sin excepción de "dato
  externo heredado", por instrucción explícita del titular). Carpeta
  `glosas/` renombrada a `referencia/` (nombre más preciso: contiene
  diccionarios + percentiles + oferta académica + indicadores, no solo
  glosarios).
- **Por qué:** POLITICA §2 (naming); instrucción explícita del titular de
  no aplicar la excepción de §1.2 en este caso.
- **Cómo se verificó:** dry-run mostrado antes de ejecutar; guardas de 0
  colisiones y 0 nombres no-snake tras ejecutar; log auditable versionado
  (`andamios/20260701_renombrado_insumos_datos.md`, 69 renombres).
- **Bug encontrado y corregido en el camino:** ver §6, bug 1.

### Cambio 6 — Stubs de 30_procesamiento/
- **Archivos:** `30_construir_auxiliares.R` (funcional),
  `31_leer_normalizar.R`, `32_agregar_territorial.R` (stubs con compuerta),
  `33_generar_html.R` + `33_motor_template.html` (funcional, motor
  andamiaje).
- **Categoría:** pipeline.
- **Qué:** los cuatro scripts numerados, `00_run_all.R` orquestando
  30→31→32→33. `30` es funcional de verdad (construye catálogos
  territoriales reales). `31`/`32` son stubs que omiten limpio si faltan
  datos, con la lógica de embudo/supresión ya esbozada pero sin ejecutar
  sobre datos reales. `33` genera un motor HTML real (autocontenido)
  aunque con datos de andamiaje.
- **Por qué:** el brief pedía stubs, no ETL completo, hasta definir el
  schema de datos reales (Fase 0 lo hizo evidente: REG/INV, wide→long).
- **Cómo se verificó:** `run_all()` corre end-to-end sin abortar.

## 5. Backlog acumulativo

**Objetivo del proyecto:** slep_paes es el cuarto panorama nacional del
Área de Monitoreo y Seguimiento de Procesos y Resultados Educativos del
SLEP Costa Central, construido con datos 100% públicos del DEMRE/MINEDUC
sobre la PAES (Prueba de Acceso a la Educación Superior), publicado como
sitio HTML autocontenido en GitHub Pages, navegable por territorio, leído
desde dos focos pares (cobertura y rendimiento), hermano arquitectónico de
slep_categoria_desempeno, slep_idps y slep_simce_adecuado.

**Nota metodológica:** cuenta como "cambio" una solicitud distinguible del
titular (no las acciones técnicas que la implementan). No cuentan los
errores del asistente corregidos de inmediato dentro de la misma
intervención; sí cuentan los bugfixes que el titular reportó o que
requirieron su decisión. Clasificación por intención primaria del pedido.
Fuente del conteo: esta conversación completa (única sesión hasta ahora).

**Clasificación temática (sesión 1):**

| Categoría | N° | % | Descripción |
|---|---|---|---|
| Scaffold y arquitectura | 3 | 21% | Estructura Rama A inicial, migración A→B, config de dos raíces |
| Gobernanza de datos | 4 | 29% | Compuerta PII, diagnóstico Fase 0, decisión Rama B, fuga PII hermano (delegada) |
| Reuso y patrón de familia | 1 | 7% | d3/pako/auxiliares/paleta |
| Dominio (contexto_paes) | 2 | 14% | Conversión inicial + transcripción manual de fórmulas |
| Organización de insumos | 3 | 21% | Estructura por etapa, renombrado snake_case, referencia/ |
| Pipeline (stubs) | 1 | 7% | 30-33 |

**Resumen estadístico por sesión:**

| Sesión | Traspasos generados | N° de cambios | Modelo | Foco |
|---|---|---|---|---|
| 1 | 1 (este, v01) | 14 | Claude (análisis) + Claude Code | Scaffold → migración A→B → insumos reales |

**Detalle cronológico (numeración global, sesión 1):**

1. Scaffold Rama A completo (estructura, reuso, paleta) — pasos 1-2 del
   plan original.
2. Estructura de `20_insumos/` por etapa + `gobernanza_datos.md` +
   `manifiesto_insumos.md` + conversión inicial de `contexto_paes.md` —
   paso 3.
3. Reubicación de `Guía de uso de datos abiertos DEMRE.pdf` a ubicación
   canónica (detectado por Claude Code, no solicitado explícitamente,
   pero reportado y aceptado).
4. Diagnóstico y transcripción manual de las 6 fórmulas faltantes en
   `contexto_paes.md` (solicitud explícita del titular, "decisión 1").
5. Confirmación de decisión React local sin CDN ("decisión 2").
6. Delegación de la fuga de PII en `slep_categoria_desempeno` a sesión
   propia ("decisión 3", encargo redactado y entregado).
7. Confirmación de remoto GitHub existente.
8. Primer encargo autónomo de Fase 0 (diagnóstico de bases reales) —
   redactado, luego corregido tras detectar que Claude Code lo saltó.
9. Reencargo con exploración/diagnóstico ampliado tras feedback del
   titular sobre la estructura real depositada (CCEA, referencia/,
   REG/INV, filtro PAES/PDT, snake_case sin excepción).
10. Tres decisiones de arquitectura (Rama B, agregación en pipeline no
    pre-agregación, renombrado diferido a una sola pasada) resueltas vía
    preguntas de opción.
11. Ejecución de Fase A (código de migración A→B).
12. Ejecución de Fase B/C (movimiento físico de datos + variable de
    entorno) — con dos incidentes menores (conteo 71 vs 74 del asistente;
    variable no aplicada correctamente en el primer intento del titular).
13. Ejecución de Fase D (validación + renombrado + reorganización
    referencia/).
14. Cierre de sesión con traspaso v01 (este documento).

**Delta del backlog:** primer cierre; no hay versión anterior. Taxonomía
inicial propuesta (6 categorías); a refinar en sesiones futuras si alguna
supera el 25% o cae bajo el 2%.

## 6. Bugs de la sesión

### Bug 1 — Placeholder `__JSON_DATA__` duplicado en comentario HTML
- **Síntoma:** el motor generado no decodificaba los datos; `const __B64`
  quedaba sin resolver.
- **Causa raíz:** `33_motor_template.html` tenía el token `__JSON_DATA__`
  tanto en un comentario como en el placeholder real; `33_generar_html.R`
  usa `sub()` (reemplaza solo la primera ocurrencia), que coincidía con el
  comentario, no con el placeholder real.
- **Solución exacta:** se quitaron los tokens del comentario en
  `33_motor_template.html` (líneas ajustadas, +6/-3).
- **Criterio de verificación:** grep de `__B64` confirmando contenido
  base64 real, 0 ocurrencias sin resolver.
- **Patrón general aprendido:** cuando un generador usa reemplazo de
  primera ocurrencia (`sub()`, no `gsub()`), cualquier texto explicativo
  en la plantilla que mencione el nombre literal del placeholder es un
  riesgo de colisión. Regla: los comentarios de plantillas no deben
  contener el string literal de ningún placeholder que el generador vaya
  a buscar.
- **Estado:** resuelto.

### Bug 2 — Locale C rompe transliteración de tildes en renombrado
- **Síntoma:** el dry-run del renombrado producía guiones espurios
  (`Códigos` → `co_digos`, `Enseñanza` → `ensen_anza`) en vez de una
  transliteración limpia.
- **Causa raíz:** bajo locale `C`, `chartr()` y operaciones de string en R
  cuentan bytes, no caracteres Unicode; un carácter acentuado UTF-8
  (2 bytes) se partía a mitad de carácter.
- **Solución exacta:** forzar locale UTF-8 explícito en el script, y usar
  transliteración robusta vía `stringi` (con `iconv //TRANSLIT` de
  respaldo) en vez de reemplazo manual byte a byte.
- **Criterio de verificación:** dry-run re-ejecutado mostrando
  transliteración correcta antes de aplicar; guardas post-ejecución de 0
  nombres no-snake.
- **Patrón general aprendido:** cualquier transformación de texto que
  toque caracteres acentuados en R debe forzar el locale explícitamente y
  usar una librería de transliteración Unicode-aware, nunca manipulación
  de bytes cruda, independientemente de qué locale tenga la sesión por
  defecto.
- **Estado:** resuelto.

## 7. Aprendizajes y restricciones descubiertas

- **Regla:** los `.docx` originados en Google Docs pueden incrustar
  fórmulas matemáticas como imágenes PNG en vez de texto u objetos OMML.
  Ninguna extracción de texto (pandoc, extract-text) las recupera; se
  requiere rasterizar el documento e inspeccionar visualmente.
  **Contexto:** si se ignora, cualquier reseña de dominio convertida
  automáticamente desde un `.docx` de origen similar quedará con huecos
  silenciosos en el contenido matemático. **Ejemplo de la sesión:** las 6
  zonas de `contexto_paes.md` (IRT, NEM, Ranking, Ponderado, PPP, piso
  Pedagogía).
- **Regla:** un `git rm --cached` seguido de gitignore no garantiza que
  los datos hayan salido del *disco* del code root; solo los saca del
  índice de Git. En una migración A→B, el vaciado físico del origen es un
  paso aparte que debe verificarse explícitamente, no asumirse por la
  ausencia en `git status`. **Contexto:** si se asume, el code root queda
  con PII en disco (aunque no en Git) de forma indefinida. **Ejemplo de
  la sesión:** Claude Code reportó "origen vaciado" prematuramente; el
  titular lo dio por bueno; una inspección posterior (no solicitada
  explícitamente, pero parte de la higiene de cierre de Fase D) encontró
  las 74 bases todavía físicas en el repo.
- **Regla:** al pasar instrucciones de shell con comentarios (`#`) para
  que el usuario las pegue en su terminal, un comentario que empieza con
  un carácter especial de shell (como `~953`) puede ejecutarse mal si el
  copiado no preserva el `#` al inicio exacto de línea. **Contexto:**
  genera errores de terminal inofensivos pero confusos. **Ejemplo de la
  sesión:** `zsh: no such user or named directory: 953`.
- **Restricción:** cuando el titular ya tiene un `~/.Renviron` con
  variables de otros proyectos, nunca ofrecer un archivo completo para
  `cp` directo: siempre verificar primero si el archivo ya existe y, de
  ser así, dar solo la línea a añadir (`>>`), nunca un reemplazo.
  **Contexto:** un `cp` ciego sobrescribe variables de otros proyectos
  Rama B activos. **Ejemplo de la sesión:** la primera instrucción de
  Fase C no tomó efecto porque no se verificó la preexistencia del
  archivo real del titular.

## 8. Decisiones de diseño

### Decisión: Rama B (dos raíces) en vez de Rama A
- **Alternativas consideradas:** (1) Rama B, (2) Rama A híbrida con
  gitignore in situ del crudo, (3) Git LFS.
- **Justificación:** PII directa (MRUN, FECHA_NACIMIENTO) no puede
  versionarse bajo ninguna circunstancia (POLITICA §6.1); Git LFS no
  resuelve ese problema (el crudo seguiría accesible en el repo público);
  la opción híbrida deja el crudo en disco del code root sin respaldo
  fuera del equipo.
- **Tensión resuelta:** simplicidad (Rama A ya estaba montada) vs.
  gobernanza (PII no negociable) — gobernanza ganó, como dicta POLITICA
  §0.3 in fine.
- **Implicancia:** todo `20_insumos/`/`40_salidas/` vive ahora en
  `~/Library/CloudStorage/OneDrive-SLEP/Proyectos/slep_paes/`; el repo
  solo tiene código y documentación; requiere `SLEP_PAES_DATA_ROOT` en
  `~/.Renviron` para correr localmente.
- **Documento de decisión:** no se generó archivo aparte en
  `decisiones/`; queda documentado en este traspaso y en
  `gobernanza_datos.md` (reescrito a Rama B).

### Decisión: Rama B estricta (sin excepción para auxiliares no-PII)
- **Alternativas:** Rama B estricta (todo sale del repo) vs. excepción
  para auxiliares públicos (~4 MB, sin PII).
- **Justificación (del titular):** simplicidad de una sola regla sin
  excepciones mixtas.
- **Implicancia:** el directorio oficial depurado, territorios, etc.
  también viven solo en OneDrive; se regeneran vía `run_all(only=30)`
  desde ahí, no están versionados en ningún punto.

### Decisión: agregación en pipeline, no pre-agregación de egresados
- **Alternativas:** pre-agregar egresados a conteos por RBD×año (sin
  MRUN, versionable) vs. mantener el microdato crudo fuera de Git y
  agregar en el pipeline (31/32) en cada corrida.
- **Justificación:** más simple dado que Rama B ya se eligió; evita
  duplicar lógica de agregación fuera del pipeline canónico.
- **Implicancia:** `31_leer_normalizar.R`/`32_agregar_territorial.R`
  deberán leer el microdato de egresados directamente desde la raíz de
  datos y agregarlo ahí, no consumir un derivado pre-calculado.

### Decisión: renombrado en una sola pasada, no en dos
- **Alternativas:** renombrar el material versionable (referencia) de
  inmediato, dejando el microdato para después vs. esperar a decidir toda
  la arquitectura y renombrar todo junto.
- **Justificación:** un cambio conceptual por commit/pasada (POLITICA
  §1.2.6); renombrar en dos tandas por criterios distintos (versionable
  ahora vs. arquitectura pendiente) fragmenta lo que debería auditarse
  como una sola pasada coherente.
- **Implicancia:** el renombrado completo (74 archivos + `glosas/` →
  `referencia/`) se ejecutó junto, después de resuelta la migración A→B,
  con un solo log auditable.

### Decisión: `demre/glosas/` → `demre/referencia/`
- **Justificación:** el contenido real (diccionarios de códigos +
  percentiles + oferta académica + indicadores por carrera + informes de
  egresados) excede lo que "glosas" describe (solo diccionarios);
  "referencia" cubre la naturaleza común (material de consulta estático
  por proceso/año).

## 9. Constantes y parámetros vigentes

| Constante | Valor | Archivo | Nota |
|---|---|---|---|
| `UMBRAL_SUPRESION_CELDA` | 8 | `10_configuracion.R` | Anclado al k-anonimato del DEMRE (no arbitrario); cambió de 1→8 durante el paso 3 al confirmarse el estándar en `contexto_paes.md` |
| `SLEP_PAES_DATA_ROOT` | `/Users/tomgc/Library/CloudStorage/OneDrive-SLEP/Proyectos/slep_paes` | `~/.Renviron` | Variable de entorno, Rama B |
| `PALETA_PAES` | uva/terracota | `10_configuracion.R` | Propia, no colisiona con paletas de datos de los 3 hermanos (verificado) |
| Paleta `slep_categoria_desempeno` (referencia, no usar) | `#EE2D49 / #E88663 / #2A8FD9 / #0062A0` + institucional `#0A3A5C/#E88663/#FFF6E0/#4A2746` | — | Documentada para evitar colisión |
| Chrome institucional común (3 hermanos) | cream/plum/ocean/coral, header `#0A3A5C` | — | Referencia de familia |

## 10. Arquitectura de archivos

Ver `50_documentacion/estructura/estructura_actual.md` (escaneo final del
cierre: 2026-07-01 11:37:41; 12 carpetas, 45 archivos en el code root — ya sin
datos, tras la migración a Rama B; el conteo subió respecto a escaneos previos
por el `backlog_acumulativo.md` y el propio traspaso completado). Cambio estructural mayor respecto al
scaffold inicial: `20_insumos/` y `40_salidas/` quedaron con un único
`README.md` cada una (puntero a la raíz de datos externa); toda la
estructura por etapa (`demre/{inscripcion,rendicion_resultados,
postulacion_seleccion,referencia,cuestionarios_caracterizacion}`,
`egresados_em/`) vive ahora en
`~/Library/CloudStorage/OneDrive-SLEP/Proyectos/slep_paes/20_insumos/`.
Verificado contra POLITICA §6.2 (modelo canónico de dos raíces).

## 11. Pendientes y ruta sugerida

### Pendiente 1 — Diseño de `31_leer_normalizar.R` contra el esquema real
- **Descripción:** el schema real de ArchivoC tiene columnas
  `<PRUEBA>_{REG,INV}_{ACTUAL,ANTERIOR}` que varían por año (28→35→36→38
  columnas, 2023→2026); ArchivoD cambia de forma wide (186 columnas,
  2023) a long (6 columnas, 2024+).
- **Contexto:** hallazgo de la Fase 0, documentado en
  `manifiesto_insumos.md`.
- **Tipo:** funcionalidad (bloqueante para avanzar el pipeline real).
- **Impacto:** determina el diseño completo de `31`/`32`.
- **Dependencias:** requiere decisión metodológica del titular sobre cómo
  homologar las columnas entre años (posiblemente contra los Libros de
  Códigos por año en `demre/referencia/`).
- **Complejidad:** Alta.
- **Principios relevantes:** B.1 (no inventar metodología), C.6 (tipado
  consistente).
- **Precauciones:** no asumir que todos los años tienen el mismo schema;
  leer por nombre de columna, nunca por posición (ya se detectó que
  `ArchivoB` reordena columnas entre años).
- **Sugerencia de enfoque:** sesión dedicada de diseño de schema,
  contrastando cada año contra su Libro de Códigos correspondiente antes
  de escribir el parser.
- **Criterio de éxito sugerido:** `31` lee los 4 años sin `NA` inesperados
  en columnas clave, homologando REG/INV y wide/long a una estructura
  única y documentada.

### Pendiente 2 — Confirmar escala PDT en columnas `*_ANTERIOR` de 2023
- **Descripción:** las columnas `*_REG_ANTERIOR` de `ArchivoC_Adm2023`
  probablemente refieren la aplicación previa (Adm2022 = PDT, escala
  150-850), no PAES (100-1000). No es determinable desde los headers.
- **Tipo:** deuda técnica / bloqueante para el diseño de 31.
- **Complejidad:** Media.
- **Sugerencia de enfoque:** revisar el Libro de Códigos ADM2023 en
  `demre/referencia/2023/` o inspeccionar el rango de valores reales de
  esas columnas (150-850 vs 100-1000 es fácilmente distinguible
  empíricamente).

### Pendiente 3 — Egresados 2026 ausente
- **Descripción:** `egresados_em/2026/` solo tiene `.DS_Store`; sin
  denominador de cobertura para 2026.
- **Tipo:** dato faltante (depende del titular / disponibilidad MINEDUC).
- **Impacto:** el foco de Cobertura para 2026 quedará incompleto hasta
  que se deposite.

### Pendiente 4 — Normalización del sufijo REG/INV en nombres de archivo 2026
- **Descripción:** solo los archivos 2026 llevan `REG` en el nombre de
  archivo (ej. `archivob_adm2026_reg.csv`); 2023-2025 no, porque
  consolidan REG+INV en columnas dentro del mismo archivo.
- **Tipo:** cosmética / naming.
- **Sugerencia de enfoque:** decidir si vale la pena homologar
  (`_reg` explícito en todos, o quitarlo de 2026) considerando que la
  distinción real vive en las columnas, no en el nombre del archivo.

### Pendiente 5 — Actualizar `contexto_paes.md` con literatura más
completa
- **Descripción:** el titular tiene un set de archivos adicional listo
  para nutrir la reseña de dominio con información más actualizada,
  incluida la descripción del CCEA (Cuestionario de Caracterización de la
  Experiencia Académica, URL de DEMRE ya provista en esta sesión).
- **Tipo:** documentación.
- **Complejidad:** Media (depende del volumen del material nuevo).

### Pendiente 6 — CCEA (ArchivoK/L) fuera de alcance activo
- **Descripción:** confirmado por el titular como cuestionario de
  auto-reporte del postulante (trayectoria previa, recursos/condiciones,
  competencias socioemocionales). No alimenta cobertura ni rendimiento.
  Datos depositados y documentados, pero fuera del pipeline por ahora.
- **Tipo:** funcionalidad futura (explícitamente diferida, no bloqueante).

### Pendiente 7 (externo, ya delegado) — Fuga de PII en
`slep_categoria_desempeno`
- **Descripción:** `directorio_oficial_ee.csv` crudo (con
  `RUT_SOSTENEDOR`+`MRUN`) commiteado en el historial de ese repo
  público.
- **Estado:** encargo redactado y entregado al titular para su propia
  sesión (ver mensaje de esta conversación con el bloque de encargo
  completo). Completado en el alcance de slep_paes (no bloquea este
  proyecto); pendiente de ejecución en la sesión de
  `slep_categoria_desempeno`.

### Evaluación de deuda técnica
- **Zona frágil:** el schema de `ArchivoC`/`ArchivoD` cambia año a año de
  forma no trivial (columnas nuevas, wide→long). Si `31` se escribe
  asumiendo el schema de un solo año, se romperá silenciosamente al
  agregar años futuros. Mitigación sugerida: validación de columnas
  esperadas vs. presentes al inicio de `31`, con `stop()` claro si faltan
  columnas críticas (C.3.8, validación de integridad).
- **Oportunidad de mejora:** ninguna urgente; el pipeline aún no procesa
  datos reales, así que no hay deuda de código ejecutándose en producción
  todavía.

### Auditoría de cierre (POLITICA §5.6, preguntas "Cierre")

| # | Pregunta | Respuesta |
|---|---|---|
| 5 | ¿Cada transformación crítica tiene check de validación? | Parcial — `30` sí (validación 8.3.7); `31`/`32` aún no aplican (stubs) |
| 6 | ¿Los outputs son reproducibles e idempotentes? | Sí — `run_all(only=30)` regenera catálogos desde cero sin intervención manual |
| 7 | ¿Decisiones metodológicas como constantes nombradas? | Sí — `UMBRAL_SUPRESION_CELDA`, `PALETA_PAES` |
| 8 | ¿Nombres de archivos y carpetas sin tildes, ñ ni espacios? | Sí — verificado con guardas tras el renombrado (0 no-snake) |

Ítem pendiente derivado de esta auditoría: ninguno nuevo (los pendientes
1-2 ya cubren la validación de `31`/`32` cuando se diseñen).

### Ruta sugerida para la próxima sesión

1. **Prioridad 1 — Confirmar escala PDT 2023** (pendiente 2): bloqueante
   menor, resoluble rápido inspeccionando valores o el Libro de Códigos.
2. **Prioridad 2 — Diseñar schema de `31_leer_normalizar.R`** (pendiente
   1): la tarea de mayor complejidad y mayor impacto; requiere el
   resultado de la prioridad 1 primero.
3. **Diferir:** pendientes 3 (egresados 2026, depende de fuente externa),
   4 (naming REG/INV, cosmético), 5 (literatura adicional, depende de
   material del titular) — ninguno bloquea el diseño de 31/32.

**Recomendación:** empezar la próxima sesión con la prioridad 1 antes que
la 2 — porque diseñar el parser de 31 sin saber si las columnas
`*_ANTERIOR` de 2023 están en escala PDT o PAES arriesga construir sobre
un supuesto no verificado (B.1).

## 12. Instrucciones específicas para la próxima sesión

- ⚠️ NO diseñar `31_leer_normalizar.R` sin antes confirmar la escala de
  las columnas `*_ANTERIOR` en `ArchivoC_Adm2023` (pendiente 2).
- ✅ ANTES de tocar cualquier archivo en `20_insumos/`, verificar que
  `SLEP_PAES_DATA_ROOT` esté resuelta (`obtener_data_root()`); el code
  root ya no contiene datos.
- 🔒 Rama B es invariante: ningún archivo de datos (csv/xlsx/parquet con
  microdato) vuelve a versionarse en el repo, sin excepciones, ni
  siquiera auxiliares no-PII (decisión explícita del titular).
- 🔒 Leer columnas de ArchivoB/C/D siempre por nombre, nunca por
  posición (el orden cambia entre años).
- ⚠️ NO asumir que el schema de un año representa a todos: validar
  columnas presentes por año antes de procesar.

## 13. Fragmentos de código de referencia

> **Corrección:** el fragmento que el resumen citaba estaba parafraseado
> (usaba `unset = NA` y un mensaje genérico, sin el chequeo `dir.exists`). El
> código **literal** implementado en `10_utils/10_configuracion.R` es el
> siguiente (dos guardas: variable no definida, y ruta inexistente):

```r
obtener_data_root <- function() {
  data_root <- Sys.getenv("SLEP_PAES_DATA_ROOT", unset = "")
  if (data_root == "") {
    stop(
      "Variable de entorno SLEP_PAES_DATA_ROOT no definida.\n",
      "Configurala asi:\n",
      "  macOS:   agregar a ~/.Renviron la linea\n",
      "    SLEP_PAES_DATA_ROOT=\"/Users/<usuario>/Library/CloudStorage/OneDrive-SLEP/Proyectos/slep_paes\"\n",
      "  Windows: agregar a C:/Users/<usuario>/.Renviron la linea\n",
      "    SLEP_PAES_DATA_ROOT=\"C:/Users/<usuario>/OneDrive - SLEP/Proyectos/slep_paes\"\n",
      "Luego reiniciar la sesion de R / Positron. Ver .Renviron.example.",
      call. = FALSE
    )
  }
  if (!dir.exists(data_root)) {
    stop(
      "La ruta apuntada por SLEP_PAES_DATA_ROOT no existe en disco:\n  ",
      data_root, "\n",
      "Verifica que OneDrive este sincronizado y que la ruta sea correcta.",
      call. = FALSE
    )
  }
  data_root
}

ruta_insumos <- function(...) file.path(obtener_data_root(), "20_insumos", ...)
ruta_salidas <- function(...) file.path(obtener_data_root(), "40_salidas", ...)
```

Transformación de renombrado a snake_case (ejecutada sobre la raíz de datos, con
guardas de 0 colisiones / 0 nombres no-snake; genera el log auditable). La regla
exacta —transliteración Unicode primero (evita el bug 2 de locale), luego split
camelCase solo antes de MAYÚSCULA seguida de letra (así `ArchivoB`→`archivob` pero
`CódigosADM`→`codigos_adm`)— fue:

```r
translit <- function(s) {                        # requiere stringi (o iconv //TRANSLIT)
  s <- enc2utf8(s); Encoding(s) <- "UTF-8"
  stringi::stri_trans_general(s, "Latin-ASCII")
}
to_snake <- function(fname) {
  ext  <- tolower(tools::file_ext(fname))
  base <- translit(tools::file_path_sans_ext(fname))            # -> ASCII puro
  base <- gsub("([a-z0-9])([A-Z][A-Za-z])", "\\1_\\2", base, perl = TRUE)
  s <- tolower(base)
  s <- gsub("[^a-z0-9]+", "_", s); s <- gsub("_+", "_", s); s <- gsub("^_|_$", "", s)
  if (nzchar(ext)) paste0(s, ".", ext) else s
}
# Ejecutado con Sys.setlocale("LC_ALL", "en_US.UTF-8") al inicio del script.
```

## 14. Reapertura

**Nombre del chat:** `slep_paes, sesión 2 (Claude Sonnet 5)`

**Mensaje de apertura pre-armado:**
> Tipo CONTINUATION. El protocolo (POLITICA_PROYECTO.md v5.2 +
> SETTINGS_Y_PROMPTS_OPERACIONALES.md v7) vive en la knowledge base de
> este Project; léelo desde ahí. Adjunto el traspaso `traspaso_cierre_v01.md`
> y el escáner `estructura_actual.md`.

**Documentos para la próxima sesión:**

1. *Protocolo en knowledge base* (NO se adjuntan, solo verificar que estén
   al día): `POLITICA_PROYECTO.md`, `SETTINGS_Y_PROMPTS_OPERACIONALES.md`.
2. *Opcionales según foco:* `CLAUDE.md` si la sesión correrá en Claude
   Code (probable, dado que el foco será diseño de `31`).
3. *Específicos de la sesión (SÍ se adjuntan):*
   - `traspaso_cierre_v01.md` (este documento)
   - `estructura_actual.md` (escaneo final del cierre 2026-07-01 11:37:41)
   - `manifiesto_insumos.md` (hallazgos de schema completos)
   - `contexto_paes.md` (reglas de NEM/Ranking/Ponderado, ahora completo)
   - Libro de Códigos ADM2023 (`demre/referencia/2023/`, para resolver
     pendiente 2) si el titular lo tiene a mano fuera de OneDrive

**Nota final:** si `manifiesto_insumos.md` o `contexto_paes.md` cambiaron
entre sesiones (el titular mencionó tener material adicional para
`contexto_paes.md`, pendiente 5), adjuntar la versión más actualizada al
abrir.

## 15. Errores del asistente (registro obligatorio, POLITICA 0.5)

| Campo | Fila 1 | Fila 2 |
|---|---|---|
| `momento` | Reencargo de Fase 0/A-D, al calcular el checklist de verificación de Fase B | Tras Fase D (renombrado), al reportar el estado del origen en el repo |
| `disparador` | Claude Code lo detectó y lo corrigió espontáneamente, señalándolo al titular | Claude Code lo detectó espontáneamente en una inspección de higiene no solicitada explícitamente |
| `que_paso` | Se comunicó "71 archivos esperados" cuando el conteo real siempre fue 74; error aritmético al armar el checklist inicial | Se reportó "origen vaciado en el repo" (Fase B) sin haber verificado el disco después del `git rm --cached`; los 74 archivos originales seguían físicamente presentes |
| `regla_violada` | POLITICA 2.3.2 (especificidad sobre generalidad: cifras deben ser exactas, no aproximadas sin verificar) | SETTINGS 1.2.6 ("nunca asumir el contenido de un archivo ni su ubicación: leer/verificar") |
| `causa_raiz` | Suma manual del inventario sin recontar programáticamente antes de comunicar el número | Se confundió "sacado del índice de Git" (`git rm --cached`) con "sacado del disco"; ambos pasos son necesarios en una migración A→B pero son operaciones distintas, y no se verificó la segunda antes de afirmarla completa |
| `salvaguarda_presente` | POLITICA (§2.3, exhaustividad y especificidad) | SETTINGS §1.2.6 (nunca asumir sin verificar) + POLITICA §6.1 (gobernanza de datos) |
| `patron` | nuevo | nuevo — relacionado conceptualmente con el aprendizaje de la sección 7 sobre `git rm --cached` vs. vaciado físico, pero es la primera vez que se registra como error explícito en este proyecto |
