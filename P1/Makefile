
FUENTE = practica1
PRUEBA = prueba.txt
LIB = lfl

all: compile run

compile:
	flex $(FUENTE).l
	gcc -o $(FUENTE) lex.yy.c -$(LIB)

clean:
	rm $(FUENTE) lex.yy.c 

run:
	./$(FUENTE) < $(PRUEBA)

run2:
	./$(FUENTE)
