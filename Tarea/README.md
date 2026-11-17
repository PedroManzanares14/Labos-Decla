# 📐 Tarea proyecto: Sistema Experto de Integrales

**Nombre:** Pedro Jose Manzanares Santos  
**Carrera:** Ing. Informatica  
**Materia:** Programacion declarativa  
**Actividad:** Tarea proyecto  
**Ciclo:** 02 2026

## Sobre el proyecto

Este proyecto lo fui armando para resolver integrales usando reglas declarativas en
**SWI-Prolog**. Ademas de mostrar la primitiva, agregue el calculo del area entre
dos limites y una interfaz web para probar las expresiones sin tener que escribir
las consultas directamente en Prolog.

La parte visual esta hecha con **JavaScript puro**, HTML5 Canvas y KaTeX. La idea
fue dejar una pagina sencilla para meter una funcion, ver el resultado y revisar
la grafica.

---

## Lo que fue agregando

1. **Base de conocimiento en SWI-Prolog**:
   - Resuelve **todas las 22 reglas oficiales (a - v)** del enunciado, no solo las 12 mínimas.
   - Motor de **simplificación algebraica automática** (identidades aditivas, multiplicativas, signos y potencias).
   - Motor de **evaluación numérica y Teorema Fundamental del Cálculo** (Regla de Barrow: $F(b) - F(a)$).
   - Generación automática de expresiones en **LaTeX** y términos canónicos de Prolog.
   - Validación robusta de dominio matemático (división por cero, logaritmos no positivos, raíces de negativos, dominios de funciones trigonométricas e hiperbólicas inversas).

2. **Interfaz web en JavaScript puro**:
   - **Renderizado matemático de alta fidelidad** con KaTeX en tiempo real mientras el usuario escribe.
   - **Graficador geométrico interactivo en Canvas 2D**:
     - Traza la curva $f(x)$ de forma continua con soporte High-DPI (Retina/4K).
     - Sombrea el área exacta bajo la curva entre los límites $[a, b]$.
     - Líneas delimitadoras verticales en $x = a$ y $x = b$ con insignias visuales.
     - Zoom interactivo (con rueda del ratón o botones) y desplazamiento continuo (Pan con arrastre).
     - Tooltip interactivo con coordenadas $(x, f(x))$ al pasar el ratón.
   - **Teclado matemático virtual**: atajos de 1 clic para símbolos comunes (`^`, `√`, `π`, `sin`, `cos`, `sh`, `asinh`, etc.).
   - **Catálogo de los 22 casos oficiales**: prueba instantánea de cada una de las 22 integrales del PDF con 1 solo clic.
   - **Historial de consultas**: guarda cálculos recientes en el navegador (`localStorage`).
   - **Modo Oscuro / Modo Claro** con transición suave.

3. **Dos formas de levantarlo**:
   - **Modo Nativo SWI-Prolog**: servidor HTTP embebido en Prolog (`backend/server.pl`), cero dependencias externas.
   - **Modo Node.js**: servidor ligero (`server.js`) que ejecuta SWI-Prolog por CLI, ideal para entornos automatizados.

---

## Como quedo organizado

```text
C:\Users\pedro\OneDrive\Documents\Labos-Decla\Tarea\
├── backend/
│   ├── integrales.pl     # Base de conocimiento (reglas s/4, evaluación, simplificación, LaTeX)
│   ├── server.pl         # Servidor HTTP nativo en SWI-Prolog
│   └── tests.pl          # Suite de pruebas automatizadas de las 22 reglas
├── frontend/
│   ├── index.html        # Estructura de la interfaz de usuario
│   ├── css/
│   │   └── styles.css    # Estilos modernos, responsivos y temas claro/oscuro
│   └── js/
│       ├── app.js        # Lógica de interacción, KaTeX, peticiones API e historial
│       └── graph.js      # Graficador interactivo 2D en Canvas HTML5
├── server.js             # Servidor alternativo en Node.js (cero npm install requerido)
├── package.json          # Metadatos del proyecto y comandos npm
├── iniciar.bat           # Script de inicio en 1 clic para Windows con SWI-Prolog
├── iniciar_node.bat      # Script alternativo con Node.js
└── README.md             # Notas del proyecto
```

---

## Como se ejecuta

### Opción A: Directo con SWI-Prolog
Haz doble clic sobre el archivo:
```text
iniciar.bat
```
O desde la terminal PowerShell / CMD:
```powershell
swipl -s backend/server.pl
```
El servidor queda en `http://localhost:8080/` y el script intenta abrirlo en el navegador.

---

### Opción B: Con Node.js
Haz doble clic sobre el archivo:
```text
iniciar_node.bat
```
O desde la terminal:
```powershell
node server.js
```
El servidor queda en `http://localhost:8080/` y se comunica con SWI-Prolog por la consola.

---

## Pruebas utilizadas para revisar el proyecto

Para revisar que las reglas principales sigan funcionando:

```powershell
swipl -s backend/tests.pl
```

