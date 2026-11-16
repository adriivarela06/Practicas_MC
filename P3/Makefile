# Definición de variables
FLEX = flex
CC = gcc
CFLAGS = -lm

# Carpetas
SRC_DIR = src
BIN_DIR = bin
TEST_IN_DIR = pruebas/inputs
TEST_OUT_DIR = pruebas/outputs

# Archivos
LEX_FILE = $(SRC_DIR)/tortuga.l
C_FILE = $(SRC_DIR)/lex.yy.c
EXEC = $(BIN_DIR)/tortuga

# Archivos de prueba
TEST1_IN = $(TEST_IN_DIR)/poligono.txt
TEST1_OUT = $(TEST_OUT_DIR)/poligono.svg
TEST2_IN = $(TEST_IN_DIR)/errores.txt
TEST2_OUT = $(TEST_OUT_DIR)/errores.svg

# Regla por defecto: compilar y ejecutar todo
all: prepare $(EXEC) run

# Crear directorios si no existen
prepare:
	@mkdir -p $(BIN_DIR) $(SRC_DIR) $(TEST_IN_DIR) $(TEST_OUT_DIR)

# Regla para compilar el ejecutable
# Depende del .c, si el .c cambia, se re-compila el ejecutable
$(EXEC): $(C_FILE)
	@echo "Compilando el ejecutable de C..."
	$(CC) $(C_FILE) -o $(EXEC) $(CFLAGS)

# Regla para generar el .c con flex
# Depende del .l, si el .l cambia, se vuelve a ejecutar flex
$(C_FILE): $(LEX_FILE)
	@echo "Ejecutando Flex..."
	$(FLEX) -o $(C_FILE) $(LEX_FILE)

# Regla para ejecutar las pruebas
run: $(EXEC)
	@echo "Ejecutando pruebas..."
	@if [ -f "$(TEST1_IN)" ]; then \
		./$(EXEC) $(TEST1_IN) > $(TEST1_OUT); \
		echo " -> $(TEST1_OUT) generado."; \
	else \
		echo "Aviso: No se encontró $(TEST1_IN)"; \
	fi
	@if [ -f "$(TEST2_IN)" ]; then \
		./$(EXEC) $(TEST2_IN) > $(TEST2_OUT); \
		echo " -> $(TEST2_OUT) generado."; \
	else \
		echo "Aviso: No se encontró $(TEST2_IN)"; \
	fi

# Limpiar archivos generados
clean:
	@echo "Limpiando archivos generados..."
	rm -f $(C_FILE) $(EXEC) $(TEST1_OUT) $(TEST2_OUT)

# Declarar que clean, prepare, run, all no son archivos
.PHONY: all prepare clean run
