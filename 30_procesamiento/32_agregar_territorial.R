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
# Fecha    : 2026-07-01
# -----------------------------------------------------------------------------
# Cableado (Fase B) contra la salida real confirmada de 31_leer_normalizar.R.
# Decision de diseno (delegada, ver decisiones/20260701_decision_territorializacion_d_matr.md
# y CLAUDE.md "Ultimos cambios"): ArchivoD (postulacion_seleccion) NO trae rbd
# propio -> se territorializa via join por (id_aux, anio_proceso) contra
# paes_inscripcion (que si trae rbd de egreso; verificado 100% de las
# combinaciones id_aux+anio de ArchivoD existen en ArchivoB). ArchivoMatr
# (matricula universitaria) NO es una etapa de ETAPAS_EMBUDO ni fue pedida por
# el encargo -> queda FUERA del arbol territorial en esta v1; el mismo mecanismo
# de join por id_aux aplicaria si una version futura la necesita.
#
# Reglas mecanicas aplicadas (documentadas, no inventadas):
#   - "rendicion" y "resultados" (embudo) filtran vigencia == "actual": una fila
#     vigencia == "anterior" es un puntaje HEREDADO del proceso previo, no una
#     rendicion de ESTE anio (evita inflar/duplicar el embudo entre anios).
#   - "resultados validos" = rindio el paquete obligatorio (CLEC + M1) este
#     anio. NO implementa el umbral fino de habilitacion a postulacion
#     centralizada (>=458 ptos promedio o 10% superior de notas,
#     contexto_paes.md L.205): PORC_SUP_NOTAS en la base real es un DECIL
#     (0,10,...,100), no un flag binario de "10% superior", y no hay glosa que
#     confirme el mapeo decil->habilitacion -> se habria inventado el corte
#     (B.1). Alcance documentado, no una detencion: el criterio CLEC+M1 esta
#     explicitamente en contexto_paes.md L.105 y es mecanico.
#   - "mate" (INV 2023-2024 sin split, ver 31_) NO cuenta como M1 para
#     resultados_validos: no es homologable a mate1 sin fuente (misma decision
#     que en 31_). Subcuenta documentada, no fabricada.
#   - "seleccion" = estado_pref %in% c(24, 26) ("en lista de seleccionados",
#     "seleccionado en preferencia anterior"; Anexo Estado Preferencia
#     ArchivoD). 25 ("en lista de espera") NO cuenta como seleccionado.
#   - Denominador "egresados": el archivo real trae ~4x mas filas que personas
#     (999.446 filas vs. ~254.750 egresados 2023) porque incluye registros de
#     grados 1-4 medio por estudiante, no solo el anio de egreso; marca_egreso
#     == 1 identifica la fila de egreso efectivo. CONFIRMADO contra glosa
#     oficial: "Esquema de registro bases de Notas y Egresados de Enseñanza
#     Media por estudiante" (Unidad de Estadisticas, Centro de Estudios,
#     Ministerio de Educacion), archivo
#     20_insumos/demre/referencia/<AAAA>/er_notas_y_egresados_ensenanza_media_publ_<AAAA>.pdf
#     (identico en 2023/2024/2025), pagina 3/8, tabla "Variables":
#     "MARCA_EGRESO | Numerico | Indicador si el alumno egresa en el año
#     (solo para alumnos con informacion completa de enseñanza media) |
#     0: No egresa / 1: Egresa". La tabla "Numero de observaciones por año" de
#     la pagina 1/8 reporta "Numero de Egresados de la educacion Media" =
#     254.750 (2023) / 257.261 (2024) / 281.356 (2025) -- coincide EXACTO con
#     la cardinalidad post-filtro `marca_egreso==1` calculada en este script.
#     (El mismo documento tambien confirma nota al pie 2: "Para casos sin
#     informacion de RBD, se asigna el valor 0" -- por eso `rbd=="0"` cae
#     correctamente en "rezagados" via el left_join con `mapa`, sin trato
#     especial en el codigo.)
#   - Sentinela 0 en ptje_nem/ptje_ranking = sin valor calculado (mismo patron
#     que puntaje en 31_; confirmado: rango sin el 0 es 100-1000, la escala
#     PAES exacta) -> se excluye del promedio de rendimiento.
# =============================================================================

library(here)
source(here::here("10_utils", "10_utils.R"))
source(here::here("10_utils", "10_configuracion.R"))   # UMBRAL_SUPRESION_CELDA, ETAPAS_EMBUDO, PRUEBAS_PAES, ETIQUETA_SIN_RBD_VIGENTE
instalar_si_falta(c("here", "dplyr", "tidyr", "arrow"))
library(dplyr)

