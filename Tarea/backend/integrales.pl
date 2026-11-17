% Pedro Jose Manzanarres Santos 00230422

% reglas para resolver integrales y sacar el area

:- module(integrales, [
    integrar/3,
    integrar/4,
    simplificar/2,
    evaluar/3,
    area_bajo_curva/6,
    resolver/4,
    resolver_json/4,
    to_latex/2
]).

:- use_module(library(json)).

% ver si aparece la variable

contiene_var(Var, Var) :- !.
contiene_var(Term, Var) :-
    compound(Term),
    !,
    Term =.. [_|Args],
    contiene_var_lista(Args, Var).

contiene_var_lista([H|_], Var) :- contiene_var(H, Var), !.
contiene_var_lista([_|T], Var) :- contiene_var_lista(T, Var).

es_constante(Expr, Var) :-
    \+ contiene_var(Expr, Var).

% reglas de integracion, una por una

% suma
s(Var, A + B, IntA + IntB, 'Suma de funciones: ∫(u + v)dx = ∫u dx + ∫v dx') :-
    s(Var, A, IntA, _),
    s(Var, B, IntB, _),
    !.

% resta
s(Var, A - B, IntA - IntB, 'Resta de funciones: ∫(u - v)dx = ∫u dx - ∫v dx') :-
    s(Var, A, IntA, _),
    s(Var, B, IntB, _),
    !.

% signo menos
s(Var, -U, -IntU, 'Negacion unaria: ∫ -u dx = - ∫ u dx') :-
    s(Var, U, IntU, _),
    !.

% constante por funcion
s(Var, K * U, K * IntU, 'Multiplo constante: ∫(k * u)dx = k * ∫u dx') :-
    es_constante(K, Var),
    contiene_var(U, Var),
    s(Var, U, IntU, _),
    !.

s(Var, U * K, K * IntU, 'Multiplo constante: ∫(u * k)dx = k * ∫u dx') :-
    es_constante(K, Var),
    contiene_var(U, Var),
    s(Var, U, IntU, _),
    !.

% dividir por constante
s(Var, U / K, (1 / K) * IntU, 'Division por constante: ∫(u / k)dx = (1/k) * ∫u dx') :-
    es_constante(K, Var),
    contiene_var(U, Var),
    s(Var, U, IntU, _),
    !.

% k entre x
s(Var, K / Var, K * ln(abs(Var)), 'Potencia -1: ∫(k / x)dx = k * ln|x|') :-
    es_constante(K, Var),
    !.

s(Var, 1 / Var, ln(abs(Var)), 'Potencia -1: ∫(1 / x)dx = ln|x|') :-
    !.

% potencia abajo
s(Var, 1 / (Var ^ N), Res, Regla) :-
    number(N),
    N =\= 1,
    Exp is -N,
    s(Var, Var ^ Exp, Res, Regla),
    !.

s(Var, K / (Var ^ N), K * Res, Regla) :-
    es_constante(K, Var),
    number(N),
    N =\= 1,
    Exp is -N,
    s(Var, Var ^ Exp, Res, Regla),
    !.

% constante
s(Var, K, K * Var, 'Constante: ∫ k dx = k * x') :-
    es_constante(K, Var),
    !.

% la variable sola
s(Var, Var, (Var ^ 2) / 2, 'Variable respecto a si misma: ∫ x dx = (x^2)/2') :-
    !.

% constante por x
s(Var, K * Var, (K / 2) * (Var ^ 2), 'Constante por variable: ∫(k * x)dx = (k/2) * x^2') :-
    es_constante(K, Var),
    !.

% potencia
s(Var, Var ^ N, ln(abs(Var)), 'Potencia n = -1: ∫ x^(-1) dx = ln|x|') :-
    number(N),
    N =:= -1,
    !.

s(Var, Var ^ 0, Var, 'Potencia n = 0: ∫ x^0 dx = x') :-
    !.

s(Var, Var ^ 1, (Var ^ 2) / 2, 'Potencia n = 1: ∫ x^1 dx = (x^2)/2') :-
    !.

