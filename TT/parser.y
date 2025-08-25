%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include "pokemon.h"
#include <time.h>
#include <pokemonAscii.h>

extern int yylineno;
extern int yylex(void);  
extern void yyrestart(FILE*);
extern FILE *yyin;

Pokemon* pokemon_list[100]; 
Pokemon* equipo1[3];
Pokemon* equipo2[3];
Pokemon* atacante;
Pokemon* defensor;

char* expected;
char* actual_pokemon;

int yyerror(char* expected);

int  pos = 0, num_types = 0, num_abilities = 0, cont_abilities = 0, cont_types = 0;
int mode = 0, indice = 0;
int cont_defensor = 0, cont_atacante = 0, turno = 0;
bool created = false, pokemon_caido = false, generado = false, encombate = false;

void pokemon_aux(Pokemon** pokemon_list, int pos, const char* id);
void malloc_id(Pokemon** pokemon_list, int pos, const char* id);
void malloc_name(Pokemon** pokemon_list, int pos, const char* name);
void malloc_hp(Pokemon** pokemon_list, int pos, const char* hp);
void malloc_attack(Pokemon** pokemon_list, int pos, const char* attack);
void malloc_defense(Pokemon** pokemon_list, int pos, const char* defense);
void malloc_sp_attack(Pokemon** pokemon_list, int pos, const char* sp_attack);
void malloc_sp_defense(Pokemon** pokemon_list, int pos, const char* sp_defense);
void malloc_evolutions(Pokemon** pokemon_list, int pos, const char* evolutions);
void malloc_speed(Pokemon** pokemon_list, int pos, const char* speed);
void malloc_hidden_ability(Pokemon** pokemon_list, int pos, const char* hidden_ability);
void add_ability(Pokemon** pokemon_list, int pos, const char* ability, int* cont_abilities);
void add_type(Pokemon** pokemon_list, int pos, const char* type, int* num_types);

void seleccionarEquipoPokemonAleatorio(Pokemon** equipo);
int tipoPresente(char** types, int num_types, const char* tipo);
void aplicarEfectividad(Pokemon* atacante, Pokemon* defensor, int* daño);
void print_all_pokemons(Pokemon** pokemon_list, int pos);

void print_menu();

%}

%union{
	char * tipo_string;
}

%token LBRACKET RBRACKET
%token LBRACE RBRACE
%token ID NAME TY BS ABILITY H_ABILITY EVO
%token HP ATTACK DEFENSE SP_ATTACK SP_DEFENSE SPEED
%token COMMA QT
%token <tipo_string> TEXT DIGIT
%token ATACAR CAMBIAR CREAR VER ADD SEE QUIT
%start comienzo
%%

comienzo:
    json_pokemons
    | battle_commands

json_pokemons:
    LBRACKET pokemon_list RBRACKET
    ;


pokemon_list:
    pokemon
    | pokemon COMMA pokemon_list;

pokemon:
    LBRACE id_section name_section ty_section bs_section abilities_section h_ability_section evo_section RBRACE {        
    pos++;
    cont_types = 0;
    cont_abilities = 0;
  };

id_section: 
    id 
    | {yyerror("Falta la clave 'ID'.");} 
    ;
id:
    ID DIGIT COMMA {
    pokemon_aux(pokemon_list, pos, $2);
    malloc_id(pokemon_list, pos, $2);
    strcpy(pokemon_list[pos]->id, $2); 
    }
    | ID COMMA{
        {yyerror("Valor incorrecto en ID'.");}; 
    }
    | ID DIGIT{
        {yyerror("Falta la coma en ID'.");}; 
    };
  
name_section:
    name
    | {yyerror("Falta la clave 'NAME'.");} 

name:
    NAME QT TEXT QT COMMA {
    malloc_name(pokemon_list, pos, $3);
    strcpy(pokemon_list[pos]->name, $3);
    }
    | NAME COMMA {
        {yyerror("Valor incorrecto en NAME'.");}; 
    }
    | NAME QT TEXT QT {
        {yyerror("Falta la coma en NAME'.");}; 
    };
    
ty_section:
    ty 
    | {yyerror("Falta la clave 'TYPE'.");}
