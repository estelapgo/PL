all: run

lab1:
	bison practica2.y -yd
	flex practica2.l
	gcc -o practica2 lex.yy.c y.tab.c -lfl

run: lab1
	./practica2 < practica2_ejemplo1.xml
