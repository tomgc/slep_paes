# Decisión — Territorialización de ArchivoD (Postulación/Selección) y ArchivoMatr en `32_agregar_territorial.R`

> Decisión delegada al implementar 32 (Fase B), documentada per encargo.
> Contexto: `31_leer_normalizar.R` confirma que ArchivoD
> (`paes_postulacion_seleccion.parquet`) y ArchivoMatr
> (`paes_matricula.parquet`) NO traen columna `rbd` propia — su único puente a
> territorio es `id_aux`.

## Alternativas evaluadas

1. **Territorializar vía join por `(id_aux, anio_proceso)` contra
   `paes_inscripcion`** (que sí trae `rbd` de egreso), para las etapas que lo
   necesiten.
2. **Dejar ArchivoD/Matr fuera del árbol territorial** en esta primera versión
   de 32 (cobertura/rendimiento con B/C/egresados solamente).

## Evidencia que resuelve la decisión

- `id_aux` es único por `(id_aux, anio_proceso)` en `paes_inscripcion` (0
  duplicados verificado) → join seguro, sin fan-out.
- **100% de las combinaciones `(id_aux, anio_proceso)` presentes en ArchivoD
  (751.175) se encuentran en `paes_inscripcion`** (0 huérfanos) → el join no
  pierde población de postulación/selección.
- El propio encargo de esta tarea enumera explícitamente el embudo de
  cobertura como **egresados → inscripción → rendición → resultados_validos →
  postulación → selección** — las dos últimas etapas están en el alcance
  pedido, no son opcionales.
- **Matrícula NO es una etapa de `ETAPAS_EMBUDO`** (definida en
  `10_configuracion.R`: el embudo llega hasta "seleccion") ni fue solicitada
  como etapa por este encargo.

## Decisión (recomendación aplicada)

- **ArchivoD (postulación + selección): SÍ se territorializa**, vía join por
  `(id_aux, anio_proceso)` contra `paes_inscripcion` (`rbd` de egreso). Es la
  única forma de cumplir las 6 etapas del embudo pedidas explícitamente, y la
  evidencia de cobertura del join (100%, sin duplicación de llave) la hace
  segura.
- **ArchivoMatr (matrícula universitaria): queda FUERA del árbol territorial
  en esta v1.** No es una etapa del embudo definido en `ETAPAS_EMBUDO` ni fue
  pedida por el encargo; territorializarla ahora sería alcance no solicitado.
  El mismo mecanismo (join por `id_aux` + `anio_proceso` contra
  `paes_inscripcion`, verificando cobertura del join antes de asumirlo) se
  puede aplicar sin cambios de diseño si una versión futura de 32 agrega
  "matrícula" como séptima etapa del embudo.

## Implicancia para el código

En `32_agregar_territorial.R`, `postulacion` (ArchivoD) se enriquece con
`left_join(inscripcion_rbd, by = c("id_aux","anio_proceso"))` antes de entrar a
`agregar_conteo_territorial()`, para las etapas `postulacion` y `seleccion`.
`paes_matricula.parquet` no se lee en 32.
