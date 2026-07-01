# =============================================================================
# 30_construir_auxiliares.R
# -----------------------------------------------------------------------------
# Proyecto : slep_paes
# Proposito: Construir los catalogos territoriales del proyecto a partir del
#            directorio oficial PUBLICO (reusado, sin RUT/MRUN) y el listado
#            SLEP. Salidas en 40_salidas/intermedios/:
#              1. comunas_chile.parquet        comuna -> region
#              2. sleps_chile.parquet          SLEP x RBD (+ rama prospectiva)
#              3. establecimientos_chile.parquet  RBD -> comuna/region/dependencia
#            Es la fuente del cruce RBD -> territorio de 31_/32_ y de la
#            navegacion territorial del motor. Patron reusado de los hermanos
#            (slep_categoria_desempeno), adaptado a slep_paes.
# Insumos  : 20_insumos/auxiliares/directorio_oficial_ee_publico.csv
#            20_insumos/auxiliares/listado_slep_2026.xlsx (hoja "Listado SLEP")
# Salidas  : 40_salidas/intermedios/{comunas,sleps,establecimientos}_chile.parquet
# Fecha    : 2026-06-30
# -----------------------------------------------------------------------------
# NOTA: este paso SI es ejecutable (sus insumos ya estan en el repo). Las llaves
# (rbd, cod_com_rbd, cod_reg_rbd, cod_slep) van SIEMPRE como character (POLITICA
# 5.3.6). Convencion de la familia: paquetes prefijados; solo library(here).
# =============================================================================

library(here)

# --- Autoinstalacion -------------------------------------------------------
source(here::here("10_utils", "10_utils.R"))
instalar_si_falta(c("here", "fs", "readr", "readxl", "janitor", "dplyr", "arrow"))

# --- Constantes -------------------------------------------------------------
# Anio del DIRECTORIO (snapshot MINEDUC). Los SLEP con traspaso <= vigente figuran
# con COD_DEPE == 6; los de traspaso prospectivo (vigente+1) administran desde ya
# pero aun aparecen como municipales (COD_DEPE 1/2) y entran por la rama 3.2.
ANIO_DATOS_VIGENTE <- 2025L

# Nombres oficiales de region (ASCII para el parquet; el motor restituye tildes
# desde NOMBRES_REGION de 10_configuracion.R al serializar).
NOMBRES_REGION_ASCII <- c(
  "1"="Tarapaca","2"="Antofagasta","3"="Atacama","4"="Coquimbo","5"="Valparaiso",
  "6"="O'Higgins","7"="Maule","8"="Biobio","9"="La Araucania","10"="Los Lagos",
  "11"="Aysen","12"="Magallanes","13"="Metropolitana","14"="Los Rios",
  "15"="Arica y Parinacota","16"="Nuble"
)

ruta_int <- function(f) here::here("40_salidas", "intermedios", f)

# ============================================================================
# Bloque 1 — Directorio oficial publico
# ============================================================================
message("[1] Leyendo directorio_oficial_ee_publico.csv...")
ruta_directorio <- here::here("20_insumos", "auxiliares",
                              "directorio_oficial_ee_publico.csv")
stopifnot("Falta el directorio publico" = file.exists(ruta_directorio))

df_dir_raw <- readr::read_delim(
  ruta_directorio, delim = ";",
  locale = readr::locale(encoding = "UTF-8", decimal_mark = ","),
  show_col_types = FALSE, progress = FALSE
)

cols_req <- c("AGNO","RBD","NOM_RBD","COD_COM_RBD","NOM_COM_RBD",
              "COD_REG_RBD","NOM_REG_RBD_A","COD_DEPE","COD_DEPE2",
              "MATRICULA","ESTADO_ESTAB")
faltan <- setdiff(cols_req, names(df_dir_raw))
stopifnot("Faltan columnas en el directorio publico" = length(faltan) == 0)
message(sprintf("    OK: %d filas.", nrow(df_dir_raw)))

# ============================================================================
# Bloque 2 — comunas_chile.parquet
# ============================================================================
message("[2] comunas_chile.parquet...")
df_comunas <- df_dir_raw |>
  dplyr::filter(.data$ESTADO_ESTAB == 1, .data$MATRICULA == 1) |>
  dplyr::transmute(
    cod_com_rbd = as.character(COD_COM_RBD),
    nom_com_rbd = NOM_COM_RBD,
    cod_reg_rbd = as.character(COD_REG_RBD),
    nom_reg_rbd = dplyr::recode(as.character(COD_REG_RBD),
                               !!!NOMBRES_REGION_ASCII, .default = NOM_REG_RBD_A)
  ) |>
  dplyr::distinct()
arrow::write_parquet(df_comunas, ruta_int("comunas_chile.parquet"))
message(sprintf("    OK: %d comunas.", nrow(df_comunas)))

