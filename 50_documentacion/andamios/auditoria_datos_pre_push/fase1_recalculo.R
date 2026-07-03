# =============================================================================
# fase1_recalculo.R — FASE 1: recalculo independiente (panel adversarial)
# -----------------------------------------------------------------------------
# Recalcula TODOS los indicadores publicados desde los parquets crudos con codigo
# propio (lib_auditoria.R) y los compara celda-a-celda contra el JSON PUBLICADO
# (docs/index.html committeado). Poblacion completa, no muestreo:
#   - cobertura: 6 etapas x 3 cohortes x todos los territorios x todos los anios
#     (+ n_seleccionados, n_prioridad_1, pct_prioridad_1 en seleccion).
#   - rendimiento: subset publicado (reg+actual + nem/ranking) x 3 cohortes.
# Criterio B.4: 0 discrepancias, o discrepancia con causa raiz documentada.
# =============================================================================
suppressMessages(source("/Users/tomgc/Projects/slep_paes/50_documentacion/andamios/auditoria_datos_pre_push/lib_auditoria.R"))

cat("=========================================================\n")
cat("FASE 1 — Recalculo independiente vs JSON publicado\n")
cat("=========================================================\n\n")

# --- JSON publicado committeado ----------------------------------------------
jc <- extraer_json_publicado()
cob_pub <- columnar_a_df(jc$cobertura)
ren_pub <- columnar_a_df(jc$rendimiento)
# tipos coherentes
cob_pub$anio_proceso <- as.integer(cob_pub$anio_proceso)
ren_pub$anio_proceso <- as.integer(ren_pub$anio_proceso)

# --- Recalculo independiente -------------------------------------------------
cat("[recalculo] cargando parquets crudos y agregando (codigo propio)...\n")
ins <- cargar_insumos()
mapa <- construir_mapa(ins$cat_estab, ins$cat_slep)
cob_rec <- recalcular_cobertura(ins, mapa)
ren_rec <- recalcular_rendimiento(ins, mapa)
cob_rec$anio_proceso <- as.integer(cob_rec$anio_proceso)
ren_rec$anio_proceso <- as.integer(ren_rec$anio_proceso)

# =============================================================================
# COMPARACION COBERTURA
# =============================================================================
kcob <- c("tipo_entidad", "cod_entidad", "anio_proceso", "cohorte", "etapa")
cob_pub$.k <- do.call(paste, c(cob_pub[kcob], sep = "|"))
cob_rec$.k <- do.call(paste, c(cob_rec[kcob], sep = "|"))

# orfandad (filas en un lado y no en el otro)
orf_pub <- setdiff(cob_pub$.k, cob_rec$.k)
orf_rec <- setdiff(cob_rec$.k, cob_pub$.k)
cat(sprintf("\n[COBERTURA] filas pub=%d rec=%d | solo-pub=%d solo-rec=%d\n",
            nrow(cob_pub), nrow(cob_rec), length(orf_pub), length(orf_rec)))

m <- merge(cob_pub, cob_rec, by = ".k", suffixes = c(".pub", ".rec"))
eqNA <- function(a, b) (is.na(a) & is.na(b)) | (!is.na(a) & !is.na(b) & a == b)
eqNum <- function(a, b, tol = 1e-3) (is.na(a) & is.na(b)) | (!is.na(a) & !is.na(b) & abs(a - b) < tol)

m$ok_n   <- eqNA(m$n.pub, m$n.rec)
m$ok_sup <- eqNA(m$suprimida.pub, m$suprimida.rec)
# solo en seleccion aplican nsel/np1/pct1
sel <- m$etapa.pub == "seleccion"
m$ok_nsel <- TRUE; m$ok_np1 <- TRUE; m$ok_pct1 <- TRUE
m$ok_nsel[sel] <- eqNA(m$n_seleccionados.pub[sel], m$n_seleccionados.rec[sel])
m$ok_np1[sel]  <- eqNA(m$n_prioridad_1.pub[sel],  m$n_prioridad_1.rec[sel])
m$ok_pct1[sel] <- eqNum(m$pct_prioridad_1.pub[sel], m$pct_prioridad_1.rec[sel])

res_cob <- data.frame(
  check = c("n", "suprimida", "n_seleccionados", "n_prioridad_1", "pct_prioridad_1"),
  total = c(nrow(m), nrow(m), sum(sel), sum(sel), sum(sel)),
  match = c(sum(m$ok_n), sum(m$ok_sup), sum(m$ok_nsel[sel]), sum(m$ok_np1[sel]), sum(m$ok_pct1[sel]))
)
res_cob$mismatch <- res_cob$total - res_cob$match
cat("\n[COBERTURA] resultado por check:\n"); print(res_cob, row.names = FALSE)

# max % >100 chequeo rapido (se profundiza en fase 3)
cat(sprintf("\n[COBERTURA] filas comparadas (merge): %d\n", nrow(m)))

