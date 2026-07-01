# 20_insumos/demre/glosas/

Diccionarios de variables ("Glosas de Variables") del DEMRE: definen la
codificación exacta de cada columna de cada base, **por año de proceso**. Son
imprescindibles para normalizar sin inventar (B.1): el DEMRE cambia nombres de
columnas y códigos entre años.

## Qué va aquí

Una glosa por base y por año, tal como el DEMRE las publica (xlsx o pdf).

## Nombre canónico

```
glosas_<base>_<AAAA>.<ext>
```

- `<base>` = `inscripcion` | `rendicion_resultados` | `postulacion_seleccion`.
- `<AAAA>` = año del proceso de admisión al que aplica la glosa.
- `<ext>` = `xlsx` o `pdf` según entrega el DEMRE.
- Ejemplos: `glosas_inscripcion_2025.xlsx`,
  `glosas_rendicion_resultados_2025.xlsx`,
  `glosas_postulacion_seleccion_2025.pdf`.

> Las glosas NO son insumo de cálculo: son la referencia de codificación que el
> pipeline consulta para homologar columnas y códigos. La codificación de
> dependencia (`COD_DEPE`: 1 Municipal, 2 Part. subv., 3 Part. pagado, 4 Adm.
> Delegada, 5 SLEP) y los filtros de confidencialidad (k-anonimato = 8) viven en
> estas glosas; ver el resumen estable en `contexto_paes.md`.
