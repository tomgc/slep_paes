# =============================================================================
# reauditoria_post_fix.R — RE-AUDITORIA tras fixes F1 (egresados agno+1) y F2
# (resguardo en 1.a prioridad). Panel adversarial ajustado a la NUEVA indexacion.
# Fases 1-3 + corolario del hueco. Fase 4 (DOM) se corre aparte con preview.
# =============================================================================
suppressMessages(source("/Users/tomgc/Projects/slep_paes/50_documentacion/andamios/auditoria_datos_pre_push/lib_reauditoria.R"))
suppressMessages(library(tidyr))

cat("=========================================================\n")
cat("RE-AUDITORIA POST-FIX (F1 + F2)\n")
cat("=========================================================\n\n")

jc <- extraer_json_publicado()
cob_pub <- columnar_a_df(jc$cobertura); cob_pub$anio_proceso <- as.integer(cob_pub$anio_proceso)
ren_pub <- columnar_a_df(jc$rendimiento); ren_pub$anio_proceso <- as.integer(ren_pub$anio_proceso)
AA <- as.integer(jc$meta$anio_actual)
cat(sprintf("meta.anio_actual = %d (esperado 2026 tras F1)\n\n", AA))

ins <- cargar_insumos(); mapa <- construir_mapa(ins$cat_estab, ins$cat_slep)
cob_rec <- recalcular_cobertura(ins, mapa); cob_rec$anio_proceso <- as.integer(cob_rec$anio_proceso)
ren_rec <- recalcular_rendimiento(ins, mapa); ren_rec$anio_proceso <- as.integer(ren_rec$anio_proceso)

eqNA  <- function(a,b) (is.na(a)&is.na(b)) | (!is.na(a)&!is.na(b)&a==b)
eqNum <- function(a,b,tol=1e-3) (is.na(a)&is.na(b)) | (!is.na(a)&!is.na(b)&abs(a-b)<tol)

# ---------------- FASE 1: MATCH TOTAL ----------------------------------------
kcob <- c("tipo_entidad","cod_entidad","anio_proceso","cohorte","etapa")
cob_pub$.k <- do.call(paste,c(cob_pub[kcob],sep="|")); cob_rec$.k <- do.call(paste,c(cob_rec[kcob],sep="|"))
orf <- length(setdiff(cob_pub$.k,cob_rec$.k))+length(setdiff(cob_rec$.k,cob_pub$.k))
m <- merge(cob_pub, cob_rec, by=".k", suffixes=c(".pub",".rec"))
sel <- m$etapa.pub=="seleccion"
d_n   <- sum(!eqNA(m$n.pub,m$n.rec))
d_sup <- sum(!eqNA(m$suprimida.pub,m$suprimida.rec))
d_ns  <- sum(!eqNA(m$n_seleccionados.pub[sel],m$n_seleccionados.rec[sel]))
d_np1 <- sum(!eqNA(m$n_prioridad_1.pub[sel],m$n_prioridad_1.rec[sel]))
d_p1  <- sum(!eqNum(m$pct_prioridad_1.pub[sel],m$pct_prioridad_1.rec[sel]))
kren <- c("tipo_entidad","cod_entidad","anio_proceso","cohorte","prueba")
ren_pub$.k <- do.call(paste,c(ren_pub[kren],sep="|")); ren_rec$.k <- do.call(paste,c(ren_rec[kren],sep="|"))
orfr <- length(setdiff(ren_pub$.k,ren_rec$.k))+length(setdiff(ren_rec$.k,ren_pub$.k))
mr <- merge(ren_pub, ren_rec, by=".k", suffixes=c(".pub",".rec"))
d_rn <- sum(!eqNA(mr$n.pub,mr$n.rec)); d_rs <- sum(!eqNA(mr$suprimida.pub,mr$suprimida.rec))
d_rm <- sum(!eqNum(mr$media.pub,mr$media.rec,1e-2))
cat("--- FASE 1 (recalculo vs JSON) ---\n")
cat(sprintf("  cobertura: %d filas | orfandad=%d | n=%d sup=%d nsel=%d np1=%d pct1=%d discrepancias\n",
            nrow(m),orf,d_n,d_sup,d_ns,d_np1,d_p1))
