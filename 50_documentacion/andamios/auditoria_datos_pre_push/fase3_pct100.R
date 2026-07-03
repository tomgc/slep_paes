# =============================================================================
# fase3_pct100.R — FASE 3: barrido de porcentajes > 100% (RENDERIZADOS)
# -----------------------------------------------------------------------------
# Barrido programatico restringido a los porcentajes que el motor EFECTIVAMENTE
# renderiza, replicando su logica de denominador:
#   Vista A (CobActual/CobComp): SOLO anio_actual. Etapas inscripcion..seleccion
#     via baseCob (egresados en "actual", inscripcion en anterior/todas).
#     egresados se muestra 100% ("actual") o "—" (no-actual) -> no se cuenta.
#   Vista B (CobHist): TODOS los anios. Series rindio(=rendicion), seleccionado
#     (=seleccion) y "1.a preferencia" (=n_prioridad_1/base) via baseY
#     (actual -> egresados o hueco; anterior/todas -> inscripcion).
#   pct_prioridad_1 (JSON, sobre seleccionados).
# Cobertura total: si toda celda por-territorio (incl. comuna) es <=100%, toda
# combinacion filtrada (covSel = suma comunas incluidas) tambien lo es.
# Invariante 🔒: ningun porcentaje publicado > 100%.
# + Diagnostico de causa raiz: alineacion del denominador egresados (agno vs proceso).
# =============================================================================
suppressMessages(source("/Users/tomgc/Projects/slep_paes/50_documentacion/andamios/auditoria_datos_pre_push/lib_auditoria.R"))
suppressMessages(library(tidyr))

cat("=========================================================\n")
cat("FASE 3 — Barrido de %>100% (solo renderizados) + causa raiz\n")
cat("=========================================================\n\n")

jc <- extraer_json_publicado()
cob <- columnar_a_df(jc$cobertura); cob$anio_proceso <- as.integer(cob$anio_proceso)
AA <- as.integer(jc$meta$anio_actual)

w <- cob |> select(tipo_entidad, cod_entidad, anio_proceso, cohorte, etapa, n) |>
  pivot_wider(names_from = etapa, values_from = n)
p1 <- cob |> filter(etapa == "seleccion") |>
  select(tipo_entidad, cod_entidad, anio_proceso, cohorte, n_prioridad_1, pct_prioridad_1)
w <- w |> left_join(p1, by = c("tipo_entidad", "cod_entidad", "anio_proceso", "cohorte"))
val <- function(x) !is.na(x) & x > 0

# baseCob (CobActual/CobComp): actual -> egresados o inscripcion ; else inscripcion
w$baseCob <- with(w, ifelse(cohorte == "actual" & val(egresados), egresados,
                     ifelse(val(inscripcion), inscripcion, NA_real_)))
# baseY (CobHist): actual -> egresados o HUECO(NA) ; else inscripcion
w$baseY <- with(w, ifelse(cohorte == "actual", ifelse(val(egresados), egresados, NA_real_),
                   ifelse(val(inscripcion), inscripcion, NA_real_)))

