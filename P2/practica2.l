%{
#include "y.tab.h"
#include <stdbool.h>

int open_tags = 0;            // Contador de etiquetas abiertas
int close_tags = 0;           // Contador de etiquetas cerradas
int lines_number = 0;
int has_comment = 0;
int yylex();

%}

letter [A-Za-záéíóúnÑÁÉÍÓÚ]
digit [0-9]
ws [ ]
dot [\.]
special_symbols "&lt"|"&gt"|"&amp"
all_symbols [\~\@\#\$\%\^\*\!\"\(\)\+\{\}\"\|\[\]\;\'\\\,\.\/\:=-]
attr_name ({letter}|{digit})+
attr_value \"({letter}|{digit}|{ws}|{dot})+\"

%option yylineno

%%

"<!--" {                                // Comentarios
    has_comment++;
    return COMMENT_OPEN; }

"-->" { return COMMENT_CLOSE; }

"<?" {                                  // Declaraciones
    if (has_comment > 0) {
        printf("Error en línea %d: no pueden aparecer comentarios antes de una declaración.\n", yylineno);  
        exit(1);
    }
    return DECLARATION_OPEN;  }

"?>" { return DECLARATION_CLOSE; }

"<"({letter})({letter}|{digit})*">" {   // Etiquetas
    yylval.val = strdup(yytext); 
    open_tags++;  
    return ETIQ_OPEN; 
}

"</"({letter})({letter}|{digit})*">" { 
    yylval.val = strdup(yytext); 
    close_tags++; 
    return ETIQ_CLOSE; 
}


({letter}|{digit})({letter}|{digit}|{letter}{dot}|{ws}{letter}|{dot}{digit}|{letter}{all_symbols})* { return TEXT; }

"<"({letter})+({ws}+{attr_name}={attr_value})+">"({letter}|{digit}|{ws})*"</"({letter})+">" {
    yylval.string_type = strdup(yytext);
    return TEXT;
}

{letter}+{ws}*({digit}|{letter}|{ws}|{dot})* {
    yylval.string_type = strdup(yytext);
    return TEXT;
}

{digit}+{ws}*({digit}|{letter}|{ws}|{dot})* {
    yylval.string_type = strdup(yytext);
    return TEXT;
}

({digit})({digit}|{all_symbols}|{ws}{digit})* { 
    yylval.string_type = strdup(yytext); 
    return TEXT; 
}

({all_symbols}|{special_symbols}|{digit})* { 
    yylval.string_type = strdup(yytext); 
    return TEXT; 
}

"\n" { 
    lines_number++; 
}

[ \t]+ ; // Ignoro espacios en blanco

. { 
    printf("Texto no reconocido: %s\n", yytext);        
    yylval.error = strdup(yytext); 
    return TEXT; 
}
%%

