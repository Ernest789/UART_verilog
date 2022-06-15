`timescale 1ns/1ps

module tx_uart_baud ();
    reg clk;
    wire clk_blad;
    wire clk_baud_sample;

    initial clk <= 1'b1;

    //always #5 clk <= ~clk;  // 100MHz时钟

    initial begin
      repeat(10000)
        #5 clk <= ~clk;
    end
    
    uart_baud   tb_uart_baud_ins(
        .clk      (clk),
        .clk_baud (clk_baud),
        .clk_baud_sample (clk_baud_sample)
    );


endmodule