% Base de conocimientos del ejercicio

personaje(eric).
personaje(timmy).
personaje(kelvin).
personaje(virginia).

edad(eric, 30).
edad(timmy, 28).
edad(kelvin, 32).
edad(virginia, 27).

tipo_personaje(eric, protagonista).
tipo_personaje(timmy, superviviente).
tipo_personaje(kelvin, aliado_capturado).
tipo_personaje(virginia, superviviente_mutante).

aliado(kelvin).
no_habla(kelvin).
mutante(virginia).
puede_volverse_aliada(virginia).

tiene(eric, hacha).
tiene(eric, encendedor).
tiene(eric, llave_bunker).

puede_cargar_troncos(kelvin).

zona(superficie).
zona(cuevas).
zona(bunkeres).

enemigo(canibal, superficie).
enemigo(mutante, superficie).
enemigo(mutante, cuevas).

sin_enemigos(bunkeres).
requiere_llaves(bunkeres).

nivel_peligro(superficie, medio, dia).
nivel_peligro(superficie, alto, noche).
nivel_peligro(cuevas, alto).

material(troncos, superficie).
material(piedras, superficie).

necesidad(eric, refugio).
necesidad(eric, comida).
necesidad(eric, agua).

