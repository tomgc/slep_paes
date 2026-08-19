# ============================================================================
# 10_validar_portabilidad.R
# Verificador permanente de portabilidad cross-OS (macOS / Windows).
# Plantilla canónica: herramientas_dev. Copiar idéntico a cada proyecto en
# 10_utils/; nunca editar por proyecto (mismo régimen que 10_resolver_rutas.R).
# Contrato: protocolo_portabilidad_cross_os.md §10-§11.
# Dependencias: R base + here (bootstrapping-safe: sin library()).
# Uso:
#   source(here::here("10_utils", "10_validar_portabilidad.R"))
#   resultado <- validar_portabilidad()
#   validar_portabilidad_autotest()
# ============================================================================

# --- Configuración interna --------------------------------------------------

.vp_extensiones <- "\\.(R|r|Rmd|rmd|qmd|ya?ml)$"

.vp_exclusiones_dir <- c(
  "_archivo", "renv", "node_modules", "packrat", "venv",
  file.path("50_documentacion", "andamios"),
  ".git", ".Rproj.user", ".quarto"
)

.vp_marcador_excepcion <- "# portabilidad: excepcion"

# Marcadores de hueco a rellenar. Una linea que los trae no contiene el valor
# literal de una maquina (protocolo §3) sino la plantilla de configuracion que
# el propio protocolo §6.2 obliga a documentar: "C:/Users/<usuario>/..." es
# instruccion de setup, no una ruta ejecutable. Cubre tambien las clases de
# caracteres de un regex, propias de los scripts detectores.
.vp_placeholder <- paste0(
  "<[A-Za-z_ ]{2,20}>",        # <usuario>, <user>, <tenant>, <nombre>
  "|\\$\\{[A-Za-z_]+\\}",      # ${VAR}
  "|%[A-Za-z_]+%",             # %USERPROFILE%
  "|\\[\\^",                   # clase negada de un regex
  "|/ruta/a/"                  # marcador generico en castellano
)

# Patrones estáticos. Algunos regex se componen por partes para que este
# propio archivo no contenga literales prohibidos completos.
.vp_patrones <- function() {
  # El segmento de usuario debe ser un nombre concreto: "/Users/" seguido de
  # ")" o de "<" no es una ruta de maquina, es prosa o plantilla.
  u_mac <- paste0("/", "Users", "/[A-Za-z0-9._-]")
  u_win <- paste0("[A-Za-z]:[/\\\\]+", "Users", "[/\\\\]+[A-Za-z0-9._-]")
  list(
    list(id = "ruta_usuario_macos",  severidad = "critica",
         regex = u_mac,
         descripcion = "Ruta de usuario macOS hardcodeada"),
    list(id = "ruta_usuario_windows", severidad = "critica",
         regex = u_win,
         descripcion = "Ruta de usuario Windows hardcodeada"),
    list(id = "letra_unidad", severidad = "critica",
         regex = "[\"'][A-Za-z]:[/\\\\]",
         descripcion = "Ruta con letra de unidad hardcodeada"),
    list(id = "volumes_macos", severidad = "critica",
         regex = paste0("/", "Volumes", "/"),
         descripcion = "Ruta /Volumes/ (disco macOS) hardcodeada"),
    # Detecta la RUTA de OneDrive, no la palabra: el nombre aparece de forma
    # legitima en comentarios y mensajes de ayuda ("el data root es OneDrive
    # compartido"). Se exige separador de ruta inmediatamente antes, o el
    # patron institucional "OneDrive - <tenant>/" seguido de separador.
    list(id = "onedrive_literal", severidad = "critica",
         regex = paste0("[/\\\\]One", "Drive",
                        "|One", "Drive\\s*-\\s*[^\"']{1,40}[/\\\\]"),
         descripcion = "Ruta literal de OneDrive en codigo versionado"),
    list(id = "home_como_raiz", severidad = "critica",
         regex = "Sys\\.getenv\\(\\s*[\"']HOME[\"']",
         descripcion = "HOME usado como raiz (redirigible en Windows)"),
    # "~$" es el prefijo de los archivos de bloqueo de Excel (~$libro.xlsx),
    # no una raiz redirigible: se excluye para no confundir el filtro de locks
    # con una ruta que arranca en HOME.
    list(id = "tilde_como_raiz", severidad = "critica",
         regex = "[\"']~(?![\\\\]*\\$)[/\\\\]",
         descripcion = "Ruta iniciada en ~ (HOME redirigible)"),
    # Nombrar setwd() en un comentario no es llamarlo: la prosa que explica
    # por que NO se usa quedaba marcada como violacion. Si el comentario trae
    # ademas una ruta de maquina, la detectan los patrones de ruta.
    list(id = "setwd", severidad = "critica",
         regex = "^(?![ \\t]*#)(?:[^#\"']|\"[^\"]*\"|'[^']*')*\\bsetwd\\s*\\(",
         descripcion = "setwd() prohibido; usar here::here()"),
    list(id = "nbsp", severidad = "critica",
         regex = "\u00A0",
         descripcion = "Caracter NBSP (U+00A0) en archivo versionado"),
    list(id = "separador_manual", severidad = "advertencia",
         regex = "paste0?\\s*\\([^)]*[\"'][/\\\\]",
         descripcion = "Posible separador de ruta construido a mano; preferir file.path()"),
    list(id = "system_shell", severidad = "advertencia",
         regex = "\\b(system2?|shell)\\s*\\(",
         descripcion = "Llamada a shell; verificar equivalente en R o declarar en matriz de requisitos"),
    list(id = "getwd", severidad = "advertencia",
         regex = "\\bgetwd\\s*\\(",
         descripcion = "getwd() detectado; no usar como raiz de proyecto")
  )
}

