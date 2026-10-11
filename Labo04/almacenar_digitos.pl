% Almacena los digitos de un numero en una lista, de derecha a izquierda.

almacenar(Numero, Digitos) :-
    integer(Numero),
    NumeroAbsoluto is abs(Numero),
    almacenar_digitos_aux(NumeroAbsoluto, Digitos).

almacenar_digitos_aux(Numero, [Numero]) :-
    Numero < 10.

almacenar_digitos_aux(Numero, [Digito|Digitos]) :-
    Numero >= 10,
    Digito is Numero mod 10,
    NumeroReducido is Numero // 10,
    almacenar_digitos_aux(NumeroReducido, Digitos).