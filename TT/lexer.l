%{
#include "y.tab.h"
int lines_number = 0;
%}
digit [0-9]  
letter [A-Za-záéíóúÁÉÍÓÚ]
comma [\,]
quotation [\"]

%option yylineno

%%
"atacar" { return ATACAR; }
"añadir pokemon" { return ADD; }
"ver pokedex" {return SEE;}
"quit"   { return QUIT; }
"cambiar" { return CAMBIAR; }
"crear equipo" {return CREAR;}
"ver equipo" {return VER;}
"[" {return LBRACKET;}
"]" {return RBRACKET;}
"{" {return LBRACE;}
"}" {return RBRACE;}
"\"id\":" {return ID;}
"\"name\":" {return NAME;} 
"\"type\":" {return TY;}
"\"base_stats\":" {return BS;}
"\"hp\":" {return HP;}
"\"attack\":" {return ATTACK;}
"\"defense\":" {return DEFENSE;}
"\"special_attack\":" {return SP_ATTACK;}
"\"special_defense\":" {return SP_DEFENSE;}
"\"speed\":" {return SPEED;}
"\"abilities\":" {return ABILITY;}
"\"hidden_ability\":" {return H_ABILITY;}
"\"evolutions\":" {return EVO;}
"\n" { 
    lines_number++; 
}

[ \t]+ ; 

{comma} {return COMMA;}
{quotation} {return QT;}
{letter}+ {yylval.tipo_string = strdup(yytext); return TEXT;}
{digit}+ {yylval.tipo_string = strdup(yytext); return DIGIT;}
.*;
