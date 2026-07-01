# Manifiesto de insumos — slep_paes

> Mapa maestro de qué archivo va en cada lugar de `20_insumos/`, con su nombre
> canónico y qué foco alimenta. El titular deposita los archivos a mano (POLITICA
> 0.4); este documento y los README por carpeta indican dónde y con qué nombre.
> **No se inventan contenidos de bases ni glosas** (B.1): los nombres de columnas
> y códigos salen de las glosas del DEMRE y del resumen estable de
> `contexto_paes.md`.

## 1. Estructura de `20_insumos/`

```
20_insumos/
├── auxiliares/                    ← territoriales reusados + condiciones DEMRE
│   ├── directorio_oficial_ee_publico.csv   (reusado, sin RUT/MRUN)
│   ├── diccionario_territorios.xlsx        (reusado)
│   ├── caracterizacion_establecimientos.xlsx (reusado)
│   ├── listado_slep_2026.xlsx              (reusado)
│   ├── glosas_directorio_oficial_ee.pdf    (reusado)
│   └── guia_uso_datos_abiertos_demre.pdf   (presente; condiciones de uso DEMRE)
├── demre/                         ← bases PAES por etapa (DEMRE, datos abiertos)
│   ├── inscripcion/               ← Archivo B
│   ├── rendicion_resultados/      ← Archivo C
│   ├── postulacion_seleccion/     ← base de postulaciones y seleccionados
│   └── glosas/                    ← diccionarios de variables por base y año
└── egresados_em/                  ← denominador de cobertura (MINEDUC)
```

## 2. Mapa etapa → base → nombre canónico → foco

| Etapa del proceso | Carpeta | Base DEMRE | Nombre canónico | Alimenta |
|---|---|---|---|---|
| Egresados de EM (denominador) | `egresados_em/` | — (MINEDUC) | `egresados_em_<AAAA>.csv` | Cobertura (denominador) |
| Inscripción | `demre/inscripcion/` | Archivo B — Inscritos/as | `inscritos_paes_<AAAA>_<temporada>.csv` | Cobertura |
| Rendición | `demre/rendicion_resultados/` | Archivo C — Rendición y Resultados | `rendicion_resultados_paes_<AAAA>_<temporada>.csv` | Cobertura |
| Resultados válidos | `demre/rendicion_resultados/` | Archivo C (misma base) | *(idem anterior)* | Cobertura **y** Rendimiento |
| Postulación | `demre/postulacion_seleccion/` | Base de Postulaciones y Seleccionados | `postulacion_seleccion_paes_<AAAA>.csv` | Cobertura |
| Selección | `demre/postulacion_seleccion/` | Base de Postulaciones y Seleccionados (misma base) | *(idem anterior)* | Cobertura |

Notas:
- `<AAAA>` = año del **proceso de admisión**; `<temporada>` = `regular` |
  `invierno` (la PAES se rinde dos veces al año).
- **Rendición y resultados** comparten el Archivo C; **postulación y selección**
  comparten la base consolidada. El embudo distingue las etapas *dentro* de esas
  bases (variables `SITUACION_INSCRIPCION`, `RINDIO_REQUISITO`, `ESTADO_SELECCION`),
  no en archivos separados. Esto se resuelve en `31_leer_normalizar.R`.

## 3. Glosas (imprescindibles para normalizar)

| Base | Glosa canónica | Carpeta |
|---|---|---|
| Inscripción (B) | `glosas_inscripcion_<AAAA>.xlsx` | `demre/glosas/` |
| Rendición y resultados (C) | `glosas_rendicion_resultados_<AAAA>.xlsx` | `demre/glosas/` |
| Postulación y selección | `glosas_postulacion_seleccion_<AAAA>.pdf` | `demre/glosas/` |
| Directorio oficial | `glosas_directorio_oficial_ee.pdf` | `auxiliares/` (reusado) |

## 4. Llave y cruce

- Llave de cruce entre bases DEMRE de un mismo proceso: **`ID_aux`** (anonimizada,
  reemplaza al RUN). Llave territorial: **`RBD_ENS`** (establecimiento de egreso
  de EM) → comuna → SLEP → región → nacional, vía directorio oficial reusado.
- **RBD y códigos comunales SIEMPRE `character`** (POLITICA 5.3.6).
- Rezagados (sin `RBD_ENS` de egreso vigente) → categoría explícita
  `ETIQUETA_SIN_RBD_VIGENTE`, nunca hueco ni descarte.

## 5. Estado de depósito (sesión 1)

- [x] Auxiliares territoriales reusados (paso 2).
- [x] `guia_uso_datos_abiertos_demre.pdf` (condiciones de uso DEMRE) — depositado.
- [ ] Bases por etapa (`demre/…`) y sus glosas — titular.
- [ ] `egresados_em_<AAAA>.csv` — titular.

Cuando el titular deposite las bases, `31_/32_` se completan contra su estructura
real (los stubs del paso 4 quedan listos para recibirlas).