Salida esperada:
```text
====================================================
INICIANDO PRUEBAS DE LAS 22 REGLAS DEL PROYECTO
====================================================
[TEST] a) k dx con f(x) = 5 en [0, 2] -> Area: 10.0000
[TEST] b) x dx con f(x) = x en [0, 2] -> Area: 2.0000
[TEST] c) (k * x) dx con f(x) = 3 * x en [0, 2] -> Area: 6.0000
[TEST] d) x^n dx (n=3) con f(x) = x ^ 3 en [1, 3] -> Area: 20.0000
[TEST] d) x^n dx (n=-1) con f(x) = x ^ -1 en [1, 2] -> Area: 0.6931
[TEST] e) u dx (polinomio) con f(x) = x^2 + 2*x + 1 en [0, 1] -> Area: 2.3333
[TEST] f) (k * u) dx con f(x) = 4 * sin(x) en [0, 3.14159] -> Area: 8.0000
[TEST] g) (u + v) dx con f(x) = sin(x) + cos(x) en [0, 1.570796] -> Area: 2.0000
[TEST] h) (u - v) dx con f(x) = cosh(x) - sinh(x) en [0, 1] -> Area: 0.6321
[TEST] i) a^x dx (e^x) con f(x) = e ^ x en [0, 1] -> Area: 1.7183
[TEST] i) a^x dx (2^x) con f(x) = 2 ^ x en [0, 3] -> Area: 10.0989
[TEST] j) a^u dx (e^(2*x)) con f(x) = e ^ (2 * x) en [0, 1] -> Area: 3.1945
[TEST] k) sin(x) dx con f(x) = sin(x) en [0, 3.14159265] -> Area: 2.0000
[TEST] l) cos(x) dx con f(x) = cos(x) en [0, 1.57079632] -> Area: 1.0000
[TEST] m) tan(x) dx con f(x) = tan(x) en [0, 0.785398] -> Area: 0.3466
[TEST] n) asin(x) dx con f(x) = asin(x) en [0, 0.5] -> Area: 0.1278
[TEST] o) acos(x) dx con f(x) = acos(x) en [0, 0.5] -> Area: 0.6576
[TEST] p) atan(x) dx con f(x) = atan(x) en [0, 1] -> Area: 0.4388
[TEST] q) sh(x) dx con f(x) = sh(x) en [0, 1] -> Area: 0.5431
[TEST] r) cosh(x) dx con f(x) = cosh(x) en [0, 1] -> Area: 1.1752
[TEST] s) tanh(x) dx con f(x) = tanh(x) en [0, 1] -> Area: 0.4338
[TEST] t) arcsinh(x) dx con f(x) = arcsinh(x) en [0, 1] -> Area: 0.4672
[TEST] u) arccosh(x) dx con f(x) = arccosh(x) en [1, 2] -> Area: 0.9019
[TEST] v) arctanh(x) dx con f(x) = arctanh(x) en [0, 0.5] -> Area: 0.1308
====================================================
TODAS LAS 22 REGLAS COMPLETADAS EXITOSAMENTE
====================================================
```

---

## Reglas implementadas

| Inciso | Descripción Oficial | Entrada Ejemplo | Primitiva $F(x)$ |
|:---:|:---|:---|:---|
| **a** | $\int k \, dx$, donde $k$ es constante | `5` | $5x$ |
| **b** | $\int x \, dx$ | `x` | $\frac{x^2}{2}$ |
| **c** | $\int (k * x) \, dx$, donde $k$ es constante | `3 * x` | $3 \cdot \frac{x^2}{2}$ |
| **d** | $\int x^n \, dx$, donde $n$ es número | `x ^ 3` ó `1 / x` | $\frac{x^{n+1}}{n+1}$ ó $\ln\|x\|$ |
| **e** | $\int u \, dx$, donde $u$ es función de $x$ | `x^2 + 2*x + 1` | $\frac{x^3}{3} + x^2 + x$ |
| **f** | $\int (k * u) \, dx$ | `4 * sin(x)` | $4 \cdot (-\cos(x))$ |
| **g** | $\int (u + v) \, dx$ | `sin(x) + cos(x)` | $-\cos(x) + \sin(x)$ |
| **h** | $\int (u - v) \, dx$ | `cosh(x) - sinh(x)` | $\sinh(x) - \cosh(x)$ |
| **i** | $\int a^x \, dx$ | `e ^ x` ó `2 ^ x` | $e^x$ ó $\frac{2^x}{\ln(2)}$ |
| **j** | $\int a^u \, dx$, donde $u$ es lineal | `e ^ (2 * x)` | $\frac{e^{2x}}{2}$ |
| **k** | $\int \sin(x) \, dx$ | `sin(x)` | $-\cos(x)$ |
| **l** | $\int \cos(x) \, dx$ | `cos(x)` | $\sin(x)$ |
| **m** | $\int \tan(x) \, dx$ | `tan(x)` | $-\ln\|\cos(x)\|$ |
| **n** | $\int \arcsin(x) \, dx$ | `asin(x)` | $x \arcsin(x) + \sqrt{1 - x^2}$ |
| **o** | $\int \arccos(x) \, dx$ | `acos(x)` | $x \arccos(x) - \sqrt{1 - x^2}$ |
| **p** | $\int \arctan(x) \, dx$ | `atan(x)` | $x \arctan(x) - \frac{1}{2}\ln(1 + x^2)$ |
| **q** | $\int \operatorname{sh}(x) \, dx$ | `sh(x)` | $\cosh(x)$ |
| **r** | $\int \cosh(x) \, dx$ | `cosh(x)` | $\sinh(x)$ |
| **s** | $\int \tanh(x) \, dx$ | `tanh(x)` | $\ln(\cosh(x))$ |
| **t** | $\int \operatorname{arcsinh}(x) \, dx$ | `arcsinh(x)` | $x \operatorname{arcsinh}(x) - \sqrt{x^2 + 1}$ |
| **u** | $\int \operatorname{arccosh}(x) \, dx$ | `arccosh(x)` | $x \operatorname{arccosh}(x) - \sqrt{x^2 - 1}$ |
| **v** | $\int \operatorname{arctanh}(x) \, dx$ | `arctanh(x)` | $x \operatorname{arctanh}(x) + \frac{1}{2}\ln\|1 - x^2\|$ |
