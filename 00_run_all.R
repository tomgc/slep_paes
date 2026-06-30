# 00_run_all.R
# ----------------------------------------------------------------------------
# Orquestador del pipeline slep_paes (punto de entrada unico).
#
# Ejecuta en orden los pasos de 30_procesamiento/:
#   30. 30_construir_auxiliares.R  catalogos territoriales y de establecimientos
#                                  (directorio oficial reusado: RBD -> comuna ->
#                                  SLEP -> region -> nacional).
#   31. 31_leer_normalizar.R       lee las bases por etapa (inscripcion, rendicion,
#                                  resultados, postulacion, seleccion) y la
#                                  caracterizacion de egresados; normaliza y tipa.
#   32. 32_agregar_territorial.R   agrega RBD -> comuna -> nacional para los DOS
#                                  focos: cobertura (embudo vs. denominador de
#                                  egresados) y rendimiento (puntajes por prueba).
#   33. 33_generar_html.R          motor HTML autocontenido (producto final).
#
# Solo orquesta: cero logica de negocio, no modifica scripts de estacion,
# sin cache automatico por timestamp (saltar pasos es decision explicita).
#
# Los ids de paso coinciden con el prefijo del script, de modo que el numero
# del archivo es el numero del paso (run_all(only = 33) regenera el HTML).
#
# NOTA (sesion 1, scaffold): los scripts de 30_procesamiento/ aun no existen.
# run_all() valida en tiempo de ejecucion que pasos existen en disco y avisa
# de los ausentes sin abortar. Se construyen como stubs en el paso 4 del plan,
# y con contenido real cuando el titular deposite las bases del DEMRE.
#
# Uso:
#   source(here::here("00_run_all.R"))
#   run_all()                   # todos los pasos disponibles
#   run_all(skip = c(30, 31))   # omite auxiliares y normalizacion
#   run_all(from = 32)          # desde el paso 32 en adelante
#   run_all(only = 33)          # solo el motor HTML
# ----------------------------------------------------------------------------

# ---- Anclaje de raiz (criterios .Rproj / .git / .here) ---------------------
raiz <- rprojroot::find_root(
  rprojroot::has_file(".here") |
    rprojroot::is_rstudio_project |
    rprojroot::is_git_root
)

# ---- Bootstrapping: utils antes de cualquier library() ---------------------
source(file.path(raiz, "10_utils", "10_utils.R"))

# ---- Precondiciones: paquetes del pipeline ---------------------------------
instalar_si_falta(c(
  "here", "fs", "readr", "readxl", "janitor",
  "dplyr", "tidyr", "purrr", "tibble", "stringr", "arrow"
))


# ============================================================================
# Definicion de pasos
# ============================================================================
# Cada paso: id (entero, coincide con el prefijo del script), etiqueta
# (descriptiva), ruta (relativa a la raiz). La presencia de cada script se
# valida en tiempo de ejecucion, no al definir PASOS (en scaffold no existen).

PASOS <- list(
  list(id = 30L, etiqueta = "Construir auxiliares (catalogos territoriales reusados)",
       ruta = file.path("30_procesamiento", "30_construir_auxiliares.R")),
  list(id = 31L, etiqueta = "Leer y normalizar bases por etapa + egresados",
       ruta = file.path("30_procesamiento", "31_leer_normalizar.R")),
  list(id = 32L, etiqueta = "Agregar territorial (cobertura y rendimiento)",
       ruta = file.path("30_procesamiento", "32_agregar_territorial.R")),
  list(id = 33L, etiqueta = "Generar motor HTML autocontenido (doble foco)",
       ruta = file.path("30_procesamiento", "33_generar_html.R"))
)


# ============================================================================
# run_all()
# ============================================================================

