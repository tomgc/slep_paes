# =============================================================================
# 31_leer_normalizar.R
# -----------------------------------------------------------------------------
# Proyecto : slep_paes
# Proposito: Leer y normalizar las bases DEMRE (ArchivoB/C/D/Matr) 2023-2026 +
#            la caracterizacion de egresados de EM, contra el esquema real
#            (no el generico del stub de sesion 1). Emite un parquet por etapa
#            en 40_salidas/intermedios/.
# Insumos  : 20_insumos/demre/{inscripcion,rendicion_resultados,
#            postulacion_seleccion}/<AAAA>/*.csv ; 20_insumos/egresados_em/<AAAA>/*.csv
# Salidas  : 40_salidas/intermedios/paes_{egresados,inscripcion,
#            rendicion_resultados,postulacion_seleccion,matricula}.parquet
# Fecha    : 2026-07-01
# -----------------------------------------------------------------------------
# Diseno aprobado (Fase B) en:
#   50_documentacion/activa/decisiones/20260701_decision_schema_31_leer_normalizar.md
# Resoluciones del titular:
#   1. SITUACION_POSTULANTE[_BEA|_PACE] y flags BEA/PACE de ArchivoD 2023 se
#      PRESERVAN como atributos "solo_2023" (NA en 2024+, no comparables).
#   2. ArchivoC se normaliza LONG: id_aux, prueba, tipo_rendicion (REG/INV),
#      vigencia (ACTUAL/ANTERIOR), puntaje + convocatoria_archivo (derivada del
#      NOMBRE del archivo: sufijo _reg/_inv de 2026; REGULAR por defecto en
#      2023-2025). Postulantes repetidos entre archivos _reg/_inv 2026 se
#      APILAN sin fusion automatica (no hay regla de precedencia confirmada).
# Reglas heredadas del traspaso v01 (POLITICA_PROYECTO.md):
#   - Columnas siempre por nombre, nunca por posicion.
#   - Sentinela 0 = no rindio / preferencia no utilizada -> se descarta al
#     pivotar (no se materializa como intento real).
#   - Escala PAES uniforme en las columnas *_ANTERIOR (confirmado en
#     contexto_paes.md, no es la escala PDT/PSU 150-850).
#   - Llaves (RBD, codigos territoriales, ID_aux) siempre character.
# =============================================================================

library(here)
source(here::here("10_utils", "10_utils.R"))
source(here::here("10_utils", "10_configuracion.R"))
instalar_si_falta(c("here", "fs", "readr", "janitor", "dplyr", "tidyr", "stringr", "arrow"))
library(dplyr)
library(tidyr)
library(stringr)

ruta_int <- function(f) ruta_salidas("intermedios", f)
dir.create(ruta_salidas("intermedios"), recursive = TRUE, showWarnings = FALSE)

# =============================================================================
# Helpers transversales
# =============================================================================

# Tipa como character toda llave (id_aux y cualquier columna con "rbd" o codigo
# territorial): un join con tipos mezclados falla en silencio (POLITICA 5.3.6).
tipar_llaves <- function(df) {
  patron_llave <- "^(id_aux|id|correlativo|rbd|.*rbd.*|cod_com.*|cod_reg.*|cod_prov.*)$"
  llaves <- grep(patron_llave, names(df), value = TRUE)
  for (k in llaves) df[[k]] <- as.character(df[[k]])
  df
}

# Lee un plano DEMRE (";" + decimal ",") y normaliza nombres.
leer_plano_demre <- function(ruta) {
  readr::read_delim(
    ruta, delim = ";",
    locale = readr::locale(encoding = "UTF-8", decimal_mark = ","),
    show_col_types = FALSE, progress = FALSE
  ) |> janitor::clean_names()
}

# ArchivoD (186 col wide de 2023) mezcla separador decimal coma/punto dentro
# del MISMO archivo (verificado: ~1967 celdas del bloque PACE usan "." en vez
# de ","). Con locale decimal_mark="," esas celdas se leen como NA en el read
# inicial, antes de llegar al pivot -- se pierden puntajes reales en silencio.
# Se lee ArchivoD siempre como texto (sin adivinar tipo) y se parsean los
# numericos aparte con parsear_numero_flex(), tolerante a ambas notaciones.
leer_plano_demre_texto <- function(ruta) {
  readr::read_delim(
    ruta, delim = ";",
    locale = readr::locale(encoding = "UTF-8"),
    col_types = readr::cols(.default = readr::col_character()),
    show_col_types = FALSE, progress = FALSE
  ) |> janitor::clean_names()
}