s(Var, Var ^ N, (Var ^ N1) / N1, Regla) :-
    number(N),
    N =\= -1,
    N1 is N + 1,
    swritef(Regla, 'Regla de la potencia: ∫ x^%w dx = (x^%w)/%w', [N, N1, N1]),
    !.

% raiz
s(Var, sqrt(Var), (2 / 3) * (Var ^ 1.5), 'Raiz cuadrada: ∫ √x dx = (2/3) * x^(3/2)') :-
    !.

% exponenciales
% caso e
s(Var, e ^ Var, e ^ Var, 'Exponencial natural: ∫ e^x dx = e^x') :- !.
s(Var, exp(Var), exp(Var), 'Exponencial natural: ∫ exp(x) dx = exp(x)') :- !.

% otra base
s(Var, A ^ Var, (A ^ Var) / ln(A), 'Exponencial: ∫ a^x dx = (a^x) / ln(a)') :-
    es_constante(A, Var),
    !.

% exponencial con k*x
s(Var, e ^ (K * Var), (e ^ (K * Var)) / K, 'Exponencial lineal: ∫ e^(k*x) dx = e^(k*x) / k') :-
    es_constante(K, Var),
    !.

s(Var, exp(K * Var), (exp(K * Var)) / K, 'Exponencial lineal: ∫ exp(k*x) dx = exp(k*x) / k') :-
    es_constante(K, Var),
    !.

s(Var, A ^ (K * Var), (A ^ (K * Var)) / (K * ln(A)), 'Exponencial lineal: ∫ a^(k*x) dx = a^(k*x) / (k * ln(a))') :-
    es_constante(A, Var),
    es_constante(K, Var),
    !.

% seno
s(Var, sin(Var), -cos(Var), 'Trigonometrica: ∫ sin(x) dx = -cos(x)') :- !.
s(Var, sen(Var), -cos(Var), 'Trigonometrica: ∫ sen(x) dx = -cos(x)') :- !.

% seno con k
s(Var, sin(K * Var), (-cos(K * Var)) / K, 'Trigonometrica lineal: ∫ sin(k*x) dx = -cos(k*x) / k') :-
    es_constante(K, Var),
    !.

% coseno
s(Var, cos(Var), sin(Var), 'Trigonometrica: ∫ cos(x) dx = sin(x)') :- !.

% coseno con k
s(Var, cos(K * Var), (sin(K * Var)) / K, 'Trigonometrica lineal: ∫ cos(k*x) dx = sin(k*x) / k') :-
    es_constante(K, Var),
    !.

% tangente
s(Var, tan(Var), -ln(abs(cos(Var))), 'Trigonometrica: ∫ tan(x) dx = -ln|cos(x)|') :- !.
s(Var, tg(Var), -ln(abs(cos(Var))), 'Trigonometrica: ∫ tan(x) dx = -ln|cos(x)|') :- !.

% tangente con k
s(Var, tan(K * Var), (-ln(abs(cos(K * Var)))) / K, 'Trigonometrica lineal: ∫ tan(k*x) dx = -ln|cos(k*x)| / k') :-
    es_constante(K, Var),
    !.

% arco seno
s(Var, asin(Var), Var * asin(Var) + sqrt(1 - Var ^ 2), 'Trigonometrica inversa: ∫ asin(x) dx = x*asin(x) + √(1 - x²)') :- !.
s(Var, arcsin(Var), Var * arcsin(Var) + sqrt(1 - Var ^ 2), 'Trigonometrica inversa: ∫ arcsin(x) dx = x*arcsin(x) + √(1 - x²)') :- !.

% arco coseno
s(Var, acos(Var), Var * acos(Var) - sqrt(1 - Var ^ 2), 'Trigonometrica inversa: ∫ acos(x) dx = x*acos(x) - √(1 - x²)') :- !.
s(Var, arccos(Var), Var * arccos(Var) - sqrt(1 - Var ^ 2), 'Trigonometrica inversa: ∫ arccos(x) dx = x*arccos(x) - √(1 - x²)') :- !.

