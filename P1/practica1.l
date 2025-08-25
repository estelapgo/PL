%{
unsigned charCount = 0, wordCount = 0, lineCount = 0;
unsigned mayusCount = 0, minusCount = 0, frasesCount = 0, digitCount = 0;
%}

digit [0-9]+
caract [a-zA-ZñÑáéíóúÁÉÍÓÚ]+
mayus [A-ZÑÁÉÍÓÚ]+
minus [a-zñáéíóú]+
word [^ \t\n\.]+
frase [\.]+
otros [\,\:\;\t\n\"]

%%
{frase} {frasesCount ++; charCount+=yyleng;}
{digit} {digitCount++; wordCount++; charCount+= yyleng;}
{mayus}{otros}+|{otros}+{mayus}|{mayus} {mayusCount++; wordCount++; charCount+= yyleng;}
{minus}{otros}+|{otros}+{minus}|{minus} {minusCount++;wordCount++; charCount+=yyleng;}
{word}	{wordCount++; charCount += yyleng;}
{otros} {charCount++;} 
%%

int main()
{
	yylex();
	printf("Palabras numéricas: %d, Palabras: %d, Caracteres: %d, Todomayus: %d, Todo minus: %d, Frases: %d\n", digitCount, wordCount, charCount, mayusCount, minusCount, frasesCount);
    
	return 0;
}
