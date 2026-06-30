# SETTINGS_Y_PROMPTS_OPERACIONALES.md

> **Versión 7 (consolidada).** Vive permanentemente en la knowledge base
> del Project (y se copia a `50_documentacion/activa/` de cada proyecto).
> Absorbe y reemplaza a: `prompt-apertura-sesion.md` (v3),
> `prompt-cierre-sesion.md` (v4), `prompt_orquestador.md`,
> `prompt_migrar_estructura.md` (v2), `prompt_migracion_github_v2.md` y
> `prompt_portabilidad_cross_os.md`. La arquitectura que esos prompts
> implementaban vive ahora en `POLITICA_PROYECTO.md` v5; aquí viven los
> PROTOCOLOS de sesión y de operación.
>
> **Cambios respecto a v6:** nueva subsección 2.2.15 (Errores del
> asistente, registro obligatorio): tabla estructurada de campos fijos
> (momento, disparador, qué pasó, regla violada, causa raíz, salvaguarda
> presente, patrón), distinta de bugs de código y aprendizajes técnicos.
> Implementa POLITICA 0.5 (v5.2). Objetivo: hacer analizable en conjunto,
> entre los 16 proyectos de la cartera, un problema de errores repetidos
> del asistente que las salvaguardas existentes no han prevenido por sí
> solas. §2.2 y §2.3 actualizados para incluirla como sección obligatoria
> del traspaso (punto 15) incluso cuando está vacía.
>
> **Cambios respecto a v5:** nueva subsección 2.1bis (Fase 2 — PUSH de
> estado estandarizado): todo proyecto que adopte el estándar genera, en
> su propio cierre, un `ESTADO.md` con front matter parseable
> (semáforo, sesión, sensibilidad, `tipo_pendiente`) más tres secciones
> breves en prosa. Es una destilación del traspaso, no información nueva.
> Habilita lectura barata y estable para el orquestador de cartera
> (`slep_estado_proyectos_monitoreo`), con fallback a PULL (lectura del
> traspaso/backlog) si el proyecto aún no adoptó el estándar o su
> `ESTADO.md` está desincronizado. Propagación inicial: 13 de 16
> proyectos de la cartera (sesión 5, 2026-06-30); 3 sin traspaso aún
> quedaron pendientes.
>
> **Cambios respecto a v4:** §2.2.5 ahora declara el archivo canónico
> del backlog: nombre (`backlog_acumulativo.md`), ubicación
> (`50_documentacion/activa/`) y momento de extracción (a partir del
> segundo cierre). Complementa el parche paralelo en
> `POLITICA_PROYECTO.md` §10. Cierra la brecha documental que causó
> heterogeneidad de nombres y ubicaciones en la cartera.
>
> **Cambios respecto a v3:** nueva subsección 4.6.4 (suite standalone
> offline: activar `generar_suite(standalone=TRUE)` para embeber CSS,
> fuentes, logos e iconos en cada HTML; precondición de `npm` + red para
> descargar lucide-static, validación de iconos, ajuste de versionado del
> tema). Procedimiento estándar para propagar el modo offline a cualquier
> proyecto con suite.
>
> **Cambios respecto a v2:** nueva regla 4.6.3.6 (terminología
> institucional del SLEP: "establecimiento educacional" como término
> genérico, completo en la primera mención de cada párrafo y abreviado a
> "establecimiento(s)" en las repeticiones; prohibición de "EE" en texto
> visible y de "colegio" como sustantivo genérico, con excepciones para
> la voz del lector en FAQ, los ejemplos del universo y nombres propios
> externos).
>
> **Cambios respecto a v1:** nueva sección 4.6 (generar la documentación
> de un proyecto con el paquete `suitedoc`: guion de insumos, mapeo a la
> `cfg`, reglas de gobernanza y de no-invención de metodología).
>
> **Regla crítica de automatización:** este documento y la política viven
> en la knowledge base. El asistente los procesa proactivamente al inicio
> de cada sesión. JAMÁS pide al usuario que los adjunte. Solo en un chat
> suelto fuera de un Project, y solo si la tarea los requiere, los
> solicita una vez. Si la knowledge base contiene una versión más
> reciente de un documento que la citada en el traspaso, usar la más
> reciente y declararlo en el acuse de recibo.
>
> **Nomenclatura de principios:** las referencias B.N / C.N apuntan a
> los principios de interacción (B) y técnicos (C) de la política,
> sección 5 (B.1 pensar antes de codificar, B.2 simplicidad, B.3 cambios
> quirúrgicos, B.4 ejecución dirigida por objetivos; C.N = numeración de
> la sección 5.2-5.3).

---

## 1. Protocolo de sesiones

### 1.1 Clasificación (primer paso de toda sesión)

Cuatro tipos:

- **CONTINUATION:** retomar un proyecto en curso. Señales: "continuemos
  con", "retomar", "donde quedamos", traspaso adjunto.
- **NEW PROJECT:** proyecto de desarrollo desde cero. Señales:
  descripción de algo a construir, requerimientos, pedido de andamiaje.
- **ONE-OFF:** consulta aislada sin ciclo de vida (1-5 turnos). Una
  pregunta, una revisión, una explicación.
- **BIBLIOTECA:** sesión generativa que produce artefactos para
  `herramientas_dev/` (políticas, prompts, plantillas). Taller, no
  consulta: si el primer mensaje pide diseñar o mejorar instrumental,
  es BIBLIOTECA aunque parezca simple.

Si tras el primer mensaje el tipo es ambiguo, UNA pregunta para
clasificar y proceder.

### 1.2 CONTINUATION

El objetivo de la apertura es **analizar, comprender, planificar y
proponer antes de tocar una sola línea de código**. Sin atajos.

#### 1.2.1 Insumos

(a) Esta knowledge base (política + este documento), leída sin pedirla.
(b) El traspaso `traspaso_cierre_vNN.md` de la sesión anterior.
(c) El escáner reciente (`estructura_actual.md`).
Si (b) o (c) faltan y no están en la knowledge base, pedirlos en un
solo mensaje y detenerse. Insumo opcional: `CLAUDE.md` del proyecto si
la sesión correrá en Claude Code.

#### 1.2.2 Fase A — Lectura y verificación

1. Leer la política completa (estructura, naming, gobernanza,
   principios de la sección 5) y el traspaso completo de principio a
   fin, **incluido todo el backlog acumulativo**. No escanear, no
   resumir prematuramente, no saltar secciones.
