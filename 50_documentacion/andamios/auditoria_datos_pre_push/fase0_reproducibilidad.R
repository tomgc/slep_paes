# =============================================================================
# fase0_reproducibilidad.R — FASE 0 de la auditoria de datos pre-push
# -----------------------------------------------------------------------------
# (1) Verifica el invariante UMBRAL de forma independiente (audit vs config).
# (2) Extrae y resume el JSON PUBLICADO (docs/index.html committeado).
# (3) Confirma que run_all(only=33) es reproducible y que el artefacto
#     committeado coincide con lo que produce el pipeline sobre los parquets
#     actuales (deteccion de staleness). Restaura el docs committeado al final.
# NO modifica codigo. Corre desde ~/Projects/slep_paes.
# =============================================================================
suppressMessages(source("/Users/tomgc/Projects/slep_paes/50_documentacion/andamios/auditoria_datos_pre_push/lib_auditoria.R"))
SCRATCH <- "/private/tmp/claude-501/-Users-tomgc-Projects-slep-paes/0faa2e3f-5949-4a63-aad4-96e1c84acd77/scratchpad"

cat("=========================================================\n")
cat("FASE 0 — Lectura del estado real\n")
cat("=========================================================\n\n")

# (1) INVARIANTE UMBRAL (independiente): parsear el valor real de config
cfg_lines <- readLines(file.path(REPO_ROOT, "10_utils", "10_configuracion.R"), warn = FALSE)
cfg_umbral <- as.integer(sub(".*UMBRAL_SUPRESION_CELDA\\s*<-\\s*([0-9]+)L.*", "\\1",
                             grep("^UMBRAL_SUPRESION_CELDA\\s*<-", cfg_lines, value = TRUE)))
cat(sprintf("[INV umbral] audit=%d  config=%d  -> %s\n\n", UMBRAL_AUDIT, cfg_umbral,
            ifelse(UMBRAL_AUDIT == cfg_umbral && cfg_umbral == 8L, "PASA", "FALLA")))
stopifnot(UMBRAL_AUDIT == cfg_umbral, cfg_umbral == 8L)

# (2) JSON publicado committeado
docs <- file.path(REPO_ROOT, "docs", "index.html")
backup <- file.path(SCRATCH, "index_committed.html")
file.copy(docs, backup, overwrite = TRUE)
jc <- extraer_json_publicado(backup)
cob_c <- columnar_a_df(jc$cobertura); ren_c <- columnar_a_df(jc$rendimiento)
cat("[JSON publicado committeado]\n")
cat(sprintf("  meta.anio_actual=%s  anios=%s\n", jc$meta$anio_actual,
            paste(jc$meta$anios, collapse = ",")))
cat(sprintf("  meta.umbral=%s  fecha_generacion=%s\n", jc$meta$umbral, jc$meta$fecha_generacion))
cat(sprintf("  cobertura: %d filas | cols: %s\n", nrow(cob_c), paste(names(cob_c), collapse = ",")))
cat(sprintf("  rendimiento: %d filas | cols: %s\n", nrow(ren_c), paste(names(ren_c), collapse = ",")))
cat(sprintf("  tipo_entidad (cob): %s\n", paste(sort(unique(cob_c$tipo_entidad)), collapse = ",")))
cat(sprintf("  cohorte (cob): %s\n", paste(sort(unique(cob_c$cohorte)), collapse = ",")))
cat(sprintf("  etapa (cob): %s\n", paste(sort(unique(cob_c$etapa)), collapse = ",")))
cat(sprintf("  prueba (ren): %s\n\n", paste(sort(unique(ren_c$prueba)), collapse = ",")))
saveRDS(list(meta = jc$meta, cob = cob_c, ren = ren_c), file.path(SCRATCH, "json_committeado.rds"))

# (3) Reproducibilidad + staleness: regenerar y comparar payload
cat("[Reproducibilidad] corriendo run_all(only=33)...\n")
suppressMessages(source(file.path(REPO_ROOT, "00_run_all.R")))
invisible(capture.output(run_all(only = 33)))
jr <- extraer_json_publicado(docs)
cob_r <- columnar_a_df(jr$cobertura); ren_r <- columnar_a_df(jr$rendimiento)

ident_cob <- isTRUE(all.equal(cob_c, cob_r))
ident_ren <- isTRUE(all.equal(ren_c, ren_r))
meta_c <- jc$meta; meta_r <- jr$meta
meta_c$fecha_generacion <- meta_r$fecha_generacion <- NULL
ident_meta <- isTRUE(all.equal(meta_c, meta_r))
cat(sprintf("  cobertura payload identico:  %s\n", ident_cob))
cat(sprintf("  rendimiento payload identico: %s\n", ident_ren))
cat(sprintf("  meta (sin fecha) identico:   %s\n", ident_meta))
cat(sprintf("  -> REPRODUCIBLE / NO STALE: %s\n\n",
            ifelse(ident_cob && ident_ren && ident_meta, "SI", "NO (revisar)")))

# Restaurar el docs committeado (evita diff espurio de fecha_generacion)
file.copy(backup, docs, overwrite = TRUE)
cat("[cleanup] docs/index.html restaurado al artefacto committeado.\n")
cat("\nFASE 0 OK.\n")