# muestras de mismatch (sin exponer RBD/RUT; cod_entidad territorial es publico)
mm <- m[!(m$ok_n & m$ok_sup & m$ok_nsel & m$ok_np1 & m$ok_pct1), ]
if (nrow(mm) > 0) {
  cat(sprintf("\n[COBERTURA] %d filas con discrepancia. Muestra (hasta 20):\n", nrow(mm)))
  print(head(mm[, c("tipo_entidad.pub","cod_entidad.pub","anio_proceso.pub","cohorte.pub","etapa.pub",
                    "n.pub","n.rec","n_seleccionados.pub","n_seleccionados.rec",
                    "n_prioridad_1.pub","n_prioridad_1.rec","pct_prioridad_1.pub","pct_prioridad_1.rec")], 20),
        row.names = FALSE)
} else cat("\n[COBERTURA] 0 discrepancias.\n")

# --- HALLAZGO: "0% enganoso" en 1.a prioridad --------------------------------
# Celdas seleccion donde n_seleccionados se MUESTRA (>=8) pero el conteo real de
# 1.a prioridad esta suprimido (1..7) -> 32 coalesce a 0 -> se publica "0% (0)"
# indistinguible de un cero genuino (convencion del proyecto: suprimido = "resguardo").
sel_rec <- cob_rec[cob_rec$etapa == "seleccion", ]
afect <- sel_rec[!is.na(sel_rec$n_seleccionados) & sel_rec$n_p1_raw >= 1 & sel_rec$n_p1_raw <= 7, ]
cat(sprintf("\n[HALLAZGO 0%% 1.a prioridad] celdas con pct=0%% visible pero n_prioridad_1 real 1..7: %d\n",
            nrow(afect)))
if (nrow(afect) > 0) {
  cat("  por tipo_entidad:\n"); print(table(afect$tipo_entidad))
  cat("  por cohorte:\n"); print(table(afect$cohorte))
  cat(sprintf("  todas con pct publicado == 0: %s\n",
              all(cob_pub$pct_prioridad_1[match(do.call(paste,c(afect[kcob],sep='|')), cob_pub$.k)] == 0, na.rm = TRUE)))
}

# =============================================================================
# COMPARACION RENDIMIENTO (subset publicado)
# =============================================================================
kren <- c("tipo_entidad", "cod_entidad", "anio_proceso", "cohorte", "prueba")
ren_pub$.k <- do.call(paste, c(ren_pub[kren], sep = "|"))
ren_rec$.k <- do.call(paste, c(ren_rec[kren], sep = "|"))
orf_rpub <- setdiff(ren_pub$.k, ren_rec$.k)
orf_rrec <- setdiff(ren_rec$.k, ren_pub$.k)
cat(sprintf("\n[RENDIMIENTO] filas pub=%d rec=%d | solo-pub=%d solo-rec=%d\n",
            nrow(ren_pub), nrow(ren_rec), length(orf_rpub), length(orf_rrec)))

mr <- merge(ren_pub, ren_rec, by = ".k", suffixes = c(".pub", ".rec"))
mr$ok_n     <- eqNA(mr$n.pub, mr$n.rec)
mr$ok_sup   <- eqNA(mr$suprimida.pub, mr$suprimida.rec)
mr$ok_media <- eqNum(mr$media.pub, mr$media.rec, tol = 1e-2)
res_ren <- data.frame(
  check = c("n", "suprimida", "media"),
  total = nrow(mr),
  match = c(sum(mr$ok_n), sum(mr$ok_sup), sum(mr$ok_media))
)
res_ren$mismatch <- res_ren$total - res_ren$match
cat("\n[RENDIMIENTO] resultado por check:\n"); print(res_ren, row.names = FALSE)

mmr <- mr[!(mr$ok_n & mr$ok_sup & mr$ok_media), ]
if (nrow(mmr) > 0) {
  cat(sprintf("\n[RENDIMIENTO] %d filas con discrepancia. Muestra (hasta 20):\n", nrow(mmr)))
  print(head(mmr[, c("tipo_entidad.pub","cod_entidad.pub","anio_proceso.pub","cohorte.pub","prueba.pub",
                     "n.pub","n.rec","media.pub","media.rec")], 20), row.names = FALSE)
} else cat("\n[RENDIMIENTO] 0 discrepancias.\n")

# =============================================================================
# VEREDICTO FASE 1
# =============================================================================
disc_cob <- sum(res_cob$mismatch) + length(orf_pub) + length(orf_rec)
disc_ren <- sum(res_ren$mismatch) + length(orf_rpub) + length(orf_rrec)
cat(sprintf("\n=== FASE 1 VEREDICTO: cobertura discrepancias=%d | rendimiento discrepancias=%d -> %s ===\n",
            disc_cob, disc_ren, ifelse(disc_cob == 0 && disc_ren == 0, "MATCH TOTAL", "REVISAR")))
saveRDS(list(res_cob = res_cob, res_ren = res_ren, orf_pub = orf_pub, orf_rec = orf_rec,
             orf_rpub = orf_rpub, orf_rrec = orf_rrec, cob_rec = cob_rec, ren_rec = ren_rec),
        "/private/tmp/claude-501/-Users-tomgc-Projects-slep-paes/0faa2e3f-5949-4a63-aad4-96e1c84acd77/scratchpad/fase1_resultado.rds")
