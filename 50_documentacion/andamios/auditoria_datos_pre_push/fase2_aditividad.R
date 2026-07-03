# =============================================================================
# fase2_aditividad.R — FASE 2: aditividad territorial post-supresion
# -----------------------------------------------------------------------------
# Panel adversarial (codigo propio). Verifica, sobre conteos CRUDOS
# (pre-supresion) recalculados de forma independiente:
#   (1) comuna -> nacional  (particion exacta)
#   (2) comuna -> region    (particion exacta por region)
#   (3) region -> nacional  (con nota de comunas sin region)
#   (4) cohorte: todas == actual + anterior  (pre-supresion)
#   (5) supresion k-anon (n in [1,7] -> NA) aplicada consistentemente en TODOS
#       los niveles (comuna/slep/region/nacional/rezagados) vs JSON publicado.
#   (6) SLEP (donde aplique): NO es particion de comunas (traspaso Decision 2);
#       se verifica la particion valida a nivel establecimiento (comuna∩SLEP)
#       para el SLEP Costa Central (503).
# =============================================================================
suppressMessages(source("/Users/tomgc/Projects/slep_paes/50_documentacion/andamios/auditoria_datos_pre_push/lib_auditoria.R"))

cat("=========================================================\n")
cat("FASE 2 — Aditividad territorial post-supresion\n")
cat("=========================================================\n\n")

ins  <- cargar_insumos()
mapa <- construir_mapa(ins$cat_estab, ins$cat_slep)
raw  <- embudo_crudo(ins, mapa)   # tipo_entidad,cod_entidad,anio_proceso,cohorte,etapa,n (CRUDO)

# comuna -> region: debe ser funcion (cada comuna -> exactamente 1 region)
com2reg <- mapa |> filter(!is.na(cod_comuna), !is.na(cod_region)) |>
  distinct(cod_comuna, cod_region)
dup_com <- com2reg |> count(cod_comuna) |> filter(n > 1)
cat(sprintf("[map] comuna->region 1:1: %s (%d comunas con >1 region)\n",
            ifelse(nrow(dup_com) == 0, "SI", "NO"), nrow(dup_com)))

key <- c("anio_proceso", "cohorte", "etapa")

# --- (1) comuna -> nacional --------------------------------------------------
com <- raw |> filter(tipo_entidad == "comuna")
nac <- raw |> filter(tipo_entidad == "nacional") |> select(all_of(key), n_nac = n)
sum_com <- com |> summarise(n_sum = sum(n), .by = all_of(key))
c1 <- full_join(sum_com, nac, by = key)
c1$ok <- c1$n_sum == c1$n_nac
cat(sprintf("\n(1) comuna->nacional: %d combinaciones, %d OK, %d FALLA\n",
            nrow(c1), sum(c1$ok, na.rm = TRUE), sum(!c1$ok | is.na(c1$ok))))

# --- (2) comuna -> region ----------------------------------------------------
reg <- raw |> filter(tipo_entidad == "region") |> select(cod_region = cod_entidad, all_of(key), n_reg = n)
sum_com_reg <- com |> left_join(com2reg, by = c("cod_entidad" = "cod_comuna")) |>
  summarise(n_sum = sum(n), .by = c(cod_region, all_of(key)))
c2 <- full_join(sum_com_reg, reg, by = c("cod_region", key))
c2$ok <- c2$n_sum == c2$n_reg
cat(sprintf("(2) comuna->region: %d combinaciones region x etapa x cohorte x anio, %d OK, %d FALLA\n",
            nrow(c2), sum(c2$ok, na.rm = TRUE), sum(!c2$ok | is.na(c2$ok))))
com_sin_reg <- com |> left_join(com2reg, by = c("cod_entidad" = "cod_comuna")) |> filter(is.na(cod_region))
cat(sprintf("    (comunas sin region mapeada: %d filas -> se excluyen del nivel region, no de nacional)\n",
            nrow(com_sin_reg)))

# --- (3) region -> nacional --------------------------------------------------
sum_reg <- reg |> summarise(n_sum = sum(n_reg), .by = all_of(key))
c3 <- full_join(sum_reg, nac, by = key)
# nacional = suma regiones + personas con comuna pero SIN region
faltante <- com_sin_reg |> summarise(n_sr = sum(n), .by = all_of(key))
c3 <- c3 |> left_join(faltante, by = key) |> mutate(n_sr = coalesce(n_sr, 0L))
c3$ok <- (c3$n_sum + c3$n_sr) == c3$n_nac
cat(sprintf("(3) region(+comunas sin region)->nacional: %d combinaciones, %d OK, %d FALLA\n",
            nrow(c3), sum(c3$ok, na.rm = TRUE), sum(!c3$ok | is.na(c3$ok))))

# --- (4) cohorte: todas == actual + anterior (crudo) -------------------------
kc <- c("tipo_entidad", "cod_entidad", "anio_proceso", "etapa")
tot <- raw |> filter(cohorte == "todas") |> select(all_of(kc), n_tot = n)
ss  <- raw |> filter(cohorte %in% c("actual", "anterior")) |>
  summarise(n_ss = sum(n), .by = all_of(kc))