ty:
    TY LBRACKET type_list RBRACKET COMMA;

type_list:
    QT TEXT QT {
        add_type(pokemon_list, pos, $2, &cont_types);     
    }  
    | QT TEXT QT COMMA type_list {
        add_type(pokemon_list, pos, $2, &cont_types);     
    };

bs_section:
    bs
    | {yyerror("Falta la sección 'BASE_STATS'.");}
bs:
   BS LBRACE hp attack defense sp_attack sp_defense speed RBRACE COMMA;

hp:
    HP DIGIT COMMA {
    malloc_hp(pokemon_list, pos, $2);
    strcpy(pokemon_list[pos]->hp, $2);  
    }
    | HP DIGIT {
        {yyerror("Falta la coma en HP'.");}; 
    }
    
    | HP COMMA {
        {yyerror("Valor incorrecto en HP'.");}; 
    }
    | HP {
        {yyerror("Valor incorrecto en HP'.");}; 
    }
    | {yyerror("Falta la clave 'HP'.");}
    ;

attack:
    ATTACK DIGIT COMMA {
        malloc_attack(pokemon_list, pos, $2);
        strcpy(pokemon_list[pos]->attack, $2);  
    }
    | ATTACK DIGIT {
        {yyerror("Falta la coma en ATTACK'.");} 
    }
    | ATTACK COMMA {
        {yyerror("Valor incorrecto en ATTACK'.");}
    }
    | ATTACK {
        {yyerror("Valor incorrecto en ATTACK'.");} 
    }
    | {yyerror("Falta la clave 'ATTACK'.");}
    ;

defense:
    DEFENSE DIGIT COMMA {
    malloc_defense(pokemon_list, pos, $2);
    strcpy(pokemon_list[pos]->defense, $2);
    }
    | DEFENSE DIGIT {
        {yyerror("Falta la coma en DEFENSE'.");} 
    }
    | DEFENSE COMMA {
         {yyerror("Valor incorrecto en DEFENSE'.");}
    }
    | DEFENSE {
         {yyerror("Valor incorrecto en DEFENSE'.");} 
    }
    | {yyerror("Falta la clave 'DEFENSE'.");}
    ;

sp_attack:
    SP_ATTACK DIGIT COMMA {
    malloc_sp_attack(pokemon_list, pos, $2);
    strcpy(pokemon_list[pos]->sp_attack, $2);  
    }
    | SP_ATTACK DIGIT {
    {yyerror("Falta la coma en SPECIAL_ATTACK'.");} 
    }
    | SP_ATTACK COMMA{
    {yyerror("Valor incorrecto en SPECIAL_ATTACK'.");} 
    }
    | SP_ATTACK {
    {yyerror("Valor incorrecto en SPECIAL_ATTACK'.");} 
    }
    | {yyerror("Falta la clave 'SPECIAL_ATTACK'.");}
    ;

sp_defense:
    SP_DEFENSE DIGIT COMMA {
    malloc_sp_defense(pokemon_list, pos, $2);
    strcpy(pokemon_list[pos]->sp_defense, $2); 
    }
    | SP_DEFENSE DIGIT {
    {yyerror("Falta la coma en 'SPECIAL_DEFENSE'.");} 
    }
    | SP_DEFENSE COMMA{
    {yyerror("Valor incorrecto en 'SPECIAL_DEFENSE'.");} 
    }
    | SP_DEFENSE {
    {yyerror("Valor incorrecto en 'SPECIAL_DEFENSE'.");} 
    }
    | {yyerror("Falta la clave 'SPECIAL_DEFENSE'.");}
    ;

speed:
    SPEED DIGIT {
    malloc_speed(pokemon_list, pos, $2);
    strcpy(pokemon_list[pos]->speed, $2); 
    }
    | SPEED {
    {yyerror("Valor incorrecto en SPEED'.");}
    }
    | {yyerror("Falta la clave 'SPEED'.");}
    ;
    
abilities_section:
    ability
    | {yyerror("Falta la clave 'ABILITIES'.");} 
    ;