# ============================================================================
# Bloque 3 — sleps_chile.parquet (una fila por SLEP x RBD)
# ============================================================================
message("[3] sleps_chile.parquet...")
ruta_sleps <- here::here("20_insumos", "auxiliares", "listado_slep_2026.xlsx")
stopifnot("Falta el listado SLEP" = file.exists(ruta_sleps))

df_sleps_raw <- readxl::read_excel(ruta_sleps, sheet = "Listado SLEP",
                                   col_types = "text") |>
  janitor::clean_names()

cols_slep_req <- c("cod_slep","nombre_slep_formato","agno_traspaso_educ","cod_com_rbd")
faltan_slep <- setdiff(cols_slep_req, names(df_sleps_raw))
stopifnot("Faltan columnas en listado_slep_2026.xlsx" = length(faltan_slep) == 0)

df_slep_comunas <- df_sleps_raw |>
  dplyr::transmute(
    cod_slep      = as.character(cod_slep),
    nombre_slep   = nombre_slep_formato,
    anio_traspaso = suppressWarnings(as.integer(agno_traspaso_educ)),
    cod_com_rbd   = as.character(cod_com_rbd)
  ) |>
  dplyr::distinct()

# Dos ramas: (a) SLEP ya traspasados (COD_DEPE==6); (b) prospectivos vigente+1
# (aun municipales, COD_DEPE 1/2). SLEP con traspaso > vigente+1 no se incluyen.
comunas_traspasadas <- df_slep_comunas |>
  dplyr::filter(.data$anio_traspaso <= ANIO_DATOS_VIGENTE) |>
  dplyr::pull(cod_com_rbd) |> unique()
comunas_prospectivas <- df_slep_comunas |>
  dplyr::filter(.data$anio_traspaso == ANIO_DATOS_VIGENTE + 1L) |>
  dplyr::pull(cod_com_rbd) |> unique()

df_dir_slep <- df_dir_raw |>
  dplyr::filter(.data$ESTADO_ESTAB == 1, .data$MATRICULA == 1) |>
  dplyr::mutate(cod_com_rbd = as.character(COD_COM_RBD)) |>
  dplyr::filter(
    (.data$COD_DEPE == 6 & .data$cod_com_rbd %in% comunas_traspasadas) |
      (.data$COD_DEPE %in% c(1,2) & .data$cod_com_rbd %in% comunas_prospectivas)
  ) |>
  dplyr::transmute(cod_com_rbd = cod_com_rbd, rbd = as.character(RBD), nom_rbd = NOM_RBD)

df_sleps <- dplyr::inner_join(df_slep_comunas, df_dir_slep, by = "cod_com_rbd") |>
  dplyr::left_join(dplyr::select(df_comunas, cod_com_rbd, nom_com_rbd), by = "cod_com_rbd") |>
  dplyr::select(cod_slep, nombre_slep, anio_traspaso, cod_com_rbd, nom_com_rbd, rbd, nom_rbd) |>
  dplyr::arrange(cod_slep, cod_com_rbd, rbd)

if (nrow(df_sleps) == 0) stop("Join SLEP x directorio devolvio 0 filas.")
arrow::write_parquet(df_sleps, ruta_int("sleps_chile.parquet"))
message(sprintf("    OK: %d SLEPs, %d comunas, %d establecimientos.",
                dplyr::n_distinct(df_sleps$cod_slep),
                dplyr::n_distinct(df_sleps$cod_com_rbd),
                dplyr::n_distinct(df_sleps$rbd)))

# Sanity check Costa Central.
cc <- df_sleps |> dplyr::filter(nombre_slep == "Costa Central") |>
  dplyr::distinct(nom_com_rbd)
message(sprintf("    Costa Central: %d comunas (%s).",
                nrow(cc), paste(cc$nom_com_rbd, collapse = ", ")))

# ============================================================================
# Bloque 4 — establecimientos_chile.parquet
# ============================================================================
message("[4] establecimientos_chile.parquet...")
df_establecimientos <- df_dir_raw |>
  dplyr::filter(.data$ESTADO_ESTAB == 1, .data$MATRICULA == 1) |>
  dplyr::transmute(
    rbd         = as.character(RBD),
    nom_rbd     = NOM_RBD,
    cod_com_rbd = as.character(COD_COM_RBD),
    nom_com_rbd = NOM_COM_RBD,
    cod_reg_rbd = as.character(COD_REG_RBD),
    cod_depe2   = as.character(COD_DEPE2)
  ) |>
  dplyr::distinct() |>
  dplyr::arrange(cod_com_rbd, nom_rbd)

rbd_dups <- df_establecimientos |> dplyr::count(rbd, name = "n") |> dplyr::filter(.data$n > 1)
if (nrow(rbd_dups) > 0) warning(sprintf("%d RBDs duplicados (esperado 0).", nrow(rbd_dups)))
arrow::write_parquet(df_establecimientos, ruta_int("establecimientos_chile.parquet"))
message(sprintf("    OK: %d establecimientos.", nrow(df_establecimientos)))

message("\n30_construir_auxiliares.R: OK.")