2. Comparar el árbol del escáner con la estructura canónica de la
   política. Toda desviación (carpetas con nombres antiguos, archivos
   fuera de lugar, huecos de numeración) se marca como **deuda
   heredada**, no se "ajusta" en silencio.
3. Ejecutar la auditoría de apertura (política, sección 5.6, preguntas
   marcadas "Apertura") y anotar hallazgos.

#### 1.2.3 Fase B — Acuse de recibo estructurado

```markdown
## Acuse de recibo — Traspaso vNN

### Estado comprendido
[Resumen en palabras propias: qué funciona, qué no, qué cambió en la última sesión]

### Bugs y resoluciones asimilados
- **Bug N:** [síntoma] → **Causa raíz:** [comprensión] → **Regla aprendida:** [regla a respetar]

### Restricciones técnicas vigentes
[Todas las restricciones, convenciones y trampas que deben respetarse]

### Instrucciones específicas heredadas
[Reproducción literal de la sección 12 del traspaso]

### Estado del backlog
[Total de cambios acumulados, sesiones completadas, 3-4 categorías dominantes con porcentaje]

### Principios activados para esta sesión
- **B.2 (Simplicidad primero):** aplica porque [razón concreta].
- **C.6 vs B.2:** tensión a monitorear porque [razón].

### Auditoría de apertura (política 5.6)
- [pregunta] → [Sí / No — acción requerida]
```

Cerrar con confirmación explícita de haber procesado política,
traspaso (con N bugs, N restricciones, N pendientes, backlog de NNN
cambios) y escáner. Declarar aquí si se usó una versión de documento
más reciente que la citada en el traspaso.

#### 1.2.4 Fase C — Ruta de desarrollo propuesta

No esperar a que el usuario diga qué hacer: con el traspaso completo,
el asistente propone.

```markdown
## Ruta de desarrollo propuesta para esta sesión

### Diagnóstico de situación
[1-2 párrafos: dónde está el proyecto, urgencias, patrón del backlog
(¿deuda acumulándose? ¿bugs bloqueantes? ¿deuda heredada detectada?)]

### Prioridad N: [Título]
- **Qué:** descripción concreta.
- **Por qué en este orden:** justificación relativa.
- **Complejidad estimada:** Baja / Media / Alta.
- **Principios relevantes:** B.N / C.N.
- **Criterio de éxito (B.4):** condición verificable de término.

### Tareas que sugiero NO abordar en esta sesión
[Pendientes a diferir y por qué]

### Ruta alternativa (opcional)
[Camino distinto igualmente válido, con recomendación explícita]
```

Tantas prioridades como quepan razonablemente en una sesión; no inflar.

**Criterios de priorización, en este orden:** (1) bugs activos siempre
primero; (2) bloqueantes; (3) instrucciones explícitas del traspaso
(⚠️ / ✅ / 🔒); (4) deuda heredada de la auditoría de apertura; (5)
deuda técnica acumulada (patrón de bugfixes recurrentes en la misma
zona → proponer refactor antes de construir encima); (6) pendientes de
alta complejidad al inicio, cuando hay más contexto; (7) funcionalidad
nueva; (8) cosmética y documentación al final o en sesión dedicada.

**Esta es la única compuerta de aprobación de la sesión.** El usuario
aprueba, reordena o propone alternativa; cualquiera es válido.

#### 1.2.5 Fase D — Ejecución por tarea

Con la ruta aprobada, se ejecuta con autonomía (política 0.3): solo se
interrumpe por decisión estratégica vital, archivo crítico faltante o
compuerta de gobernanza. Por cada tarea, antes de codificar, plan
compacto (presentado y ejecutado en el mismo turno salvo que active
una de esas tres excepciones):

```markdown
## Plan — [Tarea]
- **Objetivo:** [una oración]
- **Criterio de éxito (B.4):** [definido ANTES de codificar]
- **Archivos involucrados:** [rutas relativas y rol]
- **Impacto:** [funciones afectadas directa/indirectamente, insumos requeridos, salidas que cambian]
- **Riesgos:** [riesgo + mitigación]
- **Verificación contra traspaso y principios:** [restricciones o bugs previos que aplican; tensiones declaradas]
```

Construcción incremental en bloques verificables (flujo: comprender →
planificar → construir → verificar → documentar). Tras cada bloque:
¿reintroduce un bug documentado?, ¿respeta restricciones del traspaso,
principios, política y convenciones?, ¿tocó solo lo necesario (B.3)?

Si el usuario pide algo que contradice un principio, una restricción
del traspaso, una regla aprendida o la política, señalarlo ANTES de
proceder, citando la fuente: "Antes de avanzar: [regla/principio]
indica [X]; lo que propones [riesgo]. ¿Procedemos o ajustamos?"

#### 1.2.6 Reglas permanentes de la sesión

- **NUNCA modificar código sin haberlo leído primero.** La fuente
  principal de errores entre sesiones es operar sobre un estado
  supuesto. No asumir el contenido de un archivo ni su ubicación: leer
  el archivo, consultar el escáner (y pedir re-correrlo si está
  desactualizado).
- **NUNCA aplicar cambios no solicitados ni aprobados** (B.3). Las
  mejoras detectadas se mencionan, no se implementan.
- **Un cambio conceptual por intervención:** un cambio, una
  explicación, una verificación. No agrupar cambios distintos.
- **Bugs: causa raíz antes de corregir.** Diagnosticar, documentar,
  verificar si es un caso conocido del traspaso, y solo entonces
  corregir, verificando no romper otra cosa.
- **La política es contrato, no sugerencia.** Desviaciones se
  documentan como deuda heredada y se proponen como pendiente.

#### 1.2.7 Registro continuo para el cierre

Durante toda la sesión, registrar mentalmente por cada cambio: qué y
por qué, categoría temática del backlog, causa raíz si hubo bug,
alternativas si hubo decisión de diseño, tensiones entre principios y
cómo se resolvieron. Es el insumo del traspaso (sección 2).

### 1.3 NEW PROJECT

Sin traspaso. Primera acción obligatoria: la pregunta de bifurcación
por sensibilidad de datos (política, sección 8.1). Luego el plan:

```markdown
Comprensión del proyecto
[2-4 bullets en palabras propias]

Supuestos que estoy haciendo
[supuestos e inferencias declarados]

Ruta de trabajo propuesta
[3-6 pasos numerados; el paso 1 es siempre la inicialización según la
rama A o B de la política, sección 8]

Decisiones que necesito de ti antes de empezar
[solo bloqueantes; la sensibilidad de datos ya debe estar resuelta]

¿Avanzamos con el paso 1 o ajustamos la ruta?
```

