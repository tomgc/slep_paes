# =============================================================================
# 10_locale.R — Guarda de locale UTF-8 (generico, copiado desde herramientas_dev)
# =============================================================================
# Proposito : garantizar que ningun proceso de R corra con una locale de
#             caracteres no UTF-8. Un proceso lanzado desde un shell sin locale
#             (LC_CTYPE=C: cron, CI, shells no interactivos) escribe TODO texto
#             acentuado escapado como <c3><a1>, sin emitir error alguno
#             (evidencia: 4 xlsx del gemelo con 5.665 escapes y cero tildes,
#             sesion v108 de slep_aprendizajes_ep).
# Contrato  : POLITICA_PROYECTO.md 6.2 — este archivo se copia IDENTICO a
#             10_utils/10_locale.R de cada proyecto y NUNCA se edita por
#             proyecto. Si un proyecto necesita algo distinto, el helper esta
#             mal disenado y se corrige en herramientas_dev/plantillas/.
# Uso       : source(here::here("10_utils", "10_locale.R"))
#             asegurar_locale_utf8("<script que llama>")
# Diseno    : el assert ABORTA; nunca repara en silencio. Prohibido envolver
#             la llamada en try(..., silent = TRUE) o suppressWarnings():
#             una configuracion ausente tiene que producir un aborto ruidoso,
#             no una corrida que escribe tildes escapadas.
# Cero dependencias de paquetes. Solo ASCII: este archivo debe ser inmune a la
# condicion que verifica.
# =============================================================================

# Locales UTF-8 aceptables, en orden de preferencia. Pobladas con lo que existe
# realmente en las maquinas de la cartera (macOS: verificado con `locale -a` el
# 2026-07-29) y en los runners de CI (ubuntu trae C.UTF-8 siempre).
# es_CL.UTF-8 NO existe en macOS: no agregarla (ocho bootstraps del piloto la
# intentaban primero y caian al fallback en silencio).
LOCALES_UTF8_CANDIDATAS <- c("es_ES.UTF-8", "en_US.UTF-8", "C.UTF-8")

#' Asegurar que el proceso corre con locale de caracteres UTF-8
#'
#' Si la locale ya es UTF-8, no hace nada. Si no lo es, intenta UNA vez
#' corregirla recorriendo LOCALES_UTF8_CANDIDATAS; si lo logra avisa por
#' message() (una locale corregida en caliente es un sintoma de entorno mal
#' configurado, no una victoria); si no lo logra, stop() con el remedio.
#'
#' @param contexto string con el nombre del script que llama (para el mensaje).
#' @return invisible(TRUE) si la locale queda UTF-8; stop() si no se pudo.
asegurar_locale_utf8 <- function(contexto = "pipeline") {
  if (isTRUE(l10n_info()[["UTF-8"]])) return(invisible(TRUE))

  desde <- Sys.getlocale("LC_CTYPE")

  # Sin try() ni suppressWarnings() a proposito: una candidata inexistente
  # avisa por warning del propio R y se prueba la siguiente. El exito se
  # comprueba contra l10n_info(), no contra el valor de retorno: en algunos
  # sistemas Sys.setlocale() devuelve string no vacio aunque no haya quedado
  # UTF-8.
  for (candidata in LOCALES_UTF8_CANDIDATAS) {
    Sys.setlocale("LC_ALL", candidata)
    if (isTRUE(l10n_info()[["UTF-8"]])) {
      message(
        "[ locale ] ", contexto, ": locale corregida en caliente a ", candidata,
        " (el proceso arranco con ", desde, ").\n",
        "  Es un sintoma de entorno mal configurado, no una victoria: otro\n",
        "  proceso R de esta maquina puede arrancar igual y escribir texto\n",
        "  acentuado escapado. Remedio permanente: agregar la linea LANG de\n",
        "  .Renviron.example a ~/.Renviron y reiniciar R."
      )
      return(invisible(TRUE))
    }
  }

  stop(
    "[ locale ] ABORTADO en ", contexto, ": el proceso corre sin locale UTF-8 ",
    "y no se pudo corregir.\n",
    "  LC_CTYPE actual    : ", Sys.getlocale("LC_CTYPE"), "\n",
    "  Candidatas probadas: ", paste(LOCALES_UTF8_CANDIDATAS, collapse = ", "), "\n",
    "  Consecuencia: todo texto acentuado que este proceso escriba quedara\n",
    "  escapado como <c3><a1> (xlsx, json, html), sin error visible.\n",
    "  Remedio: agregar LANG (ver .Renviron.example) a ~/.Renviron y reiniciar R.",
    call. = FALSE
  )
}
