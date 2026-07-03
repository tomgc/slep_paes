# =============================================================================
# lib_reauditoria.R — panel adversarial AJUSTADO a los fixes F1 y F2 (20260703)
# -----------------------------------------------------------------------------
# Reusa lib_auditoria.R como base y SOBRESCRIBE las 2 funciones afectadas por los
# fixes, para comparar contra la NUEVA definicion del pipeline (no la vieja):
#   F1: etapa egresados indexada por anio_proceso = agno + 1 (proceso P <- egreso P-1).
#   F2: n_prioridad_1 suprimido (1..7) -> resguardo (NA/NA), no coalesce a 0.
# El resto de helpers (JSON, mapa, agregadores crudos, rendimiento) se heredan.
# =============================================================================
suppressMessages(source("/Users/tomgc/Projects/slep_paes/50_documentacion/andamios/auditoria_datos_pre_push/lib_auditoria.R"))

# --- F1: person-sets con egresados en anio_proceso = agno + 1 ----------------
personas_embudo <- function(ins) {
  egr <- ins$egresados; insc <- ins$inscripcion; ren <- ins$rendicion; pos <- ins$postulacion
  egreso_lookup <- insc |>
    distinct(id_aux, anio_proceso, anyo_egreso = as.integer(anyo_egreso))
  inscripcion_rbd <- insc |>
    distinct(id_aux, anio_proceso, rbd = as.character(rbd), anyo_egreso = as.integer(anyo_egreso))

  # F1: agno + 1L (el proceso de admision P consume egresados de agno = P-1)
  p_egr <- egr |> filter(.data$marca_egreso == 1) |>
    transmute(rbd = as.character(rbd), anio_proceso = as.integer(agno) + 1L, cohorte = "actual")
  p_insc <- insc |>
    distinct(id_aux, rbd = as.character(rbd), anio_proceso, anyo_egreso = as.integer(anyo_egreso)) |>
    mutate(cohorte = cohorte_audit(anyo_egreso, anio_proceso))
  p_ren <- ren |> filter(.data$vigencia == "actual") |>
    distinct(id_aux, rbd = as.character(rbd), anio_proceso) |>
    left_join(egreso_lookup, by = c("id_aux", "anio_proceso")) |>
    mutate(cohorte = cohorte_audit(anyo_egreso, anio_proceso))
  ids_ok <- ren |> filter(.data$vigencia == "actual", .data$prueba %in% c("clec", "mate1")) |>
    distinct(id_aux, anio_proceso, prueba) |>
    count(id_aux, anio_proceso, name = "np") |> filter(.data$np == 2)
  p_res <- ren |> distinct(id_aux, rbd = as.character(rbd), anio_proceso) |>
    inner_join(ids_ok, by = c("id_aux", "anio_proceso")) |>
    left_join(egreso_lookup, by = c("id_aux", "anio_proceso")) |>
    mutate(cohorte = cohorte_audit(anyo_egreso, anio_proceso))
  p_pos <- pos |> distinct(id_aux, anio_proceso) |>
    left_join(inscripcion_rbd, by = c("id_aux", "anio_proceso")) |>
    mutate(cohorte = cohorte_audit(anyo_egreso, anio_proceso))
  p_sel <- pos |> filter(.data$estado_pref %in% c(24, 26)) |>
    distinct(id_aux, anio_proceso) |>
    left_join(inscripcion_rbd, by = c("id_aux", "anio_proceso")) |>
    mutate(cohorte = cohorte_audit(anyo_egreso, anio_proceso))
  p_p1 <- pos |> filter(.data$estado_pref == 24, .data$orden_pref == 1) |>
    distinct(id_aux, anio_proceso) |>
    left_join(inscripcion_rbd, by = c("id_aux", "anio_proceso")) |>
    mutate(cohorte = cohorte_audit(anyo_egreso, anio_proceso))
  list(egresados = p_egr, inscripcion = p_insc, rendicion = p_ren,
       resultados = p_res, postulacion = p_pos, seleccion = p_sel, prioridad_1 = p_p1)
}

# --- F2: recalculo cobertura con resguardo en 1.a prioridad suprimida ---------
recalcular_cobertura <- function(ins, mapa) {
  P <- personas_embudo(ins)   # ya con F1
  e_egr  <- agregar_conteo_cohorte_audit(P$egresados,   mapa, "anio_proceso") |> mutate(etapa = "egresados")
  e_insc <- agregar_conteo_cohorte_audit(P$inscripcion, mapa, "anio_proceso") |> mutate(etapa = "inscripcion")
  e_ren  <- agregar_conteo_cohorte_audit(P$rendicion,   mapa, "anio_proceso") |> mutate(etapa = "rendicion")
  e_res  <- agregar_conteo_cohorte_audit(P$resultados,  mapa, "anio_proceso") |> mutate(etapa = "resultados")
  e_pos  <- agregar_conteo_cohorte_audit(P$postulacion, mapa, "anio_proceso") |> mutate(etapa = "postulacion")
  e_sel  <- agregar_conteo_cohorte_audit(P$seleccion,   mapa, "anio_proceso") |> mutate(etapa = "seleccion")

  kpi_p1 <- agregar_conteo_cohorte_audit(P$prioridad_1, mapa, by_base = "anio_proceso") |>
    transmute(tipo_entidad, cod_entidad, anio_proceso, cohorte, n_p1_raw = n)

  embudo <- bind_rows(e_egr, e_insc, e_ren, e_res, e_pos, e_sel)
  sp <- suprimir_n(embudo$n); embudo$n <- sp$n; embudo$suprimida <- sp$suprimida

  sel_kpi <- e_sel |> transmute(tipo_entidad, cod_entidad, anio_proceso, cohorte,
                                n_seleccionados = n) |>
    mutate(sup_sel = !is.na(n_seleccionados) & n_seleccionados > 0 & n_seleccionados < UMBRAL_AUDIT)
  sel_kpi <- sel_kpi |>
    left_join(kpi_p1, by = c("tipo_entidad", "cod_entidad", "anio_proceso", "cohorte")) |>
    mutate(
      n_p1_raw = coalesce(n_p1_raw, 0L),
      # F2: conteo real 1..7 -> resguardo (como suprimida_p1==TRUE en 32)
      sup_p1 = n_p1_raw > 0 & n_p1_raw < UMBRAL_AUDIT,
      resguardo_p1 = sup_sel | sup_p1,
      pct_prioridad_1 = ifelse(resguardo_p1, NA_real_, 100 * n_p1_raw / n_seleccionados),
      n_prioridad_1 = ifelse(resguardo_p1, NA_integer_, n_p1_raw),
      n_seleccionados = ifelse(sup_sel, NA_integer_, n_seleccionados),
      etapa = "seleccion"
    ) |>
    select(tipo_entidad, cod_entidad, anio_proceso, cohorte, etapa,
           n_seleccionados, n_prioridad_1, pct_prioridad_1, n_p1_raw)

  embudo |>
    left_join(sel_kpi, by = c("tipo_entidad", "cod_entidad", "anio_proceso", "cohorte", "etapa"))
}

message("lib_reauditoria.R cargada (F1 agno+1, F2 resguardo).")
