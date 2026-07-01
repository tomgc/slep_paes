# 20_insumos/ — vacío en Git (RAMA B)

**Este repositorio NO contiene datos reales.** Los insumos del proyecto (bases
DEMRE/MINEDUC: microdato por persona, con `MRUN` de estudiantes y
`FECHA_NACIMIENTO` — datos personales, Ley 19.628 / 21.719) viven **fuera del
repo**, en la raíz de datos de OneDrive institucional apuntada por la variable de
entorno `SLEP_PAES_DATA_ROOT`:

```
<SLEP_PAES_DATA_ROOT>/20_insumos/
├── auxiliares/                    directorio oficial depurado, territorios, guía DEMRE
├── demre/
│   ├── inscripcion/<AAAA>/        ArchivoB (inscritos)
│   ├── rendicion_resultados/<AAAA>/  ArchivoC (rendición + resultados)
│   ├── postulacion_seleccion/<AAAA>/ ArchivoD + ArchivoMatr
│   ├── cuestionarios_caracterizacion/<AAAA>/  ArchivoK/L (CCEA, fuera de alcance activo)
│   └── referencia/<AAAA>/         Libros de Códigos, percentiles, oferta, indicadores
└── egresados_em/<AAAA>/           Notas y Egresados EM (denominador; trae MRUN)
```

Qué archivo va en cada lugar, con qué nombre canónico y qué foco alimenta:
`50_documentacion/activa/manifiesto_insumos.md`. Gobernanza y clasificación de
datos: `50_documentacion/activa/gobernanza_datos.md`. Configuración en una máquina
nueva: `README.md` de la raíz.
