# Ejercicios progresivos de Verilog — Cap. 1 + sincronización/pipeline

Sin soluciones — la idea es que los resuelvas vos y los revisamos juntos, como veníamos haciendo con `multi_compuerta`.

---

## Nivel 1 — Fundamentos (una sola compuerta)

**1.1 —** Módulo con 2 entradas (`a`, `b`) y 1 salida (`y`) que implemente un AND simple. Practicá la sintaxis mínima: declaración de puertos + un solo `assign`.

**1.2 —** Igual que el anterior pero con OR.

**1.3 —** Módulo con 1 entrada y 1 salida que implemente un NOT.

**1.4 —** Módulo con 2 entradas y 1 salida que implemente un XOR **sin usar el operador `^`** — solo con `&`, `|` y `~` (repasar la expresión de suma de productos).

---

## Nivel 2 — Varias compuertas combinadas

**2.1 —** 3 entradas (`a,b,c`), 1 salida. La salida es 1 solo si **las tres** entradas coinciden (las tres en 0, o las tres en 1). Usá señales internas (`wire`) para los términos intermedios, como hicimos con `e`, `d`, `t`, `r` en `multi_compuerta`.

**2.2 —** 4 entradas, 1 salida. Implementá la función `y = (a & b) | (c & ~d)`. Declarar explícitamente cada señal intermedia (nada de expresiones gigantes en un solo `assign`).

**2.3 —** Mismo circuito que 2.2, pero ahora con **2 salidas**: la salida original `y`, y una segunda salida `y_n` que sea la negada de `y`. Pensalo en términos de "¿cuántas piezas de hardware necesito y cómo las conecto?", no en términos de código.

---

## Nivel 3 — Multi-bit / buses

**3.1 —** Comparador de igualdad de 2 bits (el ejemplo del capítulo 1) armado **vos mismo** desde cero, sin mirar el ejemplo — con puertos `[1:0] a, b` y salida `aeqb`.

**3.2 —** Mismo comparador de 2 bits, pero ahora armado con **descripción estructural**: instanciá dos comparadores de 1 bit (los que armaste en 1.4 o similar) y combiná sus resultados con un AND, en vez de escribir la expresión de suma de productos completa.

**3.3 —** Comparador de "mayor que" de 2 bits: salida `gt` que vale 1 si `a > b` (con `a`, `b` de 2 bits). Pensalo primero en papel con tabla de verdad antes de escribir el Verilog.

---

## Nivel 4 — Sincronización con flip-flops (lo que vimos en `multi_compuerta`)

**4.1 —** Tomá el circuito del ejercicio 2.1 (el de "3 entradas coinciden") y agregale **un solo registro de entrada**: las 3 entradas se sincronizan con `always @(posedge clk)` antes de entrar al combinacional, tal como hicimos con `q1-q4` al principio.

**4.2 —** Igual que 4.1, pero agregale también **reset síncrono** que ponga los registros en 0.

**4.3 —** Tomá el circuito de 3.1 (comparador de 2 bits) y armá un **pipeline de 2 etapas** igual al que hicimos en `multi_compuerta`: registro de entrada → combinacional → registro de salida. Acordate de los cambios de `wire`/`reg` en los puertos que tuvimos que hacer.

---

## Nivel 5 — Un poco más de desafío

**5.1 —** Circuito con 4 entradas (`a,b,c,d`) y **2 salidas** (`x,y`), donde `x` e `y` comparten parte de la lógica combinacional (por ejemplo, ambas usan el mismo término `a & b` en algún punto). Armalo con **pipeline de 2 etapas** como en `multi_compuerta`, prestando atención a que la señal compartida solo se calcule una vez (no la dupliques).

**5.2 —** Extendé el ejercicio 4.3 (comparador de 2 bits en pipeline) a un **pipeline de 3 etapas**: agregá una etapa de registro extra en el medio, entre dos partes del combinacional (por ejemplo, registrar los resultados parciales `p0,p1,p2,p3` antes de combinarlos en el OR final). Fijate cómo cambia la latencia total en ciclos de clock respecto al pipeline de 2 etapas.

**5.3 (el más largo) —** Armá un módulo con 4 entradas (`a,b,c,d`) que calcule **dos funciones lógicas independientes** en pipeline de 2 etapas, y después escribile un testbench con barrido exhaustivo (como el que armamos para `multi_compuerta`) que además **verifique automáticamente** con `if`/`$display` si la salida obtenida en cada ciclo coincide con la esperada — teniendo en cuenta el desfasaje de 2 ciclos por la latencia del pipeline. Este último punto (la verificación automática) todavía no lo vimos en detalle, así que si llegás hasta acá avisame y lo armamos juntos.

---

### Cómo te recomiendo abordarlos

Andá de a uno, empezando por el 1.1, y mandame tu código igual que veníamos haciendo — yo no te tiro la solución, te voy marcando qué está bien y qué falta corregir, para que llegues vos a la versión final. Si en algún ejercicio te trabás con un concepto puntual (por ejemplo, cómo declarar el reset síncrono), avisame y lo repasamos antes de que sigas.