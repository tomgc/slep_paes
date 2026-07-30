# Locale UTF-8 garantizada (encargo v108 de slep_aprendizajes_ep)

**Qué se instaló.**

- `10_utils/10_locale.R`: guarda `asegurar_locale_utf8()`, copia idéntica de
  `herramientas_dev/plantillas/10_locale.R` (política §6.2: no se edita por
  proyecto; si necesita algo distinto, se corrige en la fuente).
- Llamada a `asegurar_locale_utf8("10_configuracion")` en la primera línea
  ejecutable de `10_utils/10_configuracion.R`, antes de todo lo demás.
- Línea `LANG=es_ES.UTF-8` en `.Renviron.example` (documental: R no lee ese
  archivo; el arreglo de cada máquina es copiarla a `~/.Renviron`).
- Si el repo tiene workflows de CI que ejecutan R: `env: LANG: C.UTF-8` a
  nivel de job (el default de los runners es POSIX).

**Por qué.** Un proceso de R lanzado desde un shell sin locale (LC_CTYPE en C:
cron, CI, shells no interactivos) escribe TODO el texto acentuado escapado
byte a byte, sin emitir error alguno. Evidencia: sesión v108 de
slep_aprendizajes_ep, 4 xlsx del gemelo sintético con 5.665 escapes y cero
tildes válidas. La guarda corrige una vez con aviso o aborta con el remedio;
queda prohibido envolver `Sys.setlocale()` en `try(..., silent = TRUE)` o
`suppressWarnings()` (una configuración que falla en silencio es exactamente
lo que produjo la corrupción).

**Cómo se verifica.**

- Rama de corrección (desde la raíz del repo):
  `LC_ALL=C Rscript -e 'source(here::here("10_utils", "10_configuracion.R")); cat(l10n_info()[["UTF-8"]])'`
  → `TRUE`, con un `message()` que declara la corrección y desde qué valor.
- Rama de aborto: en un sondeo aparte (sin editar el helper), sustituir
  `LOCALES_UTF8_CANDIDATAS` por una locale inexistente y llamar la guarda →
  `stop()` con exit distinto de cero.
- Verificador de referencia con las tres ramas y sabotaje probado:
  `30_procesamiento/31b_verificar_locale.R` de slep_aprendizajes_ep (PR #111).

Este archivo apaga el gatillo de apertura del pendiente de locale
(SETTINGS_Y_PROMPTS_OPERACIONALES §1.2.2).
