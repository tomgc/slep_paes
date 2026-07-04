# Checklist — Setup de máquina nueva en Windows (`slep_paes`)

> **Caso C** de `prompt_portabilidad_cross_os.md` (setup de máquina nueva, no
> migración de una ya configurada = Caso B). Referencia: pendiente 4 de
> `traspaso_cierre_v05.md` §10. `slep_paes` es Rama B (dos raíces): el repo
> (código) y la raíz de **datos** (OneDrive institucional) viven en discos/rutas
> separados; en Windows ambos cambian de forma (separador de rutas, `HOME`,
> nombre de carpeta de OneDrive).
>
> **Para quién es esto:** checklist de **ejecución manual** del titular frente a
> la máquina Windows. No es un script — cada paso pide una acción y una
> verificación visual/de consola antes de seguir. Si un paso falla, **detente**
> y sigue la sección "Si falla" antes de continuar al siguiente.

---

## Paso 1 — Clonar el repo en la ruta Windows equivalente

**Acción:**

```powershell
cd C:\Users\<usuario>\Projects
git clone https://github.com/tomgc/slep_paes.git
```

**Convención de ruta:** `C:\Users\<usuario>\Projects\slep_paes` (equivalente
Windows de `~/Projects/slep_paes` en macOS). Mantener el mismo nombre de
carpeta (`slep_paes`) y el mismo padre relativo (`Projects/`) — el proyecto no
depende de la ruta absoluta del **repo** (solo del código, vía `here::here()`),
así que esta convención es por consistencia entre máquinas, no un requisito
técnico duro.

