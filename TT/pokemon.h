#ifndef POKEMON_H
#define POKEMON_H

#define MAX_POKEMON 100  

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char *id;
    char *name;
    char **types;
    int num_types;
    char *hp;
    char *attack;
    char *defense;
    char *sp_attack;
    char *sp_defense;
    char *speed;
    char **abilities;
    int  num_abilities;
    char *hidden_ability;
    char *evolutions;
} Pokemon;

Pokemon* clonarPokemon(Pokemon* original) {
    if (!original) return NULL;

    Pokemon* copia = malloc(sizeof(Pokemon));
    if (!copia) return NULL;

    copia->id = strdup(original->id);
    if (!copia->id) return NULL;

    copia->name = strdup(original->name);
    if (!copia->name) return NULL;

    copia->hp = strdup(original->hp);
    if (!copia->hp) return NULL;

    copia->attack = strdup(original->attack);
    if (!copia->attack) return NULL;

    copia->defense = strdup(original->defense);
    if (!copia->defense) return NULL;

    copia->sp_attack = strdup(original->sp_attack);
    if (!copia->sp_attack) return NULL;

    copia->sp_defense = strdup(original->sp_defense);
    if (!copia->sp_defense) return NULL;

    copia->speed = strdup(original->speed);
    if (!copia->speed) return NULL;

    copia->hidden_ability = strdup(original->hidden_ability);
    if (!copia->hidden_ability) return NULL;

    copia->evolutions = strdup(original->evolutions);
    if (!copia->evolutions) return NULL;

    copia->num_types = original->num_types;
    if (copia->num_types > 0) {
        copia->types = malloc(copia->num_types * sizeof(char*));
        if (!copia->types) return NULL;
        for (int i = 0; i < copia->num_types; i++) {
            copia->types[i] = strdup(original->types[i]);
            if (!copia->types[i]) return NULL;
        }
    } else {
        copia->types = NULL;
    }

    copia->num_abilities = original->num_abilities;
    if (copia->num_abilities > 0) {
        copia->abilities = malloc(copia->num_abilities * sizeof(char*));
        if (!copia->abilities) return NULL;
        for (int i = 0; i < copia->num_abilities; i++) {
            copia->abilities[i] = strdup(original->abilities[i]);
            if (!copia->abilities[i]) return NULL;
        }
    } else {
        copia->abilities = NULL;
    }

    return copia;
}

#endif 
