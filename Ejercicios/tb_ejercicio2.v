`timescale 1ns / 1ps

module tb_multi_compuerta;

    // Señales que maneja el testbench (van a las entradas del DUT)
    reg A, B, C, D;
    reg clk;

    // Señales que observa el testbench (vienen de las salidas del DUT)
    wire x, y;

    // Contador para el barrido exhaustivo (4 bits = 16 combinaciones)
    integer i;

    // Instancia del módulo bajo prueba (DUT = Device Under Test)
    multi_compuerta DUT (
        .A(A),
        .B(B),
        .C(C),
        .D(D),
        .clk(clk),
        .x(x),
        .y(y)
    );

    // Generación del clock: periodo de 10ns (5ns en alto, 5ns en bajo)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Estímulos: barrido exhaustivo de las 16 combinaciones de A,B,C,D
    initial begin
        // Encabezado para leer la salida en consola
        $display("time\tA B C D | x y");
        $monitor("%4t\t%b %b %b %b | %b %b", $time, A, B, C, D, x, y);

        // Estado inicial
        {A, B, C, D} = 4'b0000;

        // Esperamos un par de flancos para que el pipeline se estabilice
        // antes de empezar a cambiar entradas (llena la primera etapa)
        @(posedge clk);
        @(posedge clk);

        // Barrido exhaustivo: 16 combinaciones, una por flanco de clock
        for (i = 0; i < 16; i = i + 1) begin
            {A, B, C, D} = i[3:0];
            @(posedge clk); // esperamos el flanco donde se captura esta entrada
        end

        // Dejamos correr 2 flancos más para que las últimas entradas
        // aplicadas terminen de propagarse por las 2 etapas del pipeline
        @(posedge clk);
        @(posedge clk);

        $display("Fin de la simulacion");
        $finish;
    end

endmodule