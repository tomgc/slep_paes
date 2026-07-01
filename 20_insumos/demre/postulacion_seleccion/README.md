# 20_insumos/demre/postulacion_seleccion/

**Etapas de cobertura:** postulación (quiénes postulan en el sistema
centralizado) y selección (quiénes son seleccionados).

## Qué base va aquí

La **Base de Postulaciones y Seleccionados** del DEMRE (procesos consolidados):
preferencias de carreras, orden de opciones, puntajes ponderados por carrera y
resultado del proceso (Seleccionado / Lista de Espera / No Seleccionado). Llave
`ID_aux`.

## Nombre canónico

```
postulacion_seleccion_paes_<AAAA>.csv
```

- `<AAAA>` = año del proceso de admisión consolidado (p. ej. `2025`). Este
  módulo es del proceso consolidado, no se separa por temporada.
- Ejemplo: `postulacion_seleccion_paes_2025.csv`.

## Forma de la base (importante para la ETL)

Un mismo postulante puede postular hasta ~20 carreras, así que la base puede venir:

- **Ancho (wide):** columnas `COD_CARRERA_01`, `PTJE_POND_01`, ... → requiere
  `tidyr::pivot_longer()`.
- **Largo (long):** una fila por postulación, diferenciada por
  `NUM_PREFERENCIA`.

Dejar la base **tal como la entrega el DEMRE**; la normalización a formato largo
se hace en `31_leer_normalizar.R` (no editar el crudo, POLITICA 5.2.1).

## Variables clave (según glosas DEMRE)

`ID_aux`, `PREFERENCIA`/`NUM_PREFERENCIA`, `COD_CARRERA`, `PTJE_PONDERADO`,
`ESTADO_SELECCION` (`SEL`, `LE`, `ELI`...), `CUPOS_REGULARES`/`CUPOS_ESPECIALES`
(vía de ingreso: PACE, BEA, equidad de género, pueblos originarios).

## Compuerta de gobernanza (antes de versionar)

Confirmar llave `ID_aux` (no `RUN`/`RUT`/nombre). Ver
`50_documentacion/activa/gobernanza_datos.md`.
