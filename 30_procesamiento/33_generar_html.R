# =============================================================================
# 33_generar_html.R
# -----------------------------------------------------------------------------
# Proyecto : slep_paes
# Proposito: Construir el producto final motor_paes.html: HTML AUTOCONTENIDO con
#            React/ReactDOM/D3/pako LOCALES (sin CDN), JSON columnar comprimido
#            (gzip + base64, descomprimido en cliente con pako), navegacion
#            territorial y toggle de DOBLE FOCO (cobertura / rendimiento).
#            PALETA_PAES (10_configuracion.R) es la fuente unica de color.
#            Patron: decisiones/20260630_decision_patron_comun_y_paleta.md.
# Insumos  : 40_salidas/intermedios/{comunas,sleps,establecimientos}_chile.parquet
#            40_salidas/intermedios/paes_{cobertura,rendimiento}_territorial.parquet
#            10_utils/{react,react-dom}.production.min.js, d3.min.js, pako.min.js
#            30_procesamiento/33_motor_template.html
# Salidas  : 40_salidas/motor_paes.html  (+ copia a docs/index.html)
# Fecha    : 2026-06-30
# -----------------------------------------------------------------------------
# STUB FUNCIONAL (sesion 1): genera con lo que exista. Tras correr 30_ ya produce
# un motor-esqueleto navegable (chrome, nav territorial, toggle de foco) con los
# bloques de datos vacios (rows=0) y un aviso "aun sin datos del DEMRE". Cuando
# 32_ escriba los parquets de cobertura/rendimiento, el motor los muestra sin
# tocar este generador.
# =============================================================================

library(here)
source(here::here("10_utils", "10_utils.R"))
source(here::here("10_utils", "10_configuracion.R"))  # PALETA_PAES, FOCOS_PAES, ETAPAS_EMBUDO, PRUEBAS_PAES, ESCALA_*, etc.
instalar_si_falta(c("here", "fs", "dplyr", "arrow", "jsonlite"))

ruta_int <- function(f) ruta_salidas("intermedios", f)

# Lee un parquet si existe; si no, devuelve un tibble vacio (bloque rows=0).
leer_o_vacio <- function(f) {
  p <- ruta_int(f)
  if (file.exists(p)) arrow::read_parquet(p) else dplyr::tibble()
}

# Convierte un data.frame a lista columnar (arrays paralelos + rows), patron de
# la familia para JSON compacto.
columnar <- function(df) {
  out <- list(rows = nrow(df))
  for (nm in names(df)) out[[nm]] <- df[[nm]]
  out
}

# ============================================================================
# Bloque 1 — Cargar catalogos y focos (guardado)
# ============================================================================
message("[1] Cargando insumos disponibles...")
df_com   <- leer_o_vacio("comunas_chile.parquet")
df_slep  <- leer_o_vacio("sleps_chile.parquet")
df_estab <- leer_o_vacio("establecimientos_chile.parquet")
df_cob   <- leer_o_vacio("paes_cobertura_territorial.parquet")
df_ren   <- leer_o_vacio("paes_rendimiento_territorial.parquet")

hay_datos <- (nrow(df_cob) + nrow(df_ren)) > 0
if (nrow(df_estab) == 0) {
  log_msg("Catalogos ausentes (corre 30_ primero): el motor saldra como esqueleto vacio.",
          "WARN", "33")
}

# ============================================================================
# Bloque 2 — Meta (PALETA_PAES como fuente unica) y JSON
# ============================================================================
message("[2] Construyendo JSON...")

meta <- list(
  fecha_generacion  = format(Sys.Date()),
  proyecto          = PROYECTO_ID,
  focos             = FOCOS_PAES,
  escala            = list(min = ESCALA_PAES_MIN, max = ESCALA_PAES_MAX),
  etapas_embudo     = as.list(ETAPAS_EMBUDO),
  pruebas           = as.list(PRUEBAS_PAES),
  factores_contexto = as.list(FACTORES_CONTEXTO),
  rezagados_label   = ETIQUETA_SIN_RBD_VIGENTE,
  umbral_supresion  = UMBRAL_SUPRESION_CELDA,
  nombres_region    = as.list(NOMBRES_REGION),
  paleta            = PALETA_PAES,          # fuente unica de color
  hay_datos         = hay_datos
)

