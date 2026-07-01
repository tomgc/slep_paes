# =============================================================================
# 10_utils/10_configuracion.R
# -----------------------------------------------------------------------------
# Proyecto : slep_paes
# Proposito: Resolucion de rutas (DOS RAICES) + constantes del proyecto.
#            RAMA B (datos personales): el repo (raiz de CODIGO) NO contiene
#            datos; los datos reales viven en la raiz de DATOS en OneDrive
#            institucional, apuntada por la variable de entorno
#            SLEP_PAES_DATA_ROOT (POLITICA_PROYECTO.md secciones 6.2 y 8.3).
# Fecha    : 2026-07-01
# -----------------------------------------------------------------------------
# Por que Rama B: las bases DEMRE/MINEDUC depositadas son MICRODATO por persona.
# egresados_em trae MRUN / MRUN_IPE (RUN enmascarado de estudiante = NNA) y
# ArchivoB trae FECHA_NACIMIENTO: datos personales (Ley 19.628 / 21.719) que
# jamas entran a Git (POLITICA 6.1). Ver gobernanza_datos.md.
#
# Este modulo usa solo base R (cero dependencias de paquetes cargados): se carga
# antes de cualquier library() (bootstrapping, POLITICA 1.4).
#
# NO-INVENCION DE METODOLOGIA (B.1): las constantes de dominio PAES trazan a
# 50_documentacion/activa/contexto_paes.md y a las glosas del DEMRE. El esquema
# por etapa NO se congela aqui; se define en 31_/32_ contra las bases reales.
# =============================================================================

# --- Identificador del proyecto ---------------------------------------------
PROYECTO_ID <- "slep_paes"

# ============================================================================
# Resolucion de la raiz de DATOS (dos raices)
# ============================================================================
# La raiz de datos contiene 20_insumos/ y 40_salidas/ reales, fuera del repo.
# Variable canonica: <PROYECTO_ID en MAYUS>_DATA_ROOT (POLITICA 6.2).
obtener_data_root <- function() {
  data_root <- Sys.getenv("SLEP_PAES_DATA_ROOT", unset = "")
  if (data_root == "") {
    stop(
      "Variable de entorno SLEP_PAES_DATA_ROOT no definida.\n",
      "Configurala asi:\n",
      "  macOS:   agregar a ~/.Renviron la linea\n",
      "    SLEP_PAES_DATA_ROOT=\"/Users/<usuario>/Library/CloudStorage/OneDrive-SLEP/Proyectos/slep_paes\"\n",
      "  Windows: agregar a C:/Users/<usuario>/.Renviron la linea\n",
      "    SLEP_PAES_DATA_ROOT=\"C:/Users/<usuario>/OneDrive - SLEP/Proyectos/slep_paes\"\n",
      "Luego reiniciar la sesion de R / Positron. Ver .Renviron.example.",
      call. = FALSE
    )
  }
  if (!dir.exists(data_root)) {
    stop(
      "La ruta apuntada por SLEP_PAES_DATA_ROOT no existe en disco:\n  ",
      data_root, "\n",
      "Verifica que OneDrive este sincronizado y que la ruta sea correcta.",
      call. = FALSE
    )
  }
  data_root
}

# Ruta a insumos:  file.path(<data_root>, "20_insumos", ...)
ruta_insumos <- function(...) file.path(obtener_data_root(), "20_insumos", ...)
# Ruta a salidas:  file.path(<data_root>, "40_salidas", ...)
ruta_salidas <- function(...) file.path(obtener_data_root(), "40_salidas", ...)

# ============================================================================
# Constantes territoriales (reusadas de los hermanos, NO reconstruidas)
# ============================================================================
# Fuente canonica RBD -> comuna -> SLEP: directorio oficial y territorios en la
# raiz de datos (20_insumos/auxiliares/). RBD y codigos comunales SIEMPRE como
# character (un join con tipos mezclados falla en silencio; POLITICA 5.3.6).
COMUNAS_SLEP_CC <- c("VINA DEL MAR", "CONCON", "QUINTERO", "PUCHUNCAVI")

COD_REGION_REFERENCIA <- 5L

