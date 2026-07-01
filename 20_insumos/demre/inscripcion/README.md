# 20_insumos/demre/inscripcion/

**Etapa de cobertura:** inscripción (quiénes se registran para rendir).

## Qué base va aquí

El **Archivo B — Base de Inscritos/as** del Portal de Datos Abiertos del DEMRE:
información demográfica, socioeconómica y de origen escolar de **todas** las
personas que se registraron para rendir la PAES en un proceso, hayan asistido o
no. Una fila por inscrito/a, llave `ID_aux` (anonimizada, no RUN).

## Nombre canónico

```
inscritos_paes_<AAAA>_<temporada>.csv
```

- `<AAAA>` = año del **proceso de admisión** (p. ej. `2025`).
- `<temporada>` = `regular` o `invierno` (la PAES se rinde dos veces al año;
  ver contexto_paes.md). Una base por temporada y proceso.
- Ejemplos: `inscritos_paes_2025_regular.csv`,
  `inscritos_paes_2025_invierno.csv`.

> Si el DEMRE entrega `.txt` separado por `;` o `.rar/.zip`, descomprimir y dejar
> el plano renombrado al nombre canónico (snake_case, sin tildes). El año del
> nombre es el del proceso de admisión, no el calendario de rendición.

## Variables clave (según glosas DEMRE)

`ID_aux`, `RBD_ENS` (establecimiento de egreso de EM), `COD_DEPE`,
`COMUNA_EGRESO`/`REGION_EGRESO`, `ANIO_EGRESO`, `SITUACION_INSCRIPCION`
(trabajar solo con inscripciones **válidas**), más cuestionario de contexto.

## Compuerta de gobernanza (antes de versionar)

Verificar que la base sea la **versión abierta k-anonimizada** del DEMRE: llave
`ID_aux` (no `RUN`/`RUT`/nombre). Si apareciera una columna identificadora
directa (`MRUN`, `RUN`, nombre), **no versionar** y avisar (ver
`50_documentacion/activa/gobernanza_datos.md`).