**Riesgo específico Windows:** ninguno grave en este paso — `git clone` es
neutro entre SO. El riesgo aparece si el usuario de Windows tiene un perfil
corporativo con `Documents`/`Escritorio` **redirigidos a OneDrive o a una
unidad de red** (ver Paso 3): si `Projects\` también quedara dentro de una
carpeta redirigida, cualquier sincronización de OneDrive sobre el **repo**
(no solo sobre los datos) podría generar conflictos de archivo bloqueado
mientras Git escribe. Evitarlo: clonar bajo el perfil de usuario local
(`C:\Users\<usuario>\Projects\`), **no** dentro de una carpeta con el ícono de
sincronización de OneDrive.

**Si falla:**
- `git` no reconocido → instalar Git for Windows y reabrir la terminal
  (variable `PATH` no se actualiza en la sesión ya abierta).
- Error de permisos al clonar dentro de una carpeta redirigida → clonar en
  `C:\Users\<usuario>\Projects\` explícitamente, confirmando con
  `echo %USERPROFILE%` que no apunta a una ruta de OneDrive/red.

---

## Paso 2 — Verificar OneDrive institucional y localizar `SLEP_PAES_DATA_ROOT`

**Acción:**
1. Confirmar que el ícono de OneDrive en la bandeja del sistema muestra
   sincronización completa (nube con check verde, no flecha de "sincronizando"
   ni nube con signo de exclamación).
2. Navegar en el Explorador de archivos hasta la carpeta del proyecto dentro
   de OneDrive institucional (habitualmente
   `C:\Users\<usuario>\OneDrive - SLEP\Proyectos\slep_paes\`) y confirmar que
   contiene `20_insumos\` y `40_salidas\` con archivos adentro (no carpetas
   vacías con el ícono de "disponible solo en línea" sin descargar).
3. **Copiar la ruta exacta** desde la barra de direcciones del Explorador
   (no escribirla a mano) — este es el valor que se pega en `.Renviron` en el
   Paso 3.

**Riesgo específico Windows — NBSP en la ruta de OneDrive corporativo:**
el nombre de la carpeta que crea el cliente de OneDrive para cuentas
institucionales (`OneDrive - SLEP`, `OneDrive - <Organización>`) a veces
inserta un **espacio de no separación (NBSP, `U+00A0`)** en vez de un espacio
normal (`U+0020`) alrededor del guion, invisible a simple vista pero que
**rompe la comparación de string** cuando se copia la ruta a mano o se
reconstruye por teclado en `.Renviron`. Sí es seguro si la ruta se **copia**
desde la barra de direcciones (Paso 2.3) y se **pega** (no se retipea) en el
Paso 3; el riesgo aparece solo si alguien transcribe la ruta caracter a
caracter.

**Riesgo específico Windows — redirección de `HOME`/`Documents`:** en perfiles
corporativos gestionados (política de grupo / Intune), `Documents` puede estar
redirigido a OneDrive o a una unidad de red (`\\servidor\usuario$\Documents`)
en vez de `C:\Users\<usuario>\Documents`. Esto **no afecta directamente** a
`SLEP_PAES_DATA_ROOT` (que apunta a la carpeta de OneDrive del proyecto, no a
`Documents`), pero sí afecta dónde R busca `~/.Renviron` en el Paso 3, porque
R resuelve `~` contra `HOME`/`USERPROFILE`, que puede no ser
`C:\Users\<usuario>\` si hay redirección activa.

**Si falla:**
- OneDrive no sincroniza / carpeta vacía → no continuar; resolver la
  sincronización primero (reiniciar cliente de OneDrive, verificar cuenta
  institucional activa) antes de tocar R. Correr el pipeline sobre una
  carpeta a medio sincronizar produce errores de archivo no encontrado que
  parecen (pero no son) un problema de configuración.
- No se encuentra la carpeta `Proyectos\slep_paes\` → confirmar con el
  titular anterior o el equipo de TI el nombre exacto de la carpeta raíz
  compartida (puede variar por cómo se compartió/sincronizó originalmente).

---

## Paso 3 — Copiar `.Renviron.example` a `~/.Renviron`

**Acción:**
1. Determinar dónde resuelve realmente `~` para R en esta máquina:
   ```powershell
   echo %USERPROFILE%
   ```
   ```r
   # dentro de R/Positron, para comparar contra lo que R usa como HOME:
   Sys.getenv("HOME")
   normalizePath("~")
   ```
   Si ambos coinciden, `~/.Renviron` = `<USERPROFILE>\.Renviron`. Si
   **difieren** (perfil redirigido, Paso 2), usar la ruta que reporta
   `normalizePath("~")` desde R — es la que R efectivamente va a leer.
2. Copiar el archivo:
   ```powershell
   copy .Renviron.example %USERPROFILE%\.Renviron
   ```
   (ajustar el destino si el paso anterior mostró una ruta distinta).
3. Editar `%USERPROFILE%\.Renviron` con un editor de texto plano (Notepad,
   VS Code — **no** Word) y dejar solo la línea activa con la ruta **pegada**
   del Paso 2.3, con **separador `/` (forward slash)**, no `\`:
   ```
   SLEP_PAES_DATA_ROOT="C:/Users/<usuario>/OneDrive - SLEP/Proyectos/slep_paes"
   ```
   R en Windows acepta `/` en rutas de forma nativa; usar `\` obliga a
   escapar cada uno (`\\`) y es la fuente más común de rutas rotas al portar
   `.Renviron` entre sistemas.

**Riesgo específico Windows:** el mismo NBSP del Paso 2 puede reintroducirse
aquí si se **retipea** la ruta en vez de pegarla; y el separador de rutas
(`\` vs `/`) es la causa más frecuente de que la variable "se vea bien" en el
archivo pero falle al resolverse en R.

**Si falla:**
- `.Renviron.example` no existe en la raíz del repo clonado → verificar que el
  clone del Paso 1 se completó sin errores; el archivo debe estar versionado
  (no está en `.gitignore`, solo `.Renviron` sin `.example` lo está).
- Tras editar, `Sys.getenv("SLEP_PAES_DATA_ROOT")` en R devuelve `""` → el
  archivo no está en la ruta que R usa como `HOME` (repetir la comparación
  del punto 1) o falta reiniciar R/Positron (la variable se lee solo al
  iniciar la sesión).

---

## Paso 4 — Reiniciar R y validar (POLITICA §8.3.7)

**Acción:** cerrar y reabrir R/Positron por completo (no basta con limpiar el
entorno), luego:

```r
source(here::here("10_utils", "10_configuracion.R"))
obtener_data_root()          # debe devolver la ruta, sin error
dir.exists(ruta_insumos())   # TRUE
dir.exists(ruta_salidas())   # TRUE
```

**Nota de nombre de función:** la función real en este repo es
`obtener_data_root()` (sin sufijo `_proyecto`) — así está implementada en
`10_utils/10_configuracion.R` y así la usa `README.md`. Si alguna referencia
previa (traspasos, plantilla genérica de `POLITICA_PROYECTO.md`) menciona
`obtener_data_root_proyecto()`, es la convención genérica de la plantilla;
en `slep_paes` el nombre vigente y el que hay que tipear es el corto.

**Riesgo específico Windows:** si `obtener_data_root()` lanza el error
`"Variable de entorno SLEP_PAES_DATA_ROOT no definida"`, casi siempre es
Paso 3 no resuelto (archivo en la ruta equivocada de `HOME`) — no un problema
de esta función. Si en cambio lanza `"La ruta apuntada... no existe en
disco"`, la variable sí se leyó pero la ruta tiene un carácter distinto al
real (NBSP, `\` sin escapar, o la carpeta de OneDrive con un nombre distinto
al asumido) — comparar caracter a caracter contra la ruta copiada en el
Paso 2.3.

**Si falla:**
- Error de variable no definida → volver al Paso 3, punto 1 (confirmar dónde
  resuelve `HOME` realmente).
- Error de ruta no encontrada / `dir.exists()` da `FALSE` → volver al Paso 2:
  confirmar sincronización de OneDrive completa y ruta exacta; si el archivo
  `.Renviron` usa `\`, cambiar a `/`.
- No detenerse a "arreglar a mano" con una ruta aproximada: si el valor no
  calza carácter a carácter, es preferible volver a copiar la ruta real desde
  el Explorador que adivinar la corrección.

---

## Paso 5 — Correr el subconjunto mínimo del pipeline

**Acción:**

```r
source("00_run_all.R")
run_all(only = c(31, 32))
```

Confirma que el pipeline **lee y agrega los datos reales** end-to-end
(`31_leer_normalizar.R` → `32_agregar_territorial.R`) antes de tocar cualquier
código o generar el motor HTML. No hace falta correr `only = 33` en este
checklist — el objetivo es confirmar que la máquina nueva **lee datos**, no
regenerar el sitio publicado.

**Qué esperar en verde:** mensajes `OK: ...parquet (N filas, M cols)` para
`paes_egresados`, `paes_inscripcion`, `paes_rendicion_resultados`,
`paes_postulacion_seleccion` (paso 31) y para
`paes_cobertura_territorial` / `paes_rendimiento_territorial` (paso 32), sin
`STUB` ni `WARN` de insumos faltantes.

**Riesgo específico Windows:** ninguno nuevo en este paso si los pasos 1-4
quedaron en verde — es la confirmación de que toda la cadena (ruta de repo,
ruta de datos, `.Renviron`, `HOME`) resolvió correctamente. Un fallo aquí con
los pasos previos en verde suele ser de **contenido** de los datos (insumos
incompletos en OneDrive), no de portabilidad cross-OS.

**Si falla:**
- Mensaje `STUB: faltan parquets... -> agregacion omitida` en el paso 32 →
  el paso 31 no se completó o los CSV crudos de `20_insumos/` no están
  sincronizados; revisar el log de 31 primero.
- Error de columnas/esquema inesperado → no es un problema de Windows;
  detenerse y reportarlo aparte (podría indicar una versión distinta de los
  archivos DEMRE en esta copia de OneDrive).
- Todo lo anterior en verde pero este paso falla igual → **detenerse y
  reportar** antes de intentar correr `run_all()` completo o tocar código;
  no es un checklist de debugging de pipeline, es de portabilidad.

---

## Cierre

Con los 5 pasos en verde, la máquina Windows queda operativa para trabajar en
`slep_paes` (código) sin haber tocado los datos reales más que para leerlos.
Registrar en el próximo traspaso de cierre que el pendiente 4 (`Caso C`,
`traspaso_cierre_v05.md` §10) quedó resuelto, con la fecha y máquina/usuario
donde se validó.