% arco tangente
s(Var, atan(Var), Var * atan(Var) - (1 / 2) * ln(1 + Var ^ 2), 'Trigonometrica inversa: ∫ atan(x) dx = x*atan(x) - (1/2)*ln(1 + x²)') :- !.
s(Var, arctan(Var), Var * arctan(Var) - (1 / 2) * ln(1 + Var ^ 2), 'Trigonometrica inversa: ∫ arctan(x) dx = x*arctan(x) - (1/2)*ln(1 + x²)') :- !.

% seno hiperbolico
s(Var, sh(Var), cosh(Var), 'Hiperbolica: ∫ sh(x) dx = cosh(x)') :- !.
s(Var, sinh(Var), cosh(Var), 'Hiperbolica: ∫ sinh(x) dx = cosh(x)') :- !.

s(Var, sh(K * Var), (cosh(K * Var)) / K, 'Hiperbolica lineal: ∫ sh(k*x) dx = cosh(k*x) / k') :-
    es_constante(K, Var),
    !.
s(Var, sinh(K * Var), (cosh(K * Var)) / K, 'Hiperbolica lineal: ∫ sinh(k*x) dx = cosh(k*x) / k') :-
    es_constante(K, Var),
    !.

% coseno hiperbolico
s(Var, cosh(Var), sinh(Var), 'Hiperbolica: ∫ cosh(x) dx = sinh(x)') :- !.
s(Var, ch(Var), sinh(Var), 'Hiperbolica: ∫ ch(x) dx = sinh(x)') :- !.

s(Var, cosh(K * Var), (sinh(K * Var)) / K, 'Hiperbolica lineal: ∫ cosh(k*x) dx = sinh(k*x) / k') :-
    es_constante(K, Var),
    !.
s(Var, ch(K * Var), (sinh(K * Var)) / K, 'Hiperbolica lineal: ∫ ch(k*x) dx = sinh(k*x) / k') :-
    es_constante(K, Var),
    !.

% tangente hiperbolica
s(Var, tanh(Var), ln(cosh(Var)), 'Hiperbolica: ∫ tanh(x) dx = ln(cosh(x))') :- !.
s(Var, th(Var), ln(cosh(Var)), 'Hiperbolica: ∫ th(x) dx = ln(cosh(x))') :- !.

s(Var, tanh(K * Var), (ln(cosh(K * Var))) / K, 'Hiperbolica lineal: ∫ tanh(k*x) dx = ln(cosh(k*x)) / k') :-
    es_constante(K, Var),
    !.
s(Var, th(K * Var), (ln(cosh(K * Var))) / K, 'Hiperbolica lineal: ∫ th(k*x) dx = ln(cosh(k*x)) / k') :-
    es_constante(K, Var),
    !.

% arco seno hiperbolico
s(Var, arcsinh(Var), Var * arcsinh(Var) - sqrt(Var ^ 2 + 1), 'Hiperbolica inversa: ∫ arcsinh(x) dx = x*arcsinh(x) - √(x² + 1)') :- !.
s(Var, asinh(Var), Var * asinh(Var) - sqrt(Var ^ 2 + 1), 'Hiperbolica inversa: ∫ asinh(x) dx = x*asinh(x) - √(x² + 1)') :- !.

% arco coseno hiperbolico
s(Var, arccosh(Var), Var * arccosh(Var) - sqrt(Var ^ 2 - 1), 'Hiperbolica inversa: ∫ arccosh(x) dx = x*arccosh(x) - √(x² - 1)') :- !.
s(Var, acosh(Var), Var * acosh(Var) - sqrt(Var ^ 2 - 1), 'Hiperbolica inversa: ∫ acosh(x) dx = x*acosh(x) - √(x² - 1)') :- !.

% arco tangente hiperbolica
s(Var, arctanh(Var), Var * arctanh(Var) + (1 / 2) * ln(abs(1 - Var ^ 2)), 'Hiperbolica inversa: ∫ arctanh(x) dx = x*arctanh(x) + (1/2)*ln|1 - x²|') :- !.
s(Var, atanh(Var), Var * atanh(Var) + (1 / 2) * ln(abs(1 - Var ^ 2)), 'Hiperbolica inversa: ∫ atanh(x) dx = x*atanh(x) + (1/2)*ln|1 - x²|') :- !.

