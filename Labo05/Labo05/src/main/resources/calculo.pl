% Reglas de derivacion e integracion para la interfaz Java.

d(_, Funcion, 0) :- number(Funcion), !.
d(Variable, Variable, 1) :- atomic(Variable), !.
d(Variable, A + B, DA + DB) :- d(Variable, A, DA), d(Variable, B, DB), !.
d(Variable, A - B, DA - DB) :- d(Variable, A, DA), d(Variable, B, DB), !.
d(Variable, Constante * Funcion, Constante * Derivada) :-
    number(Constante), d(Variable, Funcion, Derivada), !.
d(Variable, Variable ^ Exponente, Exponente * Variable ^ MenosUno) :-
    atomic(Variable), number(Exponente), MenosUno is Exponente - 1, !.
d(Variable, log(Variable), 1 / Variable) :- atomic(Variable), !.

s(Variable, Constante, Constante * Variable) :-
    atomic(Variable), number(Constante), !.
s(Variable, Variable, 1 / 2 * Variable ^ 2) :- atomic(Variable), !.
s(Variable, A + B, SA + SB) :- s(Variable, A, SA), s(Variable, B, SB), !.
s(Variable, A - B, SA - SB) :- s(Variable, A, SA), s(Variable, B, SB), !.
s(Variable, Constante * Funcion, Constante * Integral) :-
    number(Constante), s(Variable, Funcion, Integral), !.
s(Variable, Variable ^ Exponente, 1 / MenosUno * Variable ^ MenosUno) :-
    atomic(Variable), number(Exponente), Exponente =\= -1,
    MenosUno is Exponente + 1, !.