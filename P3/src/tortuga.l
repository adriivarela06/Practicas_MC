%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/* Variables globales de estado */
double x = 0.0, y = 0.0;
int angulo = 0;
int lapiz = 1; 
char color[32] = "black";

double min_x = 0.0, max_x = 0.0;
double min_y = 0.0, max_y = 0.0;
char svg_buffer[65536] = "";

/* Tipos de operaciones para el array de guardado */
#define OP_AVANZA 1
#define OP_GIRA   2
#define OP_SUBE   3
#define OP_BAJA   4
#define OP_COLOR  5

/* Estructura para almacenar comandos del bucle */
struct Comando {
    int op;
    int arg;
    char arg_str[32];
};

struct Comando guardados[1024];
int n_cmd = 0;
int veces = 0;

void traducir_color(const char* color_es) {
    if (strcasecmp(color_es, "rojo") == 0) strcpy(color, "red");
    else if (strcasecmp(color_es, "azul") == 0) strcpy(color, "blue");
    else if (strcasecmp(color_es, "verde") == 0) strcpy(color, "green");
    else if (strcasecmp(color_es, "amarillo") == 0) strcpy(color, "yellow");
    else if (strcasecmp(color_es, "blanco") == 0) strcpy(color, "white");
    else strcpy(color, color_es); /* Si no está en la lista, lo deja pasar tal cual */
}

void guardar(int op, int arg, const char* str) {
    guardados[n_cmd].op = op;
    guardados[n_cmd].arg = arg;
    if (str) strcpy(guardados[n_cmd].arg_str, str);
    n_cmd++;
}

void avanza(int d) {
    double rad = angulo * M_PI / 180.0;
    double nx = x + d * cos(rad);
    double ny = y + d * sin(rad);

    if (lapiz) {
        char linea[256];
        sprintf(linea, "  <line x1=\"%.2f\" y1=\"%.2f\" x2=\"%.2f\" y2=\"%.2f\" stroke=\"%s\" />\n", 
                x, y, nx, ny, color);
        strcat(svg_buffer, linea);
    }

    x = nx;
    y = ny;

    if (x < min_x) min_x = x;
    if (x > max_x) max_x = x;
    if (y < min_y) min_y = y;
    if (y > max_y) max_y = y;
}

void ejecutar_guardados() {
    for (int i = 0; i < n_cmd; i++) {
        switch(guardados[i].op) {
            case OP_AVANZA: avanza(guardados[i].arg); break;
            case OP_GIRA:   angulo += guardados[i].arg; break;
            case OP_SUBE:   lapiz = 0; break;
            case OP_BAJA:   lapiz = 1; break;
            case OP_COLOR:  traducir_color(guardados[i].arg_str); break;
        }
    }
}
%}

%option case-insensitive yylineno noyywrap
%x BUCLE

NUM -?[0-9]+

%%

  /* --- Reglas del estado INITIAL --- */

REPITE[ \t]+[0-9]+[ \t]*"[" {
    veces = atoi(yytext + 6);
    n_cmd = 0;
    BEGIN(BUCLE);
}

AVANZA[ \t]+{NUM} {
    avanza(atoi(yytext + 6));
}

GIRA[ \t]+{NUM} {
    angulo += atoi(yytext + 4);
}

SUBE {
    lapiz = 0;
}

BAJA {
    lapiz = 1;
}

COLOR[ \t]+[a-z]+ {
    int offset = 5 + strspn(yytext + 5, " \t");
    traducir_color(yytext + offset);
}

  /* --- Reglas del estado BUCLE --- */

<BUCLE>AVANZA[ \t]+{NUM} {
    guardar(OP_AVANZA, atoi(yytext + 6), NULL);
}

<BUCLE>GIRA[ \t]+{NUM} {
    guardar(OP_GIRA, atoi(yytext + 4), NULL);
}

<BUCLE>SUBE {
    guardar(OP_SUBE, 0, NULL);
}

<BUCLE>BAJA {
    guardar(OP_BAJA, 0, NULL);
}

<BUCLE>COLOR[ \t]+[a-z]+ {
    int offset = 5 + strspn(yytext + 5, " \t");
    guardar(OP_COLOR, 0, yytext + offset);
}

<BUCLE>"]" {
    for (int i = 0; i < veces; i++) {
        ejecutar_guardados();
    }
    BEGIN(INITIAL);
}

<BUCLE>"[" {
    /* Los lenguajes regulares no pueden contar anidamientos, se bloquea explícitamente */
    fprintf(stderr, "Línea %d: REPITE anidado no admitido\n", yylineno);
}


  /* --- Reglas comunes (cajones de sastre) --- */

<*>[ \t\n]+ { 
    /* Ignoramos espacios y saltos de línea en cualquier estado para que Flex no los imprima */ 
}

<*>[^ \t\n]+ {
    /* Atrapa palabras enteras desconocidas en lugar de letra a letra */
    fprintf(stderr, "Línea %d: Comando o símbolo desconocido '%s'\n", yylineno, yytext);
}

%%

/* --- Sección 3: Código C principal --- */

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror(argv[1]);
            return 1;
        }
    }

    /* Ejecutamos el autómata. Todo el SVG se irá guardando en svg_buffer */
    yylex();

    /* Calculamos el ancho y alto final para el viewBox */
    double width = max_x - min_x;
    double height = max_y - min_y;

    /* Si no se ha dibujado nada, evitamos un viewBox con ancho/alto 0 */
    if (width == 0.0) width = 100.0;
    if (height == 0.0) height = 100.0;

    /* Imprimimos el resultado final ensamblado */
    printf("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"%.2f %.2f %.2f %.2f\">\n", 
           min_x, min_y, width, height);
    
    /* El eje Y de SVG crece hacia abajo, pero no invertimos coordenadas aquí 
       para mantener la coherencia del dibujo, solo mostramos lo generado */
    printf("%s", svg_buffer);
    
    printf("</svg>\n");

    return 0;
}
