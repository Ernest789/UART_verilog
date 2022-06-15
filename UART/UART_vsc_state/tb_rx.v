`timescale 1ns/1ps
`include "uart_rx.v"

module tb_rx ();

    parameter t = 2;
    parameter T = 32;

    reg rst;
    reg clk_baud;
    reg clk_sample;
    reg serial_in;

    wire [7:0] bus_out;

    initial begin
        rst = 0;
        clk_baud = 0;
        clk_sample = 0;
        serial_in = 0;
    end

    initial begin
        rst = 1'b1;  #t
        rst = 1'b0; 
    end

    initial begin
        repeat(100)  
        #(T/2)  clk_baud = ~clk_baud;
    end

    initial begin
        repeat(1600)
        #(t/2)  clk_sample = ~clk_sample;
    end

    //0_10011001_0_1
    //0_11000010_0_1错误校验
    initial begin
        serial_in = 1'b1; #(T*2)

        serial_in = 1'b 0 ;  #T
        serial_in = 1'b 1 ;  #T
        serial_in = 1'b 0 ;  #T
        serial_in = 1'b 0 ;  #T
        serial_in = 1'b 1 ;  #T
        serial_in = 1'b 1 ;  #T
        serial_in = 1'b 0 ;  #T
        serial_in = 1'b 0 ;  #T
        serial_in = 1'b 1 ;  #T
        serial_in = 1'b 0 ;  #T
        serial_in = 1'b 1 ;  #T

        serial_in = 1'b1; #(T*2)

        serial_in = 1'b 0 ;  #T
        serial_in = 1'b 1 ;  #T
        serial_in = 1'b 1 ;  #T
        serial_in = 1'b 0 ;  #T
        serial_in = 1'b 0 ;  #T
        serial_in = 1'b 0 ;  #T
        serial_in = 1'b 0 ;  #T
        serial_in = 1'b 1 ;  #T
        serial_in = 1'b 0 ;  #T
        serial_in = 1'b 0 ;  #T  // 错误校验位
        serial_in = 1'b 1 ;  #T

        serial_in = 1'b1;
    end

    uart_rx_moore    tb_rx_ins(
        .rst        (rst),
        .clk_baud   (clk_baud),
        .clk_sample (clk_sample),
        .serial_in  (serial_in),
        .bus_out    (bus_out)
    );

    initial begin
        $dumpfile("wave_rx.vcd");
        $dumpvars(0, tb_rx);
    end


endmodule