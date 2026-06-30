# =============================================================================
# 00_escanear_proyecto.R
# -----------------------------------------------------------------------------
# Proyecto : slep_paes — Panorama nacional de la Prueba de Acceso a la
#            Educacion Superior (PAES), datos publicos del DEMRE
#            (Area de Monitoreo y Seguimiento, SLEP Costa Central).
# Autor    : Area de Monitoreo y Seguimiento (SLEP Costa Central)
# Proposito: Generar un snapshot navegable de la estructura actual del repo,
#            conforme a la seccion 7 de POLITICA_PROYECTO.md.
#            Emite un snapshot con sello de fecha (.txt y .md) y mantiene los
#            aliases estructura_actual.{txt,md} apuntando al mas reciente.
#            Poda automaticamente los snapshots antiguos (retencion configurable).
# Fecha    : 2026-06-30
# =============================================================================

# --- Verificacion e instalacion de paquetes ---------------------------------
paquetes_requeridos <- c("here", "fs")

paquetes_faltantes <- paquetes_requeridos[
  !sapply(paquetes_requeridos, requireNamespace, quietly = TRUE)
]

if (length(paquetes_faltantes) > 0) {
  install.packages(paquetes_faltantes)
}

# --- Carga de paquetes ------------------------------------------------------
library(here)
library(fs)

# --- Rutas ------------------------------------------------------------------
ruta_raiz        <- here::here()
ruta_estructura  <- here::here("50_documentacion", "estructura")

# --- Constantes y parametros ------------------------------------------------
# Excluir _archivo/ del arbol. TRUE = excluir.
EXCLUIR_ARCHIVO <- TRUE

# Retencion de snapshots con sello de fecha. Tras generar el snapshot nuevo,
# se conservan los N mas recientes (por nombre, que ordena cronologicamente) y
# se borra el resto. Los aliases estructura_actual.{txt,md} nunca se podan
# (no llevan sello). Un snapshot de estructura es una foto reemplazable; no
# tiene valor historico acumulativo como los traspasos.
RETENER_SNAPSHOTS <- 2L

DIRS_EXCLUIR <- c(".git", "renv", ".Rproj.user")
if (EXCLUIR_ARCHIVO) DIRS_EXCLUIR <- c(DIRS_EXCLUIR, "_archivo")

# Nota: en este proyecto todos los datos son publicos (bases PAES del DEMRE,
# datos abiertos) y se versionan dentro del repo. No hay data root externo.

# --- Funciones --------------------------------------------------------------

# Recolecta recursivamente todas las rutas (carpetas y archivos) bajo `dir`,
# podando los subarboles excluidos. Devuelve un vector de rutas absolutas.
recolectar_rutas <- function(dir) {
  entradas <- fs::dir_ls(dir, recurse = FALSE, all = TRUE, fail = FALSE)
  if (length(entradas) == 0) return(character(0))

  entradas <- entradas[!fs::path_file(entradas) %in% DIRS_EXCLUIR]
  if (length(entradas) == 0) return(character(0))

  subdirs <- entradas[fs::is_dir(entradas)]
  hijos <- if (length(subdirs) > 0) {
    unlist(lapply(subdirs, recolectar_rutas), use.names = FALSE)
  } else {
    character(0)
  }
  c(entradas, hijos)
}

# Dibuja el arbol estilo `tree` (conectores box-drawing) desde `dir`.
# `prefijo` acumula las guias verticales de los niveles ancestros.
construir_arbol <- function(dir, prefijo = "") {
  entradas <- fs::dir_ls(dir, recurse = FALSE, all = TRUE, fail = FALSE)
  if (length(entradas) == 0) return(character(0))

  entradas <- entradas[!fs::path_file(entradas) %in% DIRS_EXCLUIR]
  if (length(entradas) == 0) return(character(0))

  # Carpetas primero, luego archivos; alfabetico (case-insensitive) en cada grupo.
  es_dir <- fs::is_dir(entradas)
  orden  <- order(!es_dir, tolower(fs::path_file(entradas)))
  entradas <- entradas[orden]
  es_dir   <- es_dir[orden]

  n <- length(entradas)
  lineas <- character(0)

  for (i in seq_len(n)) {
    ultimo   <- i == n
    conector <- if (ultimo) "└── " else "├── "
    nombre   <- fs::path_file(entradas[i])

    if (es_dir[i]) {
      lineas <- c(lineas, paste0(prefijo, conector, nombre, "/"))
      prefijo_hijo <- paste0(prefijo, if (ultimo) "    " else "│   ")
      lineas <- c(lineas, construir_arbol(entradas[i], prefijo_hijo))
    } else {
      tam <- as.character(fs::file_size(entradas[i]))
      lineas <- c(lineas, paste0(prefijo, conector, nombre, "  (", tam, ")"))
    }
  }
  lineas
}

# Tabula archivos por extension (minuscula), orden descendente por conteo.
contar_extensiones <- function(rutas_archivos) {
  ext <- tolower(fs::path_ext(rutas_archivos))
  ext[ext == ""] <- "(sin extension)"
  tabla <- sort(table(ext), decreasing = TRUE)
  tabla
}

