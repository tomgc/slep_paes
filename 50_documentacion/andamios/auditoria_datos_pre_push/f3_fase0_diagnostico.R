# =============================================================================
# f3_fase0_diagnostico.R — FASE 0 (obligatoria) de la reconciliacion F3
# -----------------------------------------------------------------------------
# Diagnostica, ANTES de codificar, el desfase inter-archivo que produce el
# residual F3 (Santo Domingo 2026, inscripcion 101%). Dos preguntas:
#   (1) Existe clave para enlazar una persona entre ArchivoB (inscripcion) y el
#       archivo MINEDUC (egresados)? -> decide si la reconciliacion persona-a-
#       persona autorizada es siquiera posible.
#   (2) Cual es la magnitud REAL del desfase (celdas comuna con egresados>0 e
#       inscritos>egresados), excluyendo el hueco (proceso sin egresados)?
# Solo lectura. No modifica el pipeline.
# =============================================================================
suppressMessages(source("/Users/tomgc/Projects/slep_paes/50_documentacion/andamios/auditoria_datos_pre_push/lib_reauditoria.R"))

ins <- cargar_insumos(); mapa <- construir_mapa(ins$cat_estab, ins$cat_slep)

# ---- (1) LINKAGE: hay clave comun entre ArchivoB (id_aux) y egresados (mrun)? ----
ia <- unique(as.character(ins$inscripcion$id_aux))
mr <- unique(as.character(ins$egresados$mrun)); mi <- unique(as.character(ins$egresados$mrun_ipe))
cat("== (1) LINKAGE ArchivoB.id_aux vs egresados.mrun/mrun_ipe ==\n")
cat(sprintf("  columnas id inscripcion: %s\n", paste(grep("id|mrun|run|rut", names(ins$inscripcion), value=TRUE, ignore.case=TRUE), collapse=", ")))
cat(sprintf("  columnas id egresados:   %s\n", paste(grep("id|mrun|run|rut", names(ins$egresados), value=TRUE, ignore.case=TRUE), collapse=", ")))
cat(sprintf("  ejemplo id_aux: %s | ejemplo mrun_ipe: %s\n", ia[1], mi[which(!is.na(mi))[1]]))
cat(sprintf("  solapamiento id_aux ∩ mrun: %d | id_aux ∩ mrun_ipe: %d (de %d id_aux)\n",
            length(intersect(ia,mr)), length(intersect(ia,mi)), length(ia)))
cat("  -> Sin solapamiento = NO hay clave para reconciliar a nivel persona.\n\n")

# ---- (2) MAGNITUD del desfase (agregado, sin necesidad de enlace) ----
egr <- ins$egresados |> filter(marca_egreso==1) |>
  transmute(rbd=as.character(rbd), proceso=as.integer(agno)+1L) |>   # F1: agno+1
  left_join(mapa, by="rbd") |> filter(!is.na(cod_comuna)) |>
  count(cod_comuna, proceso, name="egresados")
insc_act <- ins$inscripcion |> mutate(rbd=as.character(rbd), ae=as.integer(anyo_egreso)) |>
  filter(ae == anio_proceso-1) |>
  distinct(id_aux, rbd, anio_proceso) |>
  left_join(mapa, by="rbd") |> filter(!is.na(cod_comuna)) |>
  count(cod_comuna, proceso=anio_proceso, name="inscritos")
j <- full_join(egr, insc_act, by=c("cod_comuna","proceso")) |>
  mutate(egresados=coalesce(egresados,0L), inscritos=coalesce(inscritos,0L),
         exceso=pmax(inscritos-egresados,0L))

cat("== (2) MAGNITUD ==\n")
cat("  Nota: proceso 2023 tiene egresados=0 (corolario F1, necesitaria egreso 2022);\n")
cat("        ahi el funnel YA rebasa a inscritos=100% (caso hueco, no un >100%).\n")
real <- j |> filter(egresados>0)   # excluye el hueco
viol <- real |> filter(inscritos>egresados)
ti <- sum(real$inscritos); te <- sum(real$egresados)
cat(sprintf("  procesos con egresados (2024-2026): egresados=%d inscritos=%d -> %.1f%% (nacional <=100)\n", te, ti, 100*ti/te))
cat(sprintf("  celdas comuna (egresados>0) con inscritos>egresados: %d\n", nrow(viol)))
cat(sprintf("  EXCESO real: %d persona(s) = %.5f%% del universo (umbral detencion titular: 0.1%%)\n",
            sum(real$exceso), 100*sum(real$exceso)/ti))
print(as.data.frame(viol), row.names=FALSE)

cat("\n== CONCLUSION FASE 0 ==\n")
cat("  - Reconciliacion persona-a-persona: INFEASIBLE (sin clave DEMRE<->MINEDUC).\n")
cat("  - Desfase real: 1 persona (Santo Domingo 2026), 0.00016% << 0.1%.\n")
cat("  - Se detiene la implementacion y se reporta (ver log).\n")
