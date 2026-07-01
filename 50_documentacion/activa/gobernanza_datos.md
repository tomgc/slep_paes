# Gobernanza de datos — slep_paes

> Conforme a POLITICA_PROYECTO.md §6 y §10, y al encuadre del proyecto (brief §5).
> Marco normativo: Ley 19.628 (vida privada), Ley 21.719 (protección de datos
> personales, vigente dic-2026) y las **condiciones de uso de la información /
> datos abiertos del DEMRE**. **RAMA A** (proyecto público con gobernanza
> explícita): `20_insumos/` y `40_salidas/` viven en el repo.

## 1. Qué datos maneja el proyecto

slep_paes construye un panorama nacional del proceso PAES, leído desde **dos
focos pares**: cobertura (el embudo egresados → inscripción → rendición →
resultados → postulación → selección) y rendimiento (distribución de puntajes por
prueba). Publica **agregados territoriales** (comuna, SLEP, región, nacional). El
producto publicado **no** contiene microdato por postulante.

### 1.1 Insumos (en `20_insumos/`)

| Insumo | Origen | Naturaleza | Clasificación |
|---|---|---|---|
| `demre/inscripcion/`, `demre/rendicion_resultados/`, `demre/postulacion_seleccion/` | DEMRE — **datos abiertos** | Microdato **k-anonimizado** por postulante; llave `ID_aux` (anonimizada, reemplaza al RUN) | Datos abiertos públicos; **sin identificador directo** |
| `demre/glosas/` | DEMRE (público) | Diccionarios de variables | No personal |
| `egresados_em/` | MINEDUC (público) | Conteo de egresados de EM por RBD × año | No personal (institucional) |
| `auxiliares/directorio_oficial_ee_publico.csv` | MINEDUC (público, **depurado**) | RBD → comuna/región/dependencia | No personal (institucional) |
| `auxiliares/{diccionario_territorios,caracterizacion_establecimientos,listado_slep_2026}` | MINEDUC/interno | Territoriales | No personal |
| `auxiliares/condiciones_uso_demre.pdf` | DEMRE | Condiciones de uso | No personal |

### 1.2 Producto publicado (`docs/index.html`)

JSON embebido (comprimido) con **solo agregados territoriales**: por territorio ×
etapa (cobertura) y por territorio × prueba (rendimiento), más catálogos de
comunas/SLEP/regiones y metadatos. **`ID_aux` y cualquier microdato por persona
NUNCA cruzan al producto.** Se verificará por doble vía (trazado de código +
recuento censal parquet→sitio) antes de publicar, como en los hermanos.

## 2. K-anonimato en origen y supresión de celdas chicas

- **En origen:** el DEMRE ya aplica **k-anonimato = 8** a sus datos abiertos (Ley
  19.628): omite o agrupa categorías con menos de 8 casos (comuna de egreso, RBD,
  nacionalidad). Ver `contexto_paes.md`, "Filtros de Confidencialidad".
- **En el proyecto:** al agregar desde microdato a territorio, una celda pequeña
  podría individualizar. Por eso slep_paes aplica **supresión de celdas chicas**
  con un umbral **alineado al estándar de la fuente**:
  `UMBRAL_SUPRESION_CELDA = 8` (constante nombrada en `10_utils/10_configuracion.R`).
  Toda celda territorial con **menos de 8 personas** se suprime o etiqueta como
  "n<8", nunca se muestra el conteo exacto. **No es un número mágico:** es el
  k-anonimato documentado del DEMRE.

> **Divergencia deliberada respecto de los hermanos.** Los hermanos publicados
> (idps, categoria, simce) **no** suprimen celdas chicas: su unidad es el
> establecimiento como agregado público de la Agencia de Calidad. slep_paes sí
> suprime, porque agrega desde **microdato por postulante** del DEMRE, donde una
> celda chica puede re-identificar a una persona.

## 3. Categoría según Ley 21.719