ability:
    ABILITY LBRACKET ab_list RBRACKET COMMA
    | ABILITY LBRACKET RBRACKET COMMA{
        {yyerror("Valor incorrecto en 'ABILITIES'.");}
    }
    | ABILITY LBRACKET ab_list RBRACKET{
        {yyerror("Falta la coma en 'ABILITIES'.");}
    }
    ;
ab_list:
    QT TEXT QT {
        add_ability(pokemon_list, pos, $2, &cont_abilities);
    } 
    | QT TEXT QT COMMA ab_list {
        add_ability(pokemon_list, pos, $2, &cont_abilities);
    };

h_ability_section:
    h_ability
    | {yyerror("Falta la clave 'HIDDEN_ABILITY'.");} 
    ;

h_ability:
    H_ABILITY QT TEXT QT COMMA {
        malloc_hidden_ability(pokemon_list, pos, $3);
        strcpy(pokemon_list[pos]->hidden_ability, $3);  
    };
    | H_ABILITY COMMA{
        {yyerror("Valor incorrecto en 'HIDDEN_ABILITY'.");}
    }
    | H_ABILITY QT QT COMMA {
        {yyerror("Valor incorrecto en 'HIDDEN_ABILITY'.");}
    }
    | H_ABILITY QT TEXT QT{
        {yyerror("Falta la coma en 'HIDDEN_ABILITY'.");}
    }
    ;

evo_section:
    evo 
    | {yyerror("Falta la clave'EVOLUTIONS'.");}
    ;

evo:
    EVO LBRACKET DIGIT RBRACKET {
    malloc_evolutions(pokemon_list, pos, $3);
    strcpy(pokemon_list[pos]->evolutions, $3); 
    pokemon_list[pos]->num_abilities = cont_abilities;
    pokemon_list[pos]->num_types = cont_types;
    }
    | EVO LBRACKET RBRACKET {
    pokemon_list[pos]->evolutions = "No tiene";
    pokemon_list[pos]->num_abilities = cont_abilities;
    pokemon_list[pos]->num_types = cont_types;
    }
    

battle_commands:
    comando
    | battle_commands comando
    ;

