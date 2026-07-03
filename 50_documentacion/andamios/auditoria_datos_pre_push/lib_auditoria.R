# =============================================================================
# lib_auditoria.R — Biblioteca del PANEL ADVERSARIAL (auditoria de datos pre-push)
# -----------------------------------------------------------------------------
# Codigo de recalculo INDEPENDIENTE, escrito de cero para esta auditoria.
# NO reutiliza ninguna funcion de 32_agregar_territorial.R ni 33_generar_html.R:
# replica la semantica DOCUMENTADA del pipeline con implementacion propia, para
# detectar divergencias por contradiccion (dos caminos, un resultado).
# Solo LECTURA: no escribe parquets ni toca el pipeline.
# =============================================================================

suppressMessages({
  library(arrow)
  library(dplyr)
  library(jsonlite)
})

# --- Rutas absolutas (Rama B: datos fuera del repo) --------------------------
DATA_ROOT <- Sys.getenv("SLEP_PAES_DATA_ROOT")
stopifnot("SLEP_PAES_DATA_ROOT no definido" = nzchar(DATA_ROOT))
REPO_ROOT <- "/Users/tomgc/Projects/slep_paes"
ri <- function(f) file.path(DATA_ROOT, "40_salidas", "intermedios", f)

# --- Invariante 🔒 UMBRAL: definido de forma independiente y verificado -------
UMBRAL_AUDIT <- 8L  # k-anonimato DEMRE; se contrasta contra 10_configuracion.R en fase0

