# Log — escala de columnas *_ANTERIOR en ArchivoC_Adm2023

- Fecha: 2026-07-01 (sesion 1, encargo diagnostico Pendiente 2 del traspaso v01)
- Modo: R-only, solo lectura. No se toco 31/32/33.
- ArchivoC: `<DATA_ROOT>/20_insumos/demre/rendicion_resultados/2023/archivoc_adm2023.csv`
- Libro de Codigos: `<DATA_ROOT>/20_insumos/demre/referencia/2023/libro_codigos_adm2023_archivoc.xlsx` (hoja "Rinden")

## Evidencia documental (Libro de Codigos)
El Libro define cada columna `*_REG_ANTERIOR` como "Puntaje obtenido en la prueba de <prueba> anterior"
(CLEC=Comprension Lectora, MATE1=Matematica, HCSOC=Historia, CIEN=Ciencias, MODULO=modulo de Ciencias).
NO declara escala numerica (ni 150-850 ni 100-1000) para ninguna columna de puntaje. Silencioso sobre escala:
por tanto no contradice la evidencia empirica.

## Evidencia empirica (rango real, excluyendo NA y sentinela 0)

| Columna | n (>0) | min | max | p1 | p99 | Escala concluida |
|---|---|---|---|---|---|---|
| CLEC_REG_ANTERIOR | 59603 | 100 | 1000 | 366 | 841 | PAES (100-1000) |
| MATE1_REG_ANTERIOR | 59139 | 100 | 1000 | 282 | 867 | PAES (100-1000) |
| HCSOC_REG_ANTERIOR | 29546 | 100 | 1000 | 305 | 817 | PAES (100-1000) |
| CIEN_REG_ANTERIOR | 43261 | 100 | 1000 | 327 | 857 | PAES (100-1000) |
| MODULO_REG_ANTERIOR | 0 | - | - | - | - | (no numerica / sin datos) |

`MODULO_REG_ANTERIOR` es categorica (valores QUI/BIO/TEC/FIS = modulo de Ciencias), no un puntaje: excluida del analisis de escala.

## Conclusion
Las 4 columnas de PUNTAJE `*_REG_ANTERIOR` de ArchivoC_Adm2023 estan en **escala PAES (100-1000)**, NO en escala PDT (150-850).
Evidencia inequivoca: min=100 (por debajo del piso PDT 150) y max=1000 (por encima del techo PDT 850) en ~30k-60k valores por prueba.
El Libro de Codigos corrobora la SEMANTICA (son puntajes de la aplicacion anterior) y no menciona escala PDT ni el rango 150-850 en ninguna parte.

**Contradice la hipotesis del Pendiente 2** (que asumia ANTERIOR=Adm2022=PDT). La "aplicacion anterior" referida ya viene en escala PAES.

## Implicancia para 31_leer_normalizar.R (NO modificado en este encargo)
Las columnas `*_ANTERIOR` son directamente comparables con `*_ACTUAL` (misma escala PAES 100-1000); NO requieren reescalado PDT->PAES.
El sentinela 0 (= no rindio esa prueba en la aplicacion anterior) debe tratarse como ausencia, no como puntaje.