# Numerico tolerante a "," o "." como marca decimal (nunca hay miles: los
# puntajes PAES son < 1000, por lo que un "." presente siempre es decimal).
parsear_numero_flex <- function(x) suppressWarnings(as.numeric(gsub(",", ".", x, fixed = TRUE)))

# Metadatos desde el NOMBRE del archivo (nunca desde el contenido): tipo de
# archivo DEMRE, anio de proceso y convocatoria (REGULAR/INVIERNO). El sufijo
# _reg/_inv (solo 2026 en adelante) es la unica fuente de la convocatoria; años
# 2023-2025 traen un solo archivo por etapa -> se asume REGULAR (Decision 2).
parsear_nombre_archivo <- function(ruta) {
  b <- basename(ruta)
  anio <- stringr::str_match(b, "adm(20[0-9]{2})")[, 2]
  tipo <- dplyr::case_when(
    stringr::str_starts(tolower(b), "archivob_") ~ "B",
    stringr::str_starts(tolower(b), "archivoc_") ~ "C",
    stringr::str_starts(tolower(b), "archivo_matr_") ~ "MATR",
    stringr::str_starts(tolower(b), "archivod_") ~ "D",
    TRUE ~ NA_character_
  )
  convocatoria <- dplyr::case_when(
    stringr::str_detect(tolower(b), "_inv(\\.csv)?$") ~ "INVIERNO",
    stringr::str_detect(tolower(b), "_reg(\\.csv)?$") ~ "REGULAR",
    TRUE ~ "REGULAR"
  )
  tibble::tibble(ruta = ruta, archivo = b, tipo = tipo,
                 anio_proceso = as.integer(anio), convocatoria_archivo = convocatoria)
}

# Valida columnas criticas (aborta) vs opcionales-por-anio (solo informa).
validar_columnas <- function(df, criticas, opcionales = character(0), contexto) {
  faltan_criticas <- setdiff(criticas, names(df))
  if (length(faltan_criticas) > 0) {
    stop(sprintf(
      "31_leer_normalizar.R: columnas criticas faltantes en %s: %s",
      contexto, paste(faltan_criticas, collapse = ", ")
    ), call. = FALSE)
  }
  faltan_opc <- setdiff(opcionales, names(df))
  if (length(faltan_opc) > 0) {
    log_msg(sprintf(
      "%s: columnas opcionales ausentes (esperado segun anio de esta base): %s",
      contexto, paste(faltan_opc, collapse = ", ")
    ), "INFO", "31")
  }
  invisible(TRUE)
}

# Agrega como NA una columna esperada-pero-ausente-este-anio, para poder apilar
# entre anios con esquema distinto (p. ej. RINDIO_PROCESO_* solo desde 2026).
agregar_columna_si_falta <- function(df, columna, tipo = NA_real_) {
  if (!columna %in% names(df)) df[[columna]] <- tipo
  df
}

# Manifiesto de archivos DEMRE (recursivo, clasificado por nombre).
manifiesto_demre <- function() {
  raiz <- ruta_insumos("demre")
  if (!dir.exists(raiz)) return(tibble::tibble())
  archivos <- fs::dir_ls(raiz, recurse = TRUE, type = "file", glob = "*.csv", fail = FALSE)
  if (length(archivos) == 0) return(tibble::tibble())
  piezas_meta <- lapply(archivos, parsear_nombre_archivo)
  dplyr::bind_rows(piezas_meta) |> dplyr::filter(!is.na(.data$tipo))
}

# =============================================================================
# ArchivoB (Inscripcion) — 22 columnas estables los 4 anios, orden distinto.
# =============================================================================
CRITICAS_B <- c(
  "id_aux", "anyo_proceso", "rbd", "cod_ens", "anyo_egreso",
  "codigo_region", "codigo_comuna", "situacion_egreso",
  "rindio_proceso_anterior", "rindio_proceso_actual", "bea", "pace"
)

leer_archivo_b <- function(meta_b) {
  if (nrow(meta_b) == 0) return(NULL)
  piezas <- lapply(seq_len(nrow(meta_b)), function(i) {
    fila <- meta_b[i, ]
    df <- leer_plano_demre(fila$ruta)
    validar_columnas(df, CRITICAS_B, contexto = sprintf("ArchivoB %s", fila$archivo))
    df$anio_proceso <- fila$anio_proceso
    df$convocatoria_archivo <- fila$convocatoria_archivo
    df$archivo_origen <- fila$archivo
    df
  })
  dplyr::bind_rows(piezas) |> tipar_llaves()
}