comando:

    ATACAR {
        
        encombate = true;

        if(!created){
            seleccionarEquipoPokemonAleatorio(equipo1);
            seleccionarEquipoPokemonAleatorio(equipo2);
            printf("Equipos creados\n");
            created = true;
        }

        if(turno == 0){
            printf("¡Que comience el combate!");
            printf("\n%s\n", combat);
        }

        turno++;

        printf("---------------------------------\n");
        printf("------------ TURNO %d ------------\n", turno);
        printf("---------------------------------\n");
       
        if(!generado){
            do{
                indice = rand() % 3; 
                atacante = equipo1[indice];
                indice = rand() % 3; 
                defensor = equipo2[indice];
                generado = true;
            }while (strcmp(atacante->name, defensor->name) == 0);
        }

        actual_pokemon = atacante->name;

        printf("Tu Pokémon es: %s, el Pokémon del rival es %s\n", atacante->name,defensor->name);
        printf("\nTu turno:\n");
        printf("%s ataca a %s\n", atacante->name,defensor->name);

        int ataque_atacante = atoi(atacante->attack);
        int defensa_defensor = atoi(defensor->defense);

        int dañoantes = ataque_atacante;
        
        if(dañoantes <=0){
            dañoantes = 10;
        }
        
        aplicarEfectividad(atacante, defensor, &dañoantes);

        int dañodespues = dañoantes-defensa_defensor;

        if(dañodespues <= 0) {
            dañodespues = 10;
        }
    
        int salud_defensor = atoi(defensor->hp) - dañodespues;

        if(salud_defensor < 0 ){
            salud_defensor = 0;
        }

        char buffer[20];  
        free(defensor->hp); 
        sprintf(buffer, "%d", salud_defensor);  
        defensor->hp = strdup(buffer); 
        
        printf("%s inflinge %d de daño a %s (HP: %d)\n", atacante->name,dañodespues,defensor->name, salud_defensor);

       if (salud_defensor == 0){
            cont_defensor++;
            printf("Contador pokemons muertos del rival: %d\n", cont_defensor);
            if(cont_defensor ==3){
                printf("¡¡¡Has ganado con tu pokemon %s!!!\n",atacante->name);
                exit(0);
            }else{
                printf("¡Has derrotado a %s!\n", defensor->name);
                do{
                    indice = rand() % 3; 
                    
                    defensor = equipo2[indice];
                    printf("defensor nombre: %s\n", defensor->name);
                    printf("defensor hp: %s\n", defensor->hp);

                }while(atoi(defensor->hp) <=0);
                printf("El rival saca a %s\n", defensor->name);
            }
        }

        printf("\nTurno del rival:\n");
        printf("%s ataca a %s\n", defensor->name, atacante->name);

        int ataque_defensor = atoi(defensor->attack);

        int defensa_atacante = atoi(atacante->defense);

        int daño1antes = ataque_defensor;

      
         if(daño1antes <= 0) {
            daño1antes = 10;
        }

        aplicarEfectividad(defensor, atacante, &daño1antes);

        int daño1despues = daño1antes-defensa_atacante;

        if(daño1despues <= 0) {
            daño1despues = 10;
        }

        int salud_atacante = atoi(atacante->hp) - daño1despues;


       if(salud_atacante < 0){
        salud_atacante = 0;
       }

        char buffer2[20];  
        sprintf(buffer2, "%d", salud_atacante);  
        atacante->hp = strdup(buffer2); 
        printf("salud atacante: %d", salud_atacante);
        
        printf("%s inflinge %d de daño a %s (HP: %d)\n", defensor->name,daño1despues,atacante->name, salud_atacante);
         
        if (salud_atacante == 0){
            cont_atacante++;
            printf("Contador pokemons muertos de tu equipo: %d\n", cont_atacante);
            if(cont_atacante ==3){
                printf("Has perdido contra el pokemon %s...\n",defensor->name);
                exit(0);
            }else{
                printf("¡El rival ha derrotado a %s!\n", atacante->name);
                do{
                    indice = rand() % 3; 
                   
                    atacante = equipo1[indice];
                     printf("atacantenombre: %s\n", atacante->name);
                    printf("atacante hp: %s\n", atacante->hp);
                }while(atoi(atacante->hp) <=0);
                printf("Sacas a %s!\n", atacante->name);
            }
        }

       actual_pokemon = atacante->name;
       printf("\nEstado actual:\n");
       printf("Tu Pokémon actual es: %s, con %s HP\n", atacante->name, atacante->hp);
       printf("Te quedan %d Pokémon vivos en el equipo\n\n", 3 - cont_atacante );
       printf("El Pokémon del rival es: %s, con %s HP\n", defensor->name, defensor->hp);
       printf("Al rival le quedan %d Pokémon vivos en el equipo\n", 3 - cont_defensor);

       printf("---------------------------------\n");
       print_menu();

    }

    | CAMBIAR {

        if(encombate){
            if(cont_atacante <= 1){
                 do{
                    int indice = rand() % 3; 
                    atacante = equipo1[indice];
                }while (strcmp(actual_pokemon, atacante->name) == 0 || atoi(atacante->hp) <= 0);
                    actual_pokemon = atacante->name;
                    printf("Tu nuevo Pokemon es: %s\n", atacante->name);
                    printf("¿Qué quieres hacer a continuación? \n");
                    printf("- atacar\n");
                    printf("- cambiar\n");
                    printf("- crear equipo\n");
                    printf("- ver equipo\n");
                    printf("- quit\n");
                    printf("> ");
            }else{
                printf("No tienes Pokémon disponibles, no puedes cambiar\n");
                printf("¿Qué quieres hacer a continuación? \n");
                printf("- atacar\n");
                printf("- crear equipo\n");
                printf("- ver equipo\n");
                printf("- quit\n");
                printf("> ");
            }
           
        }else{
            printf("Antes de cambiar de Pokémon, empieza un combate\n");
            printf("¿Qué quieres hacer a continuación? \n");
            printf("- atacar\n");
            printf("- cambiar\n");
            printf("- crear equipo\n");
            printf("- ver equipo\n");
            printf("- quit\n");
            printf("> ");
        }
        
    }

    | CREAR {
        if(!created){
            seleccionarEquipoPokemonAleatorio(equipo1);
            seleccionarEquipoPokemonAleatorio(equipo2);
            printf("Equipos creados\n");
            created = true;
            print_menu();
        }else{
            printf("Ya has creado un equipo.\n");
            print_menu();
        }
        
    }

    | VER {
        printf("Tu equipo:\n");
        if(!created){
            seleccionarEquipoPokemonAleatorio(equipo1);
            seleccionarEquipoPokemonAleatorio(equipo2);
            created = true;
        }
        print_all_pokemons(equipo1,3);

        print_menu();
    }

    | QUIT {
        printf("\n %s \n", bye);
        printf("Saliendo...\n");
        exit(0);
    }

    | ADD {
        char id[50];
        char name[50];
        char type[50];
        char hp[50], attack[50], defense[50], sp_attack[50], sp_defense[50], speed[50];
        char ability[50], h_ability[50],evolution[50];
        int num_types, num_abilities;

        printf("Introduzca el id:\n");
        printf(">");
        scanf("%s", id); 
        pokemon_aux(pokemon_list, pos, id);  
        malloc_id(pokemon_list, pos, id);  
        pokemon_list[pos]->id = strdup(id);  

        printf("Introduzca el nombre:\n");
        printf(">");
        scanf("%s", name); 
        malloc_name(pokemon_list, pos, name);  
        pokemon_list[pos]->name = strdup(name);  

        printf("Introduzca el número de tipos:\n");
        printf(">");
        scanf("%d", &num_types);  
        pokemon_list[pos]->num_types = num_types;  
        pokemon_list[pos]->types = malloc(num_types * sizeof(char *)); 

        for (int i = 0; i < num_types; i++) {
            printf("Introduzca el tipo %d:\n", i+1);
            printf(">");
            scanf("%s", type);  
            pokemon_list[pos]->types[i] = strdup(type);  
        }
        
        printf("Introduzca el hp:\n");
        printf(">");
        scanf("%s", hp);  
        malloc_hp(pokemon_list, pos, hp);  
        pokemon_list[pos]->hp = strdup(hp);  

        printf("Introduzca el ataque:\n");
        printf(">");
        scanf("%s", attack);  
        malloc_attack(pokemon_list, pos, attack);  
        pokemon_list[pos]->attack = strdup(attack);  

        printf("Introduzca la defensa:\n");
        printf(">");
        scanf("%s", defense);  
        malloc_defense(pokemon_list, pos, defense);  
        pokemon_list[pos]->defense = strdup(defense);  

        printf("Introduzca el ataque especial\n");
        printf(">");
        scanf("%s", sp_attack);  
        malloc_sp_attack(pokemon_list, pos, sp_attack);  
        pokemon_list[pos]->sp_attack = strdup(sp_attack);  

        printf("Introduzca la defensa especial:\n");
        printf(">");
        scanf("%s", sp_defense);  
        malloc_sp_defense(pokemon_list, pos, sp_defense);  
        pokemon_list[pos]->sp_defense = strdup(sp_defense);  

        printf("Introduzca la velocidad:\n");
        printf(">");
        scanf("%s", speed);  
        malloc_speed(pokemon_list, pos, speed); 
        pokemon_list[pos]->speed = strdup(speed);  

        printf("Introduzca el numero de habilidades:\n");
        printf(">");
        scanf("%d", &num_abilities);  
        pokemon_list[pos]->num_abilities = num_abilities;  
        pokemon_list[pos]->abilities = malloc(num_abilities * sizeof(char *));  

        for (int i = 0; i < num_abilities; i++) {
            printf("Introduzca la habilidad:%d\n", i+1);
            printf(">");
            scanf("%s", ability);  
            pokemon_list[pos]->abilities[i] = strdup(ability);  
        }

        printf("Introduzca la habilidad oculta:\n");
        printf(">");
        scanf("%s", h_ability); 
     
        pokemon_list[pos]->hidden_ability = strdup(h_ability); 

        printf("Introduzca el número de evoluciones, 0 en caso de no tener:\n");
        printf(">");
        scanf("%s", evolution);  

        if (evolution == 0) {  
            pokemon_list[pos]->evolutions = strdup("[]"); 
        } else {
            pokemon_list[pos]->evolutions = strdup(evolution);  
        } 

        pos++;

        printf("El Pokémon ha sido almacenado correctamente\n");
        
        print_menu();
    }

    | SEE {
        print_all_pokemons(pokemon_list, pos);   
        print_menu();
    }
    
    | TEXT {
        printf("Por favor, seleccione solo las opciones disponibles:\n");
        printf("> ");
    }

    | DIGIT {
        printf("Por favor, seleccione solo las opciones disponibles\n");
        printf("> ");
    }
    ;
    
