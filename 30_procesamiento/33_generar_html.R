# =============================================================================
# 33_generar_html.R
# -----------------------------------------------------------------------------
# Proyecto : slep_paes
# Proposito: Construir el producto final motor_paes.html: HTML AUTOCONTENIDO con
#            React/ReactDOM/D3/pako LOCALES (sin CDN), fuentes de marca embebidas
#            (base64), JSON columnar comprimido (gzip + base64, descomprimido en
#            cliente con pako), navegacion territorial y DOBLE FOCO (cobertura /
#            rendimiento). CAMINO A: recrea el diseno hi-fi del handoff adaptado
#            al CONTRATO REAL de 32 (agregados territoriales, sin microdato,
#            sin nivel establecimiento, sin matricula, media no mediana). Incluye
#            el KPI de prioridad de carrera seleccionada (n_seleccionados,
#            n_prioridad_1, pct_prioridad_1; solo existe en etapa=="seleccion").
#            Patron de familia: decisiones/20260630_decision_patron_comun_y_paleta.md
#            + handoff 50_documentacion/andamios/design_handoff_ui_ux/.
# Insumos  : 40_salidas/intermedios/{comunas,sleps}_chile.parquet
#            40_salidas/intermedios/paes_{cobertura,rendimiento}_territorial.parquet
#            10_utils/{react,react-dom}.production.min.js, d3.min.js, pako.min.js
#            50_documentacion/andamios/design_handoff_ui_ux/fonts/*.otf
#            30_procesamiento/33_motor_template.html
# Salidas  : 40_salidas/motor_paes.html  (+ copia a docs/index.html)
# Fecha    : 2026-07-02
# -----------------------------------------------------------------------------
# GOBERNANZA (POLITICA 6.4 + invariantes del encargo):
#   - SOLO AGREGADOS territoriales; el JSON embebido NUNCA contiene microdato ni
#     identificadores de establecimiento (por eso NO se carga establecimientos).
#   - La supresion (n < UMBRAL_SUPRESION_CELDA) YA viene aplicada en la columna
#     `suprimida` de los parquets de 32; aqui solo se transporta, no se recalcula.
#   - "generaciones anteriores" = tipo_entidad == "rezagados" (bucket agregado
#     nacional). Termino visible: "generaciones anteriores", nunca "rezagados".
# =============================================================================

library(here)
source(here::here("10_utils", "10_utils.R"))
source(here::here("10_utils", "10_configuracion.R"))
instalar_si_falta(c("here", "fs", "dplyr", "arrow", "jsonlite"))
suppressMessages(library(dplyr))

ruta_int <- function(f) ruta_salidas("intermedios", f)

# --- Helpers -----------------------------------------------------------------
# Title case en espanol para nombres de comuna que vienen en MAYUSCULAS del
# directorio (VINA DEL MAR -> Vina del Mar). Conectores en minuscula.
titlecase_es <- function(x) {
  conect <- c("de", "del", "la", "las", "los", "y", "e", "el")
  vapply(x, function(s) {
    if (is.na(s) || s == "") return(s)
    palabras <- strsplit(tolower(s), "\\s+")[[1]]
    out <- vapply(seq_along(palabras), function(i) {
      w <- palabras[i]
      if (i > 1 && w %in% conect) return(w)
      paste0(toupper(substr(w, 1, 1)), substr(w, 2, nchar(w)))
    }, character(1))
    paste(out, collapse = " ")
  }, character(1), USE.NAMES = FALSE)
}

columnar <- function(df) {
  out <- list(rows = nrow(df))
  for (nm in names(df)) out[[nm]] <- df[[nm]]
  out
}

# Bajo locale C, los literales de las fuentes .R quedan con Encoding "unknown"
# aunque sus bytes YA sean UTF-8; enc2utf8() los corromperia (doble encode).
# Este marcador RELABELA como UTF-8 (no toca bytes) de forma recursiva, para que
# jsonlite serialice los acentos/ñ correctamente. Las cadenas de arrow ya vienen
# marcadas UTF-8 (re-marcarlas es inocuo).
marcar_utf8 <- function(x) {
  if (is.character(x)) { Encoding(x) <- "UTF-8"; x }
  else if (is.data.frame(x)) { x[] <- lapply(x, marcar_utf8); x }
  else if (is.list(x)) { lapply(x, marcar_utf8) }
  else x
}

# ============================================================================
# Bloque 1 — Cargar insumos reales (agregados de 32 + catalogos de 30)
# ============================================================================
message("[1] Cargando agregados territoriales y catalogos...")
req <- c("paes_cobertura_territorial.parquet", "paes_rendimiento_territorial.parquet",
         "comunas_chile.parquet", "sleps_chile.parquet")
