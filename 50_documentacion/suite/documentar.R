# ============================================================================
#  documentar.R — genera la suite de documentacion de "slep_paes"
#
#  Sesion BIBLIOTECA (no toca el pipeline PAES): produce los 4 HTML de la suite
#  en 50_documentacion/suite/ a partir del paquete suitedoc. La cfg de abajo se
#  poblo leyendo el material real del proyecto (escaner, traspaso v04, README,
#  CLAUDE.md, decisiones, scripts 31/32/33, gobernanza_datos.md, contexto_paes.md).
#
#  Regenerar (desde la raiz del proyecto):
#      Rscript -e 'setwd("/Users/tomgc/Projects/slep_paes"); source("50_documentacion/suite/documentar.R")'
#  o, en Positron:
#      source("50_documentacion/suite/documentar.R")
#
#  Salida standalone offline ACTIVADA desde el inicio (SETTINGS 4.6.4): los 4
#  HTML se emiten como *_standalone.html con tema, fuentes, logos e iconos
#  embebidos (0 dependencias de red). Requiere npm + red en tiempo de generacion
#  (descarga lucide-static fijado); la suite resultante SI es 100% offline.
#
#  NOTA de encoding: los valores visibles llevan acentos/ñ (UTF-8). El paquete
#  fija un locale UTF-8 (.asegurar_utf8) antes de escribir con writeBin(enc2utf8),
#  asi que los bytes se preservan aunque se corra por Rscript bajo locale C
#  (verificado: 0 mojibake). Los NOMBRES de campo y los identificadores de codigo
#  (id_aux, estado_pref, *.parquet, --fs-*) se mantienen en ASCII a proposito.
# ============================================================================
#  CONSTANCIA DE GOBERNANZA (proyecto RAMA B, con datos personales de NNA):
#  Verificado que esta cfg NO contiene nombres de establecimientos educacionales
#  reales, RUT, MRUN, nombres de personas ni datos individuales identificables.
#  Los universos se describen en abstracto (agregados territoriales). La categoria
#  de datos (Ley 21.719) se declara en cfg$gobernanza. Ver gobernanza_datos.md.
# ============================================================================

library(here)
library(suitedoc)