% log natural
s(Var, ln(Var), Var * ln(abs(Var)) - Var, 'Logaritmo natural: ∫ ln(x) dx = x*ln|x| - x') :- !.
s(Var, log(Var), Var * ln(abs(Var)) - Var, 'Logaritmo natural: ∫ log(x) dx = x*ln|x| - x') :- !.

% caso general
s(_, Expr, _, _) :-
    throw(error(integral_no_soportada, context(s/4, Expr))).


% simplificar expresiones

simplificar(Expr, Simplificada) :-
    simp_paso(Expr, Temp),
    Expr \== Temp,
    !,
    simplificar(Temp, Simplificada).
simplificar(Expr, Expr).

simp_paso(A + B, Res) :-
    simp_paso(A, SA),
    simp_paso(B, SB),
    simp_add(SA, SB, Res),
    !.

simp_paso(A - B, Res) :-
    simp_paso(A, SA),
    simp_paso(B, SB),
    simp_sub(SA, SB, Res),
    !.

simp_paso(A * B, Res) :-
    simp_paso(A, SA),
    simp_paso(B, SB),
    simp_mul(SA, SB, Res),
    !.

simp_paso(A / B, Res) :-
    simp_paso(A, SA),
    simp_paso(B, SB),
    simp_div(SA, SB, Res),
    !.

simp_paso(A ^ B, Res) :-
    simp_paso(A, SA),
    simp_paso(B, SB),
    simp_pow(SA, SB, Res),
    !.

simp_paso(-A, Res) :-
    simp_paso(A, SA),
    simp_neg(SA, Res),
    !.

simp_paso(Term, Res) :-
    compound(Term),
    !,
    Term =.. [F|Args],
    maplist(simp_paso, Args, SArgs),
    Res =.. [F|SArgs].

simp_paso(Atomic, Atomic).

% sumas
simp_add(0, B, B) :- !.
simp_add(A, 0, A) :- !.
simp_add(A, -B, A - B) :- !.
simp_add(-A, B, B - A) :- !.
simp_add(A, B, Res) :-
    number(A), number(B),
    !,
    Res is A + B.
simp_add(A, A, 2 * A) :- !.
simp_add(A, B, A + B).

% restas
simp_sub(A, 0, A) :- !.
simp_sub(0, B, -B) :- !.
simp_sub(A, -B, A + B) :- !.
simp_sub(A, A, 0) :- !.
simp_sub(A, B, Res) :-
    number(A), number(B),
    !,
    Res is A - B.
simp_sub(A, B, A - B).

% multiplicaciones
simp_mul(0, _, 0) :- !.
simp_mul(_, 0, 0) :- !.
simp_mul(1, B, B) :- !.
simp_mul(A, 1, A) :- !.
simp_mul(-1, B, -B) :- !.
simp_mul(A, -1, -A) :- !.
simp_mul(A, -B, -(Res)) :-
    simp_mul(A, B, Res),
    !.
simp_mul(-A, B, -(Res)) :-
    simp_mul(A, B, Res),
    !.
simp_mul(A, B, Res) :-
    number(A), number(B),
    !,
    Res is A * B.
simp_mul(A, B * C, (A * B) * C) :-
    number(A), number(B),
    !.
simp_mul(A, B / C, (A * B) / C) :-
    number(A), number(B),
    !.
simp_mul(A, B / C, Res) :-
    number(A), number(C),
    C =\= 0,
    0 =:= A mod C,
    !,
    K is A // C,
    Res = K * B.
simp_mul(A, B, A * B).

% divisiones
simp_div(0, _, 0) :- !.
simp_div(A, 1, A) :- !.
simp_div(A, A, 1) :- !.
simp_div(A, B, Res) :-
    number(A), number(B),
    B =\= 0,
    0 =:= A mod B,
    !,
    Res is A // B.