- **No personal / datos abiertos pseudonimizados:** las bases DEMRE se distribuyen
  como datos abiertos, k-anonimizados y con llave `ID_aux` (no RUN). Los agregados
  territoriales del producto son datos institucionales.
- **A resguardar:** el microdato por postulante (aunque pseudonimizado) no se
  publica; solo se usa para agregar, y el resultado agregado pasa por supresión.
- **Sensible:** el proyecto no publica datos sensibles (salud, origen étnico,
  etc.). Si una base de contexto trajera variables sensibles (previsión de salud,
  pueblo originario), **no** se exponen individualizadas en la web.

## 4. Base de licitud del tratamiento

Datos **públicos de fuente oficial**: bases de datos abiertas del DEMRE
(descarga pública, k-anonimizadas) y registros MINEDUC. El tratamiento se limita a
**agregación estadística territorial** con fines de análisis educativo de interés
público (Área de Monitoreo y Seguimiento, SLEP Costa Central). No se recaba ni se
publica dato personal directo de persona natural.

## 5. Qué se publica y qué no

- **Se publica** (`docs/index.html`): el motor con agregados territoriales, con
  supresión de celdas < 8.
- **Se versiona** en `20_insumos/`: las bases DEMRE abiertas (con `ID_aux`, sin
  identificador directo), las glosas, los egresados y los auxiliares depurados.
- **NO se versiona:** el directorio oficial **crudo** (`directorio_oficial_ee.csv`,
  con `RUT_SOSTENEDOR`/`MRUN`) — el `.gitignore` blinda su nombre; solo se versiona
  el `_publico.csv`. Tampoco los intermedios `.parquet` ni el HTML de `40_salidas/`
  (regenerables).

### 5.1 Compuerta de gobernanza antes de versionar una base DEMRE

Antes de commitear cualquier base depositada en `demre/…`, **verificar** que su
cabecera **no** contenga columnas identificadoras directas (`RUN`, `RUT`, `MRUN`,
nombre del postulante): la llave debe ser `ID_aux`. Si apareciera un identificador
directo, **no versionar**, de-versionar lo afectado y tratar como incidente (§8).
Esto es una compuerta de gobernanza (POLITICA 0.3: la gobernanza prevalece sobre
la autonomía), no una revisión trivial.

## 6. Dónde están los datos reales

- Insumos públicos versionados: `20_insumos/` (bases DEMRE abiertas, egresados,
  auxiliares depurados).
- Directorio crudo MINEDUC: **solo en disco local** (no versionado), re-descargable.
- Intermedios y producto: `40_salidas/` (no versionados, regenerables con
  `run_all()`). Copia publicada: `docs/index.html`.

## 7. Período de retención

Los datos son públicos y se conservan mientras el proyecto esté activo. Las bases
DEMRE se acumulan por proceso de admisión (serie histórica). Los intermedios se
regeneran y sobrescriben en cada corrida.

## 8. Procedimiento ante incidente de seguridad

1. **Detección/Contención:** si se detecta identificador directo de persona en un
   insumo versionado o en el producto, despublicar (`docs/` fuera o repo a
   privado) y de-versionar el insumo de inmediato.
2. **Evaluación:** qué dato, en qué archivo, cuántas filas, si está en el producto,
   en el historial o ambos (`git rm --cached` no purga el historial; la remoción
   histórica requiere `git filter-repo`/BFG + `push --force`).
3. **Remediación y registro:** aplicar la mitigación, documentarla como decisión
   en `decisiones/`, dejar log en `andamios/logs/` y evaluar notificación según la
   Ley 21.719.

## 9. Terminología institucional

Término genérico: "**establecimiento educacional**" (completo en la primera
mención de cada párrafo, "establecimiento(s)" luego). Nunca "EE" en texto visible
(sí en notación técnica), ni "colegio" como sustantivo genérico (SETTINGS 4.6.3.6).
El nombre del establecimiento (`nom_rbd`) es público y puede mostrarse; lo que no
se publica es el microdato por postulante.