cfg <- list(

  # ---- 1.1 Identidad del proyecto ------------------------------------------
  slug        = "slep_paes",
  institucion = "SLEP Costa Central",
  area        = "Área de Monitoreo y Seguimiento de Procesos y Resultados Educativos",
  fuente      = "Datos públicos del DEMRE (Universidad de Chile) y del Ministerio de Educación",

  salida_dir  = ".",
  css_href    = "suite_estilos.css",
  logo_href   = "assets/logo-white-stacked.png",

  # Categoria real de datos (gobernanza_datos.md, Ley 21.719). No inventada:
  # egresados_em trae MRUN de NNA; el proyecto es Rama B y publica solo agregados.
  gobernanza  = "Datos personales de NNA (Ley 21.719); se publican solo agregados territoriales",

  # Las cuatro comunas de Costa Central (franja de cierre). Colores del handoff
  # (33_generar_html.R: cc_colores). Puchuncavi es claro -> texto oscuro.
  comunas = list(
    list(nombre = "Viña del Mar", bg = "#0062A0"),
    list(nombre = "Concón",       bg = "#75924E"),
    list(nombre = "Quintero",     bg = "#4A2746"),
    list(nombre = "Puchuncaví",   bg = "#BCA493", fg = "#241B2E")
  ),

  # ---- 1.2 Textos de cabecera por documento --------------------------------
  cab = list(
    arq_tec = list(
      eyebrow = "Esquema de arquitectura &middot; Versión técnica",
      h1      = "Arquitectura del proyecto",
      mono    = "slep_paes",
      tagline = "Panorama del proceso PAES leído desde dos focos pares &mdash; cobertura del embudo y rendimiento de puntajes &mdash; agregado por territorio RBD &rarr; comuna &rarr; SLEP &rarr; región &rarr; nacional. Pipeline R (Positron) &rarr; HTML autocontenido (React + D3) &middot; datos públicos del DEMRE y del Ministerio de Educación &middot; publicado en GitHub Pages.",
      metas   = list(
        list(c="var(--ocean)", k="Lenguaje", v="R"),
        list(c="var(--coral)", k="Salida",   v="HTML autocontenido"),
        list(c="var(--olive)", k="Cobertura",v="2023&ndash;2026"),
        list(c="var(--sand)",  k="Focos",    v="Cobertura &middot; Rendimiento")
      )
    ),
    doc_tec = list(
      eyebrow = "Documentación del proyecto &middot; Versión técnica completa",
      h1      = "Manual del proyecto",
      mono    = "slep_paes",
      tagline = "Presentación de punta a punta: qué problema resuelve, qué conceptos usa, cómo se construye y qué decisiones metodológicas lo gobiernan. Pensado para que cualquier persona del equipo &mdash;o una sesión de IA&mdash; entienda el proyecto en su totalidad.",
      metas   = list(
        list(c="var(--ocean)", k="Área",   v="Monitoreo y Seguimiento"),
        list(c="var(--olive)", k="Datos",  v="DEMRE / MINEDUC (con datos personales)"),
        list(c="var(--coral)", k="Salida", v="motor_paes.html")
      )
    ),
    arq_gen = list(
      eyebrow = "Esquema de arquitectura &middot; Visión general",
      h1      = "Cómo se construye la herramienta",
      mono    = NULL,
      tagline = "De las bases del proceso PAES a un tablero que se abre en el navegador, explicado como una línea de producción. Sin nombres de programas ni tecnicismos: solo qué entra, qué pasa en cada paso y qué sale.",
      metas   = list(
        list(c="var(--coral)", k="Para",           v="directivos, equipos y comunidad"),
        list(c="var(--olive)", k="Versión técnica", v="arquitectura_slep_paes.html")
      )
    ),
    doc_gen = list(
      eyebrow = "Documentación del proyecto &middot; Guía general",
      h1      = "Qué es la herramienta y cómo leerla",
      mono    = NULL,
      tagline = "Una guía breve y sin tecnicismos para entender qué muestra el panorama PAES, qué se puede ver en él y en qué conviene fijarse al interpretarlo.",
      metas   = list(
        list(c="var(--coral)", k="Para",            v="directivos, docentes, apoderados y comunidad"),
        list(c="var(--olive)", k="Detalle técnico", v="documentacion_proyecto_slep_paes.html")
      )
    )
  ),

  # ---- 1.3 Diagrama tecnico: insumos, auxiliares, etapas --------------------
  insumos = list(
    list(t='ArchivoB &middot; Inscripción (DEMRE)', badge='4 csv',
         d='Inscritos en la PAES &middot; 2023&ndash;2026 &middot; llave <span class="code-sm">ID_aux</span><br>trae <span class="code-sm">FECHA_NACIMIENTO</span> (dato personal) &middot; RBD de egreso'),
    list(t='ArchivoC &middot; Rendición y resultados (DEMRE)', badge='4 csv',
         d='Puntajes por prueba, NEM y Ranking &middot; escala 100&ndash;1000<br>esquema por año 28&rarr;38 columnas &middot; pivot a formato largo'),
    list(t='ArchivoD &middot; Postulación y selección (DEMRE)', badge='4 csv',
         d='Preferencias, estado y puntaje ponderado<br>wide 186 col (2023) &rarr; largo 6 col (2024+)'),
    list(t='Egresados de enseñanza media (MINEDUC)', badge='3 csv',
         d='Denominador de cobertura &middot; 2023&ndash;2025 &middot; llave <span class="code-sm">MRUN</span> (NNA)<br><span class="code-sm">marca_egreso==1</span> = fila de egreso efectivo')
  ),
  auxiliares = list(
    list(t='directorio_oficial_ee_publico.csv', badge='csv',
         d='Directorio oficial depurado, sin RUT ni MRUN &middot; RBD &rarr; comuna<br>reusado de los proyectos hermanos, nunca reconstruido'),
    list(t='diccionario_territorios.xlsx', badge='xlsx',
         d='Equivalencias comuna &middot; SLEP &middot; región<br>catálogo de entidades territoriales'),
    list(t='listado_slep_2026.xlsx', badge='xlsx',
         d='Servicios Locales y sus comunas asociadas<br>rama prospectiva de traspaso')
  ),
  aux_uses = c(
    '&#8600; <code>30_construir_auxiliares.R</code> catálogos territoriales (RBD &rarr; comuna &rarr; SLEP &rarr; región)',
    '&#8600; <code>32_agregar_territorial.R</code> territorialización de postulación vía <code>ID_aux</code>'
  ),

  etapas = list(
    list(n=2, titulo='Construcción de auxiliares', sub='30_procesamiento/',
         head='<span class="code">30_construir_auxiliares.R</span> <span class="bg bg--r">R</span>',
         d='Lee el directorio oficial depurado y el diccionario de territorios<br>Construye catálogos de entidades: <strong>comuna &middot; SLEP &middot; región &middot; establecimiento &middot; nacional</strong><br>Genera <span class="code-sm">comunas_chile.parquet</span> &middot; <span class="code-sm">sleps_chile.parquet</span> &middot; <span class="code-sm">establecimientos_chile.parquet</span><br>Llaves (RBD, códigos territoriales) como <strong>character</strong> (preserva ceros a la izquierda)',
         flags=c('Directorio oficial reusado, nunca reconstruido','Llaves siempre character'),
         norm=list()),
    list(n=3, titulo='Lectura y normalización', sub='30_procesamiento/',
         head='<span class="code">31_leer_normalizar.R</span> <span class="bg bg--r">R</span>',
         d='Lee ArchivoB/C/D y egresados de enseñanza media (2023&ndash;2026) siempre por nombre de columna<br>ArchivoC &rarr; formato largo (<span class="code-sm">prueba &middot; tipo_rendicion &middot; vigencia &middot; puntaje</span>)<br>ArchivoD &rarr; unifica wide 2023 (186 col) y largo 2024+ (6 col)<br>Descarta el sentinela 0 (no rindió / preferencia no usada) al pivotar<br>Escritura atómica &rarr; un parquet por etapa',
         flags=c('Columnas por nombre, nunca por posición','Sentinela 0 descartado en el pivot','Llaves ID_aux / RBD como character'),
         norm=list(
           list(id='N1', tx='<strong>ArchivoD 2023 &mdash; separador decimal mixto.</strong> El bloque PACE mezcla coma y punto como marca decimal (~1967 celdas). Se lee todo como texto y se parsea tolerante a ambas notaciones, para no perder puntajes reales como vacíos.'),
           list(id='N2', tx='<strong>Matemática de Invierno sin división M1/M2 (2023&ndash;2024).</strong> Esa columna se conserva como prueba <span class="code-sm">mate</span>; no se homologa a M1 ni M2 sin una fuente que confirme la equivalencia.'),
           list(id='N3', tx='<strong>Atributos solo de 2023.</strong> La situación del postulante y las marcas de las vías BEA / PACE existen únicamente en 2023; se preservan como atributos <span class="code-sm">*_solo2023</span> (vacíos en 2024+), marcados como no comparables entre años.')
         )),
    list(n=4, titulo='Agregación territorial (doble foco)', sub='30_procesamiento/',
         head='<span class="code">32_agregar_territorial.R</span> <span class="bg bg--r">R</span>',
         d='Agrega los <strong>dos focos</strong> al árbol RBD &rarr; comuna &rarr; SLEP &rarr; región &rarr; nacional<br><strong>Cobertura:</strong> embudo egresados &rarr; inscripción &rarr; rendición &rarr; resultados &rarr; postulación &rarr; selección<br><strong>Rendimiento:</strong> media de puntaje por prueba + NEM / Ranking<br>Categoría explícita de generaciones anteriores (sin RBD de egreso vigente)<br>Supresión de celdas con <span class="code-sm">n &lt; 8</span> &middot; escritura atómica &rarr; dos parquets',
         flags=c('Umbral de supresión k = 8 (constante nombrada)','Generaciones anteriores etiquetadas, nunca descartadas','Media enmascarada si la celda se suprime'),
         norm=list()),
    list(n=5, titulo='Generación del motor', sub='30_procesamiento/',
         head='<span class="code">33_generar_html.R</span> <span class="bg bg--r">R</span> + <span class="code">33_motor_template.html</span> <span class="bg bg--html">HTML</span>',
         d='Serializa los agregados de cobertura y rendimiento a <strong>JSON columnar</strong><br>Comprime (gzip + base64) y lo embebe en el template React + D3<br>React / ReactDOM / D3 / pako <strong>locales</strong> (sin CDN) + fuentes de marca base64<br>Escribe <span class="code-sm">motor_paes.html</span> y copia a <span class="code-sm">docs/index.html</span> (Pages)',
         flags=c('Sin dependencias de red (0 CDN)','Solo agregados: sin microdato ni establecimientos','JSON columnar gzip + base64'),
         norm=list())
  ),

  intermedios = list(
    list(t='paes_cobertura_territorial.parquet', d='Embudo por etapa &times; territorio &times; año<br>+ KPI de prioridad de carrera (solo en selección)'),
    list(t='paes_rendimiento_territorial.parquet', d='Media de puntaje por prueba<br>NEM y Ranking &middot; por territorio &times; año'),
    list(t='Catálogos de entidades', d='comunas &middot; sleps &middot; establecimientos<br>llaves como character')
  ),

  # ---- 1.4 Diccionario de datos (referencia tecnica) -----------------------
  dic_crudos = list(
    list(campo='id_aux', tipo='character', d='Identificador anonimizado y único de cada postulante. Reemplaza al RUN y es la llave de cruce entre las bases del DEMRE.'),
    list(campo='rbd', tipo='character', d='Rol Base de Datos del establecimiento educacional de egreso. Ausente o "0" para quienes egresaron en años previos &rarr; generaciones anteriores.'),
    list(campo='anio_proceso', tipo='integer', d='Año del proceso de admisión (2023&ndash;2026).'),
    list(campo='prueba', tipo='character', d='Prueba PAES: <b>clec</b> (Competencia Lectora), <b>mate1</b> (M1), <b>mate2</b> (M2), <b>cien</b> (Ciencias), <b>hcsoc</b> (Historia y Ciencias Sociales).'),
    list(campo='tipo_rendicion', tipo='character', d='Aplicación del puntaje: <b>reg</b> (Regular, fin de año) o <b>inv</b> (Invierno, junio).'),
    list(campo='vigencia', tipo='character', d='<b>actual</b> (puntaje de este proceso) o <b>anterior</b> (heredado del proceso previo, combinable).'),
    list(campo='puntaje', tipo='numeric', d='Puntaje PAES en escala 100&ndash;1000. El sentinela 0 significa "no rindió" y se descarta.'),
    list(campo='estado_pref', tipo='numeric', d='Estado de la preferencia postulada. <b>24</b> = seleccionado (colocación activa); <b>26</b> = seleccionado en preferencia anterior; <b>25</b> = lista de espera (no cuenta como selección).'),
    list(campo='orden_pref', tipo='integer', d='Prioridad de la preferencia postulada (1&ndash;20). El valor 1 es la primera preferencia.'),
    list(campo='ptje_nem', tipo='numeric', d='Puntaje de Notas de Enseñanza Media. El sentinela 0 = sin valor calculado y se excluye.'),
    list(campo='ptje_ranking', tipo='numeric', d='Puntaje del Ranking de notas. El sentinela 0 = sin valor calculado y se excluye.'),
    list(campo='marca_egreso', tipo='numeric', d='Indicador MINEDUC: 1 = el estudiante egresa ese año (fila de egreso efectivo), 0 = no. El archivo trae una fila por grado, por eso se filtra por 1.')
  ),
  dic_intermedios = list(
    list(campo='paes_cobertura_territorial.parquet', tipo='parquet', d='Una fila por etapa &times; tipo de entidad &times; entidad &times; año, con el conteo <code>n</code>, el flag <code>suprimida</code> y el KPI de prioridad de carrera (poblado solo en la etapa de selección).'),
    list(campo='paes_rendimiento_territorial.parquet', tipo='parquet', d='Media de puntaje por prueba / aplicación / vigencia, más NEM y Ranking, por territorio &times; año, con <code>n</code> y la media enmascarada si la celda se suprime.'),
    list(campo='comunas_chile.parquet &middot; sleps_chile.parquet', tipo='parquet', d='Catálogos territoriales: comuna &rarr; SLEP &rarr; región, con las llaves como character.'),
    list(campo='establecimientos_chile.parquet', tipo='parquet', d='Catálogo de RBD. No se publica: el motor opera a nivel de territorio, nunca de establecimiento educacional (gobernanza).')
  ),

  # ---- 1.5 Decisiones metodologicas ----------------------------------------
  decisiones = list(
    list(id='5.1', titulo='Camino A: adaptar el diseño al agregado real',
         cuerpo='<p>El prototipo del handoff visual asumía un contrato de datos que el pipeline no produce: siete etapas del embudo con matrícula, indicadores de prioridad, nivel de establecimiento educacional en la comparación, gráficos por estudiante y mediana / desviación por prueba. Se recreó el lenguaje visual del prototipo (colores, componentes, comportamiento) <strong>sobre los agregados que el pipeline sí produce</strong>: seis etapas, media en vez de mediana, sin nivel de establecimiento, comparación hasta comuna.</p>',
         por_que='<strong>Por qué.</strong> Adaptar el diseño no obliga a reabrir un pipeline ya verificado, respeta la gobernanza sin ambigüedad y produce un motor embarcable en la misma sesión. Un gráfico por estudiante con puntaje individual sería reidentificable incluso con el identificador anonimizado, y eso viola la regla de no identificar establecimientos ni personas en ningún output publicado. La gobernanza de datos prevalece sobre la fidelidad visual.'),
    list(id='5.2', titulo='Patrón común de familia y paleta propia',
         cuerpo='<p>El proyecto reusa el esqueleto de pipeline y de motor de los proyectos hermanos: librerías D3 y pako locales, JSON columnar comprimido (gzip + base64) e inyectado en el HTML, escritura atómica de los parquets y fuentes de marca embebidas. Pero define una <strong>paleta propia</strong>: uva para la cobertura, terracota y teal para el rendimiento, sobre un marfil cálido.</p>',
         por_que='<strong>Por qué.</strong> La identidad compartida de la familia es la tipografía, el layout, los componentes y el motor autocontenido; las paletas de datos no son transversales. Cada proyecto define la suya para no confundirse con los demás, incluso en el chrome de la interfaz.'),
    list(id='5.3', titulo='Formato largo para ArchivoC y ramas por forma para ArchivoD',
         cuerpo='<p>ArchivoC (rendición y resultados) se normaliza a <strong>formato largo</strong> &mdash;una fila por persona, prueba, aplicación y vigencia&mdash; porque su esquema de columnas crece de 28 a 38 entre 2023 y 2026. ArchivoD (postulación y selección) se lee con una <strong>rama explícita por forma</strong>: wide de 186 columnas en 2023, largo de 6 columnas desde 2024.</p>',
         por_que='<strong>Por qué.</strong> El formato largo resuelve la variabilidad interanual una sola vez, en la lectura; los consumidores posteriores no tienen que saber qué columnas existen en qué año. Además, los dos focos del proyecto son agrupaciones naturales sobre prueba y aplicación. El sentinela 0 (no rindió / preferencia no usada) se descarta en el pivot para no materializar intentos que no ocurrieron.'),
    list(id='5.4', titulo='Territorialización de postulación y selección vía ID_aux',
         cuerpo='<p>ArchivoD no trae un RBD propio. Se territorializa con un cruce por identificador anonimizado y año contra la base de inscripción, que sí trae el RBD de egreso. La matrícula universitaria queda <strong>fuera</strong> del árbol territorial en esta versión.</p>',
         por_que='<strong>Por qué.</strong> El 100% de las combinaciones de identificador y año presentes en ArchivoD existe también en la inscripción, sin duplicación de llave, así que el cruce es seguro y completa las seis etapas del embudo pedidas. La matrícula no es una etapa del embudo definido, por lo que territorializarla ahora sería alcance no solicitado; el mismo mecanismo aplicaría si una versión futura la incorpora.')
  ),

  # ---- 1.6 Anomalias de origen (detalle largo y resumen corto) -------------
  anomalias = list(
    list(id='A1',
         largo='<strong>El archivo de egresados trae unas cuatro veces más filas que personas.</strong> Incluye un registro por grado (de 1&deg; a 4&deg; medio) por estudiante, no solo el año de egreso. La fila de egreso efectivo se identifica con <span class="inl">marca_egreso==1</span>; confirmado contra la glosa oficial del Ministerio de Educación y contra las cifras de egresados por año que ese mismo documento reporta.',
         corto='El archivo de egresados repite a cada estudiante por grado. Se usa solo la fila de egreso efectivo, confirmada con la glosa oficial.'),
    list(id='A2',
         largo='<strong>Separador decimal mixto en ArchivoD 2023.</strong> El bloque de la vía PACE mezcla coma y punto como marca decimal (~1967 celdas). Se lee todo como texto y se parsea de forma tolerante a ambas notaciones, para no perder puntajes reales convertidos en vacíos.',
         corto='Algunos puntajes de 2023 venían con separador decimal inconsistente. Se leen tolerando ambas notaciones.'),
    list(id='A3',
         largo='<strong>Matemática de Invierno sin división M1 / M2 (2023&ndash;2024).</strong> En esos años la aplicación de Invierno traía un único puntaje de matemática sin separar. Se conserva como prueba propia y no se homologa a M1 ni M2, porque no hay fuente que confirme esa equivalencia.',
         corto='En algunos años la matemática de Invierno venía sin separar en dos niveles. Se conserva tal cual, sin inventar la equivalencia.'),
    list(id='A4',
         largo='<strong>Atributos que solo existen en 2023.</strong> La situación del postulante y las marcas de las vías BEA y PACE aparecen únicamente en el ArchivoD de 2023; desde 2024 esas columnas ya no vienen. Se preservan como atributos marcados "solo 2023", vacíos en los años siguientes y no comparables entre años.',
         corto='Algunas columnas de 2023 desaparecieron en años siguientes. Se preservan marcadas como no comparables entre años.')
  ),

  # ---- 1.7 Glosarios -------------------------------------------------------
  glosario_tec = c(
    '<strong>ID_aux</strong> &mdash; identificador anonimizado por postulante; reemplaza al RUN y cruza las bases del DEMRE sin identificar a la persona.',
    '<strong>RBD</strong> &mdash; Rol Base de Datos; identificador único del establecimiento educacional de egreso.',
    '<strong>DEMRE</strong> &mdash; Departamento de Evaluación, Medición y Registro Educacional (Universidad de Chile); administra la PAES y publica las bases del proceso.',
    '<strong>MINEDUC</strong> &mdash; Ministerio de Educación; fuente de la base de notas y egresados de enseñanza media (el denominador de cobertura).',
    '<strong>Modelo de Rasch</strong> &mdash; modelo psicométrico de un parámetro (estima solo la dificultad del ítem) con que el DEMRE calibra los puntajes; la habilidad se transforma linealmente a la escala 100&ndash;1000, comparable entre años.',
    '<strong>tipo_rendicion (reg / inv)</strong> &mdash; aplicación Regular (fin de año) o de Invierno (junio) de la que proviene el puntaje.',
    '<strong>vigencia (actual / anterior)</strong> &mdash; puntaje del proceso del año o heredado del proceso previo (combinable en la postulación).',
    '<strong>UMBRAL_SUPRESION_CELDA</strong> &mdash; constante de gobernanza (=8): toda celda territorial con menos de 8 personas se suprime, alineada al k-anonimato que el DEMRE aplica en origen.',
    '<strong>parquet</strong> &mdash; formato columnar comprimido para los datos intermedios.',
    '<strong>Escritura atómica</strong> &mdash; escribir a un archivo temporal y renombrar al final, para no dejar salidas a medias.',
    '<strong>Generaciones anteriores</strong> &mdash; quienes rinden sin RBD de egreso vigente (egresaron en años previos); se agregan en una categoría explícita, nunca como hueco.'
  ),
  glosario_doc = c(
    '<strong>PAES</strong> &mdash; Prueba de Acceso a la Educación Superior; el examen con que se postula a las universidades del sistema de acceso.',
    '<strong>DEMRE</strong> &mdash; el organismo de la Universidad de Chile que administra la PAES y publica los datos.',
    '<strong>Embudo de cobertura</strong> &mdash; la secuencia de etapas desde quienes egresan de enseñanza media hasta quienes resultan seleccionados.',
    '<strong>Rendimiento</strong> &mdash; cómo les va en los puntajes a quienes rinden, prueba por prueba, en escala 100 a 1000.',
    '<strong>Escala 100&ndash;1000</strong> &mdash; el rango de puntajes de la PAES; está calibrado para ser comparable de un año a otro.',
    '<strong>NEM</strong> &mdash; Notas de Enseñanza Media; un factor de contexto que acompaña a los puntajes.',
    '<strong>Ranking</strong> &mdash; puntaje del Ranking de notas; reconoce la trayectoria del estudiante dentro de su establecimiento educacional.',
    '<strong>Generaciones anteriores</strong> &mdash; personas que rinden la PAES habiendo egresado en años previos.',
    '<strong>SLEP</strong> &mdash; Servicio Local de Educación Pública; sostenedor estatal de los establecimientos educacionales.',
    '<strong>Establecimiento educacional</strong> &mdash; el término general para escuelas, liceos y jardines infantiles.'
  ),

  # ---- 1.8 Entidades comparables -------------------------------------------
  entidades_tec = list(
    list(ct='Comuna', cd='Todos los postulantes con RBD de egreso en una comuna.'),
    list(ct='SLEP', cd='Agrupación de las comunas de un Servicio Local de Educación Pública.'),
    list(ct='Región', cd='Agrupación de todas las comunas de una región.'),
    list(ct='Nacional ("Chile")', cd='El total país.'),
    list(ct='Generaciones anteriores', cd='Quienes rinden sin RBD de egreso vigente, agregados en una categoría propia.')
  ),
  entidades_gen = list(
    list(ct='Una comuna', cd='Todos sus establecimientos educacionales juntos.'),
    list(ct='Un Servicio Local', cd='Las comunas de un SLEP.'),
    list(ct='Una región', cd='Todas las comunas de la región.'),
    list(ct='Todo el país', cd='El total nacional, "Chile".'),
    list(ct='Generaciones anteriores', cd='Quienes rindieron habiendo egresado en años previos.')
  ),

  # ---- 1.9 Linea de produccion (arquitectura general) ----------------------
  estaciones = list(
    list(icon='boxes', color='var(--ocean)', paso='Paso 1 &middot; Insumo', titulo='Llegan las bases del proceso PAES',
         parrafos=c('Cada año el DEMRE publica las bases del proceso PAES &mdash;quiénes se inscriben, qué puntajes obtienen, a qué postulan y quiénes resultan seleccionados&mdash; y el Ministerio de Educación publica quiénes egresaron de enseñanza media. Son datos <strong>públicos</strong>, organizados por persona.',
                    'El formato cambia de un año a otro: una prueba se separa en dos, una columna aparece o desaparece, un mismo dato viene con distinta notación. Tal cual llegan, no se pueden comparar entre años ni juntar por territorio.'),
         chip_in=list(ico='download', tx='Entran: bases PAES 2023&ndash;2026 + egresados'), chip_out=NULL),
    list(icon='shield-check', color='var(--olive)', paso='Paso 2 &middot; Preparación', titulo='Lectura, limpieza y resguardo',
         parrafos=c('Antes de tocar ningún número, cada base pasa por lectura y limpieza: se leen las columnas por su nombre (no por su posición), se llevan todos los años a un mismo formato y se resuelven las particularidades de origen.',
                    'Como las bases contienen datos personales &mdash;incluidos datos de niños, niñas y adolescentes&mdash;, todo el trabajo con el detalle por persona ocurre puertas adentro y nunca se publica.'),
         chip_in=list(ico='file-warning', tx='Datos personales, con diferencias entre años'),
         chip_out=list(ico='check', tx='Datos limpios y homologados')),
    list(icon='layers', color='var(--coral)', paso='Paso 3 &middot; Preparación', titulo='Agregación por territorio y resguardo estadístico',
         parrafos=c('Con todo limpio, los datos de cada persona se <strong>juntan por territorio</strong>: por comuna, por Servicio Local, por región y a nivel país. Se calculan los dos focos: el embudo de cobertura (cuántos avanzan en cada etapa) y el rendimiento (cómo les va en los puntajes).',
                    'Toda cifra que represente a menos de ocho personas se <strong>suprime</strong>, para que ningún resultado permita identificar a alguien. Quienes egresaron en años previos se agregan en una categoría propia, visible y etiquetada.'),
         chip_in=list(ico='check', tx='Datos limpios por persona'),
         chip_out=list(ico='percent', tx='Agregados por territorio (con supresión)')),
    list(icon='bar-chart-3', color='var(--plum-80)', paso='Paso 4 &middot; Producto', titulo='Empaque: se arma el tablero',
         parrafos=c('Los agregados ya calculados se empaquetan dentro de una <strong>interfaz interactiva</strong>: los gráficos, la tabla, el selector de territorios y el cambio entre cobertura y rendimiento. Todo queda dentro de un solo archivo.',
                    'Ese archivo <strong>lleva los datos adentro</strong> y no necesita conexión ni programas especiales: no depende de servicios externos para funcionar.'),
         chip_in=list(ico='percent', tx='Agregados por territorio'),
         chip_out=list(ico='file-code-2', tx='Un archivo navegable')),
    list(icon='monitor', color='var(--plum)', paso='Paso 5 &middot; Producto terminado', titulo='La herramienta lista para usar',
         parrafos=c('El resultado es un <strong>tablero que se abre en cualquier navegador</strong>, sin instalar nada. Permite elegir una comuna, un Servicio Local, una región o el país y ver el embudo de cobertura y la distribución de puntajes, con las generaciones anteriores como categoría aparte.',
                    'Está publicado en línea para consulta y se actualiza repitiendo la línea de producción completa cuando llegan datos nuevos.'),
         chip_in=NULL, chip_out=list(ico='globe', tx='Tablero publicado y consultable'))
  ),

  # ---- 1.10 Garantias ------------------------------------------------------
  # REVISAR (voz): prosa de comunidad sin fuente literal en los insumos; el
  # contenido traza a gobernanza/decisiones, pero el tono es del titular.
  garantias = list(
    list(icon='shield', titulo='Nunca publicamos datos de personas', d='Las bases traen información por persona, incluidos datos de niños, niñas y adolescentes. La herramienta solo muestra totales por territorio; el detalle individual jamás sale del resguardo institucional.'),
    list(icon='users', titulo='Ocho personas es el mínimo', d='Cualquier cifra que represente a menos de ocho personas se oculta. Así ningún resultado, por más desagregado que esté, permite identificar a alguien.'),
    list(icon='git-merge', titulo='Dos miradas, ninguna por sobre la otra', d='La cobertura &mdash;cuántos avanzan en cada etapa&mdash; y el rendimiento &mdash;cómo les va en los puntajes&mdash; se muestran como focos pares. Ni el embudo tapa los puntajes ni al revés.'),
    list(icon='flag', titulo='Las generaciones anteriores se ven', d='Quienes rinden habiendo egresado en años previos no calzan con un establecimiento educacional de egreso vigente. En vez de descartarlos, se muestran en una categoría propia y etiquetada.'),
    list(icon='layers', titulo='Cada prueba se lee por separado', d='Competencia Lectora, Matemática 1 y 2, Ciencias e Historia miden cosas distintas. Sus puntajes se muestran prueba por prueba, nunca sumados en un único número.'),
    list(icon='book-open', titulo='No inventamos metodología', d='Las definiciones y los conteos salen de la documentación oficial del DEMRE y del Ministerio de Educación. Lo que no consta en una fuente no se fabrica: se deja pendiente o se documenta su alcance.')
  ),

  # ---- 1.11 "En que fijarte" (documentacion general) -----------------------
  # REVISAR (voz): claves de lectura redactadas para comunidad; tono del titular.
  notas = list(
    list(icon='filter', tx='<strong>Hay dos focos, y conviene mirarlos juntos.</strong> El embudo de cobertura dice cuántos avanzan en cada etapa; el rendimiento dice con qué puntajes. Una comuna puede tener mucha cobertura y puntajes medios, o al revés.'),
    list(icon='flag', tx='<strong>"Generaciones anteriores" es una categoría, no un error.</strong> Reúne a quienes rinden habiendo egresado en años previos. Aparecen aparte porque no calzan con un establecimiento educacional de egreso vigente.'),
    list(icon='eye-off', tx='<strong>Verás celdas sin dato.</strong> Cuando un resultado representaría a menos de ocho personas, se oculta a propósito, como resguardo estadístico. No es un dato que falte.'),
    list(icon='calendar', tx='<strong>El año "actual" es el último con denominador completo.</strong> El embudo necesita saber cuántos egresaron; mientras ese dato no llega para el año más reciente, el foco de cobertura usa el último año que sí lo tiene.'),
    list(icon='ruler', tx='<strong>Los puntajes van de 100 a 1000 y son comparables entre años.</strong> La PAES se calibra para que un mismo puntaje signifique lo mismo en distintas aplicaciones, así que se puede mirar la evolución en el tiempo.')
  ),

  # ---- 1.12 Preguntas frecuentes -------------------------------------------
  # REVISAR (voz): FAQ redactada para comunidad (voz simulada del lector); afinar tono.
  faq = list(
    list(q='&iquest;Qué es la PAES?', a='Es la Prueba de Acceso a la Educación Superior: el examen estandarizado con que se postula a las universidades del sistema de acceso en Chile. La administra el DEMRE, de la Universidad de Chile, y reemplazó a la antigua PSU en 2022.', abierta=TRUE),
    list(q='&iquest;Qué significa que haya "dos focos"?', a='La herramienta mira el proceso PAES de dos maneras a la vez. La cobertura cuenta cuántas personas avanzan en cada etapa, desde quienes egresan de enseñanza media hasta quienes resultan seleccionados. El rendimiento muestra los puntajes de quienes rinden. Ninguna de las dos miradas está por sobre la otra.', abierta=FALSE),
    list(q='&iquest;La herramienta muestra datos de estudiantes o de mi colegio?', a='No. Aunque las bases originales vienen por persona, la herramienta solo publica totales por comuna, Servicio Local, región y país. Nunca muestra información de una persona ni de un establecimiento educacional en particular, y oculta cualquier cifra que represente a menos de ocho personas.', abierta=FALSE),
    list(q='&iquest;Por qué a veces aparece "sin dato"?', a='Porque esa cifra representaría a muy pocas personas &mdash;menos de ocho&mdash; y mostrarla podría permitir identificar a alguien. Es un resguardo estadístico deliberado, no un error ni un dato que falte.', abierta=FALSE),
    list(q='&iquest;Quiénes son las "generaciones anteriores"?', a='Son las personas que rinden la PAES habiendo egresado de enseñanza media en años previos. Como no tienen un establecimiento educacional de egreso vigente en el año del proceso, se agrupan en una categoría propia y visible, en vez de descartarlas.', abierta=FALSE),
    list(q='&iquest;Necesito instalar algo para usarla?', a='No. Es un archivo que se abre en cualquier navegador y funciona sin conexión a internet. También está publicada en línea para consultarla directamente.', abierta=FALSE),
    list(q='&iquest;Cada cuánto se actualiza?', a='Se actualiza cuando el DEMRE y el Ministerio de Educación publican nuevos datos del proceso. El equipo vuelve a correr el pipeline completo y publica la versión al día.', abierta=FALSE)
  ),

  # ---- 1.13 Bloques de prosa de los documentos de lectura ------------------
  prosa = list(
    doc_que = c(
      '<code class="inl">slep_paes</code> es una herramienta de análisis interno que ofrece un <strong>panorama del proceso de la Prueba de Acceso a la Educación Superior (PAES)</strong>, navegable por territorio &mdash;comuna, Servicio Local, región y país&mdash; y leído desde dos focos pares: la <strong>cobertura</strong> del embudo del proceso y el <strong>rendimiento</strong> en los puntajes.',
      'El problema que resuelve es concreto: el DEMRE publica el proceso PAES en varias bases por persona (inscripción, rendición, postulación y selección), con formatos que cambian de un año a otro, y el Ministerio de Educación publica por separado quiénes egresaron de enseñanza media. Responder "cuántos de quienes pueden rendir efectivamente avanzan en cada etapa, y con qué puntajes, en las comunas de Costa Central comparadas con su región" exige consolidar esas bases, homologar años y agregar por territorio con resguardo de los datos personales.',
      'El producto final es un <strong>archivo HTML autónomo</strong> (<code class="inl">motor_paes.html</code>): se abre en cualquier navegador, sin instalar nada ni depender de servicios externos, y publica únicamente agregados territoriales.'
    ),
    doc_pipeline = c(
      'Detrás del archivo navegable hay un <strong>pipeline en R</strong> de cuatro etapas, orquestado por un único script (<code class="inl">00_run_all.R</code>). Cada etapa lee el resultado de la anterior y escribe el suyo, de modo que el proceso completo es reproducible de principio a fin. Como el proyecto trata datos personales, las bases crudas viven <strong>fuera</strong> del repositorio &mdash;en una raíz de datos externa apuntada por <code class="inl">SLEP_PAES_DATA_ROOT</code>&mdash; y el repositorio guarda solo código, documentación y los agregados publicados.'
    ),
    # REVISAR (voz): "por que existe" para comunidad; sin fuente literal, tono del titular.
    gen_porque = c(
      'El proceso PAES se publica cada año en varias bases separadas, con formatos que cambian, y el dato de egresados viene de otra fuente. Responder algo tan simple como <em>"cómo avanza mi comuna en cada etapa, y con qué puntajes, comparada con la región"</em> normalmente exige horas de trabajo técnico y cuidado con datos personales.',
      'Esta herramienta hace ese trabajo una sola vez, con reglas claras y resguardo de la información, y entrega la respuesta lista para mirar. El objetivo es que la conversación sea sobre <strong>qué dicen los datos</strong>, no sobre cómo armarlos.'
    ),
    etapas_pipeline = '<h3>1 &middot; Construir el mapa del territorio</h3><p>Se arman los catálogos que traducen un establecimiento educacional (RBD) a su comuna, su Servicio Local y su región.</p><h3>2 &middot; Leer y limpiar las bases</h3><p>Se leen las bases del DEMRE y de egresados por nombre de columna, se llevan a un mismo formato entre años y se resuelven las particularidades de origen.</p><h3>3 &middot; Agregar por territorio</h3><p>El dato de cada persona se sube a comuna, Servicio Local, región y país, para los dos focos, suprimiendo las celdas de menos de ocho personas.</p><h3>4 &middot; Generar el motor navegable</h3><p>Los agregados se empaquetan dentro de un archivo HTML autónomo, sin dependencias de red.</p>'
  ),

  # ---- 1.14 Gobernanza (sello al pie) --------------------------------------
  # (definida arriba en cfg$gobernanza)

  # ---- 1.15 Rotulos del diagrama tecnico -----------------------------------
  rotulos = list(
    lbl_fuentes     = 'Fuentes de datos <span class="sub">20_insumos/ (raíz de datos externa)</span>',
    lbl_auxiliares  = 'Tablas auxiliares <span class="sub">20_insumos/auxiliares/</span>',
    lbl_intermedios = 'Datos intermedios <span class="sub">40_salidas/intermedios/</span>',
    norm_titulo     = 'Particularidades de origen resueltas (bases DEMRE / MINEDUC)',
    exec = '<span class="cm"># Ejecución canónica del pipeline completo:</span><br><span class="fn">source</span>(<span class="str">"00_run_all.R"</span>)<br><span class="fn">run_all</span>()<br><br><span class="cm"># Regenerar solo el motor HTML:</span><br><span class="fn">run_all</span>(only = <span class="str">33</span>)'
  ),

  # ---- 1.16 Leyenda del diagrama tecnico -----------------------------------
  leyenda = list(
    list(color="var(--ocean)", texto="Pipeline R"),
    list(color="var(--plum)",  texto="Auxiliares / Motor"),
    list(color="var(--sand)",  texto="Datos intermedios"),
    list(color="var(--amber)", texto="Decisión metodológica"),
    list(color="var(--olive)", texto="Particularidad de origen resuelta")
  ),

  # ---- 1.17 Reglas de calculo ----------------------------------------------
  reglas_calculo = list(
    list(titulo='Supresión de celdas chicas (k-anonimato)',
         cuerpo='<pre>suprimir si  0 &lt; n &lt; UMBRAL_SUPRESION_CELDA   (= 8)</pre><p>Toda celda territorial con menos de ocho personas se suprime: el conteo pasa a vacío y, si es un promedio, la media también se enmascara. El umbral se alinea con el k-anonimato que el DEMRE aplica en origen; no es un número inventado.</p>'),
    list(titulo='Embudo de cobertura (definición de cada etapa)',
         cuerpo='<p>Seis etapas sobre el mismo árbol territorial: <strong>egresados</strong> (denominador, <span class="inl">marca_egreso==1</span>) &rarr; <strong>inscripción</strong> &rarr; <strong>rendición</strong> (rindió al menos una prueba con vigencia actual) &rarr; <strong>resultados válidos</strong> (rindió el paquete obligatorio Competencia Lectora + M1) &rarr; <strong>postulación</strong> &rarr; <strong>selección</strong> (<span class="inl">estado_pref</span> 24 o 26; la lista de espera, 25, no cuenta).</p>'),
    list(titulo='Prioridad de la carrera seleccionada',
         cuerpo='<p>Sobre el universo de seleccionados, el porcentaje que quedó en su <strong>primera preferencia</strong> (<span class="inl">orden_pref==1</span>). La prioridad se lee de la fila de colocación activa (<span class="inl">estado_pref==24</span>), nunca de la marca posterior de menor prioridad (<span class="inl">estado_pref==26</span>). La supresión se aplica sobre el denominador de seleccionados.</p>'),
    list(titulo='Rendimiento: media por prueba',
         cuerpo='<p>El rendimiento de un territorio es la <strong>media de los puntajes</strong> de quienes rinden, por prueba, aplicación (Regular / Invierno) y vigencia. Cada fila es una observación persona-prueba, así que el promedio ya queda ponderado por el número de rendidos. NEM y Ranking se promedian deduplicando por persona (son atributos por persona, no por prueba) y excluyendo el sentinela 0.</p>'),
    list(titulo='Escala tipográfica del motor',
         cuerpo='<p>Los tamaños de letra del tablero se definen con variables CSS nombradas (<span class="inl">--fs-*</span>), con un piso de 12 px por legibilidad. Al agregar un elemento nuevo, su tamaño se elige por el <strong>rol</strong> del elemento, no por el rango numérico en que caería.</p>')
  ),

  # ---- 1.18 Pie por documento ----------------------------------------------
  pie_extra = list(
    arq_tec = "Particularidades de origen documentadas en contexto_paes.md y en las decisiones del proyecto",
    doc_tec = "",
    arq_gen = "¿Necesitas el detalle técnico? Abre arquitectura_slep_paes.html",
    doc_gen = ""
  ),

  # ---- 1.19 Textos de seccion y hero-notes ---------------------------------
  # REVISAR (voz): los hero-notes (gen_hero, gen_frase, doc_gen_hero) son prosa de
  # comunidad sin fuente literal; el resto son titulos/intros de seccion. Afinar tono.
  textos = list(
    # Arquitectura tecnica
    ref_intro         = 'El diagrama de arriba muestra <strong>cómo fluyen los datos</strong>. Las secciones siguientes documentan el proyecto al detalle, de modo que cualquier persona técnica (o una sesión de IA) pueda reconstruir el contexto completo sin material adicional.',
    dic_crudos_titulo = 'Datos crudos (bases DEMRE / MINEDUC)',
    dic_interm_titulo = 'Datos intermedios producidos',
    reglas_titulo     = 'Reglas de cálculo',
    anom_titulo       = 'Anomalías de origen (detalle)',
    anom_intro        = 'Particularidades de las bases crudas del DEMRE y del Ministerio de Educación que el pipeline resuelve de forma trazable <strong>antes</strong> de cualquier cálculo. No son errores del proyecto.',
    # Manual
    doc_s2_intro      = 'El panorama permite comparar el proceso PAES entre distintas <strong>entidades</strong> territoriales:',
    doc_s2_cierre     = 'Para cualquier entidad se muestran los <strong>dos focos</strong>: el embudo de cobertura etapa por etapa y la distribución de puntajes por prueba, con NEM y Ranking como contexto. Las generaciones anteriores aparecen como una categoría aparte.',
    doc_dec_intro     = 'Reglas que gobiernan la construcción del panorama. Cada una fija una interpretación trazable de los datos, no una elección arbitraria.',
    doc_s5_intro      = 'Los datos provienen del <strong>DEMRE</strong> (proceso PAES) y del <strong>Ministerio de Educación</strong> (egresados de enseñanza media). Las bases crudas traen particularidades de origen que el pipeline normaliza antes de cualquier cálculo:',
    # Arquitectura general
    gen_hero          = 'Piensa en este proyecto como una <strong>pequeña fábrica de datos</strong>. Llegan materias primas &mdash;las bases del proceso PAES y de egresados&mdash;, pasan por una línea de producción que las limpia, las junta por territorio y las ensambla, y al final sale un <strong>producto terminado</strong>: una herramienta que cualquier persona puede abrir para mirar cobertura y puntajes con resguardo de los datos personales.',
    gen_linea_titulo  = 'La línea de producción',
    gen_guards_titulo = 'Las garantías de calidad de la fábrica',
    gen_guards_intro  = 'Toda fábrica seria tiene reglas que nunca se salta. Estas existen para que el panorama sea <strong>útil y respetuoso de los datos personales</strong>:',
    gen_frase_titulo  = 'En una frase',
    gen_frase         = 'Una línea de producción que toma las bases dispersas del proceso PAES y de egresados, las limpia, las junta por territorio con resguardo de datos y las convierte en un <strong>tablero navegable</strong> para mirar cobertura y puntajes en las comunas de Costa Central y el resto del país.',
    # Guia general
    doc_gen_hero          = 'Es una herramienta para <strong>mirar el proceso PAES por territorio</strong>: cuántas personas avanzan en cada etapa &mdash;desde egresar de enseñanza media hasta ser seleccionado&mdash; y con qué puntajes, por comuna, Servicio Local, región o país.',
    doc_gen_porque_titulo = 'Por qué existe',
    doc_gen_hacer_titulo  = 'Qué puedes hacer con ella',
    doc_gen_hacer_intro   = 'Eliges <strong>qué territorio quieres mirar</strong> y la herramienta te muestra sus dos focos:',
    doc_gen_hacer_cierre  = 'Para lo que elijas, verás el <strong>embudo de cobertura</strong> etapa por etapa y la <strong>distribución de puntajes</strong> por prueba, con las generaciones anteriores como categoría aparte.',
    doc_gen_fijarte_titulo= 'En qué fijarte al leerla',
    doc_gen_fijarte_intro = 'Cinco claves para interpretar la herramienta sin malentendidos:',
    doc_gen_datos_titulo  = 'De dónde vienen los datos',
    doc_gen_datos_cuerpo  = 'Los datos provienen del <strong>DEMRE</strong> y del <strong>Ministerio de Educación</strong>. La herramienta no contiene información de personas individuales ni de establecimientos educacionales: trabaja siempre con totales por territorio, y oculta cualquier cifra que represente a menos de ocho personas.',
    doc_gen_faq_titulo    = 'Preguntas frecuentes'
  )
)

# ---- Generar (standalone offline, activado desde el inicio) ----------------
suitedoc::generar_suite(
  cfg,
  salida_dir  = here::here("50_documentacion", "suite"),
  copiar_tema = TRUE,
  verificar   = TRUE,
  standalone  = TRUE,
  verbose     = TRUE
)
