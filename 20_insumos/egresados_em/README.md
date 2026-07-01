# 20_insumos/egresados_em/

**Capa de elegibilidad / denominador de cobertura** (NO es una etapa del embudo).

## Qué base va aquí

La **caracterización de egresados de enseñanza media**: cuántas personas egresan
de EM por establecimiento (RBD) y año, base contra la cual se mide la cobertura
del embudo PAES (cuántos de los que *pueden* rendir efectivamente inscriben,
rinden, etc.). Fuente: registros públicos del MINEDUC (egreso / rendimiento de
enseñanza media), **no** el DEMRE — por eso vive fuera de `demre/`.

## Nombre canónico

```
egresados_em_<AAAA>.csv
```

- `<AAAA>` = año de egreso de enseñanza media.
- Ejemplo: `egresados_em_2024.csv`.

## Granularidad esperada

Conteo de egresados por **RBD × año de egreso** (con dependencia y territorio
derivables del directorio oficial reusado). RBD y códigos comunales como
`character`.

## Por qué es el denominador, no una etapa

El embudo (inscripción → rendición → resultados → postulación → selección) se
lee **contra** los egresados de EM elegibles. La promoción del año tiene RBD de
egreso limpio; los rezagados (egresados de años anteriores) que rinden sin RBD
vigente se agregan en una categoría **explícita** de cobertura
(`ETIQUETA_SIN_RBD_VIGENTE`), nunca como hueco ni descarte (ver brief §3-4 y
`10_configuracion.R`).

## Compuerta de gobernanza

Datos de conteo agregados por establecimiento (no microdato por persona). Aun
así, confirmar que no traiga identificadores de personas antes de versionar.