simp_div(A, B, Res) :-
    number(A), number(B),
    B =\= 0,
    !,
    Res is A / B.
simp_div(-A, B, -(A / B)) :- !.
simp_div(A, -B, -(A / B)) :- !.
simp_div(A, B, A / B).

% potencias
simp_pow(_, 0, 1) :- !.
simp_pow(A, 1, A) :- !.
simp_pow(0, _, 0) :- !.
simp_pow(1, _, 1) :- !.
simp_pow(A, B, Res) :-
    number(A), number(B),
    B >= 0,
    B =:= floor(B),
    !,
    Res is A ^ B.
simp_pow(A, B, A ^ B).

% negativos
simp_neg(-A, A) :- !.
simp_neg(0, 0) :- !.
simp_neg(N, Res) :-
    number(N),
    !,
    Res is -N.
simp_neg(A, -A).


% evaluar con un numero

evaluar(_, N, Res) :-
    number(N),
    !,
    Res is float(N).

evaluar(Val, x, Res) :-
    !,
    Res is float(Val).

evaluar(Val, Var, Res) :-
    atom(Var),
    Var == x,
    !,
    Res is float(Val).

evaluar(_, pi, Res) :-
    !,
    Res is pi.

evaluar(_, e, Res) :-
    !,
    Res is exp(1).

evaluar(X, A + B, Res) :-
    evaluar(X, A, VA),
    evaluar(X, B, VB),
    Res is VA + VB,
    !.

evaluar(X, A - B, Res) :-
    evaluar(X, A, VA),
    evaluar(X, B, VB),
    Res is VA - VB,
    !.

evaluar(X, -A, Res) :-
    evaluar(X, A, VA),
    Res is -VA,
    !.

evaluar(X, A * B, Res) :-
    evaluar(X, A, VA),
    evaluar(X, B, VB),
    Res is VA * VB,
    !.

evaluar(X, A / B, Res) :-
    evaluar(X, A, VA),
    evaluar(X, B, VB),
    (   abs(VB) < 1.0e-12
    ->  throw(error(division_por_cero, context(evaluar/3, A / B)))
    ;   Res is VA / VB
    ),
    !.

evaluar(X, A ^ B, Res) :-
    evaluar(X, A, VA),
    evaluar(X, B, VB),
    Res is VA ** VB,
    !.

evaluar(X, abs(A), Res) :-
    evaluar(X, A, VA),
    Res is abs(VA),
    !.

evaluar(X, sqrt(A), Res) :-
    evaluar(X, A, VA),
    (   VA < 0.0
    ->  throw(error(raiz_de_negativo, context(evaluar/3, sqrt(A))))
    ;   Res is sqrt(VA)
    ),
    !.

evaluar(X, exp(A), Res) :-
    evaluar(X, A, VA),
    Res is exp(VA),
    !.

evaluar(X, ln(A), Res) :-
    evaluar(X, A, VA),
    (   VA =< 0.0
    ->  throw(error(logaritmo_no_positivo, context(evaluar/3, ln(A))))
    ;   Res is log(VA)
    ),
    !.

evaluar(X, log(A), Res) :-
    evaluar(X, ln(A), Res),
    !.

evaluar(X, sin(A), Res) :-
    evaluar(X, A, VA),
    Res is sin(VA),
    !.

evaluar(X, sen(A), Res) :-
    evaluar(X, sin(A), Res),
    !.

evaluar(X, cos(A), Res) :-
    evaluar(X, A, VA),
    Res is cos(VA),
    !.

evaluar(X, tan(A), Res) :-
    evaluar(X, A, VA),
    Res is tan(VA),
    !.

evaluar(X, tg(A), Res) :-
    evaluar(X, tan(A), Res),
    !.

evaluar(X, asin(A), Res) :-
    evaluar(X, A, VA),
    (   (VA < -1.000001 ; VA > 1.000001)
    ->  throw(error(dominio_asin, context(evaluar/3, asin(A))))
    ;   VAClamped is max(-1.0, min(1.0, VA)),
        Res is asin(VAClamped)
    ),
    !.

