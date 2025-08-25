%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern FILE *yyin;
int yylex(void);
int yyerror(char* expected);
char* expected;
extern int yylineno;

extern int open_tags;
extern int close_tags;

%}

%union {
 char* val;
 char* error;
 char* string_type;
 
}

%start statement
%token DECLARATION_OPEN DECLARATION_CLOSE
%token COMMENT_OPEN COMMENT_CLOSE
%token <string_type> ETIQ_OPEN ETIQ_CLOSE
%token <string_type> NAME TEXT
%type  <string_type> statement declaration comment text entry

%%
statement:
 declaration statement
 | comment statement
 | entry statement
 |  { $$ = NULL; } 
 ;

declaration:
 DECLARATION_OPEN text DECLARATION_CLOSE { $$ = $2; }       // Declaraciones XML
 ;

comment:
 COMMENT_OPEN TEXT COMMENT_CLOSE { $$ = NULL; }             // Comentarios
 ;

entry:
 ETIQ_OPEN statement ETIQ_CLOSE { 
     if(strcmp($1+1,$3+2)!=0){      // Si las etiquetas de apertura y de cierre no tienen el mismo nombre
         yyerror($1+1);
     }
     $$ = $2;
 }
 | ETIQ_OPEN TEXT ETIQ_CLOSE {
     if(strcmp($1+1,$3+2)!=0){
         yyerror($1+1);
     }
     $$ = $2;
 }
 ;

text:
 TEXT text { $$ = $1; }
 |  { $$ = NULL; }
 ;

%%

int yyerror(char* expected)     // Gestión de errores
{	
	if(strcmp(expected,"syntax error")!=0){
    	printf("Sintaxis XML incorrecta. Error en línea %d: encontrado \"%s\" y se esperaba \"</%s\".\n",yylineno,yylval.error,expected);
	}else{
        if (open_tags != close_tags) {
            printf("Error en línea %d: falta cierre de etiqueta.\n", yylineno);
            exit(1);
        }else{
            printf("Sintaxis XML incorrecta. Error:%s, en línea %d\n",expected,yylineno);
        
        }
    }
    exit(1);
}

int yywrap() 
{
    if (open_tags != close_tags) {
        printf("Error en línea %d: falta cierre de etiqueta.\n", yylineno);
        exit(1);
    } else {
        printf("Sintaxis XML correcta.\n");
        exit(0);
    }
}

int main(int argc, char *argv[])
{
	yyparse();
}
