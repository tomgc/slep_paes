# =============================================================================
# 32_agregar_territorial.R
# -----------------------------------------------------------------------------
# Proyecto : slep_paes
# Proposito: Agregar los DOS FOCOS del panorama al arbol territorial
#            RBD -> comuna -> SLEP -> region -> nacional, aplicando supresion de
#            celdas chicas (UMBRAL_SUPRESION_CELDA, k-anonimato DEMRE).
#              FOCO COBERTURA: embudo egresados(denominador) -> inscritos ->
#                rendidos -> resultados_validos -> postulantes -> seleccionados,
#                con categoria EXPLICITA de "rezagados" (rinden sin RBD_ENS de
#                egreso vigente).
#              FOCO RENDIMIENTO: distribucion de puntajes por prueba (Competencia
#                Lectora, M1, M2, Ciencias +-TP, Historia), NEM y Ranking, mismo
#                arbol territorial (media ponderada por nº de rendidos).
# Insumos  : 40_salidas/intermedios/paes_{egresados,inscripcion,
#            rendicion_resultados,postulacion_seleccion}.parquet (de 31_)
#            + catalogos territoriales (de 30_).
# Salidas  : 40_salidas/intermedios/paes_cobertura_territorial.parquet
#            40_salidas/intermedios/paes_rendimiento_territorial.parquet
# Fecha    : 2026-06-30
# -----------------------------------------------------------------------------
# STUB FUNCIONAL (sesion 1): sin los parquets de 31_ (bases DEMRE no depositadas)
# la agregacion se OMITE con aviso; el pipeline no aborta. Las FUNCIONES de
# agregacion, la categoria de rezagados y la SUPRESION de celdas chicas ya estan
# definidas; el mapeo de columnas concretas (que columna marca "rindio", que
# puntaje por prueba) se cablea contra la salida real de 31_ (B.1: no inventar).
# =============================================================================

library(here)
source(here::here("10_utils", "10_utils.R"))
source(here::here("10_utils", "10_configuracion.R"))   # UMBRAL_SUPRESION_CELDA, ETAPAS_EMBUDO, PRUEBAS_PAES, ETIQUETA_SIN_RBD_VIGENTE
instalar_si_falta(c("here", "dplyr", "tidyr", "arrow"))

ruta_int <- function(f) here::here("40_salidas", "intermedios", f)

# ============================================================================
# Funciones de agregacion territorial (reutilizables por ambos focos)
# ============================================================================

# Expande cada RBD a sus entidades territoriales (comuna, SLEP, region, nacional)
# usando los catalogos. Devuelve un df largo (una fila por rbd x tipo_entidad).
# Los establecimientos sin comuna/region (RBD historico o rezagado) se etiquetan
# como entidad especial de rezagados, NUNCA se descartan.
mapa_territorial <- function(cat_estab, cat_slep) {
  base <- cat_estab |>
    dplyr::transmute(rbd = as.character(rbd),
                     cod_comuna = as.character(cod_com_rbd),
                     cod_region = as.character(cod_reg_rbd))
  slep <- cat_slep |>
    dplyr::distinct(rbd = as.character(rbd), cod_slep = as.character(cod_slep))
  dplyr::left_join(base, slep, by = "rbd")
}

# Suprime celdas chicas: todo conteo 0 < n < UMBRAL_SUPRESION_CELDA se marca como
# suprimido (n -> NA, flag TRUE). No se muestra el conteo exacto que individualiza.
aplicar_supresion <- function(df, col_n = "n", umbral = UMBRAL_SUPRESION_CELDA) {
  n <- df[[col_n]]
  suprimir <- !is.na(n) & n > 0 & n < umbral
  df[["suprimida"]] <- suprimir
  df[[col_n]][suprimir] <- NA_integer_
  df
}