evaluar(X, arcsin(A), Res) :-
    evaluar(X, asin(A), Res),
    !.

evaluar(X, acos(A), Res) :-
    evaluar(X, A, VA),
    (   (VA < -1.000001 ; VA > 1.000001)
    ->  throw(error(dominio_acos, context(evaluar/3, acos(A))))
    ;   VAClamped is max(-1.0, min(1.0, VA)),
        Res is acos(VAClamped)
    ),
    !.

evaluar(X, arccos(A), Res) :-
    evaluar(X, acos(A), Res),
    !.

evaluar(X, atan(A), Res) :-
    evaluar(X, A, VA),
    Res is atan(VA),
    !.

evaluar(X, arctan(A), Res) :-
    evaluar(X, atan(A), Res),
    !.

evaluar(X, sinh(A), Res) :-
    evaluar(X, A, VA),
    Res is sinh(VA),
    !.

evaluar(X, sh(A), Res) :-
    evaluar(X, sinh(A), Res),
    !.

evaluar(X, cosh(A), Res) :-
    evaluar(X, A, VA),
    Res is cosh(VA),
    !.

evaluar(X, ch(A), Res) :-
    evaluar(X, cosh(A), Res),
    !.

evaluar(X, tanh(A), Res) :-
    evaluar(X, A, VA),
    Res is tanh(VA),
    !.

evaluar(X, th(A), Res) :-
    evaluar(X, tanh(A), Res),
    !.

evaluar(X, asinh(A), Res) :-
    evaluar(X, A, VA),
    Res is asinh(VA),
    !.

evaluar(X, arcsinh(A), Res) :-
    evaluar(X, asinh(A), Res),
    !.

evaluar(X, acosh(A), Res) :-
    evaluar(X, A, VA),
    (   VA < 0.999999
    ->  throw(error(dominio_acosh, context(evaluar/3, acosh(A))))
    ;   VAClamped is max(1.0, VA),
        Res is acosh(VAClamped)
    ),
    !.

evaluar(X, arccosh(A), Res) :-
    evaluar(X, acosh(A), Res),
    !.

evaluar(X, atanh(A), Res) :-
    evaluar(X, A, VA),
    (   (VA =< -1.0 ; VA >= 1.0)
    ->  throw(error(dominio_atanh, context(evaluar/3, atanh(A))))
    ;   Res is atanh(VA)
    ),
    !.

evaluar(X, arctanh(A), Res) :-
    evaluar(X, atanh(A), Res),
    !.

evaluar(_, Other, _) :-
    throw(error(evaluacion_no_soportada, context(evaluar/3, Other))).


% predicados principales

integrar(Var, Expresion, PrimitivaSimplificada) :-
    integrar(Var, Expresion, PrimitivaSimplificada, _).

integrar(Var, Expresion, PrimitivaSimplificada, Regla) :-
    s(Var, Expresion, Primitiva, Regla),
    simplificar(Primitiva, PrimitivaSimplificada).

area_bajo_curva(Var, Expresion, A, B, PrimitivaSimplificada, Area) :-
    integrar(Var, Expresion, PrimitivaSimplificada, _),
    evaluar(A, PrimitivaSimplificada, ValorA),
    evaluar(B, PrimitivaSimplificada, ValorB),
    Area is ValorB - ValorA.


% pasar a latex

to_latex(N, Str) :-
    number(N),
    !,
    format(string(Str), "~w", [N]).

to_latex(Var, Str) :-
    atom(Var),
    !,
    format(string(Str), "~w", [Var]).

to_latex(A + B, Str) :-
    to_latex(A, SA),
    to_latex(B, SB),
    format(string(Str), "~w + ~w", [SA, SB]),
    !.

to_latex(A - B, Str) :-
    to_latex(A, SA),
    to_latex_paren_if_needed(B, SB),
    format(string(Str), "~w - ~w", [SA, SB]),
    !.

to_latex(-A, Str) :-
    to_latex_paren_if_needed(A, SA),
    format(string(Str), "-~w", [SA]),
    !.

