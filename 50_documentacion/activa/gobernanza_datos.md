# Gobernanza de datos — slep_paes

> Conforme a POLITICA_PROYECTO.md §6 (dos raíces) y §10. Marco normativo: Ley
> 19.628 (vida privada), Ley 21.719 (protección de datos personales, vigente
> dic-2026) y las condiciones de uso de los datos abiertos del DEMRE.
> **RAMA B (proyecto con datos personales):** el repositorio (raíz de código) NO
> contiene datos; los datos reales viven en la raíz de datos de OneDrive
> institucional (`SLEP_PAES_DATA_ROOT`). Reclasificado a Rama B el 2026-07-01 tras
> el diagnóstico de las bases reales (ver más abajo).

## 0. Por qué Rama B (reclasificación fundacional)

El diseño inicial supuso agregados públicos (como los proyectos hermanos). El
diagnóstico de las bases realmente depositadas mostró **microdato por persona con
datos personales**, lo que obliga a Rama B (POLITICA §6.1: los datos personales
jamás entran a Git):

- **`egresados_em` (Notas y Egresados EM, MINEDUC), 2023-2025:** trae **`MRUN`** y
  **`MRUN_IPE`** (RUN enmascarado del estudiante = **NNA**) junto a la nota
  individual (`PROM_NOTAS_ALU`). Microdato personal de menores.
- **`ArchivoB` (inscritos, DEMRE), todos los años:** trae **`FECHA_NACIMIENTO`**
  (mes-año), más `SEXO`, `PAIS_NACIMIENTO`, `INGRESO_PERCAPITA_GRUPO_FA` a nivel
  persona: cuasi-identificadores.
- **Volumen:** ~953 MB; `ArchivoD_Adm2023.csv` (104 MB) supera el límite duro de
  GitHub (100 MB). Aun sin PII, el microdato masivo no corresponde a un repo.

## 1. Qué datos maneja el proyecto

Construye un panorama nacional del proceso PAES leído desde dos focos pares
(cobertura del embudo y rendimiento de puntajes) y **publica solo agregados
territoriales** (comuna, SLEP, región, nacional). El microdato por persona se usa
únicamente para agregar; nunca se publica.

### 1.1 Insumos (en la raíz de DATOS, fuera del repo)

| Insumo | Origen | Llave | Naturaleza / clasificación |
|---|---|---|---|
| `demre/inscripcion/` (ArchivoB) | DEMRE (datos abiertos) | `ID_aux` | Microdato pseudonimizado; **`FECHA_NACIMIENTO` = personal** |
| `demre/rendicion_resultados/` (ArchivoC) | DEMRE | `ID_aux` | Microdato pseudonimizado (puntajes, NEM, Ranking). Sin identificador directo |
| `demre/postulacion_seleccion/` (ArchivoD, ArchivoMatr) | DEMRE | `ID_aux` | Microdato pseudonimizado. Sin identificador directo |
| `demre/cuestionarios_caracterizacion/` (ArchivoK/L, CCEA) | DEMRE | `ID` | Auto-reporte socioeconómico/socioemocional por persona. **Fuera de alcance activo** |
| `egresados_em/` (Notas y Egresados EM) | MINEDUC | **`MRUN`** | **Dato personal de NNA** (RUN enmascarado + nota individual) |
| `demre/referencia/` (Libros de Códigos, percentiles, oferta, indicadores) | DEMRE | — | Material de consulta estático. No personal |
| `auxiliares/` (directorio depurado, territorios, guía DEMRE) | MINEDUC/DEMRE | — | No personal (institucional / público) |

### 1.2 Producto publicado (`docs/index.html`, GitHub Pages)

JSON embebido con **solo agregados territoriales** (cobertura por etapa,
rendimiento por prueba), catálogos de comunas/SLEP/regiones y metadatos.
**Ningún `ID_aux`, `MRUN`, `FECHA_NACIMIENTO` ni microdato cruza al producto.** Se
verificará por doble vía (trazado de código + recuento parquet→sitio) antes de
publicar, y toda celda con menos de `UMBRAL_SUPRESION_CELDA` (=8) personas se
suprime.

## 2. K-anonimato y supresión de celdas chicas

- **En origen:** el DEMRE ya aplica **k-anonimato = 8** a sus datos abiertos (Ley
  19.628). Ver `contexto_paes.md`.