Desde la aprobación de la ruta aplican las fases D y siguientes de
1.2, y el primer cierre genera el traspaso v01 con el backlog inicial
(objetivo del proyecto, nota metodológica y taxonomía inicial; ver
2.2.5).

### 1.4 ONE-OFF

Sin protocolo. Responder directo. Sin ritual de cierre.

### 1.5 BIBLIOTECA

Sin apertura formal. Responder directo. Si la sesión produce 3 o más
artefactos persistentes, ofrecer proactivamente un **cierre liviano**:

```markdown
Artefactos producidos
[lista de archivos con destino]

Decisiones clave
[2-4 decisiones de diseño que conviene recordar]

Próximos artefactos posibles
[ideas no materializadas]
```

Guardar como `herramientas_dev/logs/YYYYMMDD_sesion_<tema>.md` previa
confirmación del usuario.

### 1.6 Prohibido en cualquier tipo

Aperturas vagas ("¿en qué trabajamos hoy?"); acuses genéricos antes del
plan; empezar trabajo tangible antes de entregar el plan (cuando
aplica); planes no anclados en insumos reales.

---

## 2. Protocolo de cierre de sesión de proyecto

### 2.1 Generación

Al cerrar una sesión CONTINUATION o NEW PROJECT, generar
`traspaso_cierre_vNN.md` (correlativo global, dos dígitos; snake_case
según la política, sección 2; unifica la grafía antigua con guiones)
en `50_documentacion/traspasos/`. El traspaso es el **único puente**
entre sesiones: todo lo que no quede ahí, se pierde. Antes de cerrar:
ejecutar el escáner y referenciarlo.

> **Convención de nombre — no negociable.** El separador es SIEMPRE
> guión bajo: `traspaso_cierre_vNN.md`. NUNCA con guión medio
> (`traspaso-cierre-vNN.md` es no-canónico y no se versiona). Esto
> aplica a todo archivo que Claude genere o nombre en el proyecto:
> snake_case, sin guiones medios, sin tildes, sin ñ, sin espacios
> (política, sección 2). Antes de entregar o commitear cualquier
> archivo nuevo, verificar que el nombre no contenga `-`, ` `, ni
> caracteres acentuados. Si el escáner muestra un archivo canónico
> existente con cierta grafía, esa grafía manda; no introducir una
> variante.

Incluir TODAS las secciones de 2.2; si una no aplica, incluirla con
"No aplica en esta sesión" y justificación breve.

### 2.1bis Generación de ESTADO.md (Fase 2 — PUSH)

Todo proyecto que adopte el estándar de Fase 2 genera o actualiza, en el
mismo cierre que produce el traspaso, un archivo
`50_documentacion/activa/ESTADO.md`. Es una **destilación** de campos que
el traspaso ya produce, no información nueva: front matter estructurado
(parseable de forma determinista) más tres secciones breves en prosa.

**Formato canónico:**

```
---
slug: <slug>
nombre_real: <nombre>
categoria: activo
semaforo: activo|pausa|bloqueado|cerrado
sesion_actual: vNN
ultima_actividad: AAAA-MM-DD
maneja_sensibles: true|false
tipo_pendiente: bug|bloqueante|deuda_heredada|deuda_tecnica|nuevo|cosmetica|ninguno
---
## En que vamos
<2-3 oraciones>
## Proximo paso
<1 oracion>
## Bloqueantes
<lista o "ninguno">
```

**Origen de cada campo (mapeo de destilación):**

| Campo `ESTADO.md` | Se toma de (traspaso, por significado, no por número de sección — la numeración varía entre proyectos) |
|---|---|
| `slug`, `nombre_real` | Identificación del proyecto |
| `semaforo` | Inferido del estado al cierre: **bloqueado** solo si hay un bug bloqueante activo del propio pipeline; **pausa** si el proyecto completo está parado a la espera de un tercero externo (aprobación, dato de otra área) sin acción ejecutable de parte del titular; **activo** en cualquier otro caso, incluido cuando solo un ítem puntual del backlog (no el proyecto completo) está marcado como a la espera de algo. Ante duda entre activo y pausa, el criterio decisivo es: ¿hay trabajo ejecutable por el titular ahora mismo, aunque sea parcial? Si sí, activo. |
| `sesion_actual` | Versión vNN del traspaso usado como fuente |
| `ultima_actividad` | Fecha de cierre del traspaso fuente |
| `maneja_sensibles` | Gobernanza del proyecto (`gobernanza_datos.md` si existe, o POLITICA §6.1) |
| `tipo_pendiente` | Ver regla de mapeo abajo — **NO se copia literal**, se traduce |
| `## En que vamos` | Resumen ejecutivo del traspaso, condensado a 2-3 oraciones |
| `## Proximo paso` | Pendientes y ruta sugerida, la prioridad 1 |
| `## Bloqueantes` | Pendientes marcados tipo "bloqueante"; "ninguno" si no hay |

**Regla de mapeo de `tipo_pendiente` (dos taxonomías distintas, no
confundir):**

`tipo_pendiente` usa el enum de **prioridad de sesión** de §1.2.4
(`bug | bloqueante | deuda_heredada | deuda_tecnica | nuevo | cosmetica |
ninguno`). Responde la pregunta "¿qué tipo de trabajo encabeza el próximo
arranque de este proyecto?". Es **distinto** de la **clasificación
temática** del `backlog_acumulativo.md` de cada proyecto (POLITICA §10),
que es una taxonomía orgánica y propia de cada hermano (categorías como
"administrativo", "contenido", "documentación", "deuda de datos", libres
por proyecto) que responde "¿de qué trata esta entrada del backlog?".

Cuando el pendiente de prioridad 1 del traspaso esté etiquetado con
vocabulario temático del backlog (no con el enum de §1.2.4), **tradúcelo
por significado al enum de prioridad**; no lo copies literal y no
amplíes el enum para acomodarlo. Si la traducción no es evidente, usa
`nuevo` como default conservador y dilo explícitamente en el reporte de
la sesión que generó ese `ESTADO.md` (no es un error silencioso
aceptable; es una ambigüedad a revisar por el titular).