# Agrega un CONTEO (headcount) de personas a los cuatro tipos de entidad
# territorial + rezagados. `df_personas` debe traer una columna `rbd` (RBD_ENS de
# egreso, o NA para rezagados) y las columnas de desglose en `by`.
agregar_conteo_territorial <- function(df_personas, mapa, by = character(0)) {
  # TODO(31): df_personas viene de la etapa normalizada; `rbd` = rbd_ens vigente.
  d <- dplyr::left_join(df_personas, mapa, by = "rbd")

  rezagados <- d |>
    dplyr::filter(is.na(.data$cod_comuna)) |>
    dplyr::summarise(n = dplyr::n(), .by = dplyr::all_of(by)) |>
    dplyr::mutate(tipo_entidad = "rezagados", cod_entidad = ETIQUETA_SIN_RBD_VIGENTE)

  con_rbd <- d |> dplyr::filter(!is.na(.data$cod_comuna))
  por <- function(tipo, col) {
    con_rbd |>
      dplyr::filter(!is.na(.data[[col]])) |>
      dplyr::summarise(n = dplyr::n(), .by = dplyr::all_of(c(col, by))) |>
      dplyr::rename(cod_entidad = dplyr::all_of(col)) |>
      dplyr::mutate(tipo_entidad = tipo, cod_entidad = as.character(cod_entidad))
  }
  nacional <- con_rbd |>
    dplyr::summarise(n = dplyr::n(), .by = dplyr::all_of(by)) |>
    dplyr::mutate(tipo_entidad = "nacional", cod_entidad = "0")

  dplyr::bind_rows(
    por("comuna", "cod_comuna"), por("slep", "cod_slep"),
    por("region", "cod_region"), nacional, rezagados
  ) |>
    aplicar_supresion("n")
}

# ============================================================================
# Carga guardada de insumos
# ============================================================================
faltan_31 <- !all(file.exists(
  ruta_int("paes_egresados.parquet"),
  ruta_int("paes_inscripcion.parquet"),
  ruta_int("paes_rendicion_resultados.parquet"),
  ruta_int("paes_postulacion_seleccion.parquet")
))
faltan_cat <- !all(file.exists(
  ruta_int("establecimientos_chile.parquet"),
  ruta_int("sleps_chile.parquet")
))

if (faltan_cat) {
  log_msg("Faltan catalogos territoriales (corre 30_ primero).", "WARN", "32")
}
if (faltan_31 || faltan_cat) {
  log_msg("STUB: faltan parquets de 31_ (bases DEMRE) y/o catalogos -> agregacion omitida.",
          "WARN", "32")
  message("\n32_agregar_territorial.R: STUB — sin insumos completos; nada que agregar.")
} else {
  cat_estab <- arrow::read_parquet(ruta_int("establecimientos_chile.parquet"))
  cat_slep  <- arrow::read_parquet(ruta_int("sleps_chile.parquet"))
  mapa      <- mapa_territorial(cat_estab, cat_slep)

  # ---- FOCO COBERTURA: embudo por etapa ----------------------------------
  # Cada etapa aporta su universo de personas (con rbd_ens). El conteo por etapa,
  # agregado al arbol territorial + rezagados, arma el embudo. El denominador es
  # egresados. `by` incluira el anio de proceso (y prueba si aplica) cuando 31_
  # exponga esas columnas homologadas.
  # TODO(31): sustituir los df por las columnas reales de cada etapa.
  log_msg("Agregando FOCO COBERTURA (embudo egresados -> ... -> seleccionados)...", "INFO", "32")
  # ... (cableado por etapa contra la salida real de 31_) ...
  # arrow::write_parquet(cobertura, ruta_int("paes_cobertura_territorial.parquet"))

  # ---- FOCO RENDIMIENTO: puntajes por prueba -----------------------------
  # Media ponderada por nº de rendidos, por prueba (PRUEBAS_PAES), NEM y Ranking,
  # mismo arbol territorial, con supresion de celdas chicas.
  log_msg("Agregando FOCO RENDIMIENTO (puntajes por prueba, NEM, Ranking)...", "INFO", "32")
  # ... (cableado contra la salida real de 31_) ...
  # arrow::write_parquet(rendimiento, ruta_int("paes_rendimiento_territorial.parquet"))

  message("\n32_agregar_territorial.R: (cuerpo a completar con las bases reales).")
}