- **En el proyecto:** al agregar desde microdato a territorio, toda celda con
  **< 8 personas** se suprime o etiqueta "n<8" (constante nombrada
  `UMBRAL_SUPRESION_CELDA` en `10_utils/10_configuracion.R`), alineada al estándar
  de la fuente. No es un número inventado.

## 3. Categoría según Ley 21.719

- **Dato personal de NNA:** `MRUN` / `MRUN_IPE` del estudiante en `egresados_em`.
  Máxima protección; jamás sale del control institucional ni entra a Git.
- **Dato personal / cuasi-identificador:** `FECHA_NACIMIENTO`, `SEXO`,
  `PAIS_NACIMIENTO`, `INGRESO_PERCAPITA_GRUPO_FA` (ArchivoB); auto-reporte CCEA
  (ArchivoK/L). No se publican individualizados.
- **Pseudonimizado:** `ID_aux` (DEMRE): reemplaza al RUN; permite cruzar bases sin
  identificar directamente. Aun así se trata como microdato fuera del repo.
- **No personal:** agregados territoriales, catálogos, referencia, directorio
  depurado, nombres de establecimientos/carreras/universidades (públicos).

## 4. Arquitectura de dos raíces (POLITICA §6.2)

- **Raíz de código:** este repositorio Git (`~/Projects/slep_paes`). Contiene
  código, configuración, documentación no sensible y `docs/index.html` (agregados
  publicados). **No** contiene `20_insumos/` ni `40_salidas/` reales.
- **Raíz de datos:** `<SLEP_PAES_DATA_ROOT>` en OneDrive institucional
  (`.../OneDrive-SLEP/Proyectos/slep_paes/`), con `20_insumos/` y `40_salidas/`
  reales. Resuelta por `10_utils/10_configuracion.R` (`obtener_data_root()`,
  `ruta_insumos()`, `ruta_salidas()`). Si la variable no resuelve, el pipeline
  falla al inicio con mensaje claro.
- **`.gitignore` blindado** (§6.3) desde ya: ignora `20_insumos/`, `40_salidas/`,
  `*.csv/*.xlsx/*.parquet/*.rds`, `.Renviron` y secretos.

## 5. Qué se versiona y qué no

- **Se versiona (repo):** código, `10_utils/`, documentación, `docs/index.html`
  (agregados con supresión), READMEs que documentan la estructura de datos.
- **NO se versiona:** todo `20_insumos/` y `40_salidas/` (microdato, intermedios,
  motor con datos), `.Renviron`. Viven solo en la raíz de datos.
- **Compuerta pre-commit:** antes de commitear, verificar que ningún archivo con
  extensión de datos ni con `MRUN/RUN/RUT/FECHA_NACIMIENTO` entró al índice
  (`git status` + `git ls-files`). La gobernanza prevalece sobre la autonomía
  (POLITICA 0.3).

## 6. Dónde están los datos reales

- Raíz de datos en OneDrive (`SLEP_PAES_DATA_ROOT`): bases DEMRE/MINEDUC,
  auxiliares, referencia, intermedios y motor.
- Copia publicada de agregados: `docs/index.html` (repo).

## 7. Período de retención

Datos conservados mientras el proyecto esté activo, en la raíz de datos
institucional. Las bases DEMRE se acumulan por proceso de admisión (serie
histórica). Los intermedios se regeneran y sobrescriben con `run_all()`.

## 8. Procedimiento ante incidente de seguridad

1. **Detección/Contención:** si se detecta microdato o identificador personal en
   el repo o en el producto publicado, despublicar (`docs/` fuera o repo a
   privado) y de-versionar de inmediato.
2. **Evaluación:** qué dato, en qué archivo, cuántas filas, si está en el tip, en
   el historial o ambos (`git rm --cached` no purga historial; requiere
   `git filter-repo`/BFG + `push --force`).
3. **Remediación y registro:** aplicar la mitigación, documentarla en
   `decisiones/`, log en `andamios/logs/`, evaluar notificación (Ley 21.719,
   agravada por tratarse de datos de NNA).

## 9. Terminología institucional

Término genérico: "**establecimiento educacional**" (completo en la primera
mención de cada párrafo; "establecimiento(s)" luego). Nunca "EE" en texto visible
ni "colegio" como genérico (SETTINGS 4.6.3.6). El nombre del establecimiento es
público; lo que no se publica es el microdato por persona.