%%
void print_all_pokemons(Pokemon** pokemon_list, int pos) {
    printf("---------------------------------------------\n");
    for (int i = 0; i < pos; i++) {
        if (pokemon_list[i] != NULL) {
            printf("Pokémon #%d:\n", i + 1);
            printf("  ID: %s\n", pokemon_list[i]->id);
            printf("  Name: %s\n", pokemon_list[i]->name);
            printf("  Types: ");
            for (int k = 0; k < pokemon_list[i]->num_types; k++) {
                printf("%s", pokemon_list[i]->types[k]);
                if (k < pokemon_list[i]->num_types - 1) {
                    printf(", ");
                }
            }
            printf("\n");
            printf("  HP: %s\n", pokemon_list[i]->hp);
            printf("  Attack: %s\n", pokemon_list[i]->attack);
            printf("  Defense: %s\n", pokemon_list[i]->defense);
            printf("  Special Attack: %s\n", pokemon_list[i]->sp_attack);
            printf("  Special Defense: %s\n", pokemon_list[i]->sp_defense);
            printf("  Speed: %s\n", pokemon_list[i]->speed);
            printf("  Abilities: ");
            for (int k = 0; k < pokemon_list[i]->num_abilities; k++) {
                printf("%s", pokemon_list[i]->abilities[k]);
                if (k < pokemon_list[i]->num_abilities - 1) {
                    printf(", ");
                }
            }
            printf("\n");
            printf("  Hidden Ability: %s\n", pokemon_list[i]->hidden_ability);
            printf("  Evolutions: %s\n", pokemon_list[i]->evolutions);
            printf("---------------------------------------------\n");
        }
    }
}