#' Ejecutar el pipeline completo o un subconjunto de pasos.
#'
#' Los pasos se identifican por su numero de prefijo (30, 31, 32, 33).
#'
#' @param from Integer. Primer paso a ejecutar (default: el menor disponible).
#' @param to Integer. Ultimo paso a ejecutar (default: el mayor disponible).
#' @param only Integer vector. Ejecutar exactamente estos pasos (ignora from/to).
#' @param skip Integer vector. Pasos a omitir.
#' @return Invisible NULL. Emite log de progreso y resumen final.
run_all <- function(from = NULL, to = NULL, only = NULL, skip = NULL) {

  ids_def <- vapply(PASOS, function(p) p$id, integer(1))

  # ---- Resolver que pasos existen en disco --------------------------------
  ids_existentes <- ids_def[vapply(PASOS, function(p) {
    file.exists(file.path(raiz, p$ruta))
  }, logical(1))]

  ids_ausentes <- setdiff(ids_def, ids_existentes)
  if (length(ids_ausentes) > 0) {
    for (id in ids_ausentes) {
      p <- PASOS[[which(ids_def == id)]]
      log_msg(sprintf("Paso %d ausente (aun no construido): %s",
                      id, p$ruta), "WARN", "run_all")
    }
  }

  # ---- Seleccionar pasos a correr -----------------------------------------
  if (!is.null(only)) {
    seleccion <- intersect(ids_existentes, only)
  } else {
    lo <- if (is.null(from)) min(ids_existentes) else from
    hi <- if (is.null(to))   max(ids_existentes) else to
    seleccion <- ids_existentes[ids_existentes >= lo & ids_existentes <= hi]
  }
  if (!is.null(skip)) {
    seleccion <- setdiff(seleccion, skip)
  }
  seleccion <- sort(seleccion)

  if (length(seleccion) == 0) {
    log_msg("Ningun paso seleccionado para ejecutar.", "WARN", "run_all")
    return(invisible(NULL))
  }

  # ---- Ejecucion paso a paso ----------------------------------------------
  t0_total <- proc.time()
  ejecutados <- integer(0)
  duraciones <- numeric(0)

  for (id in seleccion) {
    p <- PASOS[[which(ids_def == id)]]
    ruta_abs <- file.path(raiz, p$ruta)

    message("")
    message(strrep("=", 70))
    log_msg(sprintf("PASO %d — %s", p$id, p$etiqueta), "INFO", "run_all")
    log_msg(sprintf("Ruta: %s", p$ruta), "INFO", "run_all")
    message(strrep("=", 70))

    t0 <- proc.time()
    ok <- tryCatch({
      source(ruta_abs, echo = FALSE, chdir = TRUE)
      TRUE
    }, error = function(e) {
      log_msg(sprintf("FALLO en paso %d: %s", p$id, conditionMessage(e)),
              "ERROR", "run_all")
      FALSE
    })
    dt <- round((proc.time() - t0)[["elapsed"]], 1)

    if (!ok) {
      stop(sprintf("Pipeline detenido en el paso %d (%s).", p$id, p$etiqueta),
           call. = FALSE)
    }

    log_msg(sprintf("Paso %d OK en %.1f s.", p$id, dt), "INFO", "run_all")
    ejecutados <- c(ejecutados, id)
    duraciones <- c(duraciones, dt)
  }

  # ---- Resumen ------------------------------------------------------------
  dt_total <- round((proc.time() - t0_total)[["elapsed"]], 1)
  saltados <- setdiff(ids_existentes, ejecutados)

  message("")
  message(strrep("=", 70))
  log_msg("RESUMEN", "INFO", "run_all")
  log_msg(sprintf("Ejecutados: %s", paste(ejecutados, collapse = ", ")),
          "INFO", "run_all")
  if (length(saltados) > 0) {
    log_msg(sprintf("Saltados (disponibles, no corridos): %s",
                    paste(saltados, collapse = ", ")), "INFO", "run_all")
  }
  if (length(ids_ausentes) > 0) {
    log_msg(sprintf("Ausentes (sin construir): %s",
                    paste(ids_ausentes, collapse = ", ")), "INFO", "run_all")
  }
  log_msg(sprintf("Duracion total: %.1f s.", dt_total), "INFO", "run_all")
  message(strrep("=", 70))

  invisible(NULL)
}


#' Regenerar solo el motor HTML (atajo de conveniencia).
#'
#' Equivale a run_all(only = 33). Util durante la iteracion sobre el template,
#' cuando los parquets de las etapas previas ya estan construidos y solo cambia
#' 33_motor_template.html o 33_generar_html.R. No reemplaza a run_all(): el
#' pipeline reproducible de cero sigue siendo run_all().
#'
#' @return Invisible NULL. Emite log de progreso y resumen final.
regenerar_motor <- function() {
  run_all(only = 33L)
}


# ============================================================================
# Ejemplos de uso (comentados)
# ============================================================================
# run_all()                   # todos los pasos disponibles, en orden
# run_all(skip = c(30, 31))   # omite auxiliares y normalizacion (reusa parquets)
# run_all(from = 32)          # desde el paso 32 (agregacion + motor)
# run_all(only = 31)          # exactamente el paso 31
# run_all(only = 33)          # solo regenera el motor HTML desde el template
# regenerar_motor()           # atajo equivalente a run_all(only = 33)
