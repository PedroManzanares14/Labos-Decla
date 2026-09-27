% Cuenta los digitos decimales de un numero entero.

contar_digitos(Numero, Cantidad) :-
    integer(Numero),
    NumeroAbsoluto is abs(Numero),
    contar_digitos_aux(NumeroAbsoluto, Cantidad).

contar_digitos_aux(Numero, 1) :-
    Numero < 10.

contar_digitos_aux(Numero, Cantidad) :-
    Numero >= 10,
    NumeroReducido is Numero // 10,
    contar_digitos_aux(NumeroReducido, CantidadParcial),
    Cantidad is CantidadParcial + 1.