reg_viol <- function(num, base, cond) {
  pct <- 100 * num / base
  idx <- which(cond & !is.na(pct))
  data.frame(idx = idx, pct = pct[idx])
}
# --- Vista A: anio_actual, 5 etapas via baseCob ------------------------------
A_et <- c("inscripcion", "rendicion", "resultados", "postulacion", "seleccion")
viol_A <- do.call(rbind, lapply(A_et, function(e) {
  r <- reg_viol(w[[e]], w$baseCob, w$anio_proceso == AA)
  if (nrow(r)) cbind(vista = "CobActual/Comp", indicador = e, w[r$idx, c("tipo_entidad","cod_entidad","anio_proceso","cohorte")], pct = r$pct) else NULL
}))
# --- Vista B: todos los anios, rindio/seleccion/1a-pref via baseY ------------
viol_B <- do.call(rbind, lapply(c("rendicion", "seleccion"), function(e) {
  r <- reg_viol(w[[e]], w$baseY, rep(TRUE, nrow(w)))
  if (nrow(r)) cbind(vista = "CobHist", indicador = e, w[r$idx, c("tipo_entidad","cod_entidad","anio_proceso","cohorte")], pct = r$pct) else NULL
}))
r_p1s <- reg_viol(w$n_prioridad_1, w$baseY, rep(TRUE, nrow(w)))
viol_p1s <- if (nrow(r_p1s)) cbind(vista = "CobHist", indicador = "1a_pref_serie", w[r_p1s$idx, c("tipo_entidad","cod_entidad","anio_proceso","cohorte")], pct = r_p1s$pct) else NULL
# --- pct_prioridad_1 (JSON) --------------------------------------------------
r_p1 <- which(!is.na(w$pct_prioridad_1))
viol_p1 <- cbind(vista = "P1", indicador = "pct_prioridad_1", w[r_p1, c("tipo_entidad","cod_entidad","anio_proceso","cohorte")], pct = w$pct_prioridad_1[r_p1])

todo <- rbind(viol_A, viol_B, viol_p1s, viol_p1)
todo$round <- round(todo$pct)
cat("[Resumen por indicador renderizado] (valores y cuantos > 100%)\n")
resumen <- todo |> group_by(vista, indicador) |>
  summarise(n = n(), max_raw = round(max(pct), 2), raw_gt100 = sum(pct > 100 + 1e-9),
            round_gt100 = sum(round > 100), .groups = "drop")
print(as.data.frame(resumen), row.names = FALSE)

viol <- todo[todo$round > 100, ]
cat(sprintf("\n[VIOLACIONES 🔒 (round>100, efectivamente mostradas)]: %d celdas\n", nrow(viol)))
if (nrow(viol) > 0) {
  cat("  por indicador:\n"); print(table(viol$indicador, viol$cohorte))
  cat("  todas a nivel:\n"); print(table(viol$tipo_entidad))
  cat("  muestra (hasta 25):\n")
  print(head(viol[order(-viol$pct), c("vista","indicador","tipo_entidad","cod_entidad","anio_proceso","cohorte","pct")], 25), row.names = FALSE)
}

# =============================================================================
# CAUSA RAIZ: alineacion del denominador egresados (agno = egreso vs proceso)
# =============================================================================
cat("\n--- Diagnostico causa raiz: denominador egresados desalineado 1 anio ---\n")
ins <- cargar_insumos()
egr_n <- ins$egresados |> filter(marca_egreso == 1) |> count(agno, name = "egr")
insc_act <- ins$inscripcion |> mutate(ae = as.integer(anyo_egreso)) |>
  filter(ae == anio_proceso - 1) |> count(anio_proceso, name = "insc_actual")
tab <- insc_act |>
  mutate(egr_agnoP = egr_n$egr[match(anio_proceso, egr_n$agno)],
         egr_agnoP_1 = egr_n$egr[match(anio_proceso - 1, egr_n$agno)],
         pct_MOTOR = round(100 * insc_actual / egr_agnoP, 1),
         pct_ALINEADO = round(100 * insc_actual / egr_agnoP_1, 1))
cat("  egresados keyed por AGNO (egreso); inscripcion..seleccion por PROCESO admision.\n")
cat("  proceso P nutre de egresados P-1, pero el motor usa egresados(agno=P):\n")
print(as.data.frame(tab), row.names = FALSE)

cat(sprintf("\n=== FASE 3 VEREDICTO: %d porcentajes renderizados > 100%% (round) -> %s ===\n",
            nrow(viol), ifelse(nrow(viol) == 0, "PASA", "FALLA (invariante 🔒)")))
saveRDS(viol, "/private/tmp/claude-501/-Users-tomgc-Projects-slep-paes/0faa2e3f-5949-4a63-aad4-96e1c84acd77/scratchpad/fase3_violaciones.rds")