ruta_int <- function(f) ruta_salidas("intermedios", f)
dir.create(ruta_salidas("intermedios"), recursive = TRUE, showWarnings = FALSE)

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

# Analogo a agregar_conteo_territorial() pero para un VALOR promedio (puntaje,
# NEM, Ranking) en vez de un headcount. Al ser cada fila una observacion
# persona-indicador, mean(valor_col) por entidad territorial ya queda
# ponderado por nº de observaciones (no hace falta reponderar aparte).
# Cuando la celda se suprime (n < umbral), la media TAMBIEN se enmascara: un
# promedio de <8 personas sigue siendo informacion individualizable.
agregar_promedio_territorial <- function(df_personas, mapa, valor_col, by = character(0)) {
  d <- dplyr::left_join(df_personas, mapa, by = "rbd")
  resumir <- function(datos, agrupar_por) {
    datos |>
      dplyr::summarise(
        n = dplyr::n(),
        media = mean(.data[[valor_col]], na.rm = TRUE),
        .by = dplyr::all_of(agrupar_por)
      )
  }

  rezagados <- d |>
    dplyr::filter(is.na(.data$cod_comuna)) |>
    resumir(by) |>
    dplyr::mutate(tipo_entidad = "rezagados", cod_entidad = ETIQUETA_SIN_RBD_VIGENTE)

  con_rbd <- d |> dplyr::filter(!is.na(.data$cod_comuna))
  por <- function(tipo, col) {
    con_rbd |>
      dplyr::filter(!is.na(.data[[col]])) |>
      resumir(c(col, by)) |>
      dplyr::rename(cod_entidad = dplyr::all_of(col)) |>
      dplyr::mutate(tipo_entidad = tipo, cod_entidad = as.character(cod_entidad))
  }
  nacional <- con_rbd |>
    resumir(by) |>
    dplyr::mutate(tipo_entidad = "nacional", cod_entidad = "0")

  dplyr::bind_rows(
    por("comuna", "cod_comuna"), por("slep", "cod_slep"),
    por("region", "cod_region"), nacional, rezagados
  ) |>
    aplicar_supresion("n") |>
    dplyr::mutate(media = dplyr::if_else(.data$suprimida, NA_real_, .data$media))
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

  egresados    <- arrow::read_parquet(ruta_int("paes_egresados.parquet"))
  inscripcion  <- arrow::read_parquet(ruta_int("paes_inscripcion.parquet"))
  rendicion    <- arrow::read_parquet(ruta_int("paes_rendicion_resultados.parquet"))
  postulacion  <- arrow::read_parquet(ruta_int("paes_postulacion_seleccion.parquet"))

  # ---- FOCO COBERTURA: embudo por etapa ----------------------------------
  log_msg("Agregando FOCO COBERTURA (embudo egresados -> ... -> seleccionados)...", "INFO", "32")

  # egresados (denominador): marca_egreso == 1 identifica la fila de egreso
  # efectivo. CONFIRMADO contra glosa oficial MINEDUC (ver nota de cabecera:
  # er_notas_y_egresados_ensenanza_media_publ_<AAAA>.pdf, pag. 3/8). agno ->
  # anio_proceso para homologar con el resto de las etapas.
  etapa_egresados <- egresados |>
    dplyr::filter(.data$marca_egreso == 1) |>
    dplyr::transmute(rbd = .data$rbd, anio_proceso = as.integer(.data$agno)) |>
    agregar_conteo_territorial(mapa, by = "anio_proceso") |>
    dplyr::mutate(etapa = "egresados")

  # inscripcion: una fila de ArchivoB = un inscrito.
  etapa_inscripcion <- inscripcion |>
    dplyr::distinct(id_aux, rbd, anio_proceso) |>
    agregar_conteo_territorial(mapa, by = "anio_proceso") |>
    dplyr::mutate(etapa = "inscripcion")

  # rendicion: aparece en ArchivoC (post sentinela-0 filtrado en 31_) con
  # vigencia == "actual" -> rindio al menos una prueba ESTE anio.
  etapa_rendicion <- rendicion |>
    dplyr::filter(.data$vigencia == "actual") |>
    dplyr::distinct(id_aux, rbd, anio_proceso) |>
    agregar_conteo_territorial(mapa, by = "anio_proceso") |>
    dplyr::mutate(etapa = "rendicion")

  # resultados validos: rindio CLEC + M1 (paquete obligatorio) este anio.
  # "mate" (INV sin split) no homologa a mate1 (heredado de 31_).
  ids_obligatorias_ok <- rendicion |>
    dplyr::filter(.data$vigencia == "actual", .data$prueba %in% c("clec", "mate1")) |>
    dplyr::distinct(id_aux, anio_proceso, prueba) |>
    dplyr::summarise(n_pruebas_obligatorias = dplyr::n(), .by = c(id_aux, anio_proceso)) |>
    dplyr::filter(.data$n_pruebas_obligatorias == 2)

  etapa_resultados <- rendicion |>
    dplyr::distinct(id_aux, rbd, anio_proceso) |>
    dplyr::inner_join(ids_obligatorias_ok, by = c("id_aux", "anio_proceso")) |>
    agregar_conteo_territorial(mapa, by = "anio_proceso") |>
    dplyr::mutate(etapa = "resultados")

  # postulacion / seleccion: ArchivoD no trae rbd -> join por (id_aux,
  # anio_proceso) contra inscripcion (decision documentada en la cabecera).
  inscripcion_rbd <- inscripcion |> dplyr::distinct(id_aux, anio_proceso, rbd)

  etapa_postulacion <- postulacion |>
    dplyr::distinct(id_aux, anio_proceso) |>
    dplyr::left_join(inscripcion_rbd, by = c("id_aux", "anio_proceso")) |>
    agregar_conteo_territorial(mapa, by = "anio_proceso") |>
    dplyr::mutate(etapa = "postulacion")

  # seleccion: estado_pref 24 (en lista de seleccionados) o 26 (seleccionado en
  # preferencia anterior). 25 (lista de espera) NO cuenta como seleccionado.
  etapa_seleccion <- postulacion |>
    dplyr::filter(.data$estado_pref %in% c(24, 26)) |>
    dplyr::distinct(id_aux, anio_proceso) |>
    dplyr::left_join(inscripcion_rbd, by = c("id_aux", "anio_proceso")) |>
    agregar_conteo_territorial(mapa, by = "anio_proceso") |>
    dplyr::mutate(etapa = "seleccion")

  # KPI: prioridad de la preferencia seleccionada (Camino B, delegado).
  # Fase 0 (diagnostico): ArchivoD no trae una columna "PREFERENCIA" separada;
  # el ORDEN_PREF ya normalizado en 31_ (columna orden_pref, 1-20) ES el
  # ordinal de prioridad de la preferencia postulada. Verificado contra los
  # datos reales (610.871 personas-anio seleccionadas): toda persona
  # seleccionada tiene EXACTAMENTE una fila estado_pref==24 (0 casos con >1
  # fila 24; 0 casos "solo 26 sin 24"), y en el 100% de los 563.885 casos
  # donde ademas existe una fila 26, su orden_pref es >= el de la fila 24 (0
  # excepciones) -- consistente con la glosa (24="en lista de seleccionados"
  # = colocacion activa; 26="seleccionado en preferencia anterior" = marca en
  # una preferencia de MENOR prioridad, posterior a la ya asignada). Por eso
  # la prioridad real de cada seleccionado se toma EXCLUSIVAMENTE de su
  # (unica) fila estado_pref==24, nunca de una fila 26 (que reflejaria una
  # prioridad mas baja e incorrecta). El universo estado_pref==24 coincide
  # EXACTO (610.871 = 610.871) con el universo %in% c(24,26) de
  # etapa_seleccion, asi que el denominador de este KPI se REUTILIZA de
  # etapa_seleccion (mismo n, mismo suprimida) en vez de recalcularse aparte.
  # Decision de forma (documentada, como pide el encargo): se agregan 3
  # columnas nuevas a paes_cobertura_territorial.parquet (n_seleccionados,
  # n_prioridad_1, pct_prioridad_1), pobladas SOLO en la fila etapa=="seleccion"
  # (NA en las otras 5 etapas) -- el KPI es una faceta de esa unica etapa, no
  # una etapa nueva del embudo ni una dimension cruzable como rendimiento;
  # cramearlo en una tabla separada habria duplicado la maquinaria de
  # supresion sin necesidad. La supresion se aplica UNICAMENTE sobre el
  # denominador (n_seleccionados < 8), por instruccion explicita del encargo;
  # no hay un umbral separado sobre el numerador de prioridad 1.
  kpi_prioridad_1 <- postulacion |>
    dplyr::filter(.data$estado_pref == 24, .data$orden_pref == 1) |>
    dplyr::distinct(id_aux, anio_proceso) |>
    dplyr::left_join(inscripcion_rbd, by = c("id_aux", "anio_proceso")) |>
    agregar_conteo_territorial(mapa, by = "anio_proceso") |>
    dplyr::transmute(tipo_entidad, cod_entidad, anio_proceso, n_prioridad_1 = n)

  kpi_prioridad <- etapa_seleccion |>
    dplyr::transmute(tipo_entidad, cod_entidad, anio_proceso,
                     n_seleccionados = n, suprimida_sel = suprimida) |>
    dplyr::left_join(kpi_prioridad_1, by = c("tipo_entidad", "cod_entidad", "anio_proceso")) |>
    dplyr::mutate(
      n_prioridad_1 = dplyr::coalesce(.data$n_prioridad_1, 0L),
      pct_prioridad_1 = dplyr::if_else(.data$suprimida_sel, NA_real_,
                                       100 * .data$n_prioridad_1 / .data$n_seleccionados),
      n_prioridad_1 = dplyr::if_else(.data$suprimida_sel, NA_integer_, .data$n_prioridad_1),
      etapa = "seleccion"
    ) |>
    dplyr::select(tipo_entidad, cod_entidad, anio_proceso, etapa,
                 n_seleccionados, n_prioridad_1, pct_prioridad_1)

  orden_etapas <- stats::setNames(seq_along(ETAPAS_EMBUDO), names(ETAPAS_EMBUDO))
  cobertura <- dplyr::bind_rows(
    etapa_egresados, etapa_inscripcion, etapa_rendicion,
    etapa_resultados, etapa_postulacion, etapa_seleccion
  ) |>
    dplyr::mutate(orden_etapa = orden_etapas[.data$etapa]) |>
    dplyr::left_join(kpi_prioridad, by = c("tipo_entidad", "cod_entidad", "anio_proceso", "etapa"))

  arrow::write_parquet(cobertura, ruta_int("paes_cobertura_territorial.parquet"))
  log_msg(sprintf("OK: paes_cobertura_territorial.parquet (%d filas, %d cols).",
                  nrow(cobertura), ncol(cobertura)), "INFO", "32")

  # ---- FOCO RENDIMIENTO: puntajes por prueba -----------------------------
  log_msg("Agregando FOCO RENDIMIENTO (puntajes por prueba, NEM, Ranking)...", "INFO", "32")

  # Puntajes por prueba: agrupado por prueba/tipo_rendicion/vigencia (ambas
  # vigencias, "actual" Y "anterior", son parte del desglose solicitado -- no
  # se filtran aqui, a diferencia del embudo de cobertura).
  rendimiento_puntajes <- rendicion |>
    agregar_promedio_territorial(
      mapa, valor_col = "puntaje",
      by = c("anio_proceso", "prueba", "tipo_rendicion", "vigencia")
    )

  # NEM y Ranking: atributos por PERSONA (constantes por id_aux+anio_proceso,
  # verificado), no por fila pivoteada -> deduplicar antes de promediar para no
  # sobreponderar a quienes rindieron mas pruebas. Sentinela 0 = sin valor
  # calculado (mismo patron que puntaje), se excluye del promedio.
  personas_contexto <- rendicion |>
    dplyr::distinct(id_aux, anio_proceso, rbd, ptje_nem, ptje_ranking)

  rendimiento_nem <- personas_contexto |>
    dplyr::filter(.data$ptje_nem > 0) |>
    agregar_promedio_territorial(mapa, valor_col = "ptje_nem", by = "anio_proceso") |>
    dplyr::mutate(prueba = "nem", tipo_rendicion = NA_character_, vigencia = NA_character_)

  rendimiento_ranking <- personas_contexto |>
    dplyr::filter(.data$ptje_ranking > 0) |>
    agregar_promedio_territorial(mapa, valor_col = "ptje_ranking", by = "anio_proceso") |>
    dplyr::mutate(prueba = "ranking", tipo_rendicion = NA_character_, vigencia = NA_character_)

  rendimiento <- dplyr::bind_rows(rendimiento_puntajes, rendimiento_nem, rendimiento_ranking)

  arrow::write_parquet(rendimiento, ruta_int("paes_rendimiento_territorial.parquet"))
  log_msg(sprintf("OK: paes_rendimiento_territorial.parquet (%d filas, %d cols).",
                  nrow(rendimiento), ncol(rendimiento)), "INFO", "32")

  message("\n32_agregar_territorial.R: OK. Focos agregados: cobertura, rendimiento")
}