NOMBRES_REGION <- c(
  "1" = "Tarapacá", "2" = "Antofagasta", "3" = "Atacama", "4" = "Coquimbo",
  "5" = "Valparaíso", "6" = "O'Higgins", "7" = "Maule", "8" = "Biobío",
  "9" = "La Araucanía", "10" = "Los Lagos", "11" = "Aysén", "12" = "Magallanes",
  "13" = "Metropolitana", "14" = "Los Ríos", "15" = "Arica y Parinacota",
  "16" = "Ñuble"
)

# ============================================================================
# Gobernanza: supresion de celdas chicas (constante nombrada, POLITICA 5.3.10)
# ============================================================================
# El panorama publica AGREGADOS territoriales, nunca microdato ni identificadores
# de postulantes. Toda celda con < UMBRAL_SUPRESION_CELDA personas se suprime.
# El umbral se ALINEA con el k-anonimato que el DEMRE aplica en origen (k=8, Ley
# 19.628; ver contexto_paes.md). NO es un numero inventado: es el estandar de la
# fuente. Redaccion normativa completa en gobernanza_datos.md.
UMBRAL_SUPRESION_CELDA <- 8L  # celdas con < 8 personas se suprimen (k-anonimato DEMRE)

# ============================================================================
# Dominio PAES: vocabulario estable (provenance: contexto_paes.md + glosas DEMRE)
# ============================================================================
# Los dos FOCOS del panorama, ejes PARES (ninguno subordinado al otro).
FOCOS_PAES <- c("cobertura", "rendimiento")

# Escala de puntajes PAES (IRT). Hecho de dominio (contexto_paes.md).
ESCALA_PAES_MIN <- 100L
ESCALA_PAES_MAX <- 1000L

# Pruebas PAES (slug interno -> nombre visible). El mapeo del slug a las columnas
# reales de cada base se define en 31_ contra las glosas (no se congela aqui).
# "Ciencias" incluye su version TP. (Las columnas reales del DEMRE en ArchivoC
# son CLEC, MATE1, MATE2, HCSOC, CIEN, MODULO; homologacion en 31_.)
PRUEBAS_PAES <- c(
  "competencia_lectora" = "Competencia Lectora",
  "m1"                  = "Matemática 1 (M1)",
  "m2"                  = "Matemática 2 (M2)",
  "ciencias"            = "Ciencias (incluye version TP)",
  "historia"            = "Historia y Ciencias Sociales"
)

# Factores de contexto escolar para el FOCO de rendimiento (resena de dominio).
FACTORES_CONTEXTO <- c("nem" = "NEM", "ranking" = "Ranking")

# Etapas del embudo (FOCO cobertura), en orden del proceso. La caracterizacion de
# egresados de EM es la capa de ELEGIBILIDAD/denominador, no una etapa mas.
ETAPAS_EMBUDO <- c(
  "egresados"   = "Egresados de ensenanza media (denominador de cobertura)",
  "inscripcion" = "Inscripcion de la PAES",
  "rendicion"   = "Rendicion",
  "resultados"  = "Resultados validos",
  "postulacion" = "Postulacion centralizada",
  "seleccion"   = "Seleccion"
)

# Categoria EXPLICITA de cobertura para quienes rinden sin RBD de egreso vigente
# (egresados de anios anteriores / rezagados): informacion, no hueco (brief 3-4).
ETIQUETA_SIN_RBD_VIGENTE <- "Egresados de anios anteriores (sin RBD vigente)"

# ============================================================================
# Paleta PROPIA de slep_paes (fuente unica, espejo de INDICADOR_COLORS de idps)
# ============================================================================
# Decision y justificacion completas en:
#   50_documentacion/activa/decisiones/20260630_decision_patron_comun_y_paleta.md
PALETA_PAES <- list(
  chrome = c(
    paper  = "#FBF7EF", tinta = "#241B2E", header = "#3B1D5E",
    acento = "#C2410C", linea = "#E6DECB"
  ),
  cobertura = c(
    egresados   = "#EFE9F5", inscripcion = "#D2C0E4", rendicion  = "#AE92CE",
    resultados  = "#8A65B5", postulacion = "#653F99", seleccion  = "#412072"
  ),
  sin_rbd_vigente = "#9A8FA6",
  pruebas = c(
    competencia_lectora = "#B45309", m1 = "#1F5C54", m2 = "#5B3A9E",
    ciencias = "#4D7C0F", historia = "#B91C5C"
  ),
  rendimiento_divergente = c("#B45309", "#D9A441", "#E6DECB", "#4C8C7D", "#1F5C54")
)