# --- Extraccion del JSON PUBLICADO (docs/index.html) -------------------------
# Deshace el transporte de 33: atob(base64) -> gunzip -> JSON. Independiente del
# motor; valida el artefacto real que se publicaria (no un parquet intermedio).
extraer_json_publicado <- function(html_path = file.path(REPO_ROOT, "docs", "index.html")) {
  txt <- paste(readLines(html_path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  # El blob va dentro de atob("...."): capturar todos los literales base64 y
  # quedarse con el mas largo (el payload de datos; ignora atob() menores si los hay).
  ms <- regmatches(txt, gregexpr('atob\\("[A-Za-z0-9+/=]+"\\)', txt))[[1]]
  stopifnot("No se encontro el blob atob() en el HTML" = length(ms) >= 1)
  m <- ms[which.max(nchar(ms))]
  b64 <- sub('^atob\\("', "", m); b64 <- sub('"\\)$', "", b64)
  raw_gz <- jsonlite::base64_dec(b64)
  json_txt <- rawToChar(memDecompress(raw_gz, type = "gzip"))
  Encoding(json_txt) <- "UTF-8"
  jsonlite::fromJSON(json_txt, simplifyVector = TRUE)
}

# Convierte el bloque columnar (list de arrays) a data.frame plano.
columnar_a_df <- function(col_list) {
  nms <- setdiff(names(col_list), "rows")
  as.data.frame(col_list[nms], stringsAsFactors = FALSE)
}

# --- Carga de parquets crudos (salida de 31 = microdato de entrada a 32) ------
cargar_insumos <- function() {
  list(
    egresados   = read_parquet(ri("paes_egresados.parquet")),
    inscripcion = read_parquet(ri("paes_inscripcion.parquet")),
    rendicion   = read_parquet(ri("paes_rendicion_resultados.parquet")),
    postulacion = read_parquet(ri("paes_postulacion_seleccion.parquet")),
    cat_estab   = read_parquet(ri("establecimientos_chile.parquet")),
    cat_slep    = read_parquet(ri("sleps_chile.parquet"))
  )
}

# --- Mapa territorial rbd -> comuna/region/slep (implementacion propia) -------
construir_mapa <- function(cat_estab, cat_slep) {
  base <- cat_estab |>
    transmute(rbd = as.character(rbd),
              cod_comuna = as.character(cod_com_rbd),
              cod_region = as.character(cod_reg_rbd))
  slep <- cat_slep |>
    distinct(rbd = as.character(rbd), cod_slep = as.character(cod_slep))
  left_join(base, slep, by = "rbd")
}

# --- Cohorte por recencia de egreso (invariante 🔒) --------------------------
# actual = anyo_egreso == anio_proceso - 1 ; anterior = resto (incl. NA).
cohorte_audit <- function(anyo_egreso, anio_proceso) {
  ifelse(!is.na(anyo_egreso) & anyo_egreso == anio_proceso - 1L, "actual", "anterior")
}

# --- Supresion 🔒 (0 < n < UMBRAL -> NA) --------------------------------------
suprimir_n <- function(n, umbral = UMBRAL_AUDIT) {
  sup <- !is.na(n) & n > 0 & n < umbral
  list(n = ifelse(sup, NA_integer_, as.integer(n)), suprimida = sup)
}

# --- Agregacion territorial de un HEADCOUNT (implementacion propia) -----------
# personas: df con columna `rbd` (character, o NA/"0" para rezagados) y las
# columnas de `by`. Replica agregar_conteo_territorial de 32 con codigo distinto:
# nacional/comuna/slep/region se cuentan desde las filas con comuna mapeada;
# rezagados = filas sin comuna mapeada. Devuelve n SIN suprimir (crudo).
agregar_conteo_crudo <- function(personas, mapa, by = character(0)) {
  d <- left_join(personas, mapa, by = "rbd")
  con_rbd <- d |> filter(!is.na(.data$cod_comuna))
  rez <- d |> filter(is.na(.data$cod_comuna))

  g_comuna <- con_rbd |> count(cod_entidad = .data$cod_comuna, !!!syms(by), name = "n") |>
    mutate(tipo_entidad = "comuna", cod_entidad = as.character(cod_entidad))
  g_slep <- con_rbd |> filter(!is.na(.data$cod_slep)) |>
    count(cod_entidad = .data$cod_slep, !!!syms(by), name = "n") |>
    mutate(tipo_entidad = "slep", cod_entidad = as.character(cod_entidad))
  g_region <- con_rbd |> filter(!is.na(.data$cod_region)) |>
    count(cod_entidad = .data$cod_region, !!!syms(by), name = "n") |>
    mutate(tipo_entidad = "region", cod_entidad = as.character(cod_entidad))
  g_nac <- con_rbd |> count(!!!syms(by), name = "n") |>
    mutate(tipo_entidad = "nacional", cod_entidad = "0")
  g_rez <- rez |> count(!!!syms(by), name = "n") |>
    mutate(tipo_entidad = "rezagados", cod_entidad = "Egresados de anios anteriores (sin RBD vigente)")

  bind_rows(g_comuna, g_slep, g_region, g_nac, g_rez)
}

# Emite las 3 cohortes (personas debe traer columna `cohorte` actual/anterior).
agregar_conteo_cohorte_audit <- function(personas, mapa, by_base = character(0)) {
  por <- agregar_conteo_crudo(personas, mapa, by = c(by_base, "cohorte"))
  todas <- agregar_conteo_crudo(personas, mapa, by = by_base) |> mutate(cohorte = "todas")
  bind_rows(por, todas)
}

# --- Agregacion territorial de un PROMEDIO (implementacion propia) ------------
# personas: df con `rbd`, `cohorte`, la columna valor y las de `by`.
agregar_promedio_crudo <- function(personas, mapa, valor_col, by = character(0)) {
  d <- left_join(personas, mapa, by = "rbd")
  con_rbd <- d |> filter(!is.na(.data$cod_comuna))
  rez <- d |> filter(is.na(.data$cod_comuna))
  resumir <- function(datos, grp) {
    datos |> summarise(n = n(), media = mean(.data[[valor_col]], na.rm = TRUE),
                       .by = all_of(grp))
  }
  g_comuna <- con_rbd |> resumir(c("cod_comuna", by)) |>
    rename(cod_entidad = cod_comuna) |> mutate(tipo_entidad = "comuna", cod_entidad = as.character(cod_entidad))
  g_slep <- con_rbd |> filter(!is.na(.data$cod_slep)) |> resumir(c("cod_slep", by)) |>
    rename(cod_entidad = cod_slep) |> mutate(tipo_entidad = "slep", cod_entidad = as.character(cod_entidad))
  g_region <- con_rbd |> filter(!is.na(.data$cod_region)) |> resumir(c("cod_region", by)) |>
    rename(cod_entidad = cod_region) |> mutate(tipo_entidad = "region", cod_entidad = as.character(cod_entidad))
  g_nac <- con_rbd |> resumir(by) |> mutate(tipo_entidad = "nacional", cod_entidad = "0")
  g_rez <- rez |> resumir(by) |>
    mutate(tipo_entidad = "rezagados", cod_entidad = "Egresados de anios anteriores (sin RBD vigente)")
  bind_rows(g_comuna, g_slep, g_region, g_nac, g_rez)
}
agregar_promedio_cohorte_audit <- function(personas, mapa, valor_col, by_base = character(0)) {
  por <- agregar_promedio_crudo(personas, mapa, valor_col, by = c(by_base, "cohorte"))
  todas <- agregar_promedio_crudo(personas, mapa, valor_col, by = by_base) |> mutate(cohorte = "todas")
  bind_rows(por, todas)
}

# --- Recalculo COMPLETO del foco cobertura (embudo + kpi p1) ------------------
# Devuelve un df largo: tipo_entidad, cod_entidad, anio_proceso, cohorte, etapa,
# n (suprimido), suprimida, y para seleccion: n_seleccionados, n_prioridad_1,
# pct_prioridad_1. Implementacion independiente de 32.
recalcular_cobertura <- function(ins, mapa) {
  egr <- ins$egresados; insc <- ins$inscripcion; ren <- ins$rendicion; pos <- ins$postulacion

  egreso_lookup <- insc |>
    distinct(id_aux, anio_proceso, anyo_egreso = as.integer(anyo_egreso))
  inscripcion_rbd <- insc |>
    distinct(id_aux, anio_proceso, rbd = as.character(rbd), anyo_egreso = as.integer(anyo_egreso))

  # egresados (denominador): marca_egreso==1, cohorte fija "actual"
  p_egr <- egr |> filter(.data$marca_egreso == 1) |>
    transmute(rbd = as.character(rbd), anio_proceso = as.integer(agno), cohorte = "actual")
  e_egr <- agregar_conteo_cohorte_audit(p_egr, mapa, by_base = "anio_proceso") |> mutate(etapa = "egresados")

  # inscripcion
  p_insc <- insc |>
    distinct(id_aux, rbd = as.character(rbd), anio_proceso, anyo_egreso = as.integer(anyo_egreso)) |>
    mutate(cohorte = cohorte_audit(anyo_egreso, anio_proceso))
  e_insc <- agregar_conteo_cohorte_audit(p_insc, mapa, by_base = "anio_proceso") |> mutate(etapa = "inscripcion")

  # rendicion (vigencia actual)
  p_ren <- ren |> filter(.data$vigencia == "actual") |>
    distinct(id_aux, rbd = as.character(rbd), anio_proceso) |>
    left_join(egreso_lookup, by = c("id_aux", "anio_proceso")) |>
    mutate(cohorte = cohorte_audit(anyo_egreso, anio_proceso))
  e_ren <- agregar_conteo_cohorte_audit(p_ren, mapa, by_base = "anio_proceso") |> mutate(etapa = "rendicion")

  # resultados validos (clec + mate1, vigencia actual)
  ids_ok <- ren |> filter(.data$vigencia == "actual", .data$prueba %in% c("clec", "mate1")) |>
    distinct(id_aux, anio_proceso, prueba) |>
    count(id_aux, anio_proceso, name = "np") |> filter(.data$np == 2)
  p_res <- ren |> distinct(id_aux, rbd = as.character(rbd), anio_proceso) |>
    inner_join(ids_ok, by = c("id_aux", "anio_proceso")) |>
    left_join(egreso_lookup, by = c("id_aux", "anio_proceso")) |>
    mutate(cohorte = cohorte_audit(anyo_egreso, anio_proceso))
  e_res <- agregar_conteo_cohorte_audit(p_res, mapa, by_base = "anio_proceso") |> mutate(etapa = "resultados")

  # postulacion
  p_pos <- pos |> distinct(id_aux, anio_proceso) |>
    left_join(inscripcion_rbd, by = c("id_aux", "anio_proceso")) |>
    mutate(cohorte = cohorte_audit(anyo_egreso, anio_proceso))
  e_pos <- agregar_conteo_cohorte_audit(p_pos, mapa, by_base = "anio_proceso") |> mutate(etapa = "postulacion")

  # seleccion (estado_pref 24/26)
  p_sel <- pos |> filter(.data$estado_pref %in% c(24, 26)) |>
    distinct(id_aux, anio_proceso) |>
    left_join(inscripcion_rbd, by = c("id_aux", "anio_proceso")) |>
    mutate(cohorte = cohorte_audit(anyo_egreso, anio_proceso))
  e_sel <- agregar_conteo_cohorte_audit(p_sel, mapa, by_base = "anio_proceso") |> mutate(etapa = "seleccion")

  # kpi prioridad 1 (estado_pref==24 & orden_pref==1). n_p1_raw = conteo crudo
  # (para cuantificar el hallazgo de "0% enganoso"); 32 suprime este conteo
  # (k-anon) ANTES del coalesce, por eso se replica la supresion mas abajo.
  p_p1 <- pos |> filter(.data$estado_pref == 24, .data$orden_pref == 1) |>
    distinct(id_aux, anio_proceso) |>
    left_join(inscripcion_rbd, by = c("id_aux", "anio_proceso")) |>
    mutate(cohorte = cohorte_audit(anyo_egreso, anio_proceso))
  kpi_p1 <- agregar_conteo_cohorte_audit(p_p1, mapa, by_base = "anio_proceso") |>
    transmute(tipo_entidad, cod_entidad, anio_proceso, cohorte, n_p1_raw = n)

  # Combinar embudo + suprimir + kpi p1 (replica logica de 32)
  embudo <- bind_rows(e_egr, e_insc, e_ren, e_res, e_pos, e_sel)
  sp <- suprimir_n(embudo$n)
  embudo$n <- sp$n; embudo$suprimida <- sp$suprimida

  # kpi p1: n_seleccionados desde seleccion (crudo, pre-supresion) para calcular pct
  sel_crudo <- bind_rows(e_sel) # ya con n crudo? no: e_sel trae n crudo (suprimir se aplico a `embudo`, no a e_sel)
  sel_kpi <- e_sel |> transmute(tipo_entidad, cod_entidad, anio_proceso, cohorte,
                                n_seleccionados = n) |>
    mutate(sup_sel = !is.na(n_seleccionados) & n_seleccionados > 0 & n_seleccionados < UMBRAL_AUDIT)
  sel_kpi <- sel_kpi |>
    left_join(kpi_p1, by = c("tipo_entidad", "cod_entidad", "anio_proceso", "cohorte")) |>
    mutate(
      n_p1_raw = coalesce(n_p1_raw, 0L),                       # conteo real (sin suprimir)
      # 32 suprime n_prioridad_1 (k-anon) antes del coalesce: <8 -> NA -> 0
      n_p1_sup = ifelse(!is.na(n_p1_raw) & n_p1_raw > 0 & n_p1_raw < UMBRAL_AUDIT,
                        NA_integer_, n_p1_raw),
      n_prioridad_1 = coalesce(n_p1_sup, 0L),
      pct_prioridad_1 = ifelse(sup_sel, NA_real_, 100 * n_prioridad_1 / n_seleccionados),
      n_prioridad_1 = ifelse(sup_sel, NA_integer_, n_prioridad_1),
      n_seleccionados = ifelse(sup_sel, NA_integer_, n_seleccionados),
      etapa = "seleccion"
    ) |>
    select(tipo_entidad, cod_entidad, anio_proceso, cohorte, etapa,
           n_seleccionados, n_prioridad_1, pct_prioridad_1, n_p1_raw)

  embudo |>
    left_join(sel_kpi, by = c("tipo_entidad", "cod_entidad", "anio_proceso", "cohorte", "etapa"))
}

# --- Recalculo del foco rendimiento (solo el subset PUBLICADO: reg+actual+nem+ranking)
recalcular_rendimiento <- function(ins, mapa) {
  ren <- ins$rendicion
  egreso_lookup <- ins$inscripcion |>
    distinct(id_aux, anio_proceso, anyo_egreso = as.integer(anyo_egreso))

  rend_coh <- ren |>
    mutate(rbd = as.character(rbd)) |>
    left_join(egreso_lookup, by = c("id_aux", "anio_proceso")) |>
    mutate(cohorte = cohorte_audit(anyo_egreso, anio_proceso))

  puntajes <- rend_coh |>
    agregar_promedio_cohorte_audit(mapa, valor_col = "puntaje",
      by_base = c("anio_proceso", "prueba", "tipo_rendicion", "vigencia"))

  personas_ctx <- ren |>
    mutate(rbd = as.character(rbd)) |>
    distinct(id_aux, anio_proceso, rbd, ptje_nem, ptje_ranking) |>
    left_join(egreso_lookup, by = c("id_aux", "anio_proceso")) |>
    mutate(cohorte = cohorte_audit(anyo_egreso, anio_proceso))
  nem <- personas_ctx |> filter(.data$ptje_nem > 0) |>
    agregar_promedio_cohorte_audit(mapa, "ptje_nem", by_base = "anio_proceso") |>
    mutate(prueba = "nem", tipo_rendicion = NA_character_, vigencia = NA_character_)
  ranking <- personas_ctx |> filter(.data$ptje_ranking > 0) |>
    agregar_promedio_cohorte_audit(mapa, "ptje_ranking", by_base = "anio_proceso") |>
    mutate(prueba = "ranking", tipo_rendicion = NA_character_, vigencia = NA_character_)

  todo <- bind_rows(puntajes, nem, ranking)
  # supresion + enmascarado de media
  sp <- suprimir_n(todo$n)
  todo$n <- sp$n; todo$suprimida <- sp$suprimida
  todo$media <- ifelse(todo$suprimida, NA_real_, todo$media)
  # subset publicado por 33: (reg & actual) o nem/ranking
  todo |> filter((tipo_rendicion == "reg" & vigencia == "actual") |
                   prueba %in% c("nem", "ranking"))
}

message("lib_auditoria.R cargada.")