for (f in req) if (!file.exists(ruta_int(f))) {
  stop("Falta insumo de 30/32: ", f, " -> corre run_all(only=c(30,31,32)).")
}
df_cob  <- arrow::read_parquet(ruta_int("paes_cobertura_territorial.parquet"))
df_ren  <- arrow::read_parquet(ruta_int("paes_rendimiento_territorial.parquet"))
df_com  <- arrow::read_parquet(ruta_int("comunas_chile.parquet"))
df_slep <- arrow::read_parquet(ruta_int("sleps_chile.parquet"))

# NOTA: NO se carga establecimientos_chile.parquet a proposito: el motor opera a
# nivel territorio (nacional/region/SLEP/comuna); nombres de establecimiento no
# entran al output (POLITICA 6.4).

anios <- sort(unique(df_cob$anio_proceso))
# "actual" = ultimo anio con DENOMINADOR de egresados presente. 2026 trae
# inscripcion en adelante pero NO egresados (egresados_em 2026 ausente en 32);
# el embudo necesita egresados como base -> usar el ultimo anio con egresados.
anios_egr <- sort(unique(df_cob$anio_proceso[df_cob$etapa == "egresados"]))
anio_actual <- max(anios_egr)

# --- Catalogo territorial: solo nodos PRESENTES en los agregados -------------
com_map  <- df_com  |> dplyr::transmute(cod = as.character(cod_com_rbd),
                                        nombre = titlecase_es(nom_com_rbd),
                                        reg = as.character(cod_reg_rbd)) |> dplyr::distinct()
# comuna -> slep (solo comunas con SLEP vigente; puede faltar)
com_slep <- df_slep |> dplyr::transmute(cod = as.character(cod_com_rbd),
                                        slep = as.character(cod_slep)) |> dplyr::distinct()
slep_nom <- df_slep |> dplyr::transmute(slep = as.character(cod_slep),
                                        nombre = nombre_slep) |> dplyr::distinct()

present_com  <- unique(df_cob$cod_entidad[df_cob$tipo_entidad == "comuna"])
present_slep <- unique(df_cob$cod_entidad[df_cob$tipo_entidad == "slep"])
present_reg  <- unique(df_cob$cod_entidad[df_cob$tipo_entidad == "region"])

comunas <- com_map |>
  dplyr::filter(cod %in% present_com) |>
  dplyr::left_join(com_slep, by = "cod") |>
  dplyr::mutate(slep = ifelse(slep %in% present_slep, slep, NA_character_)) |>
  dplyr::arrange(nombre)

# slep -> region: derivada de la region de sus comunas (moda simple: primera)
slep_reg <- comunas |>
  dplyr::filter(!is.na(slep)) |>
  dplyr::group_by(slep) |>
  dplyr::summarise(reg = names(sort(table(reg), decreasing = TRUE))[1], .groups = "drop")
# Clave estandar `cod` en los tres niveles (el motor cliente indexa por `cod`).
sleps <- tibble::tibble(slep = present_slep) |>
  dplyr::left_join(slep_nom, by = "slep") |>
  dplyr::left_join(slep_reg, by = "slep") |>
  dplyr::transmute(cod = slep, nombre = ifelse(is.na(nombre), paste0("SLEP ", slep), nombre), reg = reg) |>
  dplyr::arrange(nombre)

regiones <- tibble::tibble(cod = as.character(present_reg)) |>
  dplyr::mutate(nombre = unname(NOMBRES_REGION[cod]),
               nombre = ifelse(is.na(nombre), paste0("Region ", cod), nombre)) |>
  dplyr::arrange(as.integer(cod))

# --- Costa Central (contexto por defecto) -----------------------------------
CC_SLEP <- "503"
cc_com_codes <- df_slep |>
  dplyr::filter(as.character(cod_slep) == CC_SLEP) |>
  dplyr::pull(cod_com_rbd) |> as.character() |> unique()
# Colores de comuna del handoff (README Design Tokens)
cc_colores <- c("5109" = "#0062A0",  # Vina del Mar
                "5103" = "#75924E",  # Concon
                "5107" = "#4A2746",  # Quintero
                "5105" = "#BCA493")  # Puchuncavi
cc_orden   <- c("5109", "5103", "5107", "5105")

