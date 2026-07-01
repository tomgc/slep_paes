# Manifiesto de insumos — slep_paes

> Mapa maestro de las bases del proyecto. **RAMA B:** los datos viven en la raíz
> de datos de OneDrive (`SLEP_PAES_DATA_ROOT`), NO en el repo. Refleja el estado
> real tras el diagnóstico y renombrado (2026-07-01). No se inventa metodología
> (B.1): columnas y códigos salen de las glosas del DEMRE y de `contexto_paes.md`.
> Log de renombrado auditable: `50_documentacion/andamios/20260701_renombrado_insumos_datos.csv`.

## 1. Estructura de `<SLEP_PAES_DATA_ROOT>/20_insumos/`

```
20_insumos/
├── auxiliares/                          territoriales + guía DEMRE (no-PII)
│   ├── directorio_oficial_ee_publico.csv   (depurado, sin RUT/MRUN)
│   ├── diccionario_territorios.xlsx
│   ├── caracterizacion_establecimientos.xlsx
│   ├── listado_slep_2026.xlsx
│   ├── glosas_directorio_oficial_ee.pdf
│   └── guia_uso_datos_abiertos_demre.pdf
├── demre/
│   ├── inscripcion/<AAAA>/              archivob_adm<AAAA>.csv            (ArchivoB)
│   ├── rendicion_resultados/<AAAA>/     archivoc_adm<AAAA>.csv            (ArchivoC)
│   ├── postulacion_seleccion/<AAAA>/    archivod_adm<AAAA>.csv (ArchivoD) + archivo_matr_adm<AAAA>.csv (ArchivoMatr)
│   ├── cuestionarios_caracterizacion/<AAAA>/  archivok_adm<AAAA>.csv, archivol_adm<AAAA>.csv  (CCEA, fuera de alcance activo)
│   └── referencia/<AAAA>/               libros de códigos, percentiles, oferta, indicadores, ER-notas (consulta estática)
└── egresados_em/<AAAA>/                 20260327_notas_y_egresados_ensenanza_media_<AAAA>_publ.csv  (denominador; trae MRUN)
```

Todos los nombres en snake_case puro (renombrados desde los originales del DEMRE/
MINEDUC con espacios/tildes/mayúsculas; `demre/glosas/` → `demre/referencia/`).

## 2. Mapa etapa → carpeta → archivo real → llave → foco

| Etapa | Carpeta | Archivo real (por año) | Años | Llave | Foco |
|---|---|---|---|---|---|
| Egresados EM (denominador) | `egresados_em/<AAAA>/` | `20260327_notas_y_egresados_ensenanza_media_<AAAA>_publ.csv` | 2023, 2024, 2025 **(2026 ausente)** | **`MRUN`** (PII) + `RBD` | Cobertura (denominador) |
| Inscripción (ArchivoB) | `demre/inscripcion/<AAAA>/` | `archivob_adm<AAAA>.csv` (2026: `archivob_adm2026reg.csv`) | 2023-2026 | `ID_aux` | Cobertura |
| Rendición + Resultados (ArchivoC) | `demre/rendicion_resultados/<AAAA>/` | `archivoc_adm<AAAA>.csv` | 2023-2026 | `ID_aux` | Cobertura **y** Rendimiento |
| Postulación + Selección (ArchivoD) | `demre/postulacion_seleccion/<AAAA>/` | `archivod_adm<AAAA>.csv` | 2023-2026 | `ID_aux` | Cobertura |
| Matrícula universitaria (ArchivoMatr) | `demre/postulacion_seleccion/<AAAA>/` | `archivo_matr_adm<AAAA>.csv` | 2023-2026 | `ID_aux` | Cobertura (etapa post-selección: matriculado) |
| CCEA (ArchivoK/L) | `demre/cuestionarios_caracterizacion/<AAAA>/` | `archivok_adm<AAAA>.csv`, `archivol_adm<AAAA>.csv` | 2024-2026 | `ID` | **Ninguno (fuera de alcance activo)** |