# Escritura atomica: escribe a un temporal en la misma carpeta y renombra.
# El rename es atomico en sistemas POSIX (macOS) y sobrescribe el destino.
escribir_atomico <- function(lineas, ruta_final) {
  dir_destino <- fs::path_dir(ruta_final)
  tmp <- fs::path(
    dir_destino,
    paste0(".tmp_", fs::path_file(ruta_final), "_", Sys.getpid())
  )
  on.exit(if (file.exists(tmp)) unlink(tmp), add = TRUE)

  con <- file(tmp, open = "wb")
  writeLines(enc2utf8(lineas), con, useBytes = TRUE)
  close(con)

  ok <- file.rename(tmp, ruta_final)
  if (!isTRUE(ok)) stop("Fallo la escritura atomica de: ", ruta_final)
  invisible(ruta_final)
}

# Poda snapshots con sello de fecha, conservando los `retener` mas recientes.
# Empareja .txt y .md por su sello; los aliases estructura_actual.* quedan
# fuera del patron (no llevan sello), asi que nunca se tocan. Devuelve el
# numero de archivos borrados.
podar_snapshots <- function(dir_estructura, retener) {
  patron <- "^[0-9]{8}_[0-9]{6}_estructura\\.(txt|md)$"
  todos  <- fs::dir_ls(dir_estructura, recurse = FALSE, fail = FALSE)
  sellados <- todos[grepl(patron, fs::path_file(todos))]
  if (length(sellados) == 0) return(0L)

  # Sello = los 15 primeros caracteres del nombre (YYYYMMDD_HHMMSS).
  sellos <- substr(fs::path_file(sellados), 1L, 15L)
  sellos_unicos <- sort(unique(sellos), decreasing = TRUE)

  if (length(sellos_unicos) <= retener) return(0L)

  sellos_a_borrar <- sellos_unicos[-seq_len(retener)]
  a_borrar <- sellados[sellos %in% sellos_a_borrar]
  fs::file_delete(a_borrar)
  length(a_borrar)
}

# --- Flujo principal --------------------------------------------------------

# Validacion temprana: la raiz debe existir (C.9).
if (!dir.exists(ruta_raiz)) {
  stop("No existe la raiz del proyecto resuelta por here::here(): ", ruta_raiz)
}

# Asegurar carpeta de salida.
if (!dir.exists(ruta_estructura)) {
  dir.create(ruta_estructura, recursive = TRUE)
}

# Inventario para totales y extensiones.
rutas_todas    <- recolectar_rutas(ruta_raiz)
es_dir_todas   <- if (length(rutas_todas) > 0) fs::is_dir(rutas_todas) else logical(0)
n_carpetas     <- sum(es_dir_todas)
n_archivos     <- sum(!es_dir_todas)
rutas_archivos <- rutas_todas[!es_dir_todas]

# Arbol y metadatos.
nombre_proyecto <- fs::path_file(ruta_raiz)
sello           <- format(Sys.time(), "%Y%m%d_%H%M%S")
fecha_legible   <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
arbol           <- c(paste0(nombre_proyecto, "/"), construir_arbol(ruta_raiz))
tabla_ext       <- contar_extensiones(rutas_archivos)
lineas_ext      <- sprintf("  %-18s %d", names(tabla_ext), as.integer(tabla_ext))

# Contenido .txt (plano, historico navegable).
contenido_txt <- c(
  paste0("ESCANEO DE ESTRUCTURA — ", nombre_proyecto),
  paste0("Raiz   : ", ruta_raiz),
  paste0("Fecha  : ", fecha_legible),
  paste0("Totales: ", n_carpetas, " carpetas, ", n_archivos, " archivos"),
  "Nota   : todos los datos son publicos (bases PAES del DEMRE) y se versionan en el repo.",
  "",
  arbol,
  "",
  "Conteo por extension:",
  lineas_ext
)

# Contenido .md (optimizado para adjuntar a sesiones de chat).
contenido_md <- c(
  paste0("# Estructura actual — ", nombre_proyecto),
  "",
  paste0("- **Raiz:** `", ruta_raiz, "`"),
  paste0("- **Fecha:** ", fecha_legible),
  paste0("- **Totales:** ", n_carpetas, " carpetas, ", n_archivos, " archivos"),
  "- **Nota:** todos los datos son publicos (bases PAES del DEMRE) y se versionan en el repo.",
  "",
  "## Arbol",
  "",
  "```",
  arbol,
  "```",
  "",
  "## Conteo por extension",
  "",
  "| Extension | Archivos |",
  "|---|---|",
  sprintf("| %s | %d |", names(tabla_ext), as.integer(tabla_ext))
)

# Escritura: snapshot con sello + aliases al mas reciente.
escribir_atomico(contenido_txt, fs::path(ruta_estructura, paste0(sello, "_estructura.txt")))
escribir_atomico(contenido_md,  fs::path(ruta_estructura, paste0(sello, "_estructura.md")))
escribir_atomico(contenido_txt, fs::path(ruta_estructura, "estructura_actual.txt"))
escribir_atomico(contenido_md,  fs::path(ruta_estructura, "estructura_actual.md"))

# Poda: conservar solo los RETENER_SNAPSHOTS sellos mas recientes (el recien
# generado entra en el conteo). Los aliases estructura_actual.* no se tocan.
n_borrados <- podar_snapshots(ruta_estructura, RETENER_SNAPSHOTS)

message("Escaneo completo: ", n_carpetas, " carpetas, ", n_archivos, " archivos.")
message("Snapshot: ", fs::path(ruta_estructura, paste0(sello, "_estructura.{txt,md}")))
message("Aliases : ", fs::path(ruta_estructura, "estructura_actual.{txt,md}"))
if (n_borrados > 0) {
  message("Poda    : ", n_borrados, " archivo(s) de snapshots antiguos eliminados (retencion: ",
          RETENER_SNAPSHOTS, " sellos).")
}
