# Prácticas de Modelos de Computación

Repositorio con las tres prácticas realizadas para la asignatura **Modelos de Computación** del curso 2026/2027.

Las prácticas aplican conceptos de autómatas finitos, máquinas de estados con salida y análisis léxico mediante JFLAP y Flex. La memoria completa se encuentra en [`doc/Prácticas_MC_26_27.pdf`](doc/Prácticas_MC_26_27.pdf), con el código fuente LaTeX en [`doc/main.tex`](doc/main.tex).

## Integrantes

- Diego Delgado Pérez
- Adrián Varela Jiménez

**Grupo:** C1

## Contenido

| Carpeta | Contenido | Tecnología |
|---|---|---|
| [`P1/`](P1/) | Diseño de un AFND, conversión a AFD y minimización | JFLAP |
| [`P2/`](P2/) | Codificación y decodificación mediante máquinas de Mealy | JFLAP |
| [`P3/`](P3/) | Analizador léxico y generación de gráficos SVG | Flex, C y Make |
| [`doc/`](doc/) | Memoria de las prácticas y sus recursos | LaTeX, PDF |

## Práctica 1: receptor de un protocolo de comunicaciones

La práctica consiste en diseñar el receptor de un protocolo de detección de transición de canal. El sistema procesa cadenas binarias y acepta aquellas que cumplen las reglas que se muestran a continuación.

El alfabeto utilizado es:

```text
Σ = {0, 1}
```

### Reglas de aceptación

- **Modo Eco:** la trama comienza por `0` y contiene internamente el patrón `010`.
- **Modo Alerta:** la trama comienza por `1` y contiene internamente el patrón `101`.
- Todas las tramas válidas deben terminar con la secuencia `011`.

La práctica sigue este proceso:

1. Diseño del **Autómata Finito No Determinista (AFND)**.
2. Conversión del AFND a **Autómata Finito Determinista (AFD)** mediante el algoritmo de construcción de subconjuntos.
3. Minimización del AFD.
4. Comprobación de que el autómata mínimo conserva el lenguaje reconocido por el modelo original.

### Archivos

- [`P1/src/protocolo_canal_AFND.jff`](P1/src/protocolo_canal_AFND.jff): diseño no determinista.
- [`P1/src/protocolo_canal_AFD.jff`](P1/src/protocolo_canal_AFD.jff): autómata determinista obtenido por conversión.
- [`P1/src/protocolo_canal_minimo.jff`](P1/src/protocolo_canal_minimo.jff): versión minimizada del AFD.
- [`P1/img/`](P1/img/): diagramas, capturas de pruebas y trazas de ejecución.

Los archivos `.jff` pueden abrirse con JFLAP.

## Práctica 2: codificador y decodificador

En esta práctica se implementa un sistema de codificación y decodificación mediante **Máquinas de Mealy**. El codificador utiliza tres estados como contador módulo 3:

- `q0`: modo transparente.
- `q1`: nivel 1 de inversión.
- `q2`: nivel 2 de inversión.

El estado se modifica al procesar un `1`, mientras que un `0` mantiene el estado actual. El decodificador invierte la transformación y permite recuperar la entrada original.

Las máquinas se han probado con cadenas mixtas y ráfagas de unos y ceros.

Ejemplos incluidos en la memoria:

| Entrada | Codificada | Recuperada |
|---|---|---|
| `01010` | `01101` | `01010` |
| `111000` | `100000` | `111000` |
| `000111` | `000100` | `000111` |

### Archivos

- [`P2/src/Codificador.jff`](P2/src/Codificador.jff): máquina de Mealy codificadora.
- [`P2/src/Decodificador.jff`](P2/src/Decodificador.jff): máquina de Mealy decodificadora.
- [`P2/img/`](P2/img/): autómatas y resultados de las ejecuciones múltiples.

## Práctica 3: analizador léxico del lenguaje de Tortuga

La tercera práctica utiliza **Flex** para reconocer los comandos de un lenguaje sencillo de dibujo y generar una imagen vectorial SVG.

