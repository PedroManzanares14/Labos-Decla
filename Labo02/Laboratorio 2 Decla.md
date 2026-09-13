# Resolución de Laboratorio 2

**1. Si la información no es completa para oferentes y demandantes, hay una falla de mercado.**

| Entidad (Sujeto) | Acción (Predicado) |
| :--- | :--- |
| La información | carece de completitud para oferentes y demandantes |

```prolog
% Hechos que indican qué agentes tienen información completa
posee_info_completa(oferentes).
posee_info_completa(demandantes).

% Regla para determinar si existe una falla en el mercado
falla_de_mercado(AgenteA, AgenteB) :-
    \+ posee_info_completa(AgenteA),
    \+ posee_info_completa(AgenteB).
```

---

**2. He pasado todas mis vacaciones en Grecia y Marruecos**

| Entidad | Descripción de la acción |
| :--- | :--- |
| Yo (Sujeto tácito) | pasé mis vacaciones completas en Grecia y Marruecos |

```prolog
es_destino(grecia).
es_destino(marruecos).

% Definimos a pedro como la persona de la oración
fue_de_vacaciones(pedro, grecia).
fue_de_vacaciones(pedro, marruecos).

% Verificamos si una persona fue a múltiples destinos
vacaciones_multiples(Persona, D1, D2) :-
    es_destino(D1),
    es_destino(D2),
    fue_de_vacaciones(Persona, D1),
    fue_de_vacaciones(Persona, D2).
```

---

**3. La realidad supera a la ficción y él no puede creerlo**

| Componente | Detalle |
| :--- | :--- |
| La realidad | es superior a la ficción |
| Él (Individuo) | es incapaz de creer el hecho |

```prolog
es_superior(realidad, ficcion).

individuo(pedro).

% Regla para evaluar si alguien no cree en un hecho
incapaz_de_creer(Sujeto, Hecho) :-
    individuo(Sujeto),
    \+ se_lo_cree(Sujeto, Hecho).
```