**Regla de generación:** `ESTADO.md` se escribe DESPUÉS del traspaso,
nunca antes (el traspaso es la fuente; `ESTADO.md` es su destilación). Si
el cierre no alcanza a generarlo, no bloquea el cierre de sesión: el
orquestador de cartera cae a PULL (lectura del traspaso/backlog) para ese
proyecto, sin error.

**Detección de desincronización (consumida por el orquestador, no por
este protocolo):** si `ultima_actividad` de `ESTADO.md` antecede al mtime
real del último `traspaso_cierre_vNN.md`, el `ESTADO.md` se considera
desactualizado y el orquestador prioriza PULL para ese proyecto en esa
corrida.

**Adopción:** no retroactiva por defecto. Un proyecto adopta Fase 2
generando su primer `ESTADO.md`; hasta entonces, el orquestador lo lee
por PULL (Fase 1, sin cambios). No hay plazo obligatorio de migración. Un
proyecto sin ningún traspaso aún no puede adoptar Fase 2 (no hay fuente
de la cual destilar): queda en PULL hasta su primer cierre formal.

### 2.2 Estructura del traspaso

1. **Identificación:** proyecto, versión vNN, fecha, sesión N con foco
   en 1-2 oraciones, entorno, archivos principales modificados.
2. **Resumen ejecutivo:** un párrafo de 5-8 oraciones (qué se propuso,
   qué se logró, qué quedó pendiente, estado general). Suficiente por
   sí solo para entender la situación.
3. **Estado al cierre:** qué funciona (con última ejecución exitosa),
   qué no funciona (síntoma observable), delta respecto a vNN-1.
4. **Registro detallado de cambios:** un bloque por cambio
   conceptualmente independiente (no agrupar aunque compartan archivo):
   archivo(s), categoría temática, qué se hizo, por qué (C.11), cómo se
   verificó (B.4), líneas o secciones clave, dependencias afectadas,
   tensiones entre principios si las hubo.
5. **Backlog acumulativo** (ver 2.2.5).
6. **Bugs de la sesión:** síntoma observable, causa raíz, solución
   exacta (archivo/línea), criterio de verificación, **patrón general
   aprendido** como regla aplicable, principios violados o aplicados,
   estado (resuelto / parcial / pendiente).
7. **Aprendizajes y restricciones descubiertas:** cada uno como regla
   concreta con principio relacionado, contexto (qué pasa si se viola)
   y ejemplo de la sesión.
8. **Decisiones de diseño:** decisión, alternativas consideradas,
   justificación, tensiones resueltas, implicancia. Las de peso
   arquitectónico se replican como archivo en
   `50_documentacion/activa/decisiones/YYYYMMDD_decision_<tema>.md`.
9. **Constantes y parámetros vigentes:** tabla constante / valor /
   archivo / nota (marcando cambios de valor).
10. **Arquitectura de archivos:** referencia al escáner al cierre; si
    la estructura cambió, resumen del cambio y verificación contra la
    política.
11. **Pendientes y ruta sugerida:**
    - Inventario: por pendiente, descripción, contexto, tipo (bug
      activo / bloqueante / funcionalidad / deuda técnica / mejora
      visual / documentación), impacto, dependencias, complejidad,
      principios relevantes, precauciones, sugerencia de enfoque y
      criterio de éxito sugerido. Campos obligatorios: son el insumo
      de la Fase C de la próxima apertura.
    - Evaluación de deuda técnica: zonas frágiles (qué principio se
      viola) y oportunidades de mejora.
    - Auditoría de cierre (política 5.6, preguntas "Cierre"); toda
      respuesta "no" se agrega como pendiente.
    - Ruta sugerida para la próxima sesión aplicando los criterios de
      priorización de 1.2.4, con justificación y criterio de éxito por
      ítem, más lo que conviene diferir.
12. **Instrucciones específicas para la próxima sesión:** formato
    ⚠️ NO [acción] sin [condición] / ✅ ANTES de [acción], verificar
    [precondición] / 🔒 [invariante intocable].
13. **Fragmentos de código de referencia:** patrones que son "la forma
    correcta" en este proyecto, ejecutables tal cual, comentados.
14. **Reapertura** (ver 2.2.14).
15. **Errores del asistente** (ver 2.2.15): tabla obligatoria, registro
    exhaustivo de desviaciones de regla canónica (POLITICA 0.5).

#### 2.2.5 Backlog acumulativo (memoria de largo plazo)

**Archivo canónico:** `50_documentacion/activa/backlog_acumulativo.md`.
Nombre y ubicación no negociables (ver política §10). En el primer
cierre el backlog puede vivir embebido en el traspaso; a partir del
segundo cierre debe existir como archivo independiente en esta ruta.

Registro histórico vivo. En cada cierre se **copia íntegro** el backlog
del traspaso anterior y se agregan los cambios nuevos al final. Jamás
se reescriben, resumen ni renumeran entradas anteriores; un error se
corrige con una entrada nueva.

- **Objetivo del proyecto:** párrafo permanente (qué es, qué produce,
  con qué herramientas, para quién, desde cuándo). Se redacta en la
  sesión 1.
- **Nota metodológica:** párrafo permanente que define qué cuenta como
  "cambio" (una solicitud distinguible del usuario, no las acciones
  técnicas que la implementan), qué no (errores del asistente
  corregidos de inmediato; sí cuentan los bugfixes reportados por el
  usuario), que la clasificación es por intención primaria, y cuáles
  son las fuentes del conteo.
- **Clasificación temática:** tabla categoría / N° / % / descripción
  con ejemplos concretos del proyecto. Taxonomía orgánica: se propone
  en la sesión 1 y se refina después. Categorías mutuamente
  excluyentes por intención primaria; entre 8 y 15; subdividir si una
  supera el 25%; absorber si una queda bajo el 2% tras varias sesiones.
- **Resumen estadístico por sesión:** tabla sesión / traspasos
  generados / N° de cambios / modelo / foco (3-6 palabras), con fila
  final separada para refinamientos menores no atribuibles, y total.
- **Detalle cronológico:** todos los cambios por sesión, con
  **numeración correlativa global y permanente** (nunca se reinicia ni
  renumera), descripciones autocontenidas, referencia cuando un cambio
  resuelve un pendiente anterior, y subtítulos temáticos en sesiones
  largas.
- **Delta del backlog:** cambios respecto a la versión anterior (N
  entradas nuevas, refinamientos de taxonomía, reclasificaciones).

#### 2.2.14 Reapertura (al final del traspaso Y replicada en el chat)

