# 20_insumos/auxiliares/

Auxiliares transversales: catálogos territoriales reusados de los hermanos y
documentos de condiciones de uso. No son bases por etapa.

## Ya presentes (reusados de slep_idps, paso 2)

| Archivo | Qué es | Gobernanza |
|---|---|---|
| `directorio_oficial_ee_publico.csv` | Directorio oficial MINEDUC **depurado** (RBD → comuna → región → dependencia), **sin `RUT_SOSTENEDOR`/`MRUN`** | Público, versionable |
| `diccionario_territorios.xlsx` | Diccionario de territorios (comuna, provincia, región) | Institucional |
| `caracterizacion_establecimientos.xlsx` | Caracterización de establecimientos del SLEP Costa Central | Institucional |
| `listado_slep_2026.xlsx` | SLEP × comunas × región, fechas de traspaso | Público (MINEDUC) |
| `glosas_directorio_oficial_ee.pdf` | Glosas del directorio oficial | Público |
| `guia_uso_datos_abiertos_demre.pdf` | Guía / condiciones de uso de los datos abiertos del DEMRE (base de licitud del tratamiento) | Público (DEMRE) |

> **Directorio oficial:** se reusa SOLO la versión **pública depurada**. El
> directorio crudo trae `RUT_SOSTENEDOR`/`MRUN` y NO se versiona (el `.gitignore`
> blinda el nombre `directorio_oficial_ee.csv`). Ver
> `50_documentacion/activa/gobernanza_datos.md`.

Las glosas de las **bases PAES** por etapa van en `../demre/glosas/`, no aquí.