# =============================================================================
# ArchivoC (Rendicion + Resultados) — pivot LONG (Decision 2).
# =============================================================================
CRITICAS_C_FIJAS <- c(
  "id_aux", "rbd", "cod_ens", "grupo_dependencia", "rama_educacional",
  "situacion_egreso", "codigo_region", "codigo_comuna",
  "promedio_notas", "porc_sup_notas", "ptje_nem", "ptje_ranking"
)
# Presentes solo desde 2024 (INV_ANTERIOR) o 2026 (RINDIO_PROCESO_*): no abortan.
OPCIONALES_C <- c(
  "mate1_inv_anterior", "mate2_inv_anterior", "mate_inv_anterior",
  "rindio_proceso_anterior", "rindio_proceso_actual"
)
# Puntajes de prueba: <prueba>_<REG|INV>_<ACTUAL|ANTERIOR>. "mate" (sin split
# M1/M2) solo aparece en INV de 2023-2024 y NO se homologa a mate1/mate2 (B.1:
# no se fabrica esa equivalencia sin fuente).
PATRON_PUNTAJE_C <- "^(clec|mate1|mate2|mate|hcsoc|cien)_(reg|inv)_(actual|anterior)$"
# MODULO_* es el modulo de Ciencias rendido (BIO/FIS/QUI/TEC), NO un puntaje:
# se pivotea aparte y se adjunta solo a las filas prueba == "cien".
PATRON_MODULO_C <- "^modulo_(reg|inv)_(actual|anterior)$"

leer_archivo_c <- function(meta_c) {
  if (nrow(meta_c) == 0) return(NULL)
  piezas <- lapply(seq_len(nrow(meta_c)), function(i) {
    fila <- meta_c[i, ]
    df <- leer_plano_demre(fila$ruta)
    validar_columnas(df, CRITICAS_C_FIJAS, OPCIONALES_C,
                      contexto = sprintf("ArchivoC %s", fila$archivo))
    if (!any(stringr::str_detect(names(df), PATRON_PUNTAJE_C))) {
      stop(sprintf(
        "31_leer_normalizar.R: %s no trae ninguna columna de puntaje reconocible (%s).",
        fila$archivo, PATRON_PUNTAJE_C
      ), call. = FALSE)
    }
    for (col in OPCIONALES_C) df <- agregar_columna_si_falta(df, col, NA_real_)

    df_puntajes <- df |>
      tidyr::pivot_longer(
        cols = matches(PATRON_PUNTAJE_C),
        names_to = c("prueba", "tipo_rendicion", "vigencia"),
        names_pattern = PATRON_PUNTAJE_C,
        values_to = "puntaje",
        values_transform = list(puntaje = as.numeric)
      ) |>
      dplyr::filter(!is.na(.data$puntaje), .data$puntaje != 0)

    df_modulos <- df |>
      dplyr::select(id_aux, matches(PATRON_MODULO_C)) |>
      tidyr::pivot_longer(
        cols = matches(PATRON_MODULO_C),
        names_to = c("tipo_rendicion", "vigencia"),
        names_pattern = PATRON_MODULO_C,
        values_to = "modulo_ciencias"
      ) |>
      dplyr::filter(!is.na(.data$modulo_ciencias), .data$modulo_ciencias != "")

    if (any(df_puntajes$prueba == "mate")) {
      log_msg(sprintf(
        "%s: MATE_INV_* sin split M1/M2 -> prueba = 'mate' (no homologable a m1/m2 sin fuente).",
        fila$archivo
      ), "WARN", "31")
    }

    df_puntajes |>
      dplyr::left_join(df_modulos, by = c("id_aux", "tipo_rendicion", "vigencia")) |>
      dplyr::mutate(
        modulo_ciencias = dplyr::if_else(.data$prueba == "cien", .data$modulo_ciencias, NA_character_),
        anio_proceso = fila$anio_proceso,
        convocatoria_archivo = fila$convocatoria_archivo,
        archivo_origen = fila$archivo
      )
  })
  dplyr::bind_rows(piezas) |> tipar_llaves()
}