Toda esta sección aparece dentro del traspaso y se replica
**textualmente** al final del mensaje con el que el asistente cierra la
sesión, para copiar todo sin abrir el archivo. Con **valores reales,
jamás placeholders**.

- **Nombre del chat:** `<Proyecto>, sesión <N+1> (<Modelo>)`.
- **Mensaje de apertura pre-armado:** declara tipo CONTINUATION, indica
  que el protocolo (política + este documento) vive en la knowledge
  base y se lee desde ahí, y lista qué se adjunta. Variante para chat
  suelto: "Adjunto los documentos de protocolo y los específicos de la
  sesión."
- **Documentos para la próxima sesión, en tres bloques:**
  1. *Protocolo en knowledge base* (NO se adjuntan; se listan con
     nombre exacto solo para verificar que la knowledge base esté al
     día): `POLITICA_PROYECTO.md`,
     `SETTINGS_Y_PROMPTS_OPERACIONALES.md`.
  2. *Opcionales según el foco real de la próxima sesión* (solo los
     que apliquen, no todos): `CLAUDE.md` si correrá en Claude Code;
     protocolos 4.1-4.6 de este documento según la tarea;
     `auditoria_codigo_proyecto_md_v1.md` si habrá auditoría de cifras.
  3. *Específicos de la sesión* (SÍ se adjuntan): el traspaso
     `traspaso_cierre_vNN.md`; el escáner `estructura_actual.md`; los
     archivos críticos para retomar (solo los que la próxima sesión
     necesita, priorizando los del pendiente foco; los voluminosos
     pero críticos se mantienen anotados como tales); datos o
     referencias externas si aplica, con su porqué.
- **Nota final obligatoria:** si algún archivo listado cambió entre
  sesiones, adjuntar la versión más actualizada al abrir y avisarlo en
  el mensaje de apertura.

#### 2.2.15 Errores del asistente (registro obligatorio, POLITICA 0.5)

Sección obligatoria del traspaso, distinta de "Bugs de la sesión" (§2.2.6,
que registra bugs de CÓDIGO) y de "Aprendizajes y restricciones" (§2.2.7,
que registra reglas técnicas DESCUBIERTAS). Esta sección registra errores
del **asistente mismo**: desviaciones de una regla canónica ya existente
(POLITICA, este documento, `CLAUDE.md`, `userPreferences`, o una
instrucción explícita ya dada en la sesión), detectadas por el asistente o
señaladas por el usuario, se hayan nombrado como "error" o no (POLITICA
0.5, disparador exhaustivo).

**Por qué es una sección separada y no se mezcla con bugs/aprendizajes:**
un bug de código se corrige editando el código; un error del asistente se
corrige ajustando el comportamiento del asistente, y su valor está en ser
**comparable entre sesiones y entre los 16 proyectos de la cartera** para
detectar patrones que ninguna sesión aislada vería. Mezclarlo con bugs de
código diluiría esa comparabilidad.

**Tabla obligatoria (campos fijos, una fila por error):**

| Campo | Contenido |
|---|---|
| `momento` | En qué punto de la sesión ocurrió (referencia al turno o tarea) |
| `disparador` | Cómo se detectó: "asistente lo señaló espontáneamente" / "usuario lo corrigió" / "usuario lo señaló sin nombrarlo error" |
| `que_paso` | Descripción concreta de la desviación, una oración |
| `regla_violada` | Documento + sección exacta de la regla que existía y no se siguió (p.ej. "userPreferences, edición de archivos: entregar completo, no fragmentos") |
| `causa_raiz` | Por qué ocurrió pese a que la regla estaba disponible (nunca "no lo sabía": la regla existía; el análisis es de por qué no se aplicó en el momento) |
| `salvaguarda_presente` | Qué documento(s) ya contenían la regla violada (POLITICA / SETTINGS / CLAUDE.md / userPreferences / más de uno) |
| `patron` | Si este error es una variante de otro ya registrado en este traspaso o en uno anterior, indicar cuál; si es nuevo, decir "nuevo" |

**Regla de registro:** el error se anota en el momento en que se
identifica dentro de la sesión (no se reconstruye de memoria al cerrar).
Si la sesión no llega a un cierre formal, el registro provisional debe
quedar localizable en el historial de la conversación.

**Consumo entre proyectos:** esta tabla es, junto al backlog, uno de los
pocos artefactos pensados explícitamente para análisis CRUZADO entre los
16 proyectos de la cartera (no solo memoria de un proyecto individual).
Si en una sesión de `slep_estado_proyectos_monitoreo` (o cualquier sesión
BIBLIOTECA dedicada) se detecta que el mismo `patron` aparece en tablas de
errores de 2 o más proyectos, eso es evidencia de que la salvaguarda
actual (la regla tal como está escrita) no es suficiente y debe
reformularse, no solo repetirse con más énfasis.

### 2.3 Reglas de redacción del traspaso

1. Exhaustividad sobre brevedad: ante la duda, incluir (la información
   faltante cuesta una sesión repitiendo errores).
2. Especificidad sobre generalidad: causa raíz exacta con archivo y
   línea, no "tenía un bug".
3. Causa raíz, no solo síntoma (C.11).
4. Cada aprendizaje como regla concreta vinculada a su principio.
5. Sin supuestos implícitos: la próxima instancia no "lo sabrá" (B.1).
6. Todo fragmento de código incluido debe ser copiable y ejecutable.
7. El backlog es la única fuente de verdad del conteo histórico.
8. Los pendientes son el mapa de la próxima ruta: sus campos son
   obligatorios.
9. La auditoría de cierre es obligatoria: la sesión no deja deuda sin
   documentar.
10. Valores reales en la reapertura, sin placeholders.
11. La tabla de errores del asistente (§2.2.15) es obligatoria incluso si
    está vacía: una fila "sin errores registrados en esta sesión" es una
    afirmación verificable; omitir la sección entera no lo es.

---

## 3. Higiene de sesión

Recomendar cierre proactivo ante: muchas vueltas con fatiga de
contexto; múltiples archivos largos cargados con confusión de
versiones; síntomas de degradación (mezclar versiones, repetir código
ya entregado, respuestas vagas, perder acuerdos); pivote a otro
dominio. Formato:

> Sugiero cerrar esta sesión. Razón: [síntoma concreto]. ¿Cerramos con
> el protocolo de cierre (proyecto) o con cierre liviano (BIBLIOTECA)?

Cerrar temprano es más barato que un traspaso corrupto.