# --- Utilidades internas ----------------------------------------------------

.vp_raiz <- function() {
  tryCatch(here::here(), error = function(e) normalizePath(getwd()))
}

.vp_listar_archivos <- function(raiz) {
  archivos <- list.files(raiz, pattern = .vp_extensiones,
                         recursive = TRUE, full.names = FALSE)
  excluir <- vapply(archivos, function(a) {
    partes <- strsplit(a, "[/\\\\]")[[1]]
    any(partes %in% basename(.vp_exclusiones_dir)) ||
      any(vapply(.vp_exclusiones_dir, function(d) {
        startsWith(a, paste0(gsub("\\\\", "/", d), "/"))
      }, logical(1)))
  }, logical(1))
  propio <- basename(archivos) == "10_validar_portabilidad.R"
  archivos[!excluir & !propio]
}

.vp_escanear_archivo <- function(raiz, archivo, patrones) {
  ruta <- file.path(raiz, archivo)
  lineas <- tryCatch(readLines(ruta, warn = FALSE, encoding = "UTF-8"),
                     error = function(e) character(0))
  hallazgos <- list()
  excepciones <- list()
  for (i in seq_along(lineas)) {
    linea <- lineas[[i]]
    es_excepcion <- grepl(.vp_marcador_excepcion, linea, fixed = TRUE)
    # Plantilla de configuracion (§6.2), no ruta de maquina: se audita aparte.
    es_plantilla <- grepl(.vp_placeholder, linea, perl = TRUE)
    for (p in patrones) {
      if (grepl(p$regex, linea, perl = TRUE, useBytes = FALSE)) {
        registro <- data.frame(
          archivo = archivo, linea = i, id = p$id,
          severidad = p$severidad, descripcion = p$descripcion,
          stringsAsFactors = FALSE
        )
        if (es_excepcion || (es_plantilla && p$severidad == "critica")) {
          excepciones[[length(excepciones) + 1L]] <- registro
        } else {
          hallazgos[[length(hallazgos) + 1L]] <- registro
        }
      }
    }
  }
  list(hallazgos = hallazgos, excepciones = excepciones)
}

.vp_check <- function(nombre, ok, detalle = "", critico = TRUE) {
  data.frame(
    check = nombre,
    estado = if (isTRUE(ok)) "OK" else if (critico) "FALLA" else "ADVERTENCIA",
    detalle = detalle,
    stringsAsFactors = FALSE
  )
}

# --- Nivel de entorno -------------------------------------------------------

.vp_validar_entorno <- function(raiz) {
  checks <- list()

  ancla <- length(list.files(raiz, pattern = "\\.Rproj$")) > 0 ||
    file.exists(file.path(raiz, ".here"))
  checks[[length(checks) + 1L]] <- .vp_check(
    "ancla_here", ancla,
    "Se requiere un .Rproj versionado (o .here) para que here::here() resuelva")

  utf8 <- isTRUE(l10n_info()[["UTF-8"]])
  checks[[length(checks) + 1L]] <- .vp_check(
    "locale_utf8", utf8,
    "Locale sin UTF-8; ejecutar la guarda asegurar_locale_utf8() (POLITICA 5.2bis)")

  checks[[length(checks) + 1L]] <- .vp_check(
    "renv_lock", file.exists(file.path(raiz, "renv.lock")),
    "renv.lock ausente; renv es obligatorio en toda la cartera")

  gitignore_ruta <- file.path(raiz, ".gitignore")
  gitignore <- if (file.exists(gitignore_ruta)) {
    readLines(gitignore_ruta, warn = FALSE)
  } else character(0)
  checks[[length(checks) + 1L]] <- .vp_check(
    "renviron_en_gitignore", any(trimws(gitignore) == ".Renviron"),
    ".gitignore no bloquea .Renviron")
  checks[[length(checks) + 1L]] <- .vp_check(
    "renviron_no_en_repo", !file.exists(file.path(raiz, ".Renviron")),
    ".Renviron presente en la raiz del repo; debe vivir en ~/.Renviron",
    critico = FALSE)
  checks[[length(checks) + 1L]] <- .vp_check(
    "renviron_example", file.exists(file.path(raiz, ".Renviron.example")),
    ".Renviron.example ausente en la raiz del repo")

  config <- file.path(raiz, "10_utils", "10_configuracion.R")
  if (file.exists(config)) {
    data_root <- tryCatch({
      env <- new.env()
      sys.source(config, envir = env)
      if (exists("obtener_data_root_proyecto", envir = env)) {
        get("obtener_data_root_proyecto", envir = env)()
      } else NA_character_
    }, error = function(e) NA_character_)
    resuelto <- !is.na(data_root) && nzchar(data_root) && dir.exists(data_root)
    checks[[length(checks) + 1L]] <- .vp_check(
      "data_root_resuelto", resuelto,
      "Data root no resuelto o inaccesible; declarar <PROYECTO>_DATA_ROOT o WORKSPACE_DATA_ROOT en ~/.Renviron")
    if (resuelto) {
      salidas <- file.path(data_root, "40_salidas")
      escribible <- dir.exists(salidas) &&
        file.access(salidas, mode = 2) == 0
      checks[[length(checks) + 1L]] <- .vp_check(
        "salidas_escribibles", escribible,
        "40_salidas/ del data root inexistente o sin permiso de escritura",
        critico = FALSE)
    }
  } else {
    checks[[length(checks) + 1L]] <- .vp_check(
      "configuracion_presente", FALSE,
      "10_utils/10_configuracion.R ausente", critico = FALSE)
  }

  do.call(rbind, checks)
}