# ============================================================================
# Bloque 2 — Rendimiento: mejor puntaje VIGENTE por prueba + NEM/Ranking
# ============================================================================
# tipo_rendicion == "vigente" (creado en 32): mejor puntaje de cada prueba entre
# las ultimas 4 rendiciones consecutivas (REG/INV x ACTUAL/ANTERIOR), regla
# oficial DEMRE "puntaje bloque" (contexto_paes.md seccion 5; Decision 6 sesion 6,
# ventana=4 aprobada por el titular). Reemplaza la publicacion anterior de solo
# reg+actual. NEM/Ranking vienen con tipo_rendicion/vigencia == NA (atributos por
# persona en 32) -> se incluyen por nombre de prueba. Las filas reg/inv/anterior
# siguen en el parquet (no publicadas). El embudo/cobertura NO cambia.
# grupo_dependencia (PP/PS/Mun/sin_dato/"todas") viaja SOLO en rendimiento (corte
# transversal por dependencia del establecimiento, focus Rendimiento). El filtro
# ya captura todas las ramas de dependencia de las filas publicadas (vigente +
# nem/ranking). El bloque de cobertura (cob_f) NO gana esta columna.
ren_f <- df_ren |>
  dplyr::filter((tipo_rendicion == "vigente" & vigencia == "actual") |
                prueba %in% c("nem", "ranking")) |>
  dplyr::select(cod_entidad, anio_proceso, prueba, tipo_entidad, cohorte,
                grupo_dependencia, n, media, suprimida)

cob_f <- df_cob |>
  dplyr::select(cod_entidad, anio_proceso, etapa, orden_etapa, tipo_entidad, cohorte, n, suprimida,
                n_seleccionados, n_prioridad_1, pct_prioridad_1)

# ============================================================================
# Bloque 3 — Meta + JSON root
# ============================================================================
message("[2] Construyendo JSON (agregados, sin microdato ni establecimientos)...")

etapas <- list(
  list(k = "egresados",   label = "Egresados de enseñanza media"),
  list(k = "inscripcion", label = "Inscritos en la PAES"),
  list(k = "rendicion",   label = "Rindió al menos una prueba"),
  list(k = "resultados",  label = "Resultados válidos"),
  list(k = "postulacion", label = "Postuló a educación superior"),
  list(k = "seleccion",   label = "Seleccionado en alguna carrera")
)
pruebas <- list(
  list(k = "clec",  sigla = "CL", short = "CL",       name = "Competencia Lectora"),
  list(k = "mate1", sigla = "M1", short = "M1",       name = "Matemática 1"),
  list(k = "mate2", sigla = "M2", short = "M2",       name = "Matemática 2"),
  list(k = "cien",  sigla = "",   short = "Ciencias", name = "Ciencias"),
  list(k = "hcsoc", sigla = "",   short = "Historia", name = "Historia y Ciencias Sociales")
)
contexto <- list(
  list(k = "nem",     sigla = "", short = "NEM",     name = "Notas de Enseñanza Media"),
  list(k = "ranking", sigla = "", short = "Ranking", name = "Ranking de notas")
)

meta <- list(
  fecha_generacion = format(Sys.Date()),
  proyecto         = PROYECTO_ID,
  focos            = FOCOS_PAES,
  escala           = list(min = ESCALA_PAES_MIN, max = ESCALA_PAES_MAX),
  anios            = anios,
  anio_actual      = anio_actual,
  etapas           = etapas,
  pruebas          = pruebas,
  contexto         = contexto,
  umbral           = UMBRAL_SUPRESION_CELDA,
  rezagados_label  = ETIQUETA_SIN_RBD_VIGENTE,
  gen_ant_label    = "Generaciones anteriores",
  territorios = list(
    nacional  = list(cod = "0", nombre = "Chile (nacional)"),
    regiones  = regiones,
    sleps     = sleps,
    comunas   = comunas
  ),
  costa_central = list(
    slep    = CC_SLEP,
    comunas = cc_orden,
    colores = as.list(cc_colores)
  )
)

json_root <- list(
  meta        = meta,
  cobertura   = columnar(cob_f),
  rendimiento = columnar(ren_f)
)

json_root <- marcar_utf8(json_root)  # relabel UTF-8 antes de serializar (locale C)
json_str <- jsonlite::toJSON(json_root, auto_unbox = TRUE, na = "null",
                             dataframe = "rows", digits = 4)
bytes_plano <- nchar(json_str, type = "bytes")
json_gzip <- memCompress(charToRaw(json_str), type = "gzip")
json_b64  <- gsub("\n", "", jsonlite::base64_enc(json_gzip), fixed = TRUE)
message(sprintf("    JSON: %.1f KB plano -> %.1f KB gzip+base64 (%.1f%%).",
                bytes_plano / 1024, nchar(json_b64, type = "bytes") / 1024,
                100 * nchar(json_b64, type = "bytes") / bytes_plano))