---

## 4. Protocolos bajo demanda

Se activan cuando la tarea de la sesión lo requiere. El asistente los
consulta solo; no espera que el usuario los invoque por nombre.

### 4.1 Generar orquestador `00_run_all.R`

Especificación completa: política, sección 4. Protocolo:

1. Obtener el inventario real de ejecutables (escáner o
   `estructura_actual.md`). No deducir nombres ni rutas.
2. Generar el archivo completo cumpliendo la sección 4 de la política
   (raíz vía `rprojroot`, `PASOS`, `run_all(from/to/only/skip)`,
   validación de rutas al inicio, logging, `.qmd` vía
   `quarto::quarto_render()`).
3. Incluir al final ejemplos de uso comentados (`run_all()`,
   `run_all(skip = c(1, 2))`, `run_all(from = 5)`, `run_all(only = 8)`).
4. Prohibido: modificar scripts de estación, asumir scripts no
   inventariados, caché automático por timestamp, lógica de negocio.

### 4.2 Migrar estructura a la convención canónica

Motor: `herramientas_dev/plantillas/99_reorganizar_estructura_PLANTILLA.R`
copiado al proyecto. Reglas no negociables: política, sección 9.
Secuencia exacta:

1. **Escaneo** del proyecto (pedirlo si no está).
2. **Diagnóstico de referencias:** buscar TODAS las referencias
   literales a las carpetas actuales en `.R`/`.qmd` (entrecomilladas,
   en `file.path()`, `test_path()`, comentarios, tests), excluyendo
   `.Rproj.user`, `renv/`, `.bak`. Sin este diagnóstico los regex de
   reescritura fallan en silencio.
3. **Mapeo justificado:** carpetas vieja → nueva contra los principios
   de la política sección 1; renombres de archivos; reorganización de
   documentación; patrones de reemplazo derivados del diagnóstico;
   exclusiones explícitas (`andamios/`). Confirmación del usuario antes
   de generar el script (decisión estratégica: excepción válida a la
   regla de autonomía).
4. **Adaptar la plantilla** con `DRY_RUN <- TRUE` y registro en
   `_archivo/log_reorganizacion.csv`.
5. **Ciclo DRY_RUN → real:** verificar que los conteos del DRY_RUN
   cuadren con el diagnóstico (Fase 3 con 0 reemplazos = regex malos);
   commit limpio; `DRY_RUN <- FALSE`; verificar integridad de copias.
6. **Validación:** reiniciar R, tests, orquestador end-to-end,
   verificación visual. Solo entonces borrar `.bak`.

No ceder a presión por saltar el DRY_RUN, aunque el usuario lo pida.

### 4.3 Migrar proyecto local a GitHub privado (dos raíces)

Arquitectura objetivo: política, sección 6.2. Contexto a confirmar al
inicio: `nombre_proyecto`, `nombre_repo_github`, ruta local actual,
ruta de código destino (`~/Projects/...`), ruta de datos destino
(OneDrive). Visibilidad: privado, no negociable sin justificación.

- **Fase 0 — Escaneo estructural.** Si la estructura está fuera de
  norma, primero migrar estructura (4.2). No se sube a GitHub un
  proyecto desordenado.
- **Fase 1 — Auditoría de seguridad pre-migración.** Script
  `diagnostico_migracion_github.R` que reporte: datos personales
  hardcodeados (regex RUT `\d{1,2}\.?\d{3}\.?\d{3}-[\dkK]`, correos,
  nombres); credenciales; rutas absolutas con información personal
  (OneDrive, `Users/<nombre>/`); archivos de datos en carpetas
  versionables; nombres con tildes/ñ/espacios; historial Git sucio si
  ya es repo. Output: `diagnostico_migracion_github.md` con hallazgo,
  severidad, norma aplicable y recomendación. **Esperar revisión del
  usuario** (compuerta de gobernanza, no interrupción trivial).
- **Fase 2 — Separación código / datos.** Mover código a la raíz de
  código, datos a la raíz de datos; configurar variable de entorno,
  `10_configuracion.R`, `.Renviron.example` y `.gitignore` blindado
  según política 6.2-6.3 y 8.3. Regla de movimiento físico: **copiar,
  no mover**; verificar que OneDrive terminó de sincronizar antes de
  borrar las carpetas de datos del origen (o moverlas a `_archivo/`
  como respaldo local). Generar `gobernanza_datos.md` y `LICENSE`
  (política, sección 10). Validar con el bloque 8.3.7 en sesión R
  limpia ANTES del primer push; si falla, diagnosticar, no continuar.
- **Fase 3 — Repo remoto.** Verificar con el usuario que es PRIVADO;
  branch protection en `main` (PR obligatorio, sin force push, sin
  borrado). **Matiz de plan:** en GitHub Free los repos privados NO
  tienen branch protection; sustituir con el workflow de validación
  del punto siguiente más autodisciplina de PR documentada en el
  README. Secret Scanning (detección básica activa por defecto en
  privados) y Dependabot; workflow de Actions que valide en cada push
  ausencia de extensiones de datos, de patrones RUT y de tokens.
- **Fase 4 — Primer push.** `git status` completo mostrado al usuario;
  confirmación de cualquier archivo sospechoso; recién entonces push.
- **Fase 5 — Despliegue (si aplica).** Secretos como variables de
  entorno del servidor; autenticación (SSO institucional preferido);
  logs sin datos personales; recordar que shinyapps.io aloja en AWS US
  (si los datos no pueden salir de Chile, Posit Connect on-premise o
  servidor institucional). Infraestructura SLEP: preguntar qué existe,
  no asumir.
- **Cierre.** Mover `diagnostico_migracion_github.md` a
  `50_documentacion/activa/decisiones/` como evidencia histórica;
  copiar `CLAUDE.md` a la raíz si las próximas sesiones serán en
  Claude Code; documentar en el traspaso la configuración pendiente
  para otras máquinas (protocolo 4.4).

### 4.4 Setup de máquina nueva (proyecto ya migrado a dos raíces)

1. Clonar el repo en `~/Projects/`.
2. Verificar que OneDrive institucional esté sincronizado y localizar
   la raíz de datos del proyecto.
3. Copiar el contenido de `.Renviron.example` a `~/.Renviron` ajustando
   la ruta al sistema operativo de la máquina.
4. Reiniciar R y validar (política 8.3.7).
5. Correr `run_all()` o el subconjunto mínimo para confirmar pipeline
   operativo.

