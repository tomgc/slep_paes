# =============================================================================
# 10_utils/10_utils.R
# -----------------------------------------------------------------------------
# Proyecto : slep_paes — Panorama nacional de la Prueba de Acceso a la
#            Educacion Superior (PAES), datos publicos del DEMRE
#            (Area de Monitoreo y Seguimiento, SLEP Costa Central).
# Proposito: Utilidades transversales del proyecto. Bootstrapping previo a
#            cualquier library(): estas funciones NO dependen de paquetes
#            cargados (POLITICA_PROYECTO.md, seccion 1.4).
# Fecha    : 2026-06-30
# -----------------------------------------------------------------------------
# NOTA DE HOMOLOGACION: instalar_si_falta() y log_msg() se mantienen
# byte-compatibles con los hermanos (slep_idps, slep_categoria_desempeno,
# slep_simce_adecuado). Cualquier utilidad de agregacion territorial que se
# agregue debe homologarse contra el patron de esos proyectos antes de
# divergir.
# =============================================================================

# --- Bootstrapping: instalar paquetes faltantes ------------------------------
# Instala solo los que faltan, sin cargar nada. Usa requireNamespace para no
# depender de library(). Idempotente.
instalar_si_falta <- function(paquetes) {
  faltantes <- paquetes[
    !vapply(paquetes, requireNamespace, logical(1), quietly = TRUE)
  ]
  if (length(faltantes) > 0) {
    message("Instalando paquetes faltantes: ", paste(faltantes, collapse = ", "))
    utils::install.packages(faltantes)
  }
  invisible(NULL)
}

# --- Logging sin dependencias ------------------------------------------------
# Formato: [YYYY-MM-DD HH:MM:SS] [origen] [NIVEL] mensaje
log_msg <- function(mensaje, nivel = c("INFO", "WARN", "ERROR"), origen = "slep_paes") {
  nivel <- match.arg(nivel)
  ts <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  cat(sprintf("[%s] [%s] [%s] %s\n", ts, origen, nivel, mensaje))
  invisible(NULL)
}