# =============================================================================
# ArchivoD (Postulacion y Seleccion) — dos formas: wide 2023 (186 col) vs
# long 2024+ (6 col). Se unifican al esquema long (Decision 1).
# =============================================================================
CRITICAS_D_LONG <- c("id_aux", "orden_pref", "cod_carrera_pref", "estado_pref", "tipo_pref", "ptje_pref")
CRITICAS_D_WIDE_2023 <- c(
  "id_aux", "situacion_postulante", "cod_carrera_pref_01", "estado_pref_01",
  "ptje_pref_01", "bea", "pace"
)
PATRON_PREF_WIDE <- "^(cod_carrera_pref|estado_pref|ptje_pref)_([0-9]{2})(_bea|_pace)?$"

es_forma_wide_2023 <- function(df) "cod_carrera_pref_01" %in% names(df) && !"orden_pref" %in% names(df)

leer_archivod_wide_2023 <- function(df, fila) {
  validar_columnas(df, CRITICAS_D_WIDE_2023, contexto = sprintf("ArchivoD %s", fila$archivo))

  df_prefs <- df |>
    dplyr::select(id_aux, matches(PATRON_PREF_WIDE)) |>
    tidyr::pivot_longer(
      cols = matches(PATRON_PREF_WIDE),
      names_to = c("variable", "orden_pref", "via_suffix"),
      names_pattern = PATRON_PREF_WIDE,
      values_transform = list(value = as.character)
    ) |>
    tidyr::pivot_wider(names_from = "variable", values_from = "value") |>
    dplyr::mutate(
      orden_pref = as.integer(.data$orden_pref),
      cod_carrera_pref = parsear_numero_flex(.data$cod_carrera_pref),
      estado_pref = parsear_numero_flex(.data$estado_pref),
      ptje_pref = parsear_numero_flex(.data$ptje_pref),
      tipo_pref = dplyr::case_when(
        .data$via_suffix == "_bea" ~ "BEA",
        .data$via_suffix == "_pace" ~ "PACE",
        TRUE ~ "REGULAR"
      )
    ) |>
    # Sentinela: preferencia no utilizada (codigo 0 en Anexo "Estado Preferencia").
    dplyr::filter(!(.data$cod_carrera_pref == 0 & .data$estado_pref == 0))

  # Atributos "solo_2023" (resolucion titular 1): per-postulante x via, NO por
  # preferencia. Se preservan, marcados NA para 2024+ al bindear mas abajo.
  df_atributos <- df |>
    dplyr::select(
      id_aux,
      situacion_postulante_REGULAR = situacion_postulante,
      situacion_postulante_BEA = situacion_postulante_bea,
      situacion_postulante_PACE = situacion_postulante_pace,
      beneficiario_bea_solo2023 = bea,
      beneficiario_pace_solo2023 = pace
    )

  df_prefs |>
    dplyr::left_join(df_atributos, by = "id_aux") |>
    dplyr::mutate(
      situacion_postulante_solo2023 = dplyr::case_when(
        .data$tipo_pref == "REGULAR" ~ .data$situacion_postulante_REGULAR,
        .data$tipo_pref == "BEA" ~ .data$situacion_postulante_BEA,
        .data$tipo_pref == "PACE" ~ .data$situacion_postulante_PACE,
        TRUE ~ NA_character_
      )
    ) |>
    dplyr::select(
      id_aux, orden_pref, tipo_pref, cod_carrera_pref, estado_pref, ptje_pref,
      situacion_postulante_solo2023, beneficiario_bea_solo2023, beneficiario_pace_solo2023
    )
}

leer_archivod_long_2024mas <- function(df, fila) {
  validar_columnas(df, CRITICAS_D_LONG, contexto = sprintf("ArchivoD %s", fila$archivo))
  df |>
    dplyr::transmute(
      id_aux, orden_pref = as.integer(.data$orden_pref),
      tipo_pref = .data$tipo_pref,
      cod_carrera_pref = parsear_numero_flex(.data$cod_carrera_pref),
      estado_pref = parsear_numero_flex(.data$estado_pref),
      ptje_pref = parsear_numero_flex(.data$ptje_pref),
      situacion_postulante_solo2023 = NA_character_,
      beneficiario_bea_solo2023 = NA_character_,
      beneficiario_pace_solo2023 = NA_character_
    )
}

leer_archivo_d <- function(meta_d) {
  if (nrow(meta_d) == 0) return(NULL)
  piezas <- lapply(seq_len(nrow(meta_d)), function(i) {
    fila <- meta_d[i, ]
    df_raw <- leer_plano_demre_texto(fila$ruta)
    df_norm <- if (es_forma_wide_2023(df_raw)) {
      leer_archivod_wide_2023(df_raw, fila)
    } else {
      leer_archivod_long_2024mas(df_raw, fila)
    }
    df_norm$anio_proceso <- fila$anio_proceso
    df_norm$convocatoria_archivo <- fila$convocatoria_archivo
    df_norm$archivo_origen <- fila$archivo
    df_norm
  })
  dplyr::bind_rows(piezas) |> tipar_llaves()
}

