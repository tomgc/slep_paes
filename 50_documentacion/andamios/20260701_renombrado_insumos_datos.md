# Log de renombrado de insumos a snake_case (raiz de datos)

- Fecha: 2026-07-01 (sesion 1, Fase D / reencargo insumos)
- Alcance: `<SLEP_PAES_DATA_ROOT>/20_insumos/`. Regla: transliteracion Unicode
  (Latin-ASCII) + split camelCase antes de MAYUS seguida de letra + minusculas +
  no-alfanumerico -> `_`. Ejecutado con guardas (0 colisiones, 0 nombres no-snake).
- Total: 68 archivos renombrados + 1 directorio (glosas -> referencia).

| original | nuevo |
|---|---|
| `demre/glosas/` | `demre/referencia/` |
| `demre/cuestionarios_caracterizacion/2024/ArchivoK_ADM2024.csv` | `demre/cuestionarios_caracterizacion/2024/archivok_adm2024.csv` |
| `demre/cuestionarios_caracterizacion/2024/ArchivoL_ADM2024.csv` | `demre/cuestionarios_caracterizacion/2024/archivol_adm2024.csv` |
| `demre/cuestionarios_caracterizacion/2025/ArchivoK_ADM2025.csv` | `demre/cuestionarios_caracterizacion/2025/archivok_adm2025.csv` |
| `demre/cuestionarios_caracterizacion/2025/ArchivoL_ADM2025.csv` | `demre/cuestionarios_caracterizacion/2025/archivol_adm2025.csv` |
| `demre/cuestionarios_caracterizacion/2026/ArchivoK_ADM2026.csv` | `demre/cuestionarios_caracterizacion/2026/archivok_adm2026.csv` |
| `demre/cuestionarios_caracterizacion/2026/ArchivoL_ADM2026.csv` | `demre/cuestionarios_caracterizacion/2026/archivol_adm2026.csv` |
| `demre/inscripcion/2023/ArchivoB_Adm2023.csv` | `demre/inscripcion/2023/archivob_adm2023.csv` |
| `demre/inscripcion/2024/ArchivoB_Adm2024.csv` | `demre/inscripcion/2024/archivob_adm2024.csv` |
| `demre/inscripcion/2025/ArchivoB_Adm2025.csv` | `demre/inscripcion/2025/archivob_adm2025.csv` |
| `demre/inscripcion/2026/ArchivoB_Adm2026REG.csv` | `demre/inscripcion/2026/archivob_adm2026_reg.csv` |
| `demre/postulacion_seleccion/2023/ArchivoD_Adm2023.csv` | `demre/postulacion_seleccion/2023/archivod_adm2023.csv` |
| `demre/postulacion_seleccion/2023/ArchivoMatr_Adm2023.csv` | `demre/postulacion_seleccion/2023/archivo_matr_adm2023.csv` |
| `demre/postulacion_seleccion/2024/ArchivoD_Adm2024.csv` | `demre/postulacion_seleccion/2024/archivod_adm2024.csv` |
| `demre/postulacion_seleccion/2024/ArchivoMatr_Adm2024.csv` | `demre/postulacion_seleccion/2024/archivo_matr_adm2024.csv` |
| `demre/postulacion_seleccion/2025/ArchivoD_Adm2025.csv` | `demre/postulacion_seleccion/2025/archivod_adm2025.csv` |
| `demre/postulacion_seleccion/2025/ArchivoMatr_Adm2025.csv` | `demre/postulacion_seleccion/2025/archivo_matr_adm2025.csv` |
| `demre/postulacion_seleccion/2026/ArchivoD_Adm2026REG.csv` | `demre/postulacion_seleccion/2026/archivod_adm2026_reg.csv` |
| `demre/postulacion_seleccion/2026/ArchivoMatr_Adm2026.csv` | `demre/postulacion_seleccion/2026/archivo_matr_adm2026.csv` |
| `demre/referencia/2023/ER Notas y Egresados Ensen| `demre/referencia/2023/Libro_Co| `demre/referencia/2023/Libro_Co| `demre/referencia/2023/Libro_Co| `demre/referencia/2023/Libro_Co| `demre/referencia/2023/OfertaAcade| `demre/referencia/2023/Percentiles ADM2023.xlsx` | `demre/referencia/2023/percentiles_adm2023.xlsx` |
| `demre/referencia/2024/ADM2024_INDICADORES_POR_CARRERA_PROMEDIO_OBLIGATORIAS_20250120.csv` | `demre/referencia/2024/adm2024_indicadores_por_carrera_promedio_obligatorias_20250120.csv` |
| `demre/referencia/2024/Documento explicativo archivos K y L 2024.docx` | `demre/referencia/2024/documento_explicativo_archivos_k_y_l_2024.docx` |
| `demre/referencia/2024/ER Notas y Egresados Ensen| `demre/referencia/2024/Libro_Co| `demre/referencia/2024/Libro_Co| `demre/referencia/2024/Libro_Co| `demre/referencia/2024/Libro_Co| `demre/referencia/2024/Libro_Co| `demre/referencia/2024/LibroCo| `demre/referencia/2024/LibroCo| `demre/referencia/2024/OfertaAcade| `demre/referencia/2024/Percentiles ADM2024.xlsx` | `demre/referencia/2024/percentiles_adm2024.xlsx` |
| `demre/referencia/2025/ADM2025_INDICADORES_POR_CARRERA_PROMEDIO_OBLIGATORIAS_20250120.csv` | `demre/referencia/2025/adm2025_indicadores_por_carrera_promedio_obligatorias_20250120.csv` |
| `demre/referencia/2025/Documento explicativo archivos K y L 2025.docx` | `demre/referencia/2025/documento_explicativo_archivos_k_y_l_2025.docx` |
| `demre/referencia/2025/ER Notas y Egresados Ensen| `demre/referencia/2025/Libro_Co| `demre/referencia/2025/Libro_Co| `demre/referencia/2025/Libro_Co| `demre/referencia/2025/Libro_Co| `demre/referencia/2025/Libro_Co| `demre/referencia/2025/LibroCo| `demre/referencia/2025/LibroCo| `demre/referencia/2025/OfertaAcade| `demre/referencia/2025/Percentiles ADM2025.xlsx` | `demre/referencia/2025/percentiles_adm2025.xlsx` |
| `demre/referencia/2026/20260102_Percentiles_Pruebas_REG2026.csv` | `demre/referencia/2026/20260102_percentiles_pruebas_reg2026.csv` |
| `demre/referencia/2026/ADM2026_INDICADORES_POR_CARRERA_PROMEDIO_OBLIGATORIAS_20260116.csv` | `demre/referencia/2026/adm2026_indicadores_por_carrera_promedio_obligatorias_20260116.csv` |
| `demre/referencia/2026/Documento explicativo archivos K y L 2026.docx` | `demre/referencia/2026/documento_explicativo_archivos_k_y_l_2026.docx` |
| `demre/referencia/2026/Libro_Co| `demre/referencia/2026/Libro_Co| `demre/referencia/2026/Libro_Co| `demre/referencia/2026/Libro_Co| `demre/referencia/2026/Libro_Co| `demre/referencia/2026/LibroCo| `demre/referencia/2026/LibroCo| `demre/referencia/2026/OfertaAcade| `demre/referencia/2026/Percentiles_ADM2026-INV.csv` | `demre/referencia/2026/percentiles_adm2026_inv.csv` |
| `demre/rendicion_resultados/2023/ArchivoC_Adm2023.csv` | `demre/rendicion_resultados/2023/archivoc_adm2023.csv` |
| `demre/rendicion_resultados/2024/ArchivoC_Adm2024.csv` | `demre/rendicion_resultados/2024/archivoc_adm2024.csv` |
| `demre/rendicion_resultados/2025/ArchivoC_Adm2025.csv` | `demre/rendicion_resultados/2025/archivoc_adm2025.csv` |
| `demre/rendicion_resultados/2026/ArchivoC_Adm2026REG.csv` | `demre/rendicion_resultados/2026/archivoc_adm2026_reg.csv` |
| `egresados_em/2023/20260327_Notas_y_Egresados_Ensen| `egresados_em/2024/20260327_Notas_y_Egresados_Ensen| `egresados_em/2025/20260327_Notas_y_Egresados_Ensen