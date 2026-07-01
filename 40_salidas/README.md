# 40_salidas/ — vacío en Git (RAMA B)

Las salidas del pipeline (parquets intermedios de `30_procesamiento/` y el motor
`motor_paes.html`) se generan en la raíz de datos de OneDrive
(`<SLEP_PAES_DATA_ROOT>/40_salidas/`), **fuera del repo** (son regenerables con
`run_all()` y pueden derivar de microdato).

La única salida que sí se versiona es la **copia publicada** `docs/index.html`
(GitHub Pages), que contiene solo **agregados territoriales** con supresión de
celdas chicas (nunca microdato). Ver `33_generar_html.R`.
