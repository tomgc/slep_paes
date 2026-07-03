# =============================================================================
# reauditoria_rendimiento_vigente.R — panel adversarial del "mejor puntaje
# vigente" (ventana=4). Recalculo INDEPENDIENTE del max-vigente desde los
# parquets crudos y comparacion celda-a-celda contra el JSON publicado.
# Ademas cuantifica el delta nacional vs la publicacion anterior (reg-actual).
# Solo lectura.
# =============================================================================
suppressMessages(source("/Users/tomgc/Projects/slep_paes/50_documentacion/andamios/auditoria_datos_pre_push/lib_auditoria.R"))

PRUEBAS5 <- c("clec", "mate1", "mate2", "cien", "hcsoc")

cat("=========================================================\n")
cat("RE-AUDITORIA — mejor puntaje vigente (ventana=4)\n")
cat("=========================================================\n\n")

ins <- cargar_insumos(); mapa <- construir_mapa(ins$cat_estab, ins$cat_slep)
ren <- ins$rendicion |> mutate(rbd = as.character(rbd))
egreso_lookup <- ins$inscripcion |>
  distinct(id_aux, anio_proceso, anyo_egreso = as.integer(anyo_egreso))
rend_coh <- ren |>
  left_join(egreso_lookup, by = c("id_aux", "anio_proceso")) |>
  mutate(cohorte = cohorte_audit(anyo_egreso, anio_proceso))

# --- Recalculo independiente del mejor vigente (max sobre las 4 casillas) -----
mejor <- rend_coh |>
  filter(prueba %in% PRUEBAS5) |>
  summarise(puntaje = max(puntaje), .by = c("id_aux", "anio_proceso", "rbd", "prueba", "cohorte"))
vig_rec <- agregar_promedio_cohorte_audit(mejor, mapa, "puntaje",
                                          by_base = c("anio_proceso", "prueba"))
# suprimir + enmascarar media (igual que 32)
sp <- suprimir_n(vig_rec$n); vig_rec$n <- sp$n; vig_rec$suprimida <- sp$suprimida
vig_rec$media <- ifelse(vig_rec$suprimida, NA_real_, vig_rec$media)
vig_rec$anio_proceso <- as.integer(vig_rec$anio_proceso)

# --- JSON publicado (rendimiento ya trae el vigente para las 5 pruebas) -------
jc <- extraer_json_publicado(); ren_pub <- columnar_a_df(jc$rendimiento)
ren_pub$anio_proceso <- as.integer(ren_pub$anio_proceso)
pub5 <- ren_pub |> filter(prueba %in% PRUEBAS5)

k <- c("tipo_entidad", "cod_entidad", "anio_proceso", "cohorte", "prueba")
vig_rec$.k <- do.call(paste, c(vig_rec[k], sep = "|"))
pub5$.k   <- do.call(paste, c(pub5[k], sep = "|"))
orf <- length(setdiff(pub5$.k, vig_rec$.k)) + length(setdiff(vig_rec$.k, pub5$.k))
m <- merge(pub5, vig_rec, by = ".k", suffixes = c(".pub", ".rec"))
eqNA  <- function(a, b) (is.na(a) & is.na(b)) | (!is.na(a) & !is.na(b) & a == b)
eqNum <- function(a, b, tol = 1e-2) (is.na(a) & is.na(b)) | (!is.na(a) & !is.na(b) & abs(a - b) < tol)
d_n <- sum(!eqNA(m$n.pub, m$n.rec)); d_s <- sum(!eqNA(m$suprimida.pub, m$suprimida.rec))
d_m <- sum(!eqNum(m$media.pub, m$media.rec))
cat(sprintf("[VIGENTE 5 pruebas] filas pub=%d rec=%d | orfandad=%d | n=%d sup=%d media=%d discrepancias\n",
            nrow(pub5), nrow(vig_rec), orf, d_n, d_s, d_m))
cat(sprintf("  => %s\n\n", ifelse(orf + d_n + d_s + d_m == 0, "MATCH TOTAL", "REVISAR")))

# --- NEM/Ranking: no deben cambiar ------------------------------------------
renrec <- recalcular_rendimiento(ins, mapa)  # incluye nem/ranking (subset publicado)
nr_rec <- renrec |> filter(prueba %in% c("nem", "ranking")); nr_rec$anio_proceso <- as.integer(nr_rec$anio_proceso)
nr_pub <- ren_pub |> filter(prueba %in% c("nem", "ranking"))
nr_rec$.k <- do.call(paste, c(nr_rec[k], sep = "|")); nr_pub$.k <- do.call(paste, c(nr_pub[k], sep = "|"))
mnr <- merge(nr_pub, nr_rec, by = ".k", suffixes = c(".pub", ".rec"))
cat(sprintf("[NEM/RANKING] %d filas | n=%d media=%d discrepancias (deben ser 0, sin cambio)\n\n",
            nrow(mnr), sum(!eqNA(mnr$n.pub, mnr$n.rec)), sum(!eqNum(mnr$media.pub, mnr$media.rec))))

# --- DELTA NACIONAL: vigente (nuevo) vs reg-actual (publicacion anterior) -----
d32 <- arrow::read_parquet(file.path(DATA_ROOT, "40_salidas", "intermedios", "paes_rendimiento_territorial.parquet"))
d32$anio_proceso <- as.integer(d32$anio_proceso)
comp <- d32 |> filter(tipo_entidad == "nacional", vigencia == "actual", prueba %in% PRUEBAS5) |>
  filter(tipo_rendicion %in% c("reg", "vigente")) |>
  select(anio_proceso, prueba, cohorte, tipo_rendicion, n, media) |>
  tidyr::pivot_wider(names_from = tipo_rendicion, values_from = c(n, media))
comp <- comp |> mutate(delta_media = round(media_vigente - media_reg, 1),
                       delta_n = n_vigente - n_reg)
cat("[DELTA NACIONAL] vigente (ventana=4) vs reg-actual (publicacion anterior), cohorte 'todas':\n")
print(as.data.frame(comp |> filter(cohorte == "todas") |>
                    select(anio_proceso, prueba, media_reg, media_vigente, delta_media, delta_n) |>
                    arrange(prueba, anio_proceso)), row.names = FALSE)
cat("\n  (delta_n > 0: personas agregadas por ventana=4 = solo-invierno + solo-anterior;\n")
cat("   delta_media puede ser +/- porque esas personas mueven el promedio, aunque cada\n")
cat("   individuo con reg-actual mejora o iguala su puntaje.)\n")