to_latex(A * B, Str) :-
    to_latex_mul_left(A, SA),
    to_latex_mul_right(B, SB),
    format(string(Str), "~w \\cdot ~w", [SA, SB]),
    !.

to_latex(A / B, Str) :-
    to_latex(A, SA),
    to_latex(B, SB),
    format(string(Str), "\\frac{~w}{~w}", [SA, SB]),
    !.

to_latex(A ^ B, Str) :-
    to_latex_paren_if_needed(A, SA),
    to_latex(B, SB),
    format(string(Str), "{~w}^{~w}", [SA, SB]),
    !.

to_latex(sqrt(A), Str) :-
    to_latex(A, SA),
    format(string(Str), "\\sqrt{~w}", [SA]),
    !.

to_latex(abs(A), Str) :-
    to_latex(A, SA),
    format(string(Str), "\\left|~w\\right|", [SA]),
    !.

to_latex(ln(A), Str) :-
    to_latex(A, SA),
    format(string(Str), "\\ln\\left(~w\\right)", [SA]),
    !.

to_latex(exp(A), Str) :-
    to_latex(A, SA),
    format(string(Str), "e^{~w}", [SA]),
    !.

to_latex(sin(A), Str) :-
    to_latex(A, SA),
    format(string(Str), "\\sin\\left(~w\\right)", [SA]),
    !.

to_latex(cos(A), Str) :-
    to_latex(A, SA),
    format(string(Str), "\\cos\\left(~w\\right)", [SA]),
    !.

to_latex(tan(A), Str) :-
    to_latex(A, SA),
    format(string(Str), "\\tan\\left(~w\\right)", [SA]),
    !.

to_latex(asin(A), Str) :-
    to_latex(A, SA),
    format(string(Str), "\\arcsin\\left(~w\\right)", [SA]),
    !.

to_latex(acos(A), Str) :-
    to_latex(A, SA),
    format(string(Str), "\\arccos\\left(~w\\right)", [SA]),
    !.

to_latex(atan(A), Str) :-
    to_latex(A, SA),
    format(string(Str), "\\arctan\\left(~w\\right)", [SA]),
    !.

to_latex(sinh(A), Str) :-
    to_latex(A, SA),
    format(string(Str), "\\sinh\\left(~w\\right)", [SA]),
    !.

to_latex(cosh(A), Str) :-
    to_latex(A, SA),
    format(string(Str), "\\cosh\\left(~w\\right)", [SA]),
    !.

to_latex(tanh(A), Str) :-
    to_latex(A, SA),
    format(string(Str), "\\tanh\\left(~w\\right)", [SA]),
    !.

to_latex(arcsinh(A), Str) :-
    to_latex(A, SA),
    format(string(Str), "\\operatorname{arcsinh}\\left(~w\\right)", [SA]),
    !.

to_latex(arccosh(A), Str) :-
    to_latex(A, SA),
    format(string(Str), "\\operatorname{arccosh}\\left(~w\\right)", [SA]),
    !.

to_latex(arctanh(A), Str) :-
    to_latex(A, SA),
    format(string(Str), "\\operatorname{arctanh}\\left(~w\\right)", [SA]),
    !.

to_latex(Term, Str) :-
    format(string(Str), "~w", [Term]).

to_latex_paren_if_needed(T, Str) :-
    (   T = _ + _ ; T = _ - _ ; T = -_  )
    ->  to_latex(T, Inner),
        format(string(Str), "\\left(~w\\right)", [Inner])
    ;   to_latex(T, Str).

to_latex_mul_left(T, Str) :-
    (   T = _ + _ ; T = _ - _ ; T = -_  )
    ->  to_latex(T, Inner),
        format(string(Str), "\\left(~w\\right)", [Inner])
    ;   to_latex(T, Str).

to_latex_mul_right(T, Str) :-
    (   T = _ + _ ; T = _ - _ ; T = -_  )
    ->  to_latex(T, Inner),
        format(string(Str), "\\left(~w\\right)", [Inner])
    ;   to_latex(T, Str).


% entrada de la api