# ============================================================================
# Bloque 4 — Fuentes de marca embebidas (base64) -> CSS @font-face
# ============================================================================
message("[3] Embebiendo fuentes de marca (gobCL / Museo Sans)...")
font_dir <- here::here("50_documentacion", "andamios", "design_handoff_ui_ux", "fonts")
fuentes <- list(
  list(fam = "gobCL",      w = 400, f = "gobCL_Regular.otf"),
  list(fam = "gobCL",      w = 900, f = "gobCL_Heavy.otf"),
  list(fam = "Museo Sans", w = 300, f = "MuseoSans-300.otf"),
  list(fam = "Museo Sans", w = 500, f = "MuseoSans_500.otf"),
  list(fam = "Museo Sans", w = 700, f = "MuseoSans_700.otf")
)
fonts_css <- vapply(fuentes, function(ft) {
  ruta <- fs::path(font_dir, ft$f)
  if (!file.exists(ruta)) stop("Falta fuente de marca: ", ruta)
  b64 <- jsonlite::base64_enc(readBin(ruta, "raw", n = file.info(ruta)$size))
  sprintf("@font-face{font-family:'%s';font-weight:%d;font-style:normal;font-display:swap;src:url(data:font/otf;base64,%s) format('opentype');}",
          ft$fam, ft$w, b64)
}, character(1)) |> paste(collapse = "\n")

# ============================================================================
# Bloque 5 — Plantilla + librerias locales (sin CDN) + reemplazo
# ============================================================================
message("[4] Ensamblando plantilla + librerias locales...")
plantilla_path <- here::here("30_procesamiento", "33_motor_template.html")
libs <- list(
  "__REACT_INLINE__"    = here::here("10_utils", "react.production.min.js"),
  "__REACTDOM_INLINE__" = here::here("10_utils", "react-dom.production.min.js"),
  "__D3_INLINE__"       = here::here("10_utils", "d3.min.js"),
  "__PAKO_INLINE__"     = here::here("10_utils", "pako.min.js")
)
stopifnot("No existe la plantilla" = file.exists(plantilla_path))
for (p in unlist(libs)) if (!file.exists(p)) stop("Falta libreria local (sin CDN): ", p)
leer_txt <- function(p) paste(readLines(p, encoding = "UTF-8", warn = FALSE), collapse = "\n")
plantilla <- leer_txt(plantilla_path)

for (ph in c(names(libs), "__FONTS_CSS__", "__JSON_DATA__")) {
  if (!grepl(ph, plantilla, fixed = TRUE)) stop("La plantilla no contiene ", ph, ".")
}
html <- plantilla
for (ph in names(libs)) html <- sub(ph, leer_txt(libs[[ph]]), html, fixed = TRUE)
html <- sub("__FONTS_CSS__", fonts_css, html, fixed = TRUE)
html <- sub("__JSON_DATA__", json_b64, html, fixed = TRUE)

html_raw <- charToRaw(enc2utf8(html))

# --- Guarda de regresion: mojibake UTF-8 (doble codificacion) ---------------
# La secuencia de bytes c3 83 = "Ã" es el sintoma inequivoco de doble-encode
# UTF-8: ningun literal legitimo del motor (nombres de comuna/region/SLEP,
# pruebas, etapas, notas) contiene "Ã", y los blobs base64 (fuentes, JSON) y
# las libs ASCII no la producen. Si aparece, un literal acentuado escapo del
# marcado UTF-8 (marcar_utf8) -> abortar antes de publicar HTML corrupto.
mojibake <- which(html_raw[-length(html_raw)] == as.raw(0xc3) & html_raw[-1] == as.raw(0x83))
if (length(mojibake) > 0) {
  stop(sprintf("Mojibake UTF-8 en el HTML final: %d secuencia(s) c3 83 ('Ã'). ",
               length(mojibake)),
       "Un literal acentuado no quedo marcado UTF-8; revisa que marcar_utf8() ",
       "cubra su ruta de serializacion antes de escribir.", call. = FALSE)
}

ruta_salida <- ruta_salidas("motor_paes.html")
dir.create(dirname(ruta_salida), recursive = TRUE, showWarnings = FALSE)
con <- file(ruta_salida, open = "wb", encoding = "UTF-8")
writeBin(html_raw, con); close(con)
message(sprintf("    OK: %s (%.0f KB)", fs::path_rel(ruta_salida, here::here()),
                file.info(ruta_salida)$size / 1024))

# --- Publicacion: copia a docs/index.html (modelo Pages) --------------------
dir_docs <- here::here("docs")
if (!dir.exists(dir_docs)) dir.create(dir_docs, recursive = TRUE)
ok <- file.copy(ruta_salida, file.path(dir_docs, "index.html"), overwrite = TRUE)
if (!ok) stop("No se pudo copiar a docs/index.html")
message("    OK: docs/index.html (copia para GitHub Pages)")

rm(json_str, json_gzip, json_b64, html, plantilla); invisible(gc(verbose = FALSE))
message("\n33_generar_html.R: OK (Camino A — agregados reales, sin microdato).")