# =============================================================================
# ArchivoMatr (Matricula universitaria) — esquema estable 2023-2026.
# =============================================================================
CRITICAS_MATR <- c("id_aux", "codigo_univ", "codigo", "via", "preferencia", "ptje_pond", "tipo_matricula")

leer_archivo_matr <- function(meta_matr) {
  if (nrow(meta_matr) == 0) return(NULL)
  piezas <- lapply(seq_len(nrow(meta_matr)), function(i) {
    fila <- meta_matr[i, ]
    df <- leer_plano_demre(fila$ruta)
    validar_columnas(df, CRITICAS_MATR, contexto = sprintf("ArchivoMatr %s", fila$archivo))
    df$anio_proceso <- fila$anio_proceso
    df$convocatoria_archivo <- fila$convocatoria_archivo
    df$archivo_origen <- fila$archivo
    df
  })
  dplyr::bind_rows(piezas) |> tipar_llaves()
}

# =============================================================================
# Egresados EM (denominador de cobertura) — comma-delimited, fuera de demre/.
# =============================================================================
CRITICAS_EGRESADOS <- c("agno", "rbd", "mrun", "cod_ense", "marca_egreso")

leer_egresados <- function() {
  carpeta_raiz <- ruta_insumos("egresados_em")
  if (!dir.exists(carpeta_raiz)) return(NULL)
  archivos <- fs::dir_ls(carpeta_raiz, recurse = TRUE, type = "file", glob = "*.csv", fail = FALSE)
  if (length(archivos) == 0) return(NULL)
  piezas <- lapply(archivos, function(ruta) {
    df <- readr::read_delim(
      ruta, delim = ",",
      locale = readr::locale(encoding = "UTF-8", decimal_mark = "."),
      show_col_types = FALSE, progress = FALSE
    ) |> janitor::clean_names()
    validar_columnas(df, CRITICAS_EGRESADOS, contexto = sprintf("Egresados EM %s", basename(ruta)))
    df$archivo_origen <- basename(ruta)
    df
  })
  dplyr::bind_rows(piezas) |> tipar_llaves()
}

# =============================================================================
# Flujo principal
# =============================================================================
manifiesto <- manifiesto_demre()
resumen <- list()

escribir_si_no_es_null <- function(df, nombre_salida, etiqueta) {
  if (is.null(df) || nrow(df) == 0) {
    log_msg(sprintf("STUB: etapa '%s' sin bases -> se omite (deposita las bases y re-corre).", etiqueta),
            "WARN", "31")
    return(invisible(NULL))
  }
  arrow::write_parquet(df, ruta_int(nombre_salida))
  log_msg(sprintf("OK: %s (%d filas, %d cols).", nombre_salida, nrow(df), ncol(df)), "INFO", "31")
  resumen[[etiqueta]] <<- nrow(df)
}

if (nrow(manifiesto) == 0) {
  log_msg("STUB: sin bases DEMRE depositadas en 20_insumos/demre -> se omiten ArchivoB/C/D/Matr.", "WARN", "31")
} else {
  log_msg(sprintf("Manifiesto DEMRE: %d archivo(s) reconocido(s) (B/C/D/MATR).", nrow(manifiesto)), "INFO", "31")
  escribir_si_no_es_null(leer_archivo_b(dplyr::filter(manifiesto, tipo == "B")), "paes_inscripcion.parquet", "inscripcion")
  escribir_si_no_es_null(leer_archivo_c(dplyr::filter(manifiesto, tipo == "C")), "paes_rendicion_resultados.parquet", "rendicion_resultados")
  escribir_si_no_es_null(leer_archivo_d(dplyr::filter(manifiesto, tipo == "D")), "paes_postulacion_seleccion.parquet", "postulacion_seleccion")
  escribir_si_no_es_null(leer_archivo_matr(dplyr::filter(manifiesto, tipo == "MATR")), "paes_matricula.parquet", "matricula")
}
escribir_si_no_es_null(leer_egresados(), "paes_egresados.parquet", "egresados")

if (length(resumen) == 0) {
  message("\n31_leer_normalizar.R: STUB — ninguna base depositada aun; nada que normalizar.")
} else {
  message("\n31_leer_normalizar.R: OK. Etapas normalizadas: ", paste(names(resumen), collapse = ", "))
}