No es un refactor: no se toca código del proyecto.

### 4.5 Auditoría de cifras publicadas

Patrón de tres scripts (helpers + orquestador de familias + spot-check)
documentado en `herramientas_dev/prompts/auditoria_codigo_proyecto_md_v1.md`
(vigente como documento independiente). Núcleo: cada cifra publicada se
calcula por dos caminos independientes (caché vs. recálculo desde el
objeto crudo) y se comparan con tolerancias definidas como constantes
nombradas. Llaves siempre `character`; patrón índice-primero en Excel
(jamás `worksheetOrder()`); una familia que falla no aborta las demás.

### 4.6 Generar la documentación de un proyecto con `suitedoc`

Produce los 4 documentos HTML de la suite (`arquitectura_*`,
`documentacion_proyecto_*`, `arquitectura_general_*`,
`documentacion_general_*`) para un proyecto, llenando su `cfg` a partir
del material existente del proyecto, sin que el usuario edite la
configuración a mano. El motor genérico vive en el paquete `suitedoc`;
este protocolo cubre cómo se arma el `documentar.R` de un proyecto
concreto.

**Tipo de sesión:** BIBLIOTECA (produce un artefacto reutilizable, el
`documentar.R` del proyecto), no CONTINUATION del proyecto documentado.
Sin acuse de recibo ni ruta de desarrollo: se entra directo al guion de
insumos. Si produce el `documentar.R` más los 4 HTML, ofrecer el cierre
liviano de 1.5.

**Regla de automatización:** el asistente NO pide al usuario que llene la
`cfg`. Pide los insumos del proyecto (abajo), extrae de ellos todo lo
inferible, y solo pregunta por lo que ningún archivo contiene (la prosa
de comunidad). El producto es un `documentar.R` completo, no una
plantilla con huecos para que el usuario rellene.

#### 4.6.1 Insumos a solicitar (en un solo mensaje)

El asistente pide estos archivos del proyecto a documentar. Los que
existan en la knowledge base del Project no se piden; se leen desde ahí.

| Insumo | Qué aporta a la `cfg` |
|---|---|
| `estructura_actual.md` (escáner) | Diagrama técnico: `insumos`, `etapas`, `intermedios`, rutas reales de los `rotulos`. **Imprescindible:** sin él, las rutas del diagrama se inventan. |
| `README.md` | Identidad (`slug`, `area`, `fuente`); `prosa$doc_que`; origen de los datos. |
| `CLAUDE.md` (si existe) | Convenciones técnicas → `glosario_tec`, flags de `etapas`. |
| Traspaso `traspaso_cierre_vNN.md` (el último) | `decisiones`, `anomalias`, `reglas_calculo`, restricciones técnicas. **Imprescindible:** es la fuente principal de las decisiones metodológicas. |
| Decisiones (`50_documentacion/activa/decisiones/`) | `decisiones` con su porqué; `gobernanza`. |
| Scripts del pipeline (los del flujo, no los utils) | Diccionario de datos (`dic_crudos`, `dic_intermedios`); detalle de `etapas`. |
| `gobernanza_datos.md` (si el proyecto tiene datos sensibles) | `cfg$gobernanza`; qué NO publicar. |

Si faltan los dos imprescindibles (escáner y traspaso), pedirlos y
detenerse: sin ellos el diagrama y las decisiones se inventarían,
violando B.1 (sin supuestos implícitos).

#### 4.6.2 Procedimiento

1. **Leer todos los insumos** de principio a fin. No resumir
   prematuramente.
2. **Verificar la versión del paquete.** Confirmar que el `suitedoc`
   instalado expone los campos que el `documentar.R` va a llenar
   (`rotulos`, `reglas_calculo`, `leyenda`, `textos`, `pie_extra`,
   `gobernanza`, `prosa$etapas_pipeline`). Si el paquete es una versión
   anterior sin esos campos, declararlo: el `documentar.R` generado los
   incluirá igual (caen al fallback del motor), pero conviene actualizar
   el paquete.
3. **Extraer lo inferible** y mapearlo a la `cfg`:
   - Del escáner: el `slug` (nombre de la carpeta raíz), las etapas del
     pipeline (los ejecutables de `30_procesamiento/` en orden), los
     insumos (`20_insumos/`), los intermedios (`40_salidas/`), y los
     `rotulos` con las rutas reales (`31_<...>.R`, etc.).
   - Del README y los scripts: identidad, diccionario de datos, origen.
   - Del traspaso y las decisiones: `decisiones` (cada una con `id`,
     `titulo`, `cuerpo`, `por_que`), `anomalias`, `reglas_calculo`, y
     `gobernanza`.
