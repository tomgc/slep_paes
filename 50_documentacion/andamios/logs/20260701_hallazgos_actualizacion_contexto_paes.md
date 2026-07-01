# Hallazgos — actualización de `contexto_paes.md` con fuentes oficiales

- **Fecha:** 2026-07-01 (sesión 1, encargo "actualizar contexto_paes.md, revisión completa").
- **Documento actualizado:** `50_documentacion/activa/contexto_paes.md`.
- **Procedimiento:** extracción de texto (R `pdftools`, R-only) de 19 PDF + 4 HTML
  oficiales depositados por el titular en
  `<SLEP_PAES_DATA_ROOT-adjunto>/insumos_nuevo_contexto_paes/`; lectura contrastada
  contra el contexto vigente por 4 lectores temáticos; búsqueda web dirigida a DEMRE
  como **complemento** (las fuentes locales oficiales prevalecen ante conflicto).
- **Regla de jerarquía:** el material oficial DEMRE (Informe Técnico, informes de
  resultados, páginas DEMRE, Ley) **prevalece** sobre la guía secundaria de la que se
  construyó la reseña en la ronda anterior. Ninguna corrección se hizo por inferencia
  propia: cada una cita su fuente.

## Inventario de archivos procesados

**Procesados con éxito (23 de datos + 1 md de referencia):** los 19 PDF y 4 HTML se
extrajeron a texto sin errores de extracción. La copia `contexto_paes.md` incluida en
la carpeta es idéntica al canónico (referencia).

**Salvedades de procesamiento (honestas):**
- Los PDF `niveles-desempeno-competencia-lectora.pdf` y `-matematica1.pdf` **perdieron
  las tablas de cortes en la extracción** (páginas con la tabla salieron vacías, el
  contenido probablemente es imagen). Los cortes de nivel se obtuvieron de las páginas
  oficiales **`demre-cl.html` y `demre-cm1.html`** (mismo emisor DEMRE), donde sí
  sobreviven íntegros.
- `WebFetch` a `demre.cl` falló de forma persistente (`Parse Error: Missing expected CR
  after header value`, problema de headers del servidor). Se usó **`WebSearch`** (que
  devuelve extractos oficiales de DEMRE) como vía alterna; cada afirmación web lleva su
  URL.
- **No se pudo verificar en esta tanda** (ningún archivo lo cubre): la tabla NEM exacta,
  la fórmula lineal de pendiente/intercepto del Ranking, el piso 458 y su vigencia 2028,
  y la escala PSU 150-850/σ=110. Se marcaron como procedencia secundaria pendiente de
  cotejo (ver "Pendientes").

## Correcciones (material oficial corrige algo ya transcrito)

