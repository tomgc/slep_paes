# =============================================================================
# 10_utils/10_configuracion.R
# -----------------------------------------------------------------------------
# Proyecto : slep_paes
# Proposito: Rutas, constantes y resolucion de ubicaciones del proyecto.
#            RAMA A (proyecto publico): raiz unificada, datos versionados en
#            el repo. SIN variable de entorno ni data root externo
#            (POLITICA_PROYECTO.md, secciones 6.2 y 8.2).
# Fecha    : 2026-06-30
# -----------------------------------------------------------------------------
# NO-INVENCION DE METODOLOGIA (B.1): las constantes de dominio PAES de este
# archivo (escala, pruebas, etapas del embudo) trazan a la resena de dominio
# (50_documentacion/activa/contexto_paes.md, pendiente) y a las glosas
# oficiales del DEMRE que el titular depositara en 20_insumos/. Lo que aqui
# se fija es VOCABULARIO estable del dominio, NO el esquema por etapa ni los
# nombres de columnas de las bases: esos se definen en 31_/32_ contra las
# bases reales y sus glosas, y NO se congelan antes de verlas (brief, seccion 7).
# =============================================================================

# --- Identificador del proyecto ---------------------------------------------
PROYECTO_ID <- "slep_paes"

# --- Rutas (Rama A: todo dentro del repo) -----------------------------------
ruta_insumos <- function(...) here::here("20_insumos", ...)
ruta_salidas <- function(...) here::here("40_salidas", ...)

# ============================================================================
# Constantes territoriales (reusadas de los hermanos, NO reconstruidas)
# ============================================================================
# Fuente canonica RBD -> comuna -> SLEP: directorio oficial y diccionario de
# territorios copiados de los hermanos a 20_insumos/auxiliares/ (paso 2). RBD y
# codigos comunales SIEMPRE como character (un join con tipos mezclados falla en
# silencio; POLITICA 5.3.6).

# Comunas del SLEP Costa Central (homologar mayusculas/sin tildes al leer).
COMUNAS_SLEP_CC <- c("VINA DEL MAR", "CONCON", "QUINTERO", "PUCHUNCAVI")

# Region de referencia para comparacion (Valparaiso).
COD_REGION_REFERENCIA <- 5L

# Nombres oficiales de region por codigo (formas cortas, UTF-8). El motor las
# fuerza a Encoding "UTF-8" antes de serializar a JSON (gotcha de locale C,
# heredado de los hermanos).
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
# de postulantes. Si una agregacion territorial dejara a la vista un conteo que
# individualice, se suprime o etiqueta. El umbral se ALINEA con el k-anonimato
# que el DEMRE ya aplica en origen a sus datos abiertos (k=8, Ley 19.628; ver
# contexto_paes.md "Filtros de Confidencialidad"). NO es un numero inventado:
# es el estandar de la fuente. Redaccion normativa completa en gobernanza_datos.md.
UMBRAL_SUPRESION_CELDA <- 8L  # celdas con < 8 personas se suprimen (k-anonimato DEMRE)

# ============================================================================
# Dominio PAES: vocabulario estable (provenance: contexto_paes.md + glosas DEMRE)
# ============================================================================

# Los dos FOCOS del panorama, ejes PARES (ninguno subordinado al otro):
#   - cobertura  : el embudo contra el denominador de egresados de EM.
#   - rendimiento: distribucion de puntajes de quienes rinden.
FOCOS_PAES <- c("cobertura", "rendimiento")

# Escala de puntajes PAES (IRT). Hecho de dominio (brief seccion 3; resena).
ESCALA_PAES_MIN <- 100L
ESCALA_PAES_MAX <- 1000L

# Pruebas PAES (slug interno -> nombre visible). El slug es identificador interno;
# el mapeo del slug a las columnas reales de cada base se define en 31_ contra las
# glosas del DEMRE (no se congela aqui). "Ciencias" incluye su version TP.
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
# egresados de EM es la capa de ELEGIBILIDAD/denominador, no una etapa mas. Cada
# etapa tiene sus propios resultados; su granularidad y esquema se definen contra
# las bases reales (paso 4), no aqui.
ETAPAS_EMBUDO <- c(
  "egresados"   = "Egresados de ensenanza media (denominador de cobertura)",
  "inscripcion" = "Inscripcion de la PAES",
  "rendicion"   = "Rendicion",
  "resultados"  = "Resultados validos",
  "postulacion" = "Postulacion centralizada",
  "seleccion"   = "Seleccion"
)

# Categoria EXPLICITA de cobertura para quienes rinden sin RBD de egreso vigente
# (egresados de anios anteriores / rezagados). NO es un hueco ni un error: es
# informacion, se agrega etiquetada y visible, jamas diluida ni descartada
# (brief secciones 3 y 4).
ETIQUETA_SIN_RBD_VIGENTE <- "Egresados de anios anteriores (sin RBD vigente)"

# ============================================================================
# Paleta PROPIA de slep_paes (fuente unica, espejo de INDICADOR_COLORS de idps)
# ============================================================================
# Decision y justificacion completas en:
#   50_documentacion/activa/decisiones/20260630_decision_patron_comun_y_paleta.md
# Las paletas NO son transversales: slep_paes NO hereda la de ningun hermano.
# v1 de trabajo; contraste AA y revision visual pendientes para el paso 4.
PALETA_PAES <- list(
  # --- Chrome / identidad ---
  chrome = c(
    paper  = "#FBF7EF",  # fondo marfil calido (gobCL, propio)
    tinta  = "#241B2E",  # texto base (tinta uva)
    header = "#3B1D5E",  # header (uva profunda, sello PAES)
    acento = "#C2410C",  # acento / activo (terracota PAES)
    linea  = "#E6DECB"   # bordes y separadores
  ),
  # --- Foco COBERTURA: secuencial uva (atenuacion del embudo) ---
  # Mismas llaves que ETAPAS_EMBUDO, en orden del proceso.
  cobertura = c(
    egresados   = "#EFE9F5",
    inscripcion = "#D2C0E4",
    rendicion   = "#AE92CE",
    resultados  = "#8A65B5",
    postulacion = "#653F99",
    seleccion   = "#412072"
  ),
  # Rezagados (sin RBD vigente): neutro diferenciado, no es una etapa del embudo.
  sin_rbd_vigente = "#9A8FA6",
  # --- Foco RENDIMIENTO: categorico por prueba (llaves de PRUEBAS_PAES) ---
  pruebas = c(
    competencia_lectora = "#B45309",  # ambar terroso
    m1                  = "#1F5C54",  # teal profundo
    m2                  = "#5B3A9E",  # uva media
    ciencias            = "#4D7C0F",  # oliva oscuro
    historia            = "#B91C5C"   # frambuesa-burdeos
  ),
  # Divergente para tramos de puntaje (bajo -> alto), neutro al centro.
  rendimiento_divergente = c(
    "#B45309", "#D9A441", "#E6DECB", "#4C8C7D", "#1F5C54"
  )
)