# --- API pública ------------------------------------------------------------

validar_portabilidad <- function(detener_si_falla = !interactive()) {
  raiz <- .vp_raiz()
  patrones <- .vp_patrones()
  archivos <- .vp_listar_archivos(raiz)

  hallazgos <- list()
  excepciones <- list()
  for (a in archivos) {
    res <- .vp_escanear_archivo(raiz, a, patrones)
    hallazgos <- c(hallazgos, res$hallazgos)
    excepciones <- c(excepciones, res$excepciones)
  }
  estatico <- if (length(hallazgos)) do.call(rbind, hallazgos) else
    data.frame(archivo = character(0), linea = integer(0), id = character(0),
               severidad = character(0), descripcion = character(0))
  excepciones_df <- if (length(excepciones)) do.call(rbind, excepciones) else NULL

  entorno <- .vp_validar_entorno(raiz)

  n_criticas <- sum(estatico$severidad == "critica") +
    sum(entorno$estado == "FALLA")
  n_advertencias <- sum(estatico$severidad == "advertencia") +
    sum(entorno$estado == "ADVERTENCIA")

  cat("== Validacion de portabilidad ==\n")
  cat("Raiz:", raiz, "\n")
  cat("Archivos escaneados:", length(archivos), "\n")
  cat("Fallas criticas:", n_criticas, "| Advertencias:", n_advertencias, "\n")
  if (nrow(estatico)) {
    cat("\n-- Hallazgos estaticos --\n")
    print(estatico, row.names = FALSE)
  }
  cat("\n-- Checks de entorno --\n")
  print(entorno, row.names = FALSE)
  if (!is.null(excepciones_df)) {
    cat("\n-- Excepciones declaradas (auditar justificacion) --\n")
    print(excepciones_df, row.names = FALSE)
  }

  resultado <- list(
    raiz = raiz,
    archivos_escaneados = length(archivos),
    estatico = estatico,
    entorno = entorno,
    excepciones = excepciones_df,
    criticas = n_criticas,
    advertencias = n_advertencias,
    ok = n_criticas == 0
  )

  if (detener_si_falla && n_criticas > 0) {
    stop("Validacion de portabilidad fallida: ", n_criticas,
         " falla(s) critica(s). Revisar el reporte anterior.", call. = FALSE)
  }
  invisible(resultado)
}

# Sabotaje positivo: siembra una violacion, comprueba deteccion, limpia y
# comprueba que el proyecto vuelve a quedar limpio de esa violacion.
validar_portabilidad_autotest <- function() {
  raiz <- .vp_raiz()
  sabotaje <- file.path(raiz, "zz_autotest_sabotaje_portabilidad.R")
  on.exit(if (file.exists(sabotaje)) file.remove(sabotaje), add = TRUE)

  linea_prohibida <- paste0(
    "ruta <- \"", "C:/", "Users", "/persona/", "One", "Drive - Tenant/x.csv\"")
  writeLines(c("# archivo temporal de autotest; se elimina solo", linea_prohibida),
             sabotaje)

  con_sabotaje <- validar_portabilidad(detener_si_falla = FALSE)
  detectado <- any(con_sabotaje$estatico$archivo ==
                     "zz_autotest_sabotaje_portabilidad.R")

  file.remove(sabotaje)
  sin_sabotaje <- validar_portabilidad(detener_si_falla = FALSE)
  limpio <- !any(sin_sabotaje$estatico$archivo ==
                   "zz_autotest_sabotaje_portabilidad.R")

  cat("\n== Autotest de sabotaje positivo ==\n")
  cat("Violacion sembrada detectada:", if (detectado) "SI" else "NO", "\n")
  cat("Limpieza verificada:", if (limpio) "SI" else "NO", "\n")

  if (!detectado || !limpio) {
    stop("Autotest fallido: el verificador no cumple su contrato.",
         call. = FALSE)
  }
  invisible(TRUE)
}