| # | Tema | Antes (contexto) | Corrección oficial | Fuente |
|---|---|---|---|---|
| C1 | **Modelo psicométrico** | IRT **3PL**: `P = c+(1−c)/(1+e^(−a(θ−b)))`, con discriminación (a) y azar (c) | **Modelo de Rasch (1 parámetro)**, solo dificultad: `p_ij = e^(θ−δ)/(1+e^(θ−δ))`; sin discriminación ni azar; estimación EAP; transformación lineal por prueba | `informe-tecnico-paes-capitulo-04-2025.pdf` PÁG 13, 16-17; `informe-tecnico-paes-capitulo-02-2025.pdf` PÁG 28; `2023-informe-resultados-pdt-invierno-admision-2023.pdf` PÁG 1 (líneas 127-129) |
| C2 | **"5 preguntas excluidas"** | Preguntas de **pilotaje/calibración futura** que no puntúan | Cinco preguntas **excluidas del puntaje** cuya función es **margen de ajuste de calidad/estabilidad** de la medición; el pilotaje es proceso separado y previo | `informe-tecnico-paes-capitulo-02-2025.pdf` PÁG 31 |
| C3 | **Ejes de M1** | "Números, **Álgebra**, Geometría y **Datos**" | "Números; **Álgebra y Funciones**; Geometría; **Probabilidad y Estadística**" | `demre-cm1.html` (página oficial DEMRE Competencia Matemática 1) |
| C4 | **Vía Pedagogía (percentiles)** | "percentil **50** o superior (piso **567,5**)" como vía autónoma; Ranking "20% o **30%**" | Ley 21.490: percentil **60** (vía puntaje autónoma); **20%** notas (vía NEM); **40%** notas + percentil **50** (vía combinada); + vía RND sin rendir | `Ley-21490_20-OCT-2022.pdf` PÁG 2 (art. 27 bis lit. b). Cortes vigentes: 567,5=percentil 37 y 603=percentil 50, DEMRE Adm. 2026, [demre.cl requisitos pedagogía](https://demre.cl/paes/postulacion/como-postulo-a-una-universidad/requisitos-postulacion-pedagogia) |
| C5 | **N° de universidades** | "**47** universidades participantes" | "**45** universidades adscritas" (Adm. 2023 y 2024; varía por año) | `2023-informe-resultados-paes-regular-admision-2023.pdf` PÁG 6; `2024-...-regular-admision-2024.pdf` |
| C6 | **Ausencia de puntaje** | "vacío (**NULL**) o códigos de ausencia" | Se registra como **`0`** en las bases; "rinde" = puntaje 100-1000 en ≥1 prueba | `Guía de uso de datos abiertos DEMRE.pdf` PÁG 5 |
| C7 | **Inauguración de la escala 100-1000** | Atribuida implícitamente a la PAES regular; método 3PL | Inaugurada con la **PDT de Invierno (jul-2022)**; transformación **lineal por prueba** (`e_k(x)=γ_k+x·m_k`); método **Rasch** | `2023-informe-resultados-pdt-invierno-admision-2023.pdf` PÁG 1, 46-47 |

## Adiciones (contenido nuevo, oficial)

| # | Tema | Qué se agregó | Fuente |
|---|---|---|---|
| A1 | **Niveles de Desempeño (CL)** | 5 niveles con cortes exactos: CL3 804-1000, CL2 654-803, CL1B 535-653, CL1A 382-534, CL0 100-381 | `demre-cl.html`; `niveles-desempeno-competencia-lectora.pdf` (FONDEF ID22I100228) |
| A2 | **Niveles de Desempeño (M1)** | 5 niveles: CM3 792-1000, CM2 658-791, CM1B 571-657, CM1A 460-570, CM0 100-459 | `demre-cm1.html`; `niveles-desempeno-competencia-matematica1.pdf` |
| A3 | **CCEA — Autoeficacia Académica** | Escala del Cuestionario de Caracterización; 4 niveles Likert (Nada/Poco/Bastante/Muy capaz); sin cortes numéricos; conecta con Archivos K/L | `demre-aa.html`; `niveles-desempeno-autoeficacia-academica.pdf` |
| A4 | **CCEA — Autorregulación del Aprendizaje** | 3 niveles Likert (Nunca/Pocas veces/Frecuentemente/Siempre); ciclo Planificación-Desempeño-Evaluación; sin cortes | `demre-ada.html`; `niveles-desempeno-autorregulacion-aprendizaje.pdf` |
| A5 | **Marco legal Pedagogía (Ley 21.490)** | Base legal citada: modifica art. 27 bis Ley 20.129 y art. 36 trans. Ley 20.903 | `Ley-21490_20-OCT-2022.pdf` PÁG 1 |
| A6 | **Equating por anclaje** | Ítems ancla 2016-2022; regresión lineal de dificultades; iteración hasta R²≥0,90; desanclaje | `informe-tecnico-paes-capitulo-04-2025.pdf` PÁG 10-12; cap-02 PÁG 29 |
| A7 | **Exclusión de ítems + casos extremos** | Se excluyen del puntaje ítems que no cumplen estándares psicométricos; habilidad máx/mín a puntaje perfecto/cero | `informe-tecnico-paes-capitulo-04-2025.pdf` PÁG 9, 13, 16 |
| A8 | **"Nuevo Ranking" (Admisión 2028)** | Dejará de ser bono sobre NEM; solo posición relativa; misma posición → mismo Ranking entre colegios | [demre.cl Nuevo Ranking](https://demre.cl/paes/factores-seleccion/nuevo-ranking); [entrevista 2025-08-22](https://demre.cl/noticias/2025-08-22-entrevista-nuevo-ranking-proceso-2028) |
| A9 | **Ranking: agrupación <30 egresados** | Establecimiento con <30 egresados en 3 generaciones se agrupa con similares | [demre.cl Puntaje Ranking](https://demre.cl/paes/factores-seleccion/puntaje-ranking) |
| A10 | **Cupo Invierno = techo no saturado** | 50.000 nunca se llena (33.379 / 30.064 / 31.067 reales 2023/24/25); invierno **no selecciona** | `2023-...-pdt-invierno`, `2024-...-invierno`, `2025-...-invierno` (informes de resultados) |
| A11 | **Portal: Archivo D + Base de Matrícula** | Rótulos oficiales (4 bases); portal desde 2024, datos desde 2004; `GRUPO_DEPENDENCIA` ≠ `COD_DEPE` | `Guía de uso de datos abiertos DEMRE.pdf` PÁG 2-3, 8 |
| A12 | **Nuevos contenidos PAES Regular 2027** | Temario ampliado para Admisión 2027 (contexto de actualización normativa) | [demre.cl noticia 2026-03-20](https://demre.cl/noticias/2026-03-20-nuevos-contenidos-paes-regular-p2027) |

## Confirmaciones (el material oficial ratifica lo que decía el contexto)

| Tema | Fuente |
|---|---|
| Competencia Lectora y M1 = **65 preguntas** c/u, selección múltiple 4 opciones | `demre-cl.html`, `demre-cm1.html` |
| Escala **100-1.000** desde Admisión 2023, propia por prueba | `informe-tecnico-paes-capitulo-04-2025.pdf` PÁG 16 |
| Cupo Invierno **50.000** los tres años | informes de resultados de invierno 2023-2025 |
| Ranking: **R1-R4**, promedio, **3 generaciones** anteriores, PROM/MAX en escala 100-1000 | [demre.cl Puntaje Ranking](https://demre.cl/paes/factores-seleccion/puntaje-ranking) |
| Definición operacional de "**rinde**" + nomenclatura `_REG/INV_ACTUAL/ANTERIOR` | `Guía de uso de datos abiertos DEMRE.pdf` PÁG 5 |
| **Puntaje Ponderado** — fórmula y ejemplo **848,75** (re-chequeo 2026-07-01): aritmética correcta (ponderaciones suman 100%); estructura = suma de factores (NEM, Ranking, PAES) × ponderación por universidad, mínimos del Comité Técnico de Acceso. Coincide con `%_NOTAS/%_Ranking/%_LENG/%_MATE1/%_MATE2/%_HYCS/%_CIEN` de la oferta académica. **Confirmado sin cambios.** Precisión: algunas carreras suman una "prueba especial". | [DEMRE Conceptos claves postulación](https://demre.cl/mesa-de-ayuda/conceptos-claves/conceptos-claves-postulacion); [Mineduc, Consideraciones cálculos ponderados](https://acceso.mineduc.cl/wp-content/uploads/2021/06/2-CONSIDERACIONES-PARA-LOS-CA%CC%81LCULOS-DE-PUNTAJES-PONDERADOS-Y-PROCESO-DE-SELECCIO%CC%81N.pdf); `2014-efecto-ranking-notas.pdf` y `Guía datos abiertos DEMRE.pdf` (mención de "puntaje ponderado", sin fórmula ni ejemplo que lo contradiga) |

## Pendientes (no verificables con este material; requieren cotejo oficial)

- **Tabla NEM** (pares 4,01→103; 5,0→415; 6,0→713; 7,0→1000): cotejar con *Tablas de
  transformación de NEM* del DEMRE, por modalidad/grupo — [demre.cl tabla NEM](https://demre.cl/paes/factores-seleccion/tabla-transformacion-nem).
- **Fórmula lineal exacta del Ranking** (pendiente `m`, intercepto `b`): no consta en el
  material; la estructura sí se confirmó.
- **Piso 458** y su vigencia "desde Admisión 2028": requieren resolución/normativa del
  Comité Técnico de Acceso.
- **Escala PSU 150-850 / σ=110:** dato secundario histórico, no en el material oficial.
- **Niveles de desempeño de M2, Ciencias e Historia:** no hay páginas DEMRE en el
  material; no se inventaron.

## Resumen cuantitativo

- **Correcciones aplicadas:** 7 (C1-C7); 3 de ellas eran contradicciones fuente-oficial
  vs. guía-secundaria, resueltas por jerarquía documental (IRT/Rasch, pedagogía,
  universidades).
- **Adiciones:** 12 (A1-A12), incluidas 2 secciones nuevas (Niveles de Desempeño, CCEA).
- **Confirmaciones:** 6 bloques (incluye el re-chequeo del Puntaje Ponderado 848,75, 2026-07-01).
- **Pendientes marcados:** 5.
- **Detenciones activadas:** ninguna. La única contradicción sobre "fórmula ya
  verificada" (IRT 3PL) **sí** era resoluble por jerarquía documental clara (Informe
  Técnico oficial DEMRE > guía secundaria), por lo que se corrigió en vez de detener.
