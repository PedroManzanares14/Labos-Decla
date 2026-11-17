# Laboratorio 5: calculo simbolico

El archivo [calculo.pl](calculo.pl) implementa derivadas e integrales indefinidas
mediante reglas de Prolog. Tambien incluye evaluacion numerica y calculo del area
firmada bajo una curva entre dos limites.

## Ejecucion

Desde SWI-Prolog:

```prolog
?- [calculo].
true.
```

## Derivadas

```prolog
?- d(x, 5, Resultado).
Resultado = 0.

?- d(x, x^3, Resultado).
Resultado = 3*x^2.

?- d(x, 3*x^2 + log(x), Resultado).
Resultado = 3*(2*x^1) + 1/x.
```

Las reglas contemplan constantes, la variable, potencias, logaritmo natural,
suma, resta y constantes por funcion.

## Integrales

```prolog
?- s(x, 3*x^2 + 4, Resultado).
Resultado = 3*(1/3*x^3) + 4*x.
```

La integral de `x^-1` no se incluye en esta version porque requiere una regla
especial para `log(x)`.

## Evaluacion y area

`evaluar/3` recibe el valor de `X`, la expresion y devuelve el resultado numerico:

```prolog
?- evaluar(2, 3*x^2 + 1, Resultado).
Resultado = 13.
```

`area/5` integra simbolicamente y evalua la primitiva en ambos limites:

```prolog
?- area(x, x^2, 0, 2, Resultado).
Resultado = 2.6666666666666665.
```

El resultado es el area firmada; para una funcion negativa o limites invertidos
puede ser negativo.
