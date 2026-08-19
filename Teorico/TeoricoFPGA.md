# Capítulo 1 — Circuitos combinacionales a nivel de compuerta (Verilog)

> Basado en el Capítulo 1 de *FPGA Prototyping by Verilog Examples*. Este documento reformula y amplía los conceptos con explicaciones propias y ejemplos originales — no reproduce el texto del libro.

## 1. Introducción a Verilog

Verilog es un **lenguaje de descripción de hardware**. Aunque su sintaxis se parece a la de C, su semántica es completamente distinta: en C las instrucciones se ejecutan **secuencialmente**, una después de la otra. En Verilog, en cambio, cada bloque de código representa una **pieza física de hardware** que existe y opera **en paralelo** con todas las demás. Esto es la idea más importante para no confundirse nunca en la materia:

> **No estás escribiendo un programa que se ejecuta. Estás describiendo un circuito que existe.**

## 2. Elementos léxicos básicos

- **Identificadores**: nombres de señales, módulos, etc. (`iO`, `eq`, `q1`). Deben empezar con letra o `_`. Pueden tener letras, números, `_` y `$`.
- **Verilog es case-sensitive**: `dato`, `Dato` y `DATO` son tres señales distintas. Conviene evitar esta ambigüedad usando siempre el mismo criterio de nombres.
- **Comentarios**: `// comentario de una línea` y `/* comentario de varias líneas */`.
- **Espacios en blanco**: se usan libremente para dar formato, no tienen efecto funcional.

## 3. Tipos de datos

### 3.1 Sistema de cuatro valores

Cada señal en Verilog puede tomar uno de estos 4 valores (no solo 0 y 1 como uno esperaría):

| Valor | Significado |
|---|---|
| `0` | lógico bajo / falso |
| `1` | lógico alto / verdadero |
| `z` | alta impedancia (típico de buffers tri-state) |
| `x` | valor desconocido (señal sin inicializar, conflicto de manejo de bus, etc.) |

Esto es clave para simulación: si en tu testbench ves una señal en `x`, generalmente significa que te olvidaste de inicializarla o que hay dos cosas manejando el mismo `wire` a la vez.

### 3.2 Grupo *net* vs. grupo *variable*

**Grupo *net*** (el más usado: `wire`): representa una **conexión física**, como un cable. No "guarda" nada por sí mismo — su valor es simplemente lo que la lógica que lo maneja (un `assign`, o la salida de otro módulo) le está poniendo en ese instante. Se usa como salida de **asignaciones continuas** (`assign`).

```verilog
wire e;
assign e = A & B;   // e siempre vale A&B, instantáneamente (con delay de propagación)
```

**Grupo *variable*** (el más usado: `reg`): representa **almacenamiento abstracto**. Se usa como salida de **asignaciones procedurales**, es decir, dentro de un bloque `always` o `initial`. Ojo — el nombre `reg` es engañoso: no todo `reg` se convierte en un flip-flop físico. Si el `always` es combinacional (`always @(*)`), el `reg` puede sintetizarse como simple cableado. Si el `always` es secuencial (`always @(posedge clk)`), ahí sí infiere un registro físico real — que es exactamente lo que armamos en tus ejercicios de sincronización.

Regla práctica para no confundirte (la misma que fuimos aplicando en tus ejercicios):
- ¿Lo asigna un `assign`? → tiene que ser `wire`.
- ¿Lo asigna algo dentro de un `always` o `initial`? → tiene que ser `reg`.
- Un `input` de un módulo siempre es `wire` (no se le puede asignar valor desde adentro).
- Un `output` puede ser `wire` (si lo maneja un `assign`) o `reg` (si lo maneja un `always`) — como cuando cambiaste `x` e `y` de `output wire` a `output reg` para poder registrarlas dentro del `always @(posedge clk)`.

### 3.3 Buses y memorias (arreglos)

Un grupo de señales relacionadas se declara como vector:

```verilog
wire [7:0] dato_a, dato_b;  // dos buses de 8 bits
wire [31:0] direccion;      // bus de 32 bits
```

Se prefiere siempre el orden **descendente** `[7:0]` (bit más significativo primero) sobre el ascendente `[0:7]`, para que el índice más alto coincida con el MSB — es la convención estándar.

Una memoria (arreglo bidimensional) se declara como un vector de vectores:

```verilog
reg [7:0] memoria [0:255];  // 256 palabras de 8 bits cada una
```

### 3.4 Representación de números

Formato general de una constante:

```
[tamaño]'[base][valor]
```

- Base: `b`/`B` binario, `o`/`O` octal, `h`/`H` hexadecimal, `d`/`D` decimal.
- El tamaño (en bits) es opcional. Si se omite, es un **número sin tamaño** (usa al menos 32 bits por defecto).

Ejemplos:

