# 20_insumos/demre/rendicion_resultados/

**Etapas de cobertura:** rendición (quiénes efectivamente rinden) y resultados
(quiénes obtienen puntajes válidos). **Foco rendimiento:** los puntajes mismos.

## Qué base va aquí

El **Archivo C — Base de Rendición y Resultados** del DEMRE: puntajes obtenidos
en cada prueba rendida, más los antecedentes escolares de rendimiento (NEM,
Ranking). Una fila por persona, llave `ID_aux`. El DEMRE entrega rendición y
resultados juntos en este archivo (por eso aquí conviven las dos etapas).

## Nombre canónico

```
rendicion_resultados_paes_<AAAA>_<temporada>.csv
```

- `<AAAA>` = año del proceso de admisión; `<temporada>` = `regular` | `invierno`.
- Ejemplo: `rendicion_resultados_paes_2025_regular.csv`.

## Variables clave (según glosas DEMRE)

- Puntajes por prueba (escala 100-1000): `CLEC` (Competencia Lectora), `CMAT1`
  (M1), `CMAT2` (M2), `CCIE` (Ciencias, con versión TP), `CHIS` (Historia y Cs.
  Sociales). Ausencia/no inscripción → vacío (`NULL`) o código de ausencia.
- Contexto escolar: `PROM_NOTAS`, `PTJE_NEM`, `PTJE_RANKING`.
- Control: `RINDIO_REQUISITO` (rindió el mínimo obligatorio CLEC + M1).

> **Quiebre de escala (no mezclar años):** hasta el proceso 2022 (PSU/PDT) la
> escala era 150-850; desde 2023 (PAES) es 100-1000 con IRT. No comparar puntajes
> crudos entre regímenes sin tablas de concordancia (ver contexto_paes.md).

## Compuerta de gobernanza (antes de versionar)

Igual que las demás bases DEMRE: confirmar llave `ID_aux` (no `RUN`/`RUT`/nombre).
Ver `50_documentacion/activa/gobernanza_datos.md`.
