% Pedro Jose Manzanarres Santos 00230422

:- use_module('integrales').

% prueba todas las reglas de la tarea
test_todos :-
    writeln('===================================================='),
    writeln('INICIANDO PRUEBAS DE LAS 22 REGLAS DEL PROYECTO'),
    writeln('===================================================='),
    
    test_caso('a) k dx', '5', 0, 2),
    test_caso('b) x dx', 'x', 0, 2),
    test_caso('c) (k * x) dx', '3 * x', 0, 2),
    test_caso('d) x^n dx (n=3)', 'x ^ 3', 1, 3),
    test_caso('d) x^n dx (n=-1)', 'x ^ -1', 1, 2),
    test_caso('e) u dx (polinomio)', 'x^2 + 2*x + 1', 0, 1),
    test_caso('f) (k * u) dx', '4 * sin(x)', 0, 3.14159),
    test_caso('g) (u + v) dx', 'sin(x) + cos(x)', 0, 1.570796),
    test_caso('h) (u - v) dx', 'cosh(x) - sinh(x)', 0, 1),
    test_caso('i) a^x dx (e^x)', 'e ^ x', 0, 1),
    test_caso('i) a^x dx (2^x)', '2 ^ x', 0, 3),
    test_caso('j) a^u dx (e^(2*x))', 'e ^ (2 * x)', 0, 1),
    test_caso('k) sin(x) dx', 'sin(x)', 0, 3.14159265),
    test_caso('l) cos(x) dx', 'cos(x)', 0, 1.57079632),
    test_caso('m) tan(x) dx', 'tan(x)', 0, 0.785398),
    test_caso('n) asin(x) dx', 'asin(x)', 0, 0.5),
    test_caso('o) acos(x) dx', 'acos(x)', 0, 0.5),
    test_caso('p) atan(x) dx', 'atan(x)', 0, 1),
    test_caso('q) sh(x) dx', 'sh(x)', 0, 1),
    test_caso('r) cosh(x) dx', 'cosh(x)', 0, 1),
    test_caso('s) tanh(x) dx', 'tanh(x)', 0, 1),
    test_caso('t) arcsinh(x) dx', 'arcsinh(x)', 0, 1),
    test_caso('u) arccosh(x) dx', 'arccosh(x)', 1, 2),
    test_caso('v) arctanh(x) dx', 'arctanh(x)', 0, 0.5),

    writeln('===================================================='),
    writeln('TODAS LAS 22 REGLAS COMPLETADAS EXITOSAMENTE'),
    writeln('====================================================').

test_caso(Etiqueta, Expr, A, B) :-
    format('[TEST] ~w con f(x) = ~w en [~w, ~w]~n', [Etiqueta, Expr, A, B]),
    resolver(Expr, A, B, Dict),
    (   Dict.success == true
    ->  format('   -> Primitiva: ~w~n', [Dict.antiderivative]),
        format('   -> Latex:     ~w~n', [Dict.antiderivative_latex]),
        format('   -> Regla:     ~w~n', [Dict.rule]),
        format('   -> Area [~w,~w]: ~4f~n~n', [A, B, Dict.area])
    ;   format('   [ERROR] Fallo: ~w~n~n', [Dict.error]),
        fail
    ).

:- initialization(test_todos, main).
