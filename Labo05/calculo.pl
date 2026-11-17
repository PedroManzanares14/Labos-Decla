% Laboratorio 5: calculo simbolico con derivadas e integrales.

% Derivada de una constante.
d(_, Funcion, 0) :-
    number(Funcion),
    !.

% Derivada de la variable respecto de si misma.
d(Variable, Variable, 1) :-
    atomic(Variable),
    !.

% Linealidad de la derivada.
d(Variable, A + B, DerivadaA + DerivadaB) :-
    d(Variable, A, DerivadaA),
    d(Variable, B, DerivadaB),
    !.

d(Variable, A - B, DerivadaA - DerivadaB) :-
    d(Variable, A, DerivadaA),
    d(Variable, B, DerivadaB),
    !.

% Regla del producto cuando uno de los factores es constante.
d(Variable, Constante * Funcion, Constante * Derivada) :-
    number(Constante),
    d(Variable, Funcion, Derivada),
    !.

% Derivada de una potencia de la variable.
d(Variable, Variable ^ Exponente, Exponente * Variable ^ ExponenteMenosUno) :-
    atomic(Variable),
    number(Exponente),
    ExponenteMenosUno is Exponente - 1,
    !.

% Derivada del logaritmo natural.
d(Variable, log(Variable), 1 / Variable) :-
    atomic(Variable),
    !.

% Integral de una constante.
s(Variable, Constante, Constante * Variable) :-
    atomic(Variable),
    number(Constante),
    !.

% Integral de la variable respecto de si misma.
s(Variable, Variable, 1 / 2 * Variable ^ 2) :-
    atomic(Variable),
    !.

% Linealidad de la integral.
s(Variable, A + B, IntegralA + IntegralB) :-
    s(Variable, A, IntegralA),
    s(Variable, B, IntegralB),
    !.

s(Variable, A - B, IntegralA - IntegralB) :-
    s(Variable, A, IntegralA),
    s(Variable, B, IntegralB),
    !.

% Integral de una constante por una funcion.
s(Variable, Constante * Funcion, Constante * Integral) :-
    number(Constante),
    s(Variable, Funcion, Integral),
    !.

% Integral de una potencia de la variable.
s(Variable, Variable ^ Exponente,
  1 / ExponenteMasUno * Variable ^ ExponenteMasUno) :-
    atomic(Variable),
    number(Exponente),
    Exponente =\= -1,
    ExponenteMasUno is Exponente + 1,
    !.

% Evaluacion numerica de una expresion en X.
evaluar(_, Numero, Numero) :-
    number(Numero),
    !.

evaluar(Valor, x, Valor) :-
    number(Valor),
    !.

evaluar(X, A + B, Valor) :-
    evaluar(X, A, ValorA),
    evaluar(X, B, ValorB),
    Valor is ValorA + ValorB,
    !.

evaluar(X, A - B, Valor) :-
    evaluar(X, A, ValorA),
    evaluar(X, B, ValorB),
    Valor is ValorA - ValorB,
    !.

evaluar(X, A * B, Valor) :-
    evaluar(X, A, ValorA),
    evaluar(X, B, ValorB),
    Valor is ValorA * ValorB,
    !.

evaluar(X, A / B, Valor) :-
    evaluar(X, A, ValorA),
    evaluar(X, B, ValorB),
    Valor is ValorA / ValorB,
    !.

evaluar(X, A ^ B, Valor) :-
    evaluar(X, A, ValorA),
    evaluar(X, B, ValorB),
    Valor is ValorA ^ ValorB,
    !.

evaluar(X, log(Expresion), Valor) :-
    evaluar(X, Expresion, ValorExpresion),
    Valor is log(ValorExpresion),
    !.

% Area bajo la curva entre los limites A y B.
area(Variable, Funcion, A, B, Resultado) :-
    s(Variable, Funcion, Primitiva),
    evaluar(A, Primitiva, ValorA),
    evaluar(B, Primitiva, ValorB),
    Resultado is ValorB - ValorA.