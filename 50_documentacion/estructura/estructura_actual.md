# Estructura actual — slep_paes

- **Raiz:** `/Users/tomgc/Projects/slep_paes`
- **Fecha:** 2026-07-04 16:34:42
- **Totales:** 20 carpetas, 111 archivos
- **Nota:** Rama B: codigo versionado en el repo; datos reales en la raiz de OneDrive (SLEP_PAES_DATA_ROOT), fuera del repo. 20_insumos/ y 40_salidas/ del repo contienen solo README.md de referencia.

## Arbol

```
slep_paes/
├── .claude/
│   └── launch.json  (364)
├── 10_utils/
│   ├── 10_configuracion.R  (7.39K)
│   ├── 10_utils.R  (1.94K)
│   ├── d3.min.js  (273K)
│   ├── pako.min.js  (45.8K)
│   ├── react-dom.production.min.js  (129K)
│   └── react.production.min.js  (10.5K)
├── 20_insumos/
│   └── README.md  (1.28K)
├── 30_procesamiento/
│   ├── 30_construir_auxiliares.R  (8.22K)
│   ├── 31_leer_normalizar.R  (18.5K)
│   ├── 32_agregar_territorial.R  (23.4K)
│   ├── 33_generar_html.R  (15.7K)
│   └── 33_motor_template.html  (70.2K)
├── 40_salidas/
│   └── README.md  (530)
├── 50_documentacion/
│   ├── activa/
│   │   ├── decisiones/
│   │   │   ├── .gitkeep  (0)
│   │   │   ├── 20260630_decision_patron_comun_y_paleta.md  (11.1K)
│   │   │   ├── 20260701_decision_schema_31_leer_normalizar.md  (14.6K)
│   │   │   ├── 20260701_decision_territorializacion_d_matr.md  (2.67K)
│   │   │   ├── 20260702_decision_camino_a_motor_33.md  (3.59K)
│   │   │   └── 20260703_decision_f3_margen_interarchivo.md  (5.39K)
│   │   ├── .DS_Store  (6K)
│   │   ├── backlog_acumulativo.md  (13.3K)
│   │   ├── contexto_paes.md  (69.8K)
│   │   ├── ESTADO.md  (954)
│   │   ├── gobernanza_datos.md  (7.16K)
│   │   ├── manifiesto_insumos.md  (5.77K)
│   │   ├── POLITICA_PROYECTO.md  (34.6K)
│   │   └── SETTINGS_Y_PROMPTS_OPERACIONALES.md  (57.3K)
│   ├── andamios/
│   │   ├── auditoria_datos_pre_push/
│   │   │   ├── f3_fase0_diagnostico.R  (3.75K)
│   │   │   ├── fase0_reproducibilidad.R  (3.98K)
│   │   │   ├── fase1_recalculo.R  (7.63K)
│   │   │   ├── fase2_aditividad.R  (7.46K)
│   │   │   ├── fase3_pct100.R  (6.2K)
│   │   │   ├── fase4_dom_evidencia.md  (2.43K)
│   │   │   ├── lib_auditoria.R  (14.9K)
│   │   │   ├── lib_reauditoria.R  (5.42K)
│   │   │   ├── reauditoria_fase4_dom.md  (2.04K)
│   │   │   ├── reauditoria_post_fix.R  (8.33K)
│   │   │   └── reauditoria_rendimiento_vigente.R  (4.9K)
│   │   ├── design_handoff_ui_ux/
│   │   │   ├── fonts/
│   │   │   │   ├── gobCL_Heavy.otf  (43.7K)
│   │   │   │   ├── gobCL_Regular.otf  (35.7K)
│   │   │   │   ├── MuseoSans_500.otf  (61K)
│   │   │   │   ├── MuseoSans_700.otf  (62.1K)
│   │   │   │   └── MuseoSans-300.otf  (61.5K)
│   │   │   ├── README.md  (14K)
│   │   │   └── slep_paes - motor.dc.html  (69.4K)
│   │   ├── logs/
│   │   │   ├── 20260701_escala_anterior_archivoc_2023.md  (2.3K)
│   │   │   ├── 20260701_hallazgos_actualizacion_contexto_paes.html  (14.4K)
│   │   │   ├── 20260701_hallazgos_actualizacion_contexto_paes.md  (10.4K)
│   │   │   ├── 20260702_ajustes_interfaz_v2_log.md  (6.23K)
│   │   │   ├── 20260702_cohorte_territorial_log.md  (7.14K)
│   │   │   ├── 20260702_fix_base_todas_log.md  (5.11K)
│   │   │   ├── 20260702_mejoras_interfaz_log.md  (8.98K)
│   │   │   ├── 20260702_motor_33_datos_reales_log.md  (8.72K)
│   │   │   ├── 20260702_rotulo_p1_convocatoria_log.md  (7.41K)
│   │   │   ├── 20260702_suitedoc_generacion_log.md  (8.08K)
│   │   │   ├── 20260702_universo_seleccionados_log.md  (4.75K)
│   │   │   ├── 20260703_auditoria_datos_pre_push_log.md  (8.4K)
│   │   │   ├── 20260703_reauditoria_post_fix_f1_f2_log.md  (6.52K)
│   │   │   ├── 20260703_reconciliacion_f3_log.md  (5.23K)
│   │   │   └── 20260703_rendimiento_vigente_ventana4_log.md  (4.03K)
│   │   ├── .DS_Store  (10K)
│   │   ├── .gitkeep  (0)
│   │   ├── 20260701_renombrado_insumos_datos.md  (5.86K)
│   │   ├── checklist_setup_windows_slep_paes.md  (10.7K)
│   │   ├── encargo_ajustes_interfaz_v2.md  (7.04K)
│   │   ├── encargo_auditoria_datos_pre_push.md  (6.42K)
│   │   ├── encargo_cohorte_territorial.md  (8.82K)
│   │   ├── encargo_mejoras_interfaz_slep_paes.md  (10.8K)
│   │   └── encargo_suitedoc_slep_paes.md  (8.09K)
│   ├── estructura/
│   │   ├── 20260703_124520_estructura.md  (7.05K)
│   │   ├── 20260703_124520_estructura.txt  (7.09K)
│   │   ├── 20260703_125306_estructura.md  (7.1K)
│   │   ├── 20260703_125306_estructura.txt  (7.15K)
│   │   ├── estructura_actual.md  (7.1K)
│   │   └── estructura_actual.txt  (7.15K)
│   ├── suite/
│   │   ├── assets/
│   │   │   ├── logo-color-stacked.png  (126K)
│   │   │   ├── logo-mark-cc.png  (118K)
│   │   │   └── logo-white-stacked.png  (143K)
│   │   ├── fonts/
│   │   │   ├── gobCL_Heavy.otf  (43.7K)
│   │   │   ├── gobCL_Light.otf  (37.1K)
│   │   │   ├── gobCL_Regular.otf  (35.7K)
│   │   │   ├── MuseoSans_500.otf  (61K)
│   │   │   ├── MuseoSans_700.otf  (62.1K)
│   │   │   └── MuseoSans-300.otf  (61.5K)
│   │   ├── arquitectura_general_slep_paes_standalone.html  (440K)
│   │   ├── arquitectura_slep_paes_standalone.html  (445K)
│   │   ├── documentacion_general_slep_paes_standalone.html  (433K)
│   │   ├── documentacion_proyecto_slep_paes_standalone.html  (435K)
│   │   ├── documentar.R  (45.9K)
│   │   └── suite_estilos.css  (21.7K)
│   ├── traspasos/
│   │   ├── .gitkeep  (0)
│   │   ├── traspaso_cierre_v01.md  (38K)
│   │   ├── traspaso_cierre_v02.md  (41.4K)
│   │   ├── traspaso_cierre_v03.md  (29.8K)
│   │   ├── traspaso_cierre_v04.md  (31K)
│   │   ├── traspaso_cierre_v05.md  (42.5K)
│   │   └── traspaso_cierre_v06.md  (39.3K)
│   └── .DS_Store  (10K)
├── docs/
│   ├── .gitkeep  (0)
│   └── index.html  (1.27M)
├── tests/
│   └── .gitkeep  (0)
├── .DS_Store  (10K)
├── .gitignore  (1.45K)
├── .Renviron.example  (771)
├── 00_escanear_proyecto.R  (9.41K)
├── 00_run_all.R  (8.23K)
├── CLAUDE.md  (12.3K)
├── LICENSE  (1.9K)
├── README.md  (5.47K)
└── slep_paes.Rproj  (220)
```

## Conteo por extension

| Extension | Archivos |
|---|---|
| md | 49 |
| r | 18 |
| (sin extension) | 11 |
| otf | 11 |
| html | 8 |
| js | 4 |
| png | 3 |
| txt | 3 |
| css | 1 |
| example | 1 |
| json | 1 |
| rproj | 1 |