```verilog
4'b1010     // 4 bits, binario: 1010
8'hFF       // 8 bits, hexadecimal: 11111111
8'd25       // 8 bits, decimal: 00011001
5'b1        // 5 bits, se rellena con ceros a la izquierda: 00001
```

Un detalle importante para simulación: si el bit más significativo del valor es `x` o `z`, el relleno se hace con `x` o `z` (no con `0`) — así el simulador te avisa cuando algo no está bien definido en vez de esconderlo con ceros.

### 3.5 Operadores (nivel de compuerta)

Para describir circuitos a nivel de compuerta (como tu `multi_compuerta`), alcanza con los operadores bit a bit:

| Operador | Función |
|---|---|
| `~` | NOT |
| `&` | AND |
| `\|` | OR |
| `^` | XOR |

Cada uno de estos, usado en un `assign`, infiere directamente una compuerta física de ese tipo. El resto de los operadores de Verilog (aritméticos, relacionales, de reducción, etc.) se ven más adelante cuando se trabaja a nivel de transferencia de registros (RTL), no a nivel de compuerta.

## 4. Esqueleto de un programa Verilog

Todo módulo sigue básicamente esta estructura de tres partes:

```verilog
module nombre_modulo (
    // 1) declaración de puertos
    input  wire a, b,
    output wire salida
);

    // 2) declaración de señales internas
    wire señal_interna;

    // 3) cuerpo del módulo
    assign señal_interna = a & b;
    assign salida = ~señal_interna;

endmodule
```

### 4.1 Declaración de puertos

Cada puerto tiene un **modo** (`input`, `output`, o `inout` para bidireccional) y un **tipo de dato** (que se puede omitir si es `wire`, ya que es el tipo por defecto).

```verilog
module comparador (
    input  wire i0, i1,
    output wire eq
);
```

### 4.2 Cuerpo del módulo

Hay tres formas de describir una "pieza de circuito" dentro del cuerpo, y las tres pueden convivir en el mismo módulo:

1. **Asignación continua** (`assign`) — la que venís usando para el combinacional.
2. **Bloque `always`** — para lógica más compleja o secuencial (lo vimos con el `always @(posedge clk)` de tus flip-flops).
3. **Instanciación de módulo** — incorporar otro módulo ya diseñado como sub-bloque (lo vemos en la sección 5).

Como cada `assign` es una pieza de hardware independiente y todas operan en paralelo, **el orden en que las escribís no importa** — es una diferencia clave respecto a programar en C.

### 4.3 Declaración de señales internas

Las señales que conectan las distintas piezas del circuito (pero que no son ni entrada ni salida del módulo) se declaran aparte, con la sintaxis:

```verilog
[tipo-de-dato] [nombres-de-señal];
```

Por ejemplo, en tu `multi_compuerta`, las señales `e`, `d`, `t`, `r` son exactamente esto: cableado interno entre las compuertas, ninguna es puerto del módulo.

> **Nota (net implícita):** si declarás una señal sin especificar su tipo, Verilog asume por defecto que es `wire`. Esto se llama *implicit net*. No es buena práctica: si escribís mal el nombre de una señal en algún lado, el simulador crea silenciosamente una nueva señal en vez de avisarte del error de tipeo. Por eso siempre conviene declarar explícitamente todo.

### 4.4 Ejemplo: comparador de 1 bit

Un ejemplo clásico para fijar estos conceptos es un comparador de igualdad de 1 bit: la salida `eq` vale 1 solo si `i0` e `i1` valen lo mismo. La expresión lógica en suma de productos es:

```
eq = (~i0 & ~i1) | (i0 & i1)
```

Y el código:

```verilog
module comparador_1bit (
    input  wire i0, i1,
    output wire eq
);

    wire p0, p1;

    assign p0 = ~i0 & ~i1;  // ambos en 0
    assign p1 =  i0 &  i1;  // ambos en 1
    assign eq = p0 | p1;

endmodule
```

Cada `assign` es una pieza de hardware separada: dos AND (con NOTs adelante) y un OR, conectados entre sí por los nombres `p0` y `p1` — igual que en el diagrama de bloques que armarías a mano en papel.

### 4.5 Extendiendo a más bits

Para extender esta idea a un comparador de 2 bits, los puertos se declaran como vectores y se arma la expresión bit a bit:

```verilog
module comparador_2bit (
    input  wire [1:0] a, b,
    output wire aeqb
);

    wire p0, p1, p2, p3;

    assign p0 = (~a[1] & ~b[1]) & (~a[0] & ~b[0]);
    assign p1 = (~a[1] & ~b[1]) & ( a[0] &  b[0]);
    assign p2 = ( a[1] &  b[1]) & (~a[0] & ~b[0]);
    assign p3 = ( a[1] &  b[1]) & ( a[0] &  b[0]);

    assign aeqb = p0 | p1 | p2 | p3;

endmodule
```

