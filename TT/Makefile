all: lab1
lab1:
	flex lexer.l
	bison parser.y -yd
	gcc -o pokemon lex.yy.c y.tab.c -I. pokemonAscii.h -lfl -lm
	./pokemon pokemon.json
clean:
	rm -f y.tab.c y.tab.h parser.tab.c parser.tab.h lex.yy.c lexer.c lexer pokemon