json_root <- list(
  meta             = meta,
  comunas          = columnar(df_com),
  sleps            = columnar(df_slep),
  establecimientos = columnar(df_estab),
  cobertura        = columnar(df_cob),
  rendimiento      = columnar(df_ren)
)

json_str <- enc2utf8(jsonlite::toJSON(json_root, auto_unbox = TRUE, na = "null",
                                      dataframe = "rows", digits = NA))
bytes_plano <- nchar(json_str, type = "bytes")
json_gzip <- memCompress(charToRaw(json_str), type = "gzip")
json_b64  <- gsub("\n", "", jsonlite::base64_enc(json_gzip), fixed = TRUE)
message(sprintf("    JSON: %.2f KB plano -> %.2f KB gzip+base64.",
                bytes_plano / 1024, nchar(json_b64, type = "bytes") / 1024))

# ============================================================================
# Bloque 3 — Plantilla y librerias locales (sin CDN)
# ============================================================================
message("[3] Leyendo plantilla y librerias locales...")
plantilla_path <- here::here("30_procesamiento", "33_motor_template.html")
libs <- list(
  "__REACT_INLINE__"    = here::here("10_utils", "react.production.min.js"),
  "__REACTDOM_INLINE__" = here::here("10_utils", "react-dom.production.min.js"),
  "__D3_INLINE__"       = here::here("10_utils", "d3.min.js"),
  "__PAKO_INLINE__"     = here::here("10_utils", "pako.min.js")
)
stopifnot("No existe la plantilla" = file.exists(plantilla_path))
for (p in unlist(libs)) {
  if (!file.exists(p)) stop("Falta libreria local (sin CDN): ", p,
                            "\n  Reusar de un hermano (10_utils/).")
}
leer_txt <- function(p) paste(readLines(p, encoding = "UTF-8", warn = FALSE), collapse = "\n")
plantilla <- leer_txt(plantilla_path)

# ============================================================================
# Bloque 4 — Reemplazar placeholders y escribir HTML
# ============================================================================
message("[4] Ensamblando HTML...")
for (ph in c(names(libs), "__JSON_DATA__")) {
  if (!grepl(ph, plantilla, fixed = TRUE)) stop("La plantilla no contiene ", ph, ".")
}
html <- plantilla
for (ph in names(libs)) html <- sub(ph, leer_txt(libs[[ph]]), html, fixed = TRUE)
html <- sub("__JSON_DATA__", json_b64, html, fixed = TRUE)

ruta_salida <- ruta_salidas("motor_paes.html")
dir.create(dirname(ruta_salida), recursive = TRUE, showWarnings = FALSE)
con <- file(ruta_salida, open = "wb", encoding = "UTF-8")
writeBin(charToRaw(enc2utf8(html)), con); close(con)
message(sprintf("    OK: %s (%.0f KB)", fs::path_rel(ruta_salida, here::here()),
                file.info(ruta_salida)$size / 1024))

# --- Publicacion: copia a docs/index.html (modelo Pages de la familia) ------
dir_docs <- here::here("docs")
if (!dir.exists(dir_docs)) dir.create(dir_docs, recursive = TRUE)
ok <- file.copy(ruta_salida, file.path(dir_docs, "index.html"), overwrite = TRUE)
if (!ok) stop("No se pudo copiar a docs/index.html")
message("    OK: docs/index.html (copia para GitHub Pages)")

rm(json_str, json_gzip, json_b64, html, plantilla); gc(verbose = FALSE)
message(sprintf("\n33_generar_html.R: OK.%s",
                if (hay_datos) "" else " (esqueleto sin datos DEMRE aun)"))