## 5. Descripción estructural (instanciación de módulos)

En vez de escribir toda la lógica desde cero, se puede construir un módulo más grande **usando módulos ya diseñados** como bloques internos. Esto se llama descripción estructural.

Por ejemplo, el comparador de 2 bits también se puede armar reutilizando dos comparadores de 1 bit (uno por cada bit) y un AND que combine ambos resultados:

```verilog
module comparador_2bit_estructural (
    input  wire [1:0] a, b,
    output wire aeqb
);

    wire e0, e1;

    // instanciación por nombre (la forma recomendada — más clara y menos propensa a errores)
    comparador_1bit bit0_unit (.i0(a[0]), .i1(b[0]), .eq(e0));
    comparador_1bit bit1_unit (.i0(a[1]), .i1(b[1]), .eq(e1));

    assign aeqb = e0 & e1;

endmodule
```

Sintaxis general de instanciación:

```
[nombre_del_modulo] [nombre_de_instancia] (
    .[puerto_del_modulo]([señal_del_modulo_actual]),
    ...
);
```

Esto se llama **conexión por nombre**: cada `.puerto(señal)` conecta explícitamente un puerto del módulo instanciado con una señal del módulo que lo contiene. El orden de estas líneas no importa. Existe también la **conexión por lista ordenada** (omitiendo los nombres de puerto y listando las señales en el mismo orden que la declaración del módulo), pero es propensa a errores difíciles de detectar — si alguien cambia el orden de los puertos en el módulo instanciado, todas las instancias quedan mal conectadas sin que nada avise. Por eso conviene usar siempre conexión por nombre.

## 6. Testbench

Una vez escrito el código, hay dos caminos: **simularlo** (verificar que funciona antes de tocar hardware real) o **sintetizarlo** (bajarlo a un dispositivo físico como una FPGA). Para simular se necesita un **testbench**: un módulo especial que no representa hardware real, sino que arma un banco de pruebas virtual.

Un testbench típico tiene tres partes conceptuales (esto es exactamente lo mismo que armamos para tu `multi_compuerta`, solo que acá lo vemos con el comparador):

1. **Generador de vectores de prueba**: aplica distintas combinaciones de entrada.
2. **UUT** (*Unit Under Test*): la instancia del módulo que estás probando.
3. **Monitor**: observa las salidas (puede ser tan simple como mirar las formas de onda, o usar `$display`/`$monitor` para imprimir en consola).

```verilog
`timescale 1ns/10ps

module comparador_2bit_tb;

    reg  [1:0] test_a, test_b;
    wire aeqb;

    // instanciación del circuito bajo prueba (UUT)
    comparador_2bit uut (.a(test_a), .b(test_b), .aeqb(aeqb));

    initial begin
        // vector 1
        test_a = 2'b00; test_b = 2'b00; #200;
        // vector 2
        test_a = 2'b01; test_b = 2'b00; #200;
        // vector 3
        test_a = 2'b01; test_b = 2'b11; #200;
        // vector 4
        test_a = 2'b10; test_b = 2'b10; #200;

        $stop;
    end

endmodule
```

Puntos clave de este código:

- Las señales que el testbench **maneja** (las entradas del UUT) se declaran `reg`, porque se les asigna valor dentro de un `initial`.
- Las señales que el testbench solo **observa** (las salidas del UUT) se declaran `wire`.
- El bloque `initial` se ejecuta **una sola vez** al arrancar la simulación, y sus sentencias sí se ejecutan en orden secuencial (a diferencia del resto de Verilog) — es una de las pocas excepciones a la regla de "todo es paralelo".
- `#200` indica "esperá 200 unidades de tiempo" antes de seguir con la siguiente sentencia — así cada vector de prueba queda aplicado el tiempo suficiente para observarlo en las formas de onda.
- `$stop` es una función de sistema que pausa la simulación y devuelve el control al software de simulación.

Esta plantilla sirve como base general para cualquier circuito combinacional: se cambia la instancia del UUT y se ajustan los vectores de prueba según el circuito nuevo. Para circuitos secuenciales, hay que sumarle además un generador de clock — que es justo lo que ya vimos en tu testbench.

## 7. Resumen de ideas clave del capítulo

- Verilog describe hardware paralelo, no un programa secuencial.
- `wire` = cableado / salida de `assign`. `reg` = almacenamiento abstracto / salida de `always` o `initial` (no implica automáticamente un flip-flop físico).
- Todo módulo sigue el esqueleto: puertos → señales internas → cuerpo (assigns, always, o instanciaciones).
- La instanciación de módulos permite construir circuitos grandes a partir de bloques más chicos, usando conexión por nombre para evitar errores.
- Un testbench es un módulo sin puertos "reales" que instancia el circuito a probar, le aplica vectores de entrada y permite observar (o imprimir) las salidas resultantes.

---
