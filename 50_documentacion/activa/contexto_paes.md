---
titulo: Reseña de dominio — Prueba de Acceso a la Educación Superior (PAES)
fuente: Guía Completa de la PAES.docx (depositada por el titular)
convertido: 2026-06-30 (sesión 1, paso 3)
estado: conocimiento de dominio estable; NO es insumo de datos (B.1)
---

# Reseña de dominio — PAES (contexto_paes.md)

> **Qué es este documento.** Reseña de conocimiento de dominio estable sobre la
> PAES, convertida automáticamente desde `Guía Completa de la PAES.docx` que el
> titular depositó en el proyecto. El motor y la documentación se apoyan en ella
> para **no inventar metodología** (qué mide cada prueba, NEM, Ranking, escala
> 100-1000 e IRT, etapas del proceso, prueba TP, estructura de las bases DEMRE).
> Es contexto, **no** un insumo de datos: ninguna cifra del panorama se deriva de
> aquí, sino de las bases del DEMRE y sus glosas.
>
> **Procedencia y fidelidad de la conversión.** El `.docx` original se archivó en
> `_archivo/` (no versionado). La conversión (zip → `word/document.xml` → md)
> preservó texto, encabezados, listas y tablas, pero **NO** las **fórmulas
> matemáticas** (IRT, Ranking, ponderado) ni algunos **valores numéricos de
> tablas de conversión NEM**, que aparecen como huecos (p. ej. "un promedio de
> se traduce en puntos"). Para esas fórmulas y tablas, consultar el `.docx`
> original o las fuentes DEMRE citadas al final. **No se rellenaron los huecos a
> mano** (B.1: no fabricar).
>
> **Anclas para slep_paes** (lo que esta reseña fija como dominio):
> - Cinco pruebas: Competencia Lectora, Matemática 1 (M1), Matemática 2 (M2),
>   Ciencias (con versión Técnico-Profesional, TP) e Historia y Cs. Sociales.
> - Escala **100-1000** puntos, calibrada por **IRT** (comparable entre años).
> - Factores de contexto escolar: **NEM** y **Ranking de Notas**.
> - Etapas del proceso → bases abiertas DEMRE: **Archivo B** (inscritos),
>   **Archivo C** (rendición y resultados), **base de postulaciones y
>   seleccionados**. Llave de cruce anonimizada **`ID_aux`** (no RUN).
> - **K-anonimato = 8** aplicado por el DEMRE en origen (umbral de confidencialidad
>   Ley 19.628): base de la constante `UMBRAL_SUPRESION_CELDA` del proyecto.
> - `COD_DEPE`: 1 Municipal, 2 Part. subvencionado, 3 Part. pagado, 4 Adm.
>   Delegada, 5 SLEP. `RBD_ENS` = establecimiento de egreso de EM.

---

# Reseña de la Prueba de Acceso a la Educación Superior (PAES) en Chile
## Definición, Naturaleza y Propósito del Sistema de Admisión
La Prueba de Acceso a la Educación Superior (PAES) constituye el instrumento estandarizado oficial para la selección y admisión de estudiantes a las universidades de Chile adscritas al Sistema de Acceso1. Administrada por el Departamento de Evaluación, Medición y Registro Educacional (DEMRE) de la Universidad de Chile, en colaboración directa con la Subsecretaría de Educación Superior del Ministerio de Educación (Mineduc), la PAES tiene la función de regular el ingreso a las instituciones mediante un proceso técnico y centralizado1.
Este examen tiene como propósito evaluar competencias clave, integrando las habilidades cognitivas de orden superior con los conocimientos disciplinares fundamentales1. A diferencia de sus antecesoras, la PAES no se limita a medir el volumen de contenidos curriculares acumulados, sino el "saber" y el "saber hacer", es decir, la capacidad latente de los postulantes para aplicar destrezas metodológicas y resolver problemas prácticos en entornos académicos diversos1. Los puntajes obtenidos operan como factores de ponderación que, combinados con las Notas de Enseñanza Media (NEM) y el Ranking de Notas de cada estudiante, determinan el acceso a las vacantes de las 47 universidades participantes del subsistema universitario2.
## Evolución Histórica y Factores de Transición Psicométrica
La gestación de la PAES obedece a un proceso de reestructuración metodológica motivado por críticas de desigualdad socioeconómica asociadas a los exámenes previos8.
### Cronología de los Instrumentos de Selección Universitaria en Chile
La evolución del sistema de selección universitaria en Chile se caracteriza por una constante búsqueda de equidad y precisión en la medición de habilidades8.

### Informes Técnicos e Hitos que Impulsaron la Reforma
El tránsito hacia la PAES se vio acelerado por evaluaciones técnicas y acciones legales que forzaron al Estado chileno a replantearse sus metodologías de medición8. En 2004, un análisis psicométrico conducido por la organización norteamericana Educational Testing Service (ETS) concluyó que el examen de matemática de la PSU mostraba niveles de dificultad excesivamente elevados, lo que impedía una discriminación adecuada en los rangos de desempeño medio y bajo8.
Posteriormente, en 2012, la consultora internacional Pearson evaluó las cuatro pruebas de la PSU y ratificó las asimetrías de dificultad8. El informe propuso desglosar las mediciones del área de ciencias y desplazar el foco de los ítems de un marco estrictamente memorístico hacia uno de habilidades complejas8.
En paralelo, en el plano legal, la egresada de educación técnico-profesional Carol Venegas Ovalle presentó en 2012 una denuncia formal contra el Mineduc y el Consejo de Rectores (CRUCH) ante la Comisión Interamericana de Derechos Humanos (CIDH)8. La demanda acusaba al Estado de discriminar sistemáticamente a los egresados de la modalidad técnico-profesional, dado que la PSU evaluaba contenidos curriculares científico-humanistas que este grupo de alumnos jamás recibía en sus planes de estudio8. La admisión de este caso por parte de la CIDH en 2018 impulsó al DEMRE a proponer en 2017 una reforma de siete puntos, que incluía la reducción de temarios, la división de la prueba de matemática en dos niveles y la adopción definitiva de la Teoría de Respuesta al Ítem (IRT)8. Tras dos años de pilotaje empírico mediante las PDT, la PAES debutó oficialmente a finales de 2022 para el proceso de postulación universitaria de 20231.
## Estructura de la Batería de Pruebas: Obligatorias y Electivas
La PAES se compone de cinco instrumentos independientes diseñados para evaluar distintos dominios de conocimiento y competencias prácticas1.
### Estructura de los Exámenes de la Batería PAES
Cada examen se diferencia en su extensión, el tiempo disponible para completarlo y los objetivos de su medición1.

### Requisitos y Condiciones de Inscripción para la Postulación Centralizada
Para participar activamente del proceso de postulación a las vacantes ofrecidas por las universidades adscritas, los estudiantes de la promoción del año (4° medio) deben inscribir y rendir obligatoriamente el paquete compuesto por las pruebas de Competencia Lectora, Competencia Matemática 1 (M1) y, al menos, una de las dos pruebas electivas (Ciencias y/o Historia y Ciencias Sociales)2. Quienes ya hayan egresado en años anteriores gozan de la prerrogativa de inscribir de forma flexible la cantidad de pruebas que estimen conveniente, desde un solo examen hasta la batería completa, con el fin de actualizar sus resultados11.
La prueba M2 constituye un requisito obligatorio para postular de manera centralizada a más de 400 carreras de alta exigencia matemática, tales como ciencias físicas, ingenierías y tecnologías14. Por disposición regulatoria del Sistema de Acceso, este examen específico debe ponderar, como mínimo, un 5% en el cálculo del puntaje final ponderado de las carreras que lo requieren13.
### Aspectos Instrumentales Comunes
- Ausencia de Penalización por Respuestas Incorrectas: Desde el proceso de admisión del año 2016 se eliminó de forma definitiva el descuento de puntaje por respuestas erróneas, criterio que se mantiene vigente en la estructura de la PAES1. El puntaje final depende exclusivamente de la cantidad de aciertos obtenidos en las preguntas consideradas para la escala de notas17.
- Preguntas de Pilotaje: Todas las pruebas integran 5 preguntas experimentales o de pilotaje distribuidas de forma oculta en el folleto1. Las respuestas a estos ítems experimentales se utilizan exclusivamente para análisis de calibración psicométrica futura y no influyen en el puntaje de selección del postulante1.
- Prueba de Ciencias Técnico-Profesional (TP): Diseñada específicamente para los egresados de establecimientos con formación técnico-profesional, esta prueba reduce el temario evaluando los módulos comunes de Biología, Física y Química referidos únicamente a los planes de estudio generales de 1° y 2° año de enseñanza media, eliminando el módulo electivo de especialidad científica para resguardar la equidad del instrumento11.
## Metodología Psicométrica de Calibración bajo IRT
Uno de los principales desarrollos de la PAES es su metodología de procesamiento de datos18. La antigua PSU utilizaba un modelo estadístico simplificado basado en la Teoría Clásica de Test (TC), mediante el cual el puntaje corregido correspondía a una transformación que dependía de la cantidad de respuestas correctas, ajustándose después a una curva normal1. Esto forzaba una distribución estadística donde el puntaje representaba la posición relativa del estudiante frente a su generación y no su nivel real de competencia, impidiendo comparar el puntaje obtenido en años distintos1.
La PAES utiliza un enfoque basado en la Teoría de Respuesta al Ítem (IRT), estimando de forma directa la habilidad latente del estudiante (representada por el parámetro estadístico )1. La probabilidad de que un examinado con un nivel de habilidad  responda correctamente a un ítem determinado se modela matemáticamente considerando las características intrínsecas de cada pregunta19:

En esta formulación matemática, se asumen tres parámetros fundamentales del reactivo: el parámetro de dificultad (), el parámetro de discriminación () y el parámetro de acierto fortuito o azar ()19. Una vez estimada la posición del examinado en la escala de habilidad latente , este valor se somete a una transformación lineal para posicionarlo dentro de una escala de referencia estándar que varía entre los 100 y los 1.000 puntos1.
### Razones Técnicas del Cambio de Escala (100 a 1.000 puntos)
El reemplazo de la escala histórica de 150 a 850 puntos por la escala unificada de 100 a 1.000 puntos obedeció a varios factores técnicos de comparabilidad y precisión psicométrica10:
- Garantía de Comparabilidad Absoluta: Debido a que el cálculo de puntajes se desprende directamente de las propiedades métricas del banco de ítems calibrado y no del desempeño relativo del grupo evaluado, los puntajes son directamente equivalentes entre distintas aplicaciones1. Un puntaje de 700 en una prueba de invierno equivale exactamente al mismo nivel de competencia que un 700 en una regular de fin de año1.
- Previsión contra Fluctuaciones del Puntaje de Corte: Al extender el rango métrico disponible, se aumenta la gradación y la sensibilidad estadística en la distribución de puntajes, reduciendo la variabilidad interanual de los puntajes de corte de las carreras universitarias20.
- Habilitación de la Combinabilidad de Puntajes: Al eliminar los sesgos de cohorte, el Sistema de Acceso permite que las universidades combinen de forma automatizada los mejores resultados individuales vigentes obtenidos por un postulante en las últimas cuatro aplicaciones consecutivas (por ejemplo, combinando el puntaje obtenido en la aplicación de invierno de un año con el de la regular del año posterior)3.
## Factores de Contexto Escolar: NEM y Ranking de Notas
Para postular a través de la postulación centralizada, el puntaje final de postulación resulta de una ponderación de los exámenes de la PAES y de dos componentes del historial del estudiante: el puntaje de Notas de Enseñanza Media (NEM) y el Ranking de Notas2.
### Notas de Enseñanza Media (NEM)
El puntaje NEM representa la conversión lineal del promedio ponderado de las calificaciones acumuladas durante los cuatro años de educación escolar secundaria, expresado con dos decimales y truncado18. Este promedio se homologa a la escala unificada de 100 a 1.000 puntos utilizando tablas de conversión diferenciadas según la modalidad educativa25. En la modalidad Científico-Humanista, la equivalencia de puntajes presenta las siguientes referencias técnicas:
- Un promedio de  se traduce en  puntos NEM28.
- Un promedio intermedio de  se traduce en  puntos NEM27.
- Un promedio destacado de  se traduce en  puntos NEM27.
- Un promedio máximo de  alcanza los  puntos NEM27.
A partir del proceso de admisión del año 2028, se ha establecido que la nota mínima de egreso escolar requerida para participar en el proceso de admisión regular centralizado equivaldrá a un piso de 458 puntos en la escala unificada26.
### Ranking de Notas
El Ranking de Notas es un ponderador diseñado para valorar el rendimiento académico del postulante en relación con su entorno socioeducativo inmediato de origen, eliminando el sesgo asociado a la disparidad de calificaciones promedio entre distintos colegios6.
La metodología evalúa los promedios de notas del postulante en cada uno de los cuatro años de enseñanza media (, ,  y ) y los contrasta individualmente con su respectiva Población de Referencia6. Esta población de referencia se constituye por el rendimiento de los alumnos de las tres generaciones inmediatamente anteriores que cursaron ese mismo nivel educativo en el establecimiento6. El promedio de estos cuatro análisis determina el Ranking final del postulante6.
Los parámetros requeridos para el cálculo lineal del Ranking son:
- Promedio Histórico del Establecimiento (): El promedio de los promedios de notas acumulados por las tres generaciones anteriores de egresados de ese colegio6.
- Promedio Máximo Histórico (): El promedio de los promedios máximos de notas de las mismas tres generaciones de egresados18.
- Promedio Acumulado del Alumno (): La calificación final promedio obtenida por el postulante18.
La asignación de puntaje de Ranking se rige por las siguientes condiciones lineales18:

Donde los parámetros de pendiente () e intersección () se determinan de forma particular para cada colegio a partir del Puntaje NEM del promedio histórico () y el valor de  asignado al máximo histórico18:

Este modelo garantiza que el estudiante que destaque por encima del promedio histórico de su colegio reciba una bonificación que eleva su puntaje Ranking por sobre su puntaje NEM puro27. Por el contrario, si el promedio del alumno se ubica por debajo de la media histórica de su entorno de referencia, el Ranking simplemente se iguala a su puntaje NEM, impidiendo cualquier perjuicio en el cálculo ponderado del estudiante18.
## Proceso de Postulación y Filtros de Admisión
Para calificar para la postulación centralizada a las universidades del Sistema de Acceso, los postulantes deben cumplir con requisitos mínimos obligatorios fijados por el Mineduc y el DEMRE1.
### Requisitos Mínimos de Postulación
El sistema exige de manera general que el estudiante obtenga un puntaje promedio mínimo igual o superior a 458 puntos entre las dos pruebas obligatorias (Competencia Lectora y Competencia Matemática M1)1. Alternativamente, aquellos estudiantes que no alcancen esta puntuación mínima pero que se ubiquen dentro del 10% superior de rendimiento escolar de su establecimiento y generación de egreso quedan plenamente habilitados para postular al sistema centralizado1.
Cabe destacar que las universidades de mayor selectividad académica tienen la facultad de imponer mínimos superiores o restringir el acceso basándose en puntajes promedio ponderados propios17. Por ejemplo, en el caso de la Universidad Central, se exige un piso general de 458 puntos PAES promedio y 500 puntos para Medicina24. En tanto, la Universidad Técnica Federico Santa María exige un promedio de ingreso mínimo de 485 puntos entre Lectora y M131.
### Cálculo del Puntaje Ponderado de Selección
El puntaje ponderado final de un estudiante se calcula multiplicando cada factor de selección por el porcentaje asignado por la carrera universitaria, sumando luego dichos valores27. Las universidades definen estos porcentajes de acuerdo con el perfil del programa académico2.
- Fórmula General:

Donde:
- : Puntaje NEM27.
- : Puntaje Ranking de Notas27.
- : Puntaje PAES de Competencia Lectora27.
- : Puntaje PAES de Competencia Matemática 127.
- : Puntaje PAES de Competencia Matemática 2 (cuando corresponda)27.
- : Puntaje PAES de Ciencias o de Historia (según el requisito de la carrera)27.
Un ejemplo práctico de ponderación de carrera de alta exigencia se presenta a continuación32:
- Puntaje NEM del Alumno:  con una ponderación de carrera de 32.
- Puntaje Ranking:  con una ponderación del 32.
- Competencia Lectora:  con una ponderación del 32.
- Competencia Matemática 1 (M1):  con una ponderación de 32.
- Prueba Electiva (Ciencias):  con una ponderación de 32.
- Competencia Matemática 2 (M2):  con una ponderación de 32.

El estudiante del ejemplo postula con un valor consolidado de 848,75 puntos para competir por una vacante en la carrera elegida32.
## Diferencias en la Gestión del Proceso: Invierno versus Regular
La organización anual de la PAES considera dos rendiciones diferenciadas en términos de calendarios de postulación, elegibilidad del postulante, costos y contenidos específicos3.
### Aplicación Regular (Fines de Año)
La PAES Regular se aplica masivamente a fines de noviembre o principios de diciembre de cada año2. Está dirigida de manera preferente a los alumnos rezagados de promociones anteriores y a toda la cohorte que se encuentra cursando su último año de educación media (4° medio)2.
El proceso oficial de inscripción digital se extiende regularmente entre el 1 de junio y el 22 de julio del año en curso3. No se contemplan períodos de inscripción adicionales o extraordinarios bajo ninguna circunstancia1. Los alumnos regulares de 4° medio que estudien en colegios con financiamiento estatal están exentos del pago del arancel de rendición gracias a la asignación de la Beca PAES34.
### Aplicación de Invierno (Mitad de Año)
La PAES de Invierno se aplica a mediados del mes de junio y está dirigida exclusivamente a personas egresadas que ya cuenten con su Licencia de Enseñanza Media y deseen rendir pruebas puntuales para mejorar sus puntajes históricos2. A diferencia de la aplicación regular, esta instancia tiene un cupo nacional limitado fijado en 50.000 inscritos22.
El período de inscripción se restringe a una ventana corta de tiempo en el mes de marzo (del 4 al 17 de marzo), cerrándose de inmediato si se agotan las vacantes asignadas antes del plazo límite22. Los inscritos en la versión de invierno no son elegibles para la beca de gratuidad estatal y deben costear el arancel correspondiente según el número de pruebas registradas22.
### Diferencias en el Contenido Evaluado
A partir del proceso de admisión de 2026, el temario de evaluación en el área matemática presenta variaciones de cobertura de contenidos según la época del año34:
- La PAES de Invierno evalúa un temario ligeramente más acotado en el eje de Geometría, limitando los ítems de cuerpos geométricos a poliedros básicos (paralelepípedos y cubos)34.
- La PAES Regular evalúa el temario completo, incorporando contenidos adicionales complejos como volumen y superficie de cilindros, semejanza, proporcionalidad de figuras a escala y problemas de posiciones relativas de rectas en el plano34.
Para la identificación formal de los postulantes al momento de ingresar a las salas de rendición, tanto en invierno como en verano, se exige presentar impresas la Tarjeta de Identificación oficial y la Cédula de Identidad chilena vigente o el Pasaporte3. Las personas extranjeras sin cédula de identidad nacionalizada pueden inscribirse y rendir acreditando su identidad mediante el Pasaporte de su país de origen o el Identificador Provisorio Escolar (IPE) previamente validado ante el Mineduc5.
## Vías de Inclusión, Acceso Directo y Programas Especiales
Con el fin de aminorar las desigualdades del sistema y promover el ingreso directo de estudiantes provenientes de contextos prioritarios, el Sistema de Acceso incorpora programas estatales y vías especiales de postulación39.
### Programa de Acompañamiento y Acceso Efectivo (PACE)
El programa PACE busca garantizar vacantes universitarias a estudiantes talentosos procedentes de colegios públicos de alta vulnerabilidad7. Los alumnos participan de actividades de preparación académica y psicoeducativa durante los dos últimos años de enseñanza media7. Para acceder a las vacantes reservadas de las 29 universidades adscritas al programa, el postulante debe cumplir con los siguientes criterios de habilitación obligatorios32:
- Haber cursado de forma continua 3° y 4° año medio en un establecimiento participante del programa PACE y egresar en el año correspondiente32.
- Ubicarse dentro del 25% superior de puntaje de ranking de su establecimiento de egreso, o haber obtenido un puntaje de ranking individual igual o superior a los 830 puntos32.
- Rendir obligatoriamente las pruebas PAES de Competencia Lectora, Competencia Matemática 1 (M1), y al menos una de las dos pruebas electivas (Ciencias o de Historia)7.
Los estudiantes que cumplen con estas condiciones están exentos del pago del arancel de inscripción de la PAES y acceden de manera preferente a los cupos de las universidades mediante el cálculo del Puntaje Ponderado PACE (), que bonifica variables geográficas y de orden de preferencia del postulante30.
### Cupos "Más Mujeres Científicas" (+MC)
Esta iniciativa especial, implementada en 44 universidades adscritas al Sistema de Acceso, busca disminuir las brechas de género en las áreas de Ciencia, Tecnología, Ingeniería y Matemáticas (STEM) mediante la asignación de vacantes adicionales exclusivas para mujeres40.
Los requisitos exigen estar legalmente registrada como mujer ante el Servicio de Registro Civil (o sexo femenino al solicitar el IPE), rendir las pruebas PAES obligatorias y específicas demandadas por la carrera, y cumplir con los puntajes de postulación mínimos43. Las postulantes interesadas participan de esta asignación a través de su postulación regular centralizada de hasta 20 carreras de interés, seleccionándose los cupos de forma paralela y descendente de acuerdo con su puntaje ponderado tradicional hasta completar las vacantes adicionales disponibles por carrera7.
### Habilitación para Carreras de Pedagogía
El ingreso centralizado a carreras de Pedagogía está normado por estándares específicos orientados a asegurar la calidad docente en el sistema escolar45. Los estudiantes deben satisfacer obligatoriamente al menos uno de los siguientes filtros de habilitación académica45:
- Puntaje PAES: Obtener un puntaje promedio entre las dos pruebas obligatorias (Competencia Lectora y M1) que posicione al postulante en el percentil 50 o superior de la distribución nacional de resultados (equivalente a un piso de  puntos en el proceso reciente)45.
- Ranking de Notas: Estar posicionado dentro del 20% o 30% superior de rendimiento de enseñanza media (NEM) del respectivo establecimiento de origen45.
- Programa de Preparación Docente: Haber completado y aprobado con éxito un Programa de Acceso a Pedagogías (PAP) o un Programa de Atracción de Talento Pedagógico validado por el Mineduc y rendir las pruebas de selección de manera regular45.
- Inclusión por Discapacidad: Estar oficialmente inscrito en el Registro Nacional de Discapacidad (RND), haber completado con éxito un programa de preparación PAP y contar con puntajes vigentes, quedando en estos casos exento del requisito de rendir las pruebas si se postula por vías de admisión directa de las universidades45.
### Distinciones a las Trayectorias Educativas (DTE)
Las Distinciones a las Trayectorias Educativas (DTE) sustituyen de manera definitiva a la antigua categoría de "Puntajes Nacionales", priorizando un reconocimiento que pondera las realidades territoriales y de identidad de los postulantes49. Se otorgan distinciones oficiales en cuatro áreas diferenciadas50:
- Territorios: Reconoce a los estudiantes de cada región del país (así como del territorio insular) que obtengan el puntaje más alto en el promedio de las pruebas obligatorias, la prueba M2, Ciencias o Historia41.
- Personas en Situación de Discapacidad: Distingue a los postulantes acreditados en el Registro Nacional de Discapacidad (RND) que registren los puntajes más altos en las pruebas obligatorias50.
- Pueblos Originarios: Reconoce a las personas pertenecientes a pueblos indígenas, con acreditación vigente de Conadi, que alcancen los máximos puntajes en los exámenes obligatorios50.
- Modalidad de Enseñanza: Distingue a los alumnos que registren un puntaje de ranking perfecto de 1.000 puntos y el promedio más alto en las pruebas obligatorias, diferenciando según procedan de establecimientos Científico-Humanistas o Técnico-Profesionales49.
Los estudiantes que obtengan una distinción DTE y que procedan de colegios de administración municipal, subvencionada o SLEP, pertenecientes al 80% más vulnerable de la población según el Registro Social de Hogares (RSH), acceden de forma automática al beneficio económico de la Beca DTE41. Este subsidio estatal financia un monto anual de hasta $1.150.000 CLP de la brecha del arancel real de la carrera en la institución donde se matriculen41.
## Conclusiones e Implicancias de Política Educativa
La implementación de la Prueba de Acceso a la Educación Superior (PAES) consolida un cambio de paradigma en la administración del sistema de selección chileno1. En el ámbito técnico de la psicometría, la adopción de la Teoría de Respuesta al Ítem (IRT) y la reformulación de la escala de puntajes a un rango de 100 a 1.000 puntos solucionaron problemas históricos de comparabilidad interanual de resultados, habilitando una postulación flexible para los estudiantes1. En el aspecto social de equidad, la división metodológica en exámenes específicos de matemática (M1 y M2) evitó penalizar a sectores vulnerables por falta de cobertura curricular, mientras que la ampliación de programas especiales (como PACE y los cupos de género +MC) y el reconocimiento contextualizado mediante las distinciones DTE facilitan el acceso universitario de grupos tradicionalmente excluidos4. El sistema actual equilibra la medición rigurosa de competencias aplicadas con los principios de equidad e inclusión educativa4.

El Portal de Bases de Datos Abiertos del DEMRE es una herramienta clave de transparencia activa y un recurso fundamental en Chile para el análisis de políticas públicas educativas, trayectorias escolares y procesos de selección universitaria (históricamente PAA, PSU, PDT y actualmente PAES).
Universidad de Chile
A continuación, se profundiza en la estructura de estas bases de datos, los tipos de archivos disponibles, sus variables principales y la lógica de sus glosas y resguardos técnicos:
### 1. ¿Qué datos hay? (Estructura de las Bases)
El portal ofrece archivos históricos descargables (comprimidos en formato .rar o .zip que contienen archivos planos, generalmente .csv o .txt separados por punto y coma o tabulaciones).
Para cada proceso de admisión (por ejemplo, Admisión 2024, 2025, etc.), la información suele segmentarse o estructurarse internamente en tres grandes bloques o "archivos" que representan las etapas del proceso:
- Archivo B - Base de Inscritos/as: Contiene la información demográfica, socioeconómica y de origen escolar de todas las personas que se registraron para rendir las pruebas en ese proceso, independientemente de si asistieron o no.DEMRE
- Archivo C - Base de Rendición y Resultados: Contiene los puntajes obtenidos en cada una de las pruebas rendidas (Competencia Lectora, Competencia Matemática 1, Competencia Matemática 2, Ciencias, Historia y Ciencias Sociales), además de los antecedentes escolares de rendimiento, como el promedio de notas de enseñanza media (NEM) y el puntaje Ranking.
- Base de Postulaciones y Seleccionados (en procesos consolidados): Muestra las preferencias de carreras que marcaron los estudiantes en el sistema centralizado, el orden de sus opciones, los puntajes ponderados calculados para cada carrera y, finalmente, el resultado del proceso (si quedó Seleccionado, en Lista de Espera o No Seleccionado).
### 2. ¿Qué variables tienen? (Campos principales)
Para permitir el cruce de los archivos (por ejemplo, unir los datos socioeconómicos del Archivo B con los puntajes del Archivo C), el DEMRE incluye una variable clave de unión (Llave Primaria):
- ID_aux (o ID / Correlativo): Es un identificador numérico anonimizado y único para cada postulante. Reemplaza al RUN para proteger la identidad.DEMRE
A grandes rasgos, las variables se agrupan en las siguientes categorías:
#### A. Variables Demográficas y Personales
- SEXO_REGISTRAL: Sexo asignado en el Registro Civil (habitualmente codificado como 1 Mujeres, 2 Hombres).
- RANGO_EDAD / EDAD: En versiones recientes se suele agrupar por rangos de edad para evitar la reidentificación de personas mayores o muy jóvenes.
- NACIONALIDAD / PAIS_NACIMIENTO: País de origen del postulante (codificado según tablas estándar de países o continentes).
- COMUNA_RESIDENCIA / REGION_RESIDENCIA: Ubicación geográfica declarada por el estudiante al momento de inscribirse.
#### B. Variables del Establecimiento Educacional de Origen
- RBD_ENS: Rol Base de Datos (RBD) de la unidad educativa de egreso de la Enseñanza Media.DEMRE
- COD_DEPE (Dependencia): Tipo de administración del colegio (Público/Municipal, Particular Subvencionado, Particular Pagado, Administración Delegada, o los nuevos Servicios Locales de Educación Pública - SLEP).
- COD_ENS / RAMO: Tipo de enseñanza cursada (Científico-Humanista Diurno/Nocturno, Técnico-Profesional Comercial, Industrial, Técnica, Agrícola, etc.).
- COMUNA_EGRESO / REGION_EGRESO: Ubicación geográfica del establecimiento educacional.
- AÑO_EGRESO: Año en que el postulante finalizó la enseñanza media.
#### C. Variables de Rendimiento y Puntajes
- PROM_NOTAS: Promedio de notas de la Enseñanza Media (NEM) con decimales.
- PTJE_NEM: Puntaje asociado al promedio de notas según la tabla de conversión vigente para ese proceso.
- PTJE_RANKING: Puntaje Ranking del estudiante, calculado según su contexto educativo.
- Puntajes por Prueba (CLEC, CMAT1, CMAT2, CCIE, CHIS): Columnas específicas para cada examen rindiendo. En las bases actuales de la PAES, estos puntajes vienen en la escala nueva (de 100 a 1.000 puntos). Si el postulante se ausentó o no inscribió la prueba, el campo suele aparecer vacío (NULL) o con códigos específicos de ausencia.
#### D. Variables de Postulación y Selección
- PREFERENCIA: El orden (1 al 20, según el proceso) en que el estudiante situó una carrera.
- COD_CARRERA: Código único de la carrera universitaria en el sistema centralizado.
- PTJE_PONDERADO: El puntaje final calculado para esa postulación específica, aplicando los porcentajes exigidos por la universidad para cada prueba, NEM y Ranking.
- ESTADO_SELECCION: Variable categórica que indica el resultado (ej: SEL = Seleccionado, LE = Lista de Espera, ELI= Eliminado por cupo, etc.).
### 3. ¿Qué dicen las Glosas y Criterios Técnicos?
Cada descarga en el portal viene acompañada (o tiene asociado en la sección de documentos del DEMRE) de un archivo o manual de Glosas de Variables (diccionario de datos). Este diccionario es crucial porque define la codificación exacta de cada columna. Por ejemplo:
- Codificación de Dependencia (COD_DEPE): * 1 = Municipal / Público
- 2 = Particular Subvencionado
- 3 = Particular Pagado
- 4 = Corporaciones de Administración Delegada (DL 3166)
- 5 = Servicio Local de Educación Pública (SLEP) (en bases recientes)
- Códigos de Regiones: Siguen la codificación político-administrativa oficial de Chile (ej: 13 para la Región Metropolitana, 05 para la Región de Valparaíso, etc.).
#### El criterio crítico: Filtros de Confidencialidad (K-Anonimato)
Las glosas y notas metodológicas del DEMRE explican detalladamente las restricciones aplicadas a los datos abiertos para dar estricto cumplimiento a la Ley N° 19.628 sobre protección de la vida privada.
Para evitar que un analista cruce variables y deduzca la identidad exacta de un alumno (por ejemplo, saber quién es el único extranjero de un colegio técnico pequeño que sacó determinado puntaje), el DEMRE aplica la regla del "umbral de 8 casos" (K-Anonymity = 8):
- Eliminación por baja frecuencia: Se omiten o se agrupan en categorías genéricas ("Otros") los registros de personas cuya comuna de egreso aparezca menos de 8 veces en toda la base nacional.
- Filtro por RBD: Si un establecimiento educacional (RBD_ENS) tiene menos de 8 inscritos en el proceso, esos alumnos son anonimizados en sus variables de origen o sus filas son omitidas/modificadas según el protocolo técnico vigente para asegurar que ningún individuo sea reconocible.
- Filtro por Nacionalidad: Paises de nacimiento o nacionalidades con menos de 8 representantes en la base de datos se agrupan bajo una categoría común.DEMRE
### ¿Cómo trabajar metodológicamente con estas bases?
Si estás planificando un análisis (por ejemplo, en R o Power BI), el flujo estándar documentado en las guías prácticas del DEMRE consiste en:
- Cargar los archivos .csv correspondientes (asegurando configurar el encoding adecuado, usualmente UTF-8 o Latin-1debido a las tildes y la "ñ" en nombres de comunas).
- Realizar un JOIN (unión) utilizando el campo ID_aux.
- Filtrar por la condición de "Postulante Válido" o "Rindió al menos una prueba" si tu objetivo es medir rendimiento, ya que la base de inscritos incluye personas que finalmente decidieron no asistir a los locales de rendición.
Para sumergirse en los niveles más avanzados de analítica e investigación usando el Portal de Datos Abiertos del DEMRE, hay que entender cómo opera esta infraestructura de datos tras bambalinas.
A continuación, te detallo aspectos técnicos profundos, anomalías o "quiebres" metodológicos en las series históricas, variables implícitas y el comportamiento específico de las glosas que debes dominar para procesar esta información sin errores.
### 1. El Quiebre de las Escalas (El dolor de cabeza de los analistas)
Uno de los errores metodológicos más comunes al usar estas bases es intentar comparar directamente los puntajes a través de los años.
- Hasta el Proceso 2022 (PSU y PDT): Las variables de puntaje venían en la escala clásica de 150 a 850 puntos, construida bajo una distribución normal fija donde el promedio nacional era forzado a estar en torno a los 500 puntos con una desviación estándar de 110.
- Desde el Proceso 2023 en adelante (PAES): Las variables de puntajes pasaron a la nueva escala de 100 a 1.000 puntos. Esta escala utiliza la Teoría de Respuesta al Ítem (TRI) para que los puntajes sean invariantes en el tiempo.
Impacto analítico: Si intentas calcular un promedio longitudinal o una regresión mezclando bases de datos de 2020 con las de 2024 usando el puntaje crudo, tu modelo fallará. Para hacer estudios históricos, debes aplicar las tablas de concordancia que publica el DEMRE o transformar los puntajes a percentiles dentro de cada base anual.
### 2. Variables de Control de Procesos Internos (Campos Técnicos)
Además de los puntajes y datos socioeconómicos obvios, existen columnas en las glosas diseñadas exclusivamente para que los investigadores limpien el universo de datos. Algunas de las más importantes son:
- SITUACION_INSCRIPCION / ESTADO_INSCRIP: Clasifica si la persona completó el proceso. Valores típicos en la glosa: Válida, Anulada, o Pendiente. Solo debes trabajar con las inscripciones válidas.
- RINDIÓ_REQUISITO: Una variable booleana o categórica de conveniencia. Indica si el postulante efectivamente rindió el mínimo obligatorio para postular centralizadamente (en la PAES: Competencia Lectora + Competencia Matemática 1). Filtrar por este campo te ahorra tener que calcular a mano quiénes cumplen con las condiciones de postulación.
- SOLICITA_AJUSTE o SITUACION_DISCAPACIDAD: En las bases de datos de la última década se incluyó esta variable para identificar si el postulante solicitó y obtuvo adecuaciones o ajustes para rendir las pruebas por motivos de discapacidad o necesidades educativas especiales (NEE).
### 3. Anatomía de los "Archivos Especiales" (Bases de Postulación y Selección)
Cuando unes el Archivo B (Inscritos) y el Archivo C (Rendición), obtienes una fila por cada estudiante. Sin embargo, la Base de Postulaciones cambia radicalmente de forma (estructura de datos) porque un mismo estudiante puede postular hasta a 20 carreras (según las últimas normativas).
Aquí la base se puede presentar de dos maneras según el año de publicación:
- Formato Ancho (Wide): Columnas repetitivas llamadas COD_CARRERA_01, PTJE_POND_01, COD_CARRERA_02, etc. Obliga a usar funciones de reestructuración en programación (como pivot_longer en R o melt en Python) para poder analizarlas de manera eficiente.
- Formato Largo (Long): Una fila por cada postulación. Si el ID_aux 94852 postuló a 5 carreras, aparecerá 5 veces en la base, diferenciado por la variable NUM_PREFERENCIA (del 1 al 5).
#### Variables críticas en este módulo:
- CUPOS_REGULARES vs CUPOS_ESPECIALES: Las glosas detallan códigos para saber por qué vía entró el estudiante. No todos entran por el puntaje estrictamente ponderado regular. La glosa identifica si la vacante fue ocupada a través de:
- Cupos PACE (Programa de Acceso a la Educación Superior).
- Cupos BEA (Beca Excelencia Académica).
- Cupos de Equidad de Género (implementados en carreras de ingeniería en años recientes).
- Cupos para Pueblos Originarios.
### 4. El "Cuestionario de Contexto" y sus Variables Escondidas
Al momento de inscribirse para la PAES, los estudiantes están obligados a responder un extenso cuestionario sociodemográfico. Las variables resultantes de este formulario vienen codificadas de forma muy estricta en las glosas del portal de Transparencia, y son el verdadero tesoro para la investigación social:
- Ingreso Familiar Mensual Per Cápita o Tramo de Ingresos: Variable categórica estructurada en tramos (ej: Tramo 1: Menos de $200.000, Tramo 2: de $200.001 a $400.000, etc.). Esencial para medir brechas de equidad.
- Nivel Educacional del Padre / Madre / Tutor: Codificado numéricamente en la glosa desde 1 (Sin estudios) hasta 10 o 12 (Postgrado: Magíster o Doctorado).
- Ocupación del Padre / Madre: Clasificada habitualmente bajo lógicas de la CIUO (Clasificación Internacional Uniforme de Ocupaciones), permitiendo categorizar si los tutores son trabajadores no calificados, profesionales, personal administrativo, etc.
- Previsión de Salud: Variable utilizada frecuentemente como proxy socioeconómico (FONASA tramos A, B, C, D o ISAPRE).
### 5. Doble Rendición Anual: PAES de Invierno y de Regular
A partir del año 2022, el sistema chileno introdujo la rendición dividida (Invierno y Regular). Esto complejizó dramáticamente las bases de datos:
- En el portal verás archivos separados que dicen "Inscritos PAES de Invierno Proceso X" e "Inscritos PAES Regular Proceso X".
- El "Puntaje Bloque": El sistema de admisión permite guardar el mejor puntaje de cada prueba obtenido en las últimas dos rendiciones consecutivas. Por ende, en la base final de Postulación y Selección de un proceso (ej: Admisión 2025), el puntaje de Competencia Lectora de un alumno puede venir de la PAES de Invierno 2024 o de la PAES Regular 2024. Las glosas modernas incorporan una variable indicadora de la procedencia del puntaje (ej: PROCEDENCIA_CLEC) para rastrear de qué examen específico provino la nota combinada.
### Consejo final de Codificación
Cuando descargues estos archivos .rar históricos, notarás que las columnas tienen nombres extremadamente cortos (MRUN, A_EGRESO, COD_PROV_RES, P_NAT_REG). Ten siempre abierto en una segunda pantalla el PDF o Excel de la Glosas de Variables del año exacto que estás estudiando, puesto que el DEMRE ha cambiado los nombres de las columnas o agregando dígitos a los códigos de respuesta a medida que se han actualizado las normativas ministeriales.

#### Works cited
- Conoce aquí todos los detalles de la nueva Prueba de Acceso a la Educación Superior (PAES) - DEMRE, https://demre.cl/noticias/2022-05-19-informacion-nueva-PAES
- Qué significa PAES: explicación simple de la prueba - SimplePAES, https://simplepaes.cl/blog/que-significa-paes
- Preguntas frecuentes - PAES Regular 2026 - Proceso de Admisión 2027 - DEMRE, https://demre.cl/mesa-de-ayuda/preguntas-frecuentes-paes-regular
- Presentan la nueva Prueba de Acceso a la Educación Superior (PAES), https://www.mineduc.cl/prueba-de-acceso-a-la-educacion-superior-paes/
- Prueba de Acceso a la educación superior PAES - Ayuda Mineduc, https://www.ayudamineduc.cl/ficha/prueba-de-acceso-la-educacion-superior-paes
- Puntaje Ranking - DEMRE, https://demre.cl/paes/factores-seleccion/puntaje-ranking
- Instrucciones generales del Portal de Postulación - Proceso de Admisión 2027 - DEMRE, https://demre.cl/paes/postulacion/como-postulo-a-una-universidad/instrucciones-generales-postulacion
- Como surgió la PAES - DEMRE, https://demre.cl/paes/como-surgio-la-paes
- La prueba pendiente de la PSU - La Tercera, https://www.latercera.com/nacional/noticia/la-prueba-pendiente-la-psu/175552/
- Escala de Puntajes - - DEMRE, https://demre.cl/paes/factores-seleccion/nueva-escala-puntajes
- Prueba de Acceso a la Educación Superior - Wikipedia, la enciclopedia libre, https://es.wikipedia.org/wiki/Prueba_de_Acceso_a_la_Educaci%C3%B3n_Superior
- Prueba de Acceso a la Educación Superior (PAES): Pruebas obligatorias, electivas y M2, https://demre.cl/paes/factores-seleccion/pruebas-acceso-paes
- Paso 7: Inscripción de pruebas - DEMRE, https://demre.cl/paes/regular/inscripcion/como-inscribirme/paso7-inscripcion-pruebas
- Prueba de Acceso a la Educación Superior (PAES) - ChileAtiende, https://www.chileatiende.gob.cl/fichas/81332-prueba-de-acceso-a-la-educacion-superior-paes
- Prueba de Acceso a la Educación Superior (PAES) Regular, https://acceso.mineduc.cl/paes/
- Preguntas Frecuentes - Acceso Mineduc - Ministerio de Educación, https://acceso.mineduc.cl/preguntas-frecuentes/
- Puntajes PAES 2026: conversión, máximos y cómo estimar tu puntaje - SimplePAES, https://simplepaes.cl/blog/puntajes-paes-2026
- INSTRUMENTOS DE ACCESO, ESPECIFICACIONES Y PROCEDIMIENTOS, https://acceso.mineduc.cl/wp-content/uploads/2023/06/DOC.-Instrumentos-Acceso-Admision-2024.pdf
- teoría clásica de medición tc y teoría de respuesta al item tri - DEMRE, https://demre.cl/adjuntos/teoria-clasica-medicion-tc-teoria-de-respuesta-item-tri.pdf
- Todo lo que debes saber sobre la nueva escala de puntajes de pruebas - DEMRE, https://demre.cl/noticias/2022-01-18-nueva-escala-puntajes-proceso-2023.php
- ¿Cómo funciona la escala de puntaje PAES? - Blog, https://blog.unitips.cl/escala-de-puntajes
- Preguntas frecuentes - PAES Invierno 2026 - Proceso de Admisión 2027 - DEMRE, https://demre.cl/mesa-de-ayuda/preguntas-frecuentes-paes-invierno
- Prueba de Acceso a la Educación Superior (PAES 2026) - Admisión Universidad Autónoma, https://admision.uautonoma.cl/prueba-de-acceso-a-la-educacion-superior-paes/
- Admisión Centralizada, https://admision.ucentral.cl/vias-de-admision/admision-centralizada/
- Nueva escala de puntajes - Acceso Educación Superior, https://acceso.mineduc.cl/nueva-escala-de-puntajes/
- Puntaje Notas Enseñanza Media (NEM) y Ranking - Acceso Educación Superior, https://acceso.mineduc.cl/puntajes-notas-ensenanza-media-nem-y-ranking/
- Calculadora Puntaje PAES: cómo estimar tu puntaje y calcular tu ponderado de admisión, https://simplepaes.cl/blog/calculadora-puntaje-paes
- Tablas NEM - Enseñanza Media Humanístico-Científica Diurna - DEMRE, https://demre.cl/paes/factores-seleccion/tabla-transformacion-nem-grupo-a
- Conceptos claves postulación - DEMRE, https://demre.cl/mesa-de-ayuda/conceptos-claves/conceptos-claves-postulacion
- Admisión Centralizada (PAES) - Requisitos de postulación, https://admision.uc.cl/vias-de-admision/via-de-admision-centralizada/admision-centralizada-requisitos-de-postulacion/
- Admisión Centralizada - PAES - Universidad Técnica Federico Santa María, https://usm.cl/admision/admision-centralizada-paes/
- oferta definitiva - de carreras, vacantes y ponderaciones - DEMRE, https://demre.cl/publicaciones/pdf/2026-25-09-25-oferta-definitiva-carreras-p2026.pdf
- Ponderaciones Admisión Centralizada 2027 - Admisión y Vinculación Escolar, https://admision.uc.cl/recursos/ponderaciones-admision-centralizada/
- Diferencia entre PAES de Invierno y PAES Regular: cuál te conviene en 2026 - SimplePAES, https://simplepaes.cl/blog/diferencia-paes-invierno-y-regular
- ¿Cuándo debo inscribirme a la PAES invierno? - Acceso Educación Superior, https://acceso.mineduc.cl/aplicacion-de-invierno/
- Beca PAES Admisión 2027 - DEMRE, https://demre.cl/inscripcion/beca-paes
- Beca Prueba de Admisión a la Educación Superior (PAES) - Ventanilla Única Social, https://www.ventanillaunicasocial.gob.cl/ficha/260/beca-prueba-admision-educacion-superior
- Portal Inscripción – PAES - Acceso Educación Superior, https://acceso.mineduc.cl/portal-inscripcion/
- Programa de Acceso a la Educación Superior, PACE - Ministerio de Educación, https://acceso.mineduc.cl/admision-universidades-2023/portal-pace/
- Admisión 2026: Cupos adicionales Más Mujeres Científicas (+MC) aumentaron en un 18,4%, https://educacionsuperior.mineduc.cl/2025/12/22/admision2026-cupos-mas-mujeres-cientificas-aumentaron/
- Beca Distinción a las Trayectorias Educativas (DTE) - Ventanilla Única Social, https://www.ventanillaunicasocial.gob.cl/ficha/254/beca-distincion-trayectorias-educativas
- OFERTA DEFINITIVA - DEMRE, https://demre.cl/publicaciones/pdf/2025-24-09-25-oferta-definitiva-carreras-p2025.pdf
- Cupos Más Mujeres Científicas(+MC) - DEMRE, https://demre.cl/paes/postulacion/como-postulo-a-una-universidad/cupos-carreras-stem-mujeres
- PROGRAMA MÁS MUJERES CIENTÍFICAS +MC - Admisión UFRO, https://admision.ufro.cl/wp-content/uploads/2025/01/Programa-mas-MC.pdf
- Requisitos para estudiar pedagogía en Chile: 2016-2026 - BCN, https://www.bcn.cl/obtienearchivo?id=repositorio/10221/37515/1/BCN_requisitos_pedagogia_2016_2026_Final.pdf
- Requisitos para Postular a Carreras y Programas de Pedagogía - DEMRE, https://demre.cl/paes/postulacion/como-postulo-a-una-universidad/requisitos-postulacion-pedagogia
- ¿Quieres estudiar Pedagogía? Te contamos qué debes saber para poder realizar tu postulación. - Acceso Educación Superior, https://acceso.mineduc.cl/blog/2021/12/29/quieres-estudiar-pedagogia-te-contamos-que-debes-saber-para-poder-realizar-tu-postulacion/
- Vía de habilitación pedagogia - Estudiantes PUCV, https://estudiantespucv.cl/postulaciones/via-de-habilitacion-pedagogia/
- Distinciones a las trayectorias educativas: el nuevo puntaje nacional - Blog, https://blog.unitips.cl/distincion-trayectorias-universitarias
- PAES 2026: ¿Qué son las Distinciones a las Trayectorias Educativas (DTE) y quiénes reciben este reconocimiento? - La Tercera, https://www.latercera.com/nacional/noticia/paes-2026-que-son-las-distinciones-a-las-trayectorias-educativas-dte-y-quienes-reciben-este-reconocimiento/
- Beca Distinción a las Trayectorias Educativas (DTE) - ChileAtiende, https://www.chileatiende.gob.cl/fichas/110432-beca-distincion-a-las-trayectorias-educativas-dte
- Distinciones a las Trayectorias Educativas - Acceso Educación Superior, https://acceso.mineduc.cl/distinciones-a-las-trayectorias-educativas/

| Período de Aplicación | Instrumento de Selección | Enfoque Metodológico Principal | Críticas y Razones de Reemplazo |
| 1967 – 2002 | Prueba de Aptitud Académica (PAA)8 | Medición de aptitudes generales lógicas y de razonamiento abstracto8. | Sesgo hacia la educación científico-humanista y falta de alineación con el currículo escolar reformado8. |
| 2003 – 2020 | Prueba de Selección Universitaria (PSU)8 | Evaluación intensiva de contenidos curriculares científico-humanistas de enseñanza media8. | Profundización de las brechas de rendimiento entre colegios municipales, subvencionados y privados particulares8. |
| 2021 – 2022 | Prueba de Transición (PDT)1 | Reducción progresiva de temarios y priorización inicial de habilidades sobre contenidos memorísticos1. | Fase provisoria de carácter experimental diseñada para ensayar las metodologías de la futura PAES1. |
| 2022 – Presente | Prueba de Acceso a la Educación Superior (PAES)1 | Medición multidimensional de competencias y destrezas de aplicación bajo Teoría de Respuesta al Ítem (IRT)1. | Implementada para dar mayor equidad y flexibilidad en el ingreso a la educación superior4. |

| Nombre Oficial de la Prueba | Tipo de Examen | Cantidad de Preguntas | Tiempo de Duración | Ejes Evaluados y Características Principales |
| Prueba Obligatoria de Competencia Lectora | Obligatorio2 | 651 | 2 h 30 min1 | Comprensión, interpretación y evaluación crítica de diversos tipos de textos literarios y no literarios1. |
| Prueba Obligatoria de Competencia Matemática 1 (M1) | Obligatorio2 | 651 | 2 h 20 min1 | Medición de habilidades generales de resolución de problemas, modelación, representación y argumentación en Números, Álgebra, Geometría y Datos (de 7° básico a 2° medio)12. |
| Prueba de Competencia Matemática 2 (M2) | Específico / Requerido2 | 551 | 2 h 20 min1 | Evaluación intensiva de las mismas destrezas de M1, agregando contenidos avanzados (como logaritmos, trigonometría, combinatoria y probabilidad condicional de 3° y 4° medio)2. |
| Prueba Electiva de Ciencias | Electivo2 | 801 | 2 h 40 min1 | Consta de un módulo común de 54 preguntas y un módulo electivo de 26 preguntas a elección del postulante entre Biología, Física o Química. Hay una versión Técnico-Profesional (TP)1. |
| Prueba Electiva de Historia y Ciencias Sociales | Electivo2 | 651 | 2 h 00 min1 | Evalúa habilidades de análisis temporal, espacial y pensamiento crítico en los ejes de Historia, Formación Ciudadana y Economía12. |