El programa mantiene el estado de la tortuga: posición, ángulo, estado del lápiz y color. Los comandos admitidos son:

| Comando | Ejemplo | Acción |
|---|---|---|
| `AVANZA` | `AVANZA 60` | Avanza una distancia determinada. |
| `GIRA` | `GIRA 60` | Modifica el ángulo actual. |
| `BAJA` | `BAJA` | Activa el trazado. |
| `SUBE` | `SUBE` | Desactiva el trazado. |
| `COLOR` | `COLOR azul` | Cambia el color del trazo. |
| `REPITE` | `REPITE 6 [...]` | Repite una secuencia de instrucciones. |

Los nombres de las instrucciones no distinguen mayúsculas y minúsculas. Los anidamientos de `REPITE` no están admitidos, al ser el lenguaje regular y no reconocer estructuras anidadas arbitrariamente.

### Ejemplo de entrada

```text
COLOR azul
BAJA
REPITE 6 [
  AVANZA 60
  GIRA 60
]
SUBE
```

El resultado generado es un SVG que representa un polígono regular de seis lados.

### Casos de prueba

- [`P3/pruebas/poligono.txt`](P3/pruebas/poligono.txt): dibuja un polígono regular.
- [`P3/pruebas/errores.txt`](P3/pruebas/errores.txt): incluye comandos desconocidos y un bucle anidado para comprobar la gestión de errores.

## Requisitos

### Prácticas 1 y 2

- [JFLAP](https://www.jflap.org/) para abrir los archivos `.jff`, ejecutar las cadenas de prueba y visualizar las transiciones.

### Práctica 3

En sistemas Linux o Windows con entorno Unix:

- Flex
- GCC
- Make
- Una librería matemática compatible con `-lm`

Instalación en sistemas basados en Debian/Ubuntu:

```bash
sudo apt update
sudo apt install flex gcc make
```

## Ejecución de la práctica 3

Situarse en la carpeta `P3`:

```bash
cd P3
```

Compilar y ejecutar ambas pruebas:

```bash
make
```

Esto crea:

- `src/lex.yy.c`: código C generado por Flex.
- `bin/tortuga`: ejecutable compilado.
- `img/poligono.svg`: salida del caso de prueba de geometría.
- `img/errores.svg`: salida del caso de prueba de errores.

Ejecutar el programa sobre un archivo propio:

```bash
./bin/tortuga ruta/al/programa.txt > salida.svg
```

Ejemplo:

```bash
./bin/tortuga pruebas/poligono.txt > img/poligono.svg
```

El archivo SVG puede abrirse en un navegador web, Inkscape u otro visor compatible con SVG.

Eliminar todos los archivos y carpetas generados:

```bash
make clean
```

## Memoria

La documentación teórica y experimental se encuentra en:

- [`doc/Prácticas_MC_26_27.pdf`](doc/Prácticas_MC_26_27.pdf): memoria final en PDF.
- [`doc/main.tex`](doc/main.tex): fuente LaTeX de la memoria.
- [`doc/logoUGR.png`](doc/logoUGR.png): logotipo utilizado en la portada.

Para generar el PDF desde el código LaTeX, es necesario disponer de una distribución de LaTeX e imágenes correspondientes a las prácticas. Desde la carpeta `doc` se puede usar, por ejemplo:

```bash
cd doc
pdflatex main.tex
pdflatex main.tex
```

## Estructura del repositorio

```text
Practicas_MC/
├── P1/
│   ├── img/
│   └── src/
│       ├── protocolo_canal_AFND.jff
│       ├── protocolo_canal_AFD.jff
│       └── protocolo_canal_minimo.jff
├── P2/
│   ├── img/
│   └── src/
│       ├── Codificador.jff
│       └── Decodificador.jff
├── P3/
│   ├── Makefile
│   ├── pruebas/
│   │   ├── poligono.txt
│   │   └── errores.txt
│   └── src/
│       └── tortuga.l
└── doc/
    ├── main.tex
    ├── logoUGR.png
    └── Prácticas_MC_26_27.pdf
```