4. **Determinar la gobernanza.** Si el proyecto trata datos personales o
   de NNA, fijar `cfg$gobernanza` con la categoría (p. ej. "Datos
   personales de NNA") y aplicar la regla de no incluir nombres reales de
   establecimientos, estudiantes ni funcionarios en ningún documento (los
   generales se publican). Describir universos en abstracto.
5. **Redactar la prosa de comunidad.** Lo que ningún archivo contiene:
   `faq`, `garantias`, `notas`, `prosa$gen_porque`, hero-notes de los
   documentos generales. El asistente la redacta desde lo que el proyecto
   hace, en el registro de la audiencia (directivos / comunidad). Si el
   usuario tiene un texto de referencia de voz (un documento ejecutivo,
   un correo tipo), se pide y se usa como base del tono; si no, se redacta
   y se marca para revisión.
6. **Entregar el `documentar.R` completo**, con todos los bloques llenos.
   Las zonas redactadas sin fuente directa (prosa de comunidad) se marcan
   con un comentario `# REVISAR (voz): ...` para que el usuario afine el
   tono, pero el contenido va completo, no en blanco.
7. **No ejecutar por el usuario.** Generar los 4 HTML es tarea del
   usuario (correr `source("documentar.R")` desde su máquina, donde está
   R y el paquete instalado). El asistente entrega el `documentar.R` y la
   instrucción de una línea para generarlo y revisarlo.

#### 4.6.3 Reglas no negociables

1. **Sobrescribir todos los bloques que los builders consumen.** Un
   bloque sin personalizar saldría con el fallback genérico del motor o,
   peor, con residuo del ejemplo. `generar_suite(verificar = TRUE)` (el
   default) aborta si detecta texto del ejemplo de fábrica; el
   `documentar.R` se entrega de modo que pase esa verificación.
2. **Gobernanza prevalece.** En proyectos con datos sensibles, ningún
   nombre real de EE/estudiante/funcionario entra a la `cfg`, porque los
   documentos generales se publican (política, sección 6).
3. **No inventar metodología.** Las `decisiones` y `anomalias` salen del
   traspaso y de los archivos de decisión, nunca de la deducción del
   asistente. Si una decisión no consta, se pregunta; no se fabrica un
   porqué (B.1).
4. **La prosa de comunidad se redacta, no se extrae** — y se marca como
   revisable, porque el tono es del usuario.
5. **Ubicación canónica de la salida:** `50_documentacion/suite/`
   (`documentar.R` + tema + los 4 HTML). Versionar el tema solo si los
   HTML se publican desde el repo; si no, `fonts/` y `assets/` al
   `.gitignore`.
6. **Terminología institucional del SLEP.** El término genérico para
   referirse a escuelas, liceos, jardines infantiles, centros de
   educación de adultos y similares es **"establecimiento educacional"**
   (plural "establecimientos educacionales"). Se despliega completo en
   la **primera mención de cada párrafo**; en las repeticiones siguientes
   del mismo párrafo se usa **"establecimiento(s)"** a secas, para no
   recargar la prosa. La regla aplica a prosa técnica y de comunidad por
   igual. Nunca usar la abreviatura "EE" en texto visible al usuario (sí
   se conserva en notación técnica de fórmulas, p. ej. `conteo de EE`,
   `n_EE`). No usar "colegio" como sustantivo genérico. Excepciones: (a)
   la voz simulada del lector en una FAQ puede usar lenguaje coloquial;
   (b) "escuela/liceo/jardín" se usan deliberadamente cuando se
   ejemplifica el universo que el término genérico engloba; (c) nombres
   propios de productos externos se conservan literalmente (p. ej.
   "Localiza tu colegio" de la Agencia de Calidad).

#### 4.6.4 Suite standalone offline (propagar a cualquier proyecto)

Genera la suite en formato **standalone offline**: embebe CSS, fuentes,
logos e iconos dentro de cada HTML, de modo que los 4 documentos no
dependan del tema en disco ni de CDN para los iconos. Es el formato
canónico para archivar o compartir la documentación como unidad
autónoma, alineado con el principio de HTML autocontenido del proyecto
(igual que el motor). La capacidad vive en `suitedoc` (HEAD `c8b3bd7` en
adelante); **no** requiere tocar el paquete, solo invocarlo bien.

**Cuándo aplica:** cualquier proyecto con suite (`documentar.R` +
`generar_suite()`) que aún produzca los HTML en modo enlazado. Activar
standalone es un cambio acotado en el `documentar.R` del proyecto, no en
`suitedoc`.

**Procedimiento (por proyecto):**

1. **Verificar la versión del paquete.** Confirmar que el `suitedoc`
   instalado expone `generar_suite(..., standalone=)`. Firma real:
   `generar_suite(cfg, salida_dir = ".", copiar_tema = TRUE,
   verificar = TRUE, standalone = FALSE, verbose = TRUE)`. Si la versión
   instalada no la expone, reinstalar desde el repo local:
   `devtools::install("/Users/tomgc/Projects/herramientas_dev/suitedoc")`.
2. **API real (no asumir otra).** `standalone = TRUE` hace que
   `generar_suite` llame **internamente** a
   `inlinar_suite(salida_dir, limpiar_enlazados = TRUE)`: escribe los 4
   `*_standalone.html` y borra los enlazados intermedios. **Nunca** se
   llama `inlinar_suite()` por separado en el flujo normal.
3. **Cambiar la llamada del `documentar.R`** del proyecto: añadir
   `standalone = TRUE`. Mantener el `verificar` que ese proyecto ya use
   (no cambiarlo sin razón declarada).
4. **Precondición de entorno (🔴).** `inlinar_suite()` descarga
   lucide-static (versión fijada, p. ej. 1.21.0) vía `npm pack`. Requiere
   `npm` en el PATH y red al registro npm **en tiempo de generación** (la
   suite resultante sí es 100% offline; generarla no). Verificar
   `npm --version` antes de regenerar; si falla, detenerse y reportarlo
   (el titular instala npm), no improvisar.
5. **Validación de iconos (A17-2 / R3).** `inlinar_suite()` valida todos
   los `data-lucide` de la cfg y **aborta sin escribir nada** si alguno
   no existe en la versión fijada de lucide-static, listando los
   faltantes. Si un icono no resuelve (caso vivido: `sitemap`→`network`),
   sustituirlo en la cfg por el equivalente lucide más cercano y
   registrarlo; si no hay equivalente obvio, detenerse y reportar.
6. **Verificación empírica sobre los `*_standalone.html` reales** (no
   sobre supuestos, R1): `grep` de referencias de red por archivo = 0
   (`http://`, `https://`, `src=`/`href=` a CDN, `<link rel="stylesheet"
   href="http`); iconos como `<svg>` embebido (no `<i data-lucide>` ni
   `<script>` de lucide); fuentes como `data:` URIs. Reportar el conteo
   de red por archivo.
7. **Ajuste de versionado.** Con standalone, el tema (`fonts/`,
   `assets/`) ya viaja embebido en el HTML y **no** se versiona. Cada
   proyecto versiona los 4 `*_standalone.html` + `documentar.R` + el CSS;
   `fonts/` y `assets/` al `.gitignore`. `git status` antes de
   `git add`; nunca `git add .`; confirmar con `git ls-files` (no con el
   escáner, A20) que el tema no entra.

**Separación de responsabilidades (importante).** Activar standalone es
**solo** lo anterior. Si la `cfg` de un proyecto además necesita
actualizaciones de contenido (decisiones formales, gobernanza), eso es
trabajo aparte que se decide explícitamente; no se mezcla con la
activación del modo offline (un cambio conceptual por intervención).

**Llamada canónica:**

```r
# setwd("<raiz_proyecto>") si se corre por Rscript (here::i_am lo exige).
suitedoc::generar_suite(
  cfg,
  salida_dir  = here::here("50_documentacion", "suite"),
  copiar_tema = TRUE,
  verificar   = FALSE,   # o TRUE si ese proyecto no dispara falsos positivos
  standalone  = TRUE,    # produce *_standalone.html offline; limpia los enlazados
  verbose     = TRUE
)
# Requiere npm + red en tiempo de generación (descarga lucide-static fijado).
```