void print_menu(){
    printf("¿Qué quieres hacer a continuación? \n");
    printf("- atacar\n");
    printf("- cambiar\n");
    printf("- ver equipo\n");
    printf("- añadir pokemon\n");
    printf("- ver pokédex\n");
    printf("- crear equipo\n");
    printf("- quit\n");
    printf("> ");
}

void pokemon_aux(Pokemon** pokemon_list, int pos, const char* id) {
    pokemon_list[pos] = malloc(sizeof(Pokemon));
    if (pokemon_list[pos] == NULL) {
        fprintf(stderr, "Error al asignar memoria para el Pokémon.\n");
        exit(1);
    }
}

void malloc_id(Pokemon** pokemon_list, int pos, const char* id){
    pokemon_list[pos]->id = malloc(sizeof(char) * (strlen(id) + 1)); 
        if (pokemon_list[pos]->id == NULL) {
            fprintf(stderr, "Error al asignar memoria para el ID.\n");
            exit(1);
        }
}

void malloc_name(Pokemon** pokemon_list, int pos, const char* name){
    pokemon_list[pos]->name = malloc(sizeof(char) * (strlen(name) + 1)); 
        if (pokemon_list[pos]->name == NULL) {
            fprintf(stderr, "Error al asignar memoria para el ID.\n");
            exit(1);
        }
}

void malloc_hp(Pokemon** pokemon_list, int pos, const char* hp){
    pokemon_list[pos]->hp = malloc(sizeof(char) * (strlen(hp) + 1)); 
        if (pokemon_list[pos]->hp == NULL) {
            fprintf(stderr, "Error al asignar memoria para el ID.\n");
            exit(1);
        }
}

void malloc_attack(Pokemon** pokemon_list, int pos, const char* attack) {
    pokemon_list[pos]->attack = malloc(sizeof(char) * (strlen(attack) + 1)); 
    if (pokemon_list[pos]->attack == NULL) {
        fprintf(stderr, "Error al asignar memoria para el ataque.\n");
        exit(1);
    }
 
}

