:- consult('hechos.pl').

zona_peligrosa(Zona) :-
    zona(Zona),
    (nivel_peligro(Zona, alto, _); nivel_peligro(Zona, alto)).

puede_abrir_bunker(Personaje) :-
    personaje(Personaje),
    tiene(Personaje, llave_bunker).

puede_ser_aliado(Personaje) :-
    personaje(Personaje),
    (aliado(Personaje); puede_volverse_aliada(Personaje)).

es_adulto(Personaje) :-
    edad(Personaje, Edad),
    Edad >= 18.

material_disponible_en_superficie(Material) :-
    material(Material, superficie).

supervivencia_basica(eric) :-
    necesidad(eric, refugio),
    necesidad(eric, comida),
    necesidad(eric, agua).
