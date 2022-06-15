`timescale 1ns/1ps
`include "uart_tx.v"
/*
uart_tx模块测试文件
波特率9600，T=104166.6ns
rst复位高电平有效
*/
module tb_tx ();

    //localparam T = 104166;
    localparam T = 16;

    reg rst;
    reg clk_baud;
    reg [7:0] bus_in;

    wire serial_out;

    initial begin
        rst = 1'b0;
        clk_baud = 1'b0;
        bus_in = 8'b0;
    end

    initial begin
        repeat(2*50)
        #(T/2)  clk_baud = ~clk_baud;
    end

    initial begin
        rst = 1'b1;  #T  // 1
        rst = 1'b0;  #(T*23)
        rst = 1'b0;  #T  // 25
        rst = 1'b0;
    end

    initial begin
        bus_in = 8'b0;  #(T*4)
        bus_in = 8'b10011001;  #(1.5*T)  // 5
        bus_in = 8'b0;  #(T*11)
        bus_in = 8'b0;  #(T*3) 
        bus_in = 8'b01100010;  #T  // 20
        bus_in = 8'b0;
    end

    uart_tx_moore     tb_tx_ins(
        .rst            (rst),
        .clk_baud       (clk_baud),
        .bus_in         (bus_in),
        .serial_out     (serial_out)
    );

    initial begin
        $dumpfile("wave_tx.vcd");
        $dumpvars(0,tb_tx);
    end

endmodule