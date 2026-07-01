# =============================================================================
# 31_leer_normalizar.R
# -----------------------------------------------------------------------------
# Proyecto : slep_paes
# Proposito: Leer y normalizar las bases por etapa del DEMRE + la caracterizacion
#            de egresados de EM. Normaliza nombres (janitor::clean_names), tipa
#            llaves (id_aux, rbd como character) y emite un parquet por etapa en
#            40_salidas/intermedios/. Homologa el esquema contra las glosas
#            (demre/glosas/) por año de proceso.
# Insumos  : 20_insumos/demre/{inscripcion,rendicion_resultados,postulacion_seleccion}/*
#            20_insumos/egresados_em/*
# Salidas  : 40_salidas/intermedios/paes_{inscripcion,rendicion_resultados,
#            postulacion_seleccion,egresados}.parquet
# Fecha    : 2026-06-30
# -----------------------------------------------------------------------------
# STUB FUNCIONAL (sesion 1): mientras el titular no deposite las bases, cada
# etapa se OMITE con aviso (no aborta el pipeline). Cuando existan, este script
# las lee, normaliza nombres, tipa llaves como character y escribe el parquet.
# El mapeo semantico de columnas (que columna es CLEC/CMAT1/PTJE_NEM/ESTADO_
# SELECCION, codigos de ausencia, filtros de inscripcion valida / rindio_
# requisito) se completa contra las GLOSAS reales del DEMRE (B.1: no inventar).
# Ver manifiesto_insumos.md y contexto_paes.md.
# =============================================================================

library(here)
source(here::here("10_utils", "10_utils.R"))
source(here::here("10_utils", "10_configuracion.R"))  # ruta_insumos(), ruta_salidas()
instalar_si_falta(c("here", "fs", "readr", "janitor", "dplyr", "stringr", "arrow"))

ruta_int <- function(f) ruta_salidas("intermedios", f)
dir.create(ruta_salidas("intermedios"), recursive = TRUE, showWarnings = FALSE)

# --- Etapas: carpeta de insumo -> parquet de salida -------------------------
ETAPAS_LECTURA <- list(
  list(carpeta = ruta_insumos("demre", "inscripcion"),
       salida  = "paes_inscripcion.parquet",             foco = "cobertura"),
  list(carpeta = ruta_insumos("demre", "rendicion_resultados"),
       salida  = "paes_rendicion_resultados.parquet",    foco = "cobertura+rendimiento"),
  list(carpeta = ruta_insumos("demre", "postulacion_seleccion"),
       salida  = "paes_postulacion_seleccion.parquet",   foco = "cobertura"),
  list(carpeta = ruta_insumos("egresados_em"),
       salida  = "paes_egresados.parquet",               foco = "denominador")
)

# --- Helpers ----------------------------------------------------------------

# Tipa como character toda llave (id_aux y cualquier columna con "rbd" o codigo
# territorial): un join con tipos mezclados falla en silencio (POLITICA 5.3.6).
tipar_llaves <- function(df) {
  patron_llave <- "^(id_aux|id|correlativo|rbd|.*rbd.*|cod_com.*|cod_reg.*|cod_prov.*)$"
  llaves <- grep(patron_llave, names(df), value = TRUE)
  for (k in llaves) df[[k]] <- as.character(df[[k]])
  df
}

# Archivos de datos de una carpeta (csv/txt), excluyendo READMEs y ocultos.
archivos_datos <- function(carpeta) {
  if (!dir.exists(carpeta)) return(character(0))
  fs::dir_ls(carpeta, type = "file", glob = "*.csv", fail = FALSE) |>
    c(fs::dir_ls(carpeta, type = "file", glob = "*.txt", fail = FALSE)) |>
    unname()
}

# Lee un plano DEMRE (separador ";" tipico) y normaliza nombres.
leer_plano <- function(ruta) {
  readr::read_delim(
    ruta, delim = ";",
    locale = readr::locale(encoding = "UTF-8", decimal_mark = ","),
    show_col_types = FALSE, progress = FALSE
  ) |>
    janitor::clean_names() |>
    tipar_llaves()
}

# --- Flujo por etapa --------------------------------------------------------
resumen <- list()
for (etapa in ETAPAS_LECTURA) {
  nombre <- tools::file_path_sans_ext(basename(etapa$salida))
  archivos <- archivos_datos(etapa$carpeta)

  if (length(archivos) == 0) {
    log_msg(sprintf("STUB: etapa '%s' sin bases en %s -> se omite (deposita las bases y re-corre).",
                    nombre, fs::path_rel(etapa$carpeta, here::here())), "WARN", "31")
    next
  }

  # Lee todos los archivos de la etapa (p. ej. varios procesos/temporadas) y los
  # apila. La procedencia (proceso/temporada) se deriva del nombre del archivo.
  log_msg(sprintf("Leyendo etapa '%s': %d archivo(s).", nombre, length(archivos)), "INFO", "31")
  piezas <- lapply(archivos, function(a) {
    df <- leer_plano(a)
    df$archivo_origen <- basename(a)
    df
  })
  df_etapa <- dplyr::bind_rows(piezas)

  # TODO (contra glosas): homologar columnas por año, filtrar inscripciones
  # validas / rindio_requisito, mapear codigos de ausencia de puntaje a NA,
  # y estandarizar la llave territorial rbd_ens -> rbd. Ver contexto_paes.md.

  arrow::write_parquet(df_etapa, ruta_int(etapa$salida))
  log_msg(sprintf("OK: %s (%d filas, %d cols).", etapa$salida, nrow(df_etapa), ncol(df_etapa)),
          "INFO", "31")
  resumen[[nombre]] <- nrow(df_etapa)
}

if (length(resumen) == 0) {
  message("\n31_leer_normalizar.R: STUB — ninguna base depositada aun; nada que normalizar.")
} else {
  message("\n31_leer_normalizar.R: OK. Etapas normalizadas: ",
          paste(names(resumen), collapse = ", "))
}