cat(sprintf("  rendimiento: %d filas | orfandad=%d | n=%d sup=%d media=%d discrepancias\n",
            nrow(mr),orfr,d_rn,d_rs,d_rm))
f1_ok <- (orf+d_n+d_sup+d_ns+d_np1+d_p1+orfr+d_rn+d_rs+d_rm)==0
cat(sprintf("  => FASE 1: %s\n\n", ifelse(f1_ok,"MATCH TOTAL","REVISAR")))

# ---------------- FASE 2: aditividad + supresion -----------------------------
raw <- embudo_crudo(ins, mapa)
com2reg <- mapa |> filter(!is.na(cod_comuna),!is.na(cod_region)) |> distinct(cod_comuna,cod_region)
key <- c("anio_proceso","cohorte","etapa")
com <- raw |> filter(tipo_entidad=="comuna"); nac <- raw |> filter(tipo_entidad=="nacional") |> select(all_of(key),n_nac=n)
c1 <- full_join(com |> summarise(n_sum=sum(n),.by=all_of(key)), nac, by=key); c1$ok <- c1$n_sum==c1$n_nac
reg <- raw |> filter(tipo_entidad=="region") |> select(cod_region=cod_entidad,all_of(key),n_reg=n)
c2 <- full_join(com |> left_join(com2reg,by=c("cod_entidad"="cod_comuna")) |> summarise(n_sum=sum(n),.by=c(cod_region,all_of(key))), reg, by=c("cod_region",key)); c2$ok <- c2$n_sum==c2$n_reg
kc <- c("tipo_entidad","cod_entidad","anio_proceso","etapa")
tot <- raw |> filter(cohorte=="todas") |> select(all_of(kc),n_tot=n)
ss <- raw |> filter(cohorte %in% c("actual","anterior")) |> summarise(n_ss=sum(n),.by=all_of(kc))
c4 <- full_join(tot,ss,by=kc); c4$n_ss <- coalesce(c4$n_ss,0L); c4$ok <- c4$n_tot==c4$n_ss
raw$.k <- do.call(paste,c(raw[kcob],sep="|"))
cmp <- merge(cob_pub, raw[,c(".k","n")], by=".k"); names(cmp)[names(cmp)=="n.y"]<-"n_raw"; names(cmp)[names(cmp)=="n.x"]<-"n_pub"
cmp$sup_exp <- !is.na(cmp$n_raw)&cmp$n_raw>0&cmp$n_raw<UMBRAL_AUDIT
sup_regla <- sum(cmp$suprimida!=cmp$sup_exp)
cat("--- FASE 2 (aditividad + supresion) ---\n")
cat(sprintf("  comuna->nacional FALLA=%d | comuna->region FALLA=%d | todas=actual+anterior FALLA=%d | supresion FALLA=%d\n",
            sum(!c1$ok|is.na(c1$ok)), sum(!c2$ok|is.na(c2$ok)), sum(!c4$ok|is.na(c4$ok)), sup_regla))
f2_ok <- (sum(!c1$ok|is.na(c1$ok))+sum(!c2$ok|is.na(c2$ok))+sum(!c4$ok|is.na(c4$ok))+sup_regla)==0
cat(sprintf("  => FASE 2: %s\n\n", ifelse(f2_ok,"ADITIVIDAD/SUPRESION EXACTAS","REVISAR")))

# ---------------- FASE 3: %>100% renderizados --------------------------------
w <- cob_pub |> select(tipo_entidad,cod_entidad,anio_proceso,cohorte,etapa,n) |>
  pivot_wider(names_from=etapa, values_from=n)