void malloc_defense(Pokemon** pokemon_list, int pos, const char* defense) {
    pokemon_list[pos]->defense = malloc(sizeof(char) * (strlen(defense) + 1)); 
    if (pokemon_list[pos]->defense == NULL) {
        fprintf(stderr, "Error al asignar memoria para la defensa.\n");
        exit(1);
    }
}

void malloc_sp_attack(Pokemon** pokemon_list, int pos, const char* sp_attack) {
    pokemon_list[pos]->sp_attack = malloc(sizeof(char) * (strlen(sp_attack) + 1)); 
    if (pokemon_list[pos]->sp_attack == NULL) {
        fprintf(stderr, "Error al asignar memoria para el ataque especial.\n");
        exit(1);
    }
}

void malloc_sp_defense(Pokemon** pokemon_list, int pos, const char* sp_defense) {
    pokemon_list[pos]->sp_defense = malloc(sizeof(char) * (strlen(sp_defense) + 1)); 
    if (pokemon_list[pos]->sp_defense == NULL) {
        fprintf(stderr, "Error al asignar memoria para la defensa especial.\n");
        exit(1);
    } 
}

void malloc_speed(Pokemon** pokemon_list, int pos, const char* speed) {
    pokemon_list[pos]->speed = malloc(sizeof(char) * (strlen(speed) + 1)); 
    if (pokemon_list[pos]->speed == NULL) {
        fprintf(stderr, "Error al asignar memoria para la velocidad.\n");
        exit(1);
    } 
}

void malloc_hidden_ability(Pokemon** pokemon_list, int pos, const char* hidden_ability) {
    pokemon_list[pos]->hidden_ability = malloc(sizeof(char) * (strlen(hidden_ability) + 1)); 
    if (pokemon_list[pos]->hidden_ability == NULL) {
        fprintf(stderr, "Error al asignar memoria para la habilidad oculta.\n");
        exit(1);
    }
}

void malloc_evolutions(Pokemon** pokemon_list, int pos, const char* evolutions) {
    pokemon_list[pos]->evolutions = malloc(sizeof(char) * (strlen(evolutions) + 1)); 
    if (pokemon_list[pos]->evolutions == NULL) {
        fprintf(stderr, "Error al asignar memoria para las evoluciones.\n");
        exit(1);
    }
}

void add_type(Pokemon** pokemon_list, int pos, const char* type, int* cont_types) {

     (*cont_types)++;

    pokemon_list[pos]->types = realloc(pokemon_list[pos]->types, (*cont_types) * sizeof(char *));
    if (pokemon_list[pos]->types == NULL) {
        fprintf(stderr, "Error al asignar memoria para types.\n");
        exit(1);
    }

    pokemon_list[pos]->types[*cont_types - 1] = malloc(sizeof(char) * (strlen(type) + 1));
    if (pokemon_list[pos]->types[*cont_types - 1] == NULL) {
        fprintf(stderr, "Error al asignar memoria para el tipo %d.\n", *cont_types - 1);
        exit(1);
    }

    strcpy(pokemon_list[pos]->types[*cont_types - 1], type);
}

void add_ability(Pokemon** pokemon_list, int pos, const char* ability, int* cont_abilities) {

    (*cont_abilities)++;

    pokemon_list[pos]->abilities = realloc(pokemon_list[pos]->abilities, (*cont_abilities) * sizeof(char *));
    if (pokemon_list[pos]->abilities == NULL) {
        fprintf(stderr, "Error al asignar memoria para abilities.\n");
        exit(1);
    }

    pokemon_list[pos]->abilities[*cont_abilities - 1] = malloc(sizeof(char) * (strlen(ability) + 1));
    if (pokemon_list[pos]->abilities[*cont_abilities - 1] == NULL) {
        fprintf(stderr, "Error al asignar memoria para la habilidad %d.\n", *cont_abilities - 1);
        exit(1);
    }

    strcpy(pokemon_list[pos]->abilities[*cont_abilities - 1], ability);
}