resolver(ExprStr, AVal, BVal, Dict) :-
    catch(
        resolver_seguro(ExprStr, AVal, BVal, Dict),
        Error,
        manejar_error(Error, Dict)
    ).

resolver_seguro(ExprStr, AVal, BVal, Dict) :-
    term_string(Term, ExprStr),
    integrar(x, Term, Primitiva, Regla),
    term_string(Primitiva, PrimitivaStr),
    to_latex(Primitiva, PrimitivaLatex),
    to_latex(Term, IntegrandoLatex),
    
    (   (nonvar(AVal), nonvar(BVal), AVal \== null, BVal \== null, AVal \== "", BVal \== "")
    ->  evaluar_limite(AVal, NumA),
        evaluar_limite(BVal, NumB),
        evaluar(NumA, Primitiva, Fa),
        evaluar(NumB, Primitiva, Fb),
        Area is Fb - Fa,
        format(string(BarrowLatex), "F(~w) - F(~w) = ~4f - (~4f) = ~4f", [NumB, NumA, Fb, Fa, Area]),
        Dict = _{
            success: true,
            expr: ExprStr,
            integrando_latex: IntegrandoLatex,
            antiderivative: PrimitivaStr,
            antiderivative_latex: PrimitivaLatex,
            rule: Regla,
            has_limits: true,
            a: NumA,
            b: NumB,
            fa: Fa,
            fb: Fb,
            area: Area,
            barrow_latex: BarrowLatex
        }
    ;   Dict = _{
            success: true,
            expr: ExprStr,
            integrando_latex: IntegrandoLatex,
            antiderivative: PrimitivaStr,
            antiderivative_latex: PrimitivaLatex,
            rule: Regla,
            has_limits: false,
            area: null
        }
    ).

evaluar_limite(Num, Num) :- number(Num), !.
evaluar_limite(Str, Num) :-
    string(Str),
    term_string(Term, Str),
    evaluar(0, Term, Num),
    !.
evaluar_limite(Atom, Num) :-
    atom(Atom),
    term_string(Term, Atom),
    evaluar(0, Term, Num),
    !.

manejar_error(error(syntax_error(Desc), _), _{success: false, error: Msg}) :-
    format(string(Msg), "Error de sintaxis en la expresion matematica: ~w", [Desc]),
    !.
manejar_error(error(integral_no_soportada, context(_, Expr)), _{success: false, error: Msg}) :-
    format(string(Msg), "La expresion '~w' no esta en la base de conocimientos o requiere metodos avanzados.", [Expr]),
    !.
manejar_error(error(division_por_cero, _), _{success: false, error: "Division por cero detectada durante la evaluacion en los limites."}) :- !.
manejar_error(error(raiz_de_negativo, _), _{success: false, error: "Raiz cuadrada de numero negativo fuera del dominio real."}) :- !.
manejar_error(error(logaritmo_no_positivo, _), _{success: false, error: "Logaritmo evaluado en valor no positivo (menor o igual a cero)."}) :- !.
manejar_error(error(dominio_asin, _), _{success: false, error: "Argumento de arcsin(x) fuera del dominio real [-1, 1]."}) :- !.
manejar_error(error(dominio_acos, _), _{success: false, error: "Argumento de arccos(x) fuera del dominio real [-1, 1]."}) :- !.
manejar_error(error(dominio_acosh, _), _{success: false, error: "Argumento de arccosh(x) fuera del dominio real [1, ∞)."}) :- !.
manejar_error(error(dominio_atanh, _), _{success: false, error: "Argumento de arctanh(x) fuera del dominio real (-1, 1)."}) :- !.
manejar_error(Error, _{success: false, error: Msg}) :-
    format(string(Msg), "Error inesperado al resolver la integral: ~w", [Error]).

% para correrlo desde consola
resolver_json(ExprStr, AVal, BVal, JSONString) :-
    resolver(ExprStr, AVal, BVal, Dict),
    atom_json_dict(JSONAtom, Dict, [as(string)]),
    string_to_atom(JSONString, JSONAtom).