p1 <- cob_pub |> filter(etapa=="seleccion") |> select(tipo_entidad,cod_entidad,anio_proceso,cohorte,n_prioridad_1,pct_prioridad_1)
w <- w |> left_join(p1, by=c("tipo_entidad","cod_entidad","anio_proceso","cohorte"))
val <- function(x) !is.na(x)&x>0
w$baseCob <- with(w, ifelse(cohorte=="actual"&val(egresados),egresados, ifelse(val(inscripcion),inscripcion,NA_real_)))
w$baseY   <- with(w, ifelse(cohorte=="actual", ifelse(val(egresados),egresados,NA_real_), ifelse(val(inscripcion),inscripcion,NA_real_)))
mk <- function(num,base,cond,ind,vista){ pct<-100*num/base; i<-which(cond&!is.na(pct))
  if(!length(i)) return(NULL); cbind(vista=vista,indicador=ind,w[i,c("tipo_entidad","cod_entidad","anio_proceso","cohorte")],pct=pct[i]) }
todo <- do.call(rbind, c(
  lapply(c("inscripcion","rendicion","resultados","postulacion","seleccion"), function(e) mk(w[[e]],w$baseCob,w$anio_proceso==AA,e,"CobActual/Comp")),
  lapply(c("rendicion","seleccion"), function(e) mk(w[[e]],w$baseY,rep(TRUE,nrow(w)),e,"CobHist")),
  list(mk(w$n_prioridad_1,w$baseY,rep(TRUE,nrow(w)),"1a_pref_serie","CobHist"))
))
todo$round <- round(todo$pct)
viol <- todo[todo$round>100,]
viol_rend <- viol[viol$tipo_entidad!="rezagados",]      # rezagados NO es navegable en el motor
viol_rez  <- viol[viol$tipo_entidad=="rezagados",]
cat("--- FASE 3 (%>100% renderizados) ---\n")
cat(sprintf("  violaciones RENDERIZADAS (excl. rezagados no-navegable): %d\n", nrow(viol_rend)))
if(nrow(viol_rend)>0){ print(viol_rend[order(-viol_rend$pct),c("vista","indicador","tipo_entidad","cod_entidad","anio_proceso","cohorte","pct")], row.names=FALSE) }
cat(sprintf("  (bucket rezagados, presente en JSON pero NO renderizado: %d celdas >100%%)\n", nrow(viol_rez)))

# ---------------- F2 render check: 0 celdas '0% (0)' enganoso -----------------
sel_pub <- cob_pub[cob_pub$etapa=="seleccion",]
cero_pct <- sel_pub[!is.na(sel_pub$pct_prioridad_1) & sel_pub$pct_prioridad_1==0,]
resguardo <- sel_pub[!is.na(sel_pub$n_seleccionados) & is.na(sel_pub$pct_prioridad_1),]
cat("\n--- F2 (1.a prioridad) ---\n")
cat(sprintf("  celdas con '0%%' mostrado en 1.a prioridad: %d (0 = fix OK)\n", nrow(cero_pct)))
cat(sprintf("  celdas seleccion mostrada + 1.a prioridad en resguardo: %d (antes eran '0%% (0)')\n", nrow(resguardo)))

# ---------------- Corolario del hueco ----------------------------------------
egr_anios <- sort(unique(cob_pub$anio_proceso[cob_pub$etapa=="egresados"]))
todos_anios <- sort(unique(cob_pub$anio_proceso))
cat("\n--- Corolario hueco ---\n")
cat(sprintf("  anios con etapa egresados: %s\n", paste(egr_anios,collapse=",")))
cat(sprintf("  anios de proceso (todos): %s\n", paste(todos_anios,collapse=",")))
cat(sprintf("  proceso 2026 tiene egresados: %s | proceso 2023 (mas antiguo) tiene egresados: %s\n",
            2026 %in% egr_anios, 2023 %in% egr_anios))

cat(sprintf("\n=== RE-AUDITORIA: F1=%s F2=%s pct>100 render=%d(+%d rezagados) 0%%p1=%d ===\n",
            ifelse(f1_ok,"MATCH","X"), ifelse(f2_ok,"OK","X"), nrow(viol_rend), nrow(viol_rez), nrow(cero_pct)))
saveRDS(list(cob_rec=cob_rec, viol_rend=viol_rend, viol_rez=viol_rez),
        "/private/tmp/claude-501/-Users-tomgc-Projects-slep-paes/0faa2e3f-5949-4a63-aad4-96e1c84acd77/scratchpad/reaudit.rds")