`<AAAA>` = año del proceso de admisión. Los 2026 llevan `reg` en el nombre
(publicación Regular); 2023-2025 no.

## 3. Hallazgos de esquema (evidencia literal — insumo para 31/32, aún NO diseñado)

- **REG/INV en ArchivoC — confirmado, varía por año.** Patrón
  `<PRUEBA>_<REG|INV>_<ACTUAL|ANTERIOR>`. Pruebas: `CLEC, MATE1, MATE2, HCSOC,
  CIEN, MODULO`. 2023 (28 col): `INV_ACTUAL` con `MATE` único (sin M1/M2), sin
  bloque `INV_ANTERIOR`. 2024 (35): aparece `MATE1/MATE2_INV_ACTUAL` y bloque
  `*_INV_ANTERIOR`. 2025 (36): `INV_ANTERIOR` gana M1/M2. 2026 (38): agrega
  `RINDIO_PROCESO_ANTERIOR/ACTUAL`. → homologar contra las glosas año a año.
- **Mejor puntaje histórico:** no hay columna "mejor" única; ArchivoC expone
  `<PRUEBA>_{REG,INV}_{ACTUAL,ANTERIOR}`. El "mejor de las últimas aplicaciones"
  se materializa en el ponderado (ArchivoD).
- **⚠️ PAES vs PDT en 2023 (sin resolver):** las columnas `*_ANTERIOR` de 2023
  refieren la aplicación previa (Adm2022 = PDT), que podría venir en escala PDT
  (150-850), no PAES (100-1000). A confirmar con el Libro de Códigos antes de
  usarlas. No se asume.
- **ArchivoD cambia de forma:** 2023 = WIDE (186 col, `COD_CARRERA_PREF_01..20`
  + bloques BEA/PACE); 2024-2026 = LONG (6 col: `ID_aux, ORDEN_PREF,
  COD_CARRERA_PREF, ESTADO_PREF, TIPO_PREF, PTJE_PREF`). 31 debe tratar ambos.
- **ArchivoB:** 22 col todos los años pero **orden distinto** → leer por nombre,
  nunca por posición.
- **ArchivoMatr** = matrícula universitaria efectiva (`CODIGO_UNIV, VIA,
  PTJE_POND, TIPO_MATRICULA`): etapa del embudo posterior a selección.

## 4. Llave y cruce

- Cruce entre bases DEMRE de un proceso: **`ID_aux`** (anonimizada, no RUN).
- Llave territorial: **`RBD`** (establecimiento de egreso) → comuna → SLEP →
  región → nacional, vía directorio depurado. **RBD y códigos comunales SIEMPRE
  `character`.**
- Rezagados (sin `RBD` de egreso vigente) → categoría explícita
  `ETIQUETA_SIN_RBD_VIGENTE`.

## 5. Gobernanza (ver gobernanza_datos.md)

- **`egresados_em` trae `MRUN`/`MRUN_IPE` (NNA)** y **`ArchivoB` trae
  `FECHA_NACIMIENTO`**: datos personales → Rama B, fuera del repo.
- DEMRE B/C/D/Matr/K/L usan `ID_aux` (pseudonimizado); referencia/auxiliares no-PII.
- La web publica solo agregados con supresión de celdas < 8 (k-anonimato DEMRE).

## 6. Estado (2026-07-01)

- [x] Bases DEMRE/MINEDUC depositadas y verificadas (74 archivos, ~953 MB).
- [x] Migradas a la raíz de datos (Rama B), renombradas a snake_case,
      `glosas/`→`referencia/`.
- [ ] **egresados 2026 ausente** (sin denominador de cobertura 2026).
- [ ] Normalización del sufijo `reg`/`inv` en nombres 2026 (pendiente decisión).
- [ ] Diseño de `31_leer_normalizar.R` contra el esquema real (§3): decisión
      metodológica del titular; 31/32/33 aún NO tocados con datos reales.