void seleccionarEquipoPokemonAleatorio(Pokemon** equipo) {
    
    int indices_seleccionados[3] = {-1, -1, -1};

    for (int i = 0; i < 3; i++) { 
        int indice_aleatorio;

        do {
            indice_aleatorio = rand() % pos; 
        } while (indice_aleatorio == indices_seleccionados[0] ||
                 indice_aleatorio == indices_seleccionados[1] ||
                 indice_aleatorio == indices_seleccionados[2]);

        indices_seleccionados[i] = indice_aleatorio;

        equipo[i] = clonarPokemon(pokemon_list[indice_aleatorio]); 
    }
}


int tipoPresente(char** types, int num_types, const char* tipo) {
    for (int i = 0; i < num_types; i++) {
        if (strcmp(types[i], tipo) == 0) {
            return 1;  
        }
    }
    return 0; 
}

void aplicarEfectividad(Pokemon* atacante, Pokemon* defensor, int* daño){
    if (tipoPresente(atacante->types, atacante->num_types, "Grass") == 1 && 
                tipoPresente(defensor->types, defensor->num_types, "Water") == 1) {
                printf("¡¡Es SUPEREFICAZ!!\n");
                *daño *= 2;
            }else  if (tipoPresente(atacante->types, atacante->num_types, "Water") == 1 && 
                tipoPresente(defensor->types, defensor->num_types, "Grass") == 1) {
                printf("Tu ataque es poco eficaz...\n");
                *daño *= 0.5;
            }else if (tipoPresente(atacante->types, atacante->num_types, "Water") == 1 && 
                tipoPresente(defensor->types, defensor->num_types, "Fire") == 1) {
                printf("¡¡Es SUPEREFICAZ!!\n");
                *daño *= 2;
            }else  if (tipoPresente(atacante->types, atacante->num_types, "Fire") == 1 && 
                tipoPresente(defensor->types, defensor->num_types, "Water") == 1) {
                printf("Tu ataque es poco eficaz...\n");
                *daño *= 0.5;
            }else if (tipoPresente(atacante->types, atacante->num_types, "Fire") == 1 && 
                tipoPresente(defensor->types, defensor->num_types, "Grass") == 1) {
                printf("¡¡Es SUPEREFICAZ!!\n");
                *daño *= 2;
            }else if (tipoPresente(atacante->types, atacante->num_types, "Grass") == 1 && 
                tipoPresente(defensor->types, defensor->num_types, "Fire") == 1) {
                printf("Tu ataque es poco eficaz...\n");
                *daño *= 0.5;
            }
}

            
int yyerror(char* expected) {
    fprintf(stderr, "Error en la línea %d: %s\n", yylineno, expected);
    exit(0);
}
int yywrap() 
{
    if (mode == 1){
        printf("\nDATOS ALMACENADOS EN LA POKÉDEX:\n");
        print_all_pokemons(pokemon_list, pos);
    }
    printf("\n%s\n", good);
    printf("Pokémons almacenados correctamente :).\n");
 
   return 1;
}

int main(int argc, char *argv[])
{
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <archivo_json>\n", argv[0]);
        return 1;
    }
    srand(time(NULL));
    printf("---------------------BIENVENIDO-------------------\n");
    printf("\n%s\n", welcome);
    printf("¿Quieres jugar un combate o analizar un JSON de la Pokédex?\n");
    printf("1 - Analizar JSON de la Pokédex\n");
    printf("2 - Jugar\n");
    printf("> ");

    char input[10];
    fgets(input, sizeof(input), stdin);  

    while (sscanf(input, "%d", &mode) != 1 || (mode != 1 && mode != 2)){
        printf("Por favor, introduce solo una de esas dos opciones:\n");
        printf("1 - Analizar JSON de la Pokédex\n");
        printf("2 - Jugar\n");
        printf("> ");
        fgets(input, sizeof(input), stdin); 
    }
    
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "Error al abrir el archivo: %s\n", argv[1]);
        return 1;
    }

    if (mode == 1) {

        yyparse();
        fclose(yyin);

    } else {

        yyparse();
        fclose(yyin);

        yyin = stdin;

        yyrestart(yyin);

        print_menu();
    
        yyparse();
        fclose(yyin);
    }
}