c4 <- full_join(tot, ss, by = kc)
c4$n_ss <- coalesce(c4$n_ss, 0L)
c4$ok <- c4$n_tot == c4$n_ss
cat(sprintf("(4) cohorte todas==actual+anterior (crudo): %d celdas, %d OK, %d FALLA\n",
            nrow(c4), sum(c4$ok, na.rm = TRUE), sum(!c4$ok | is.na(c4$ok))))

# --- (5) supresion consistente en TODOS los niveles vs JSON publicado --------
jc <- extraer_json_publicado(); pub <- columnar_a_df(jc$cobertura)
pub$anio_proceso <- as.integer(pub$anio_proceso)
kfull <- c("tipo_entidad", "cod_entidad", "anio_proceso", "cohorte", "etapa")
raw$.k <- do.call(paste, c(raw[kfull], sep = "|"))
pub$.k <- do.call(paste, c(pub[kfull], sep = "|"))
cmp <- merge(pub, raw[, c(".k", "n")], by = ".k", suffixes = c(".pub", ".raw"))
names(cmp)[names(cmp) == "n.raw"] <- "n_raw"; names(cmp)[names(cmp) == "n.pub"] <- "n_pub"
cmp$sup_expected <- !is.na(cmp$n_raw) & cmp$n_raw > 0 & cmp$n_raw < UMBRAL_AUDIT
cmp$ok_sup <- cmp$suprimida == cmp$sup_expected
cmp$ok_val <- ifelse(cmp$sup_expected, is.na(cmp$n_pub), !is.na(cmp$n_pub) & cmp$n_pub == cmp$n_raw)
cat(sprintf("(5) supresion k-anon consistente (%d celdas todas-niveles): regla_sup %d OK / %d FALLA ; valor %d OK / %d FALLA\n",
            nrow(cmp), sum(cmp$ok_sup), sum(!cmp$ok_sup), sum(cmp$ok_val), sum(!cmp$ok_val)))
cat("    supresion por nivel (celdas suprimidas / total):\n")
print(cmp |> summarise(suprimidas = sum(sup_expected), total = n(), .by = tipo_entidad))

# --- (6) SLEP: particion a nivel establecimiento (CC=503) --------------------
# SLEP no particiona comunas; SI particiona por establecimiento. Verificamos que
# el total del SLEP 503 == suma sobre comunas de personas cuyo rbd cae en 503.
P <- personas_embudo(ins)
etapas <- c("egresados", "inscripcion", "rendicion", "resultados", "postulacion", "seleccion")
slep_check <- do.call(rbind, lapply(etapas, function(e) {
  d <- left_join(P[[e]], mapa, by = "rbd") |> filter(cod_slep == "503")
  # total SLEP directo por cohorte
  tot_dir <- bind_rows(
    d |> summarise(n = n(), .by = c(anio_proceso, cohorte)),
    d |> summarise(n = n(), .by = c(anio_proceso)) |> mutate(cohorte = "todas")
  )
  # suma sobre comunas (particion por establecimiento)
  suma_com <- bind_rows(
    d |> summarise(n = n(), .by = c(anio_proceso, cohorte, cod_comuna)) |>
      summarise(n = sum(n), .by = c(anio_proceso, cohorte)),
    d |> summarise(n = n(), .by = c(anio_proceso, cod_comuna)) |>
      summarise(n = sum(n), .by = c(anio_proceso)) |> mutate(cohorte = "todas")
  )
  m <- full_join(tot_dir, suma_com, by = c("anio_proceso", "cohorte"), suffix = c("_dir", "_com"))
  m$etapa <- e; m
}))
slep_check$ok <- slep_check$n_dir == slep_check$n_com
cat(sprintf("\n(6) SLEP 503 particion por establecimiento (comuna∩SLEP): %d celdas, %d OK, %d FALLA\n",
            nrow(slep_check), sum(slep_check$ok, na.rm = TRUE), sum(!slep_check$ok | is.na(slep_check$ok))))

# --- VEREDICTO ---------------------------------------------------------------
fallas <- c(
  c1 = sum(!c1$ok | is.na(c1$ok)), c2 = sum(!c2$ok | is.na(c2$ok)),
  c3 = sum(!c3$ok | is.na(c3$ok)), c4 = sum(!c4$ok | is.na(c4$ok)),
  sup_regla = sum(!cmp$ok_sup), sup_valor = sum(!cmp$ok_val),
  slep = sum(!slep_check$ok | is.na(slep_check$ok))
)
cat("\n[FALLAS por check]:\n"); print(fallas)
cat(sprintf("\n=== FASE 2 VEREDICTO: %s ===\n",
            ifelse(sum(fallas) == 0, "ADITIVIDAD Y SUPRESION EXACTAS (0 excepciones)", "REVISAR")))
