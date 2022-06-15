`timescale 1ns/1ps

module uart_baud (
    input clk,  // 100MHz,T = 10ns
    output reg clk_baud,  // 波特�?115200,T = 8680ns
    output reg clk_baud_sample );  // 115200*16 = 1843200,T = 540ns

    // 计数寄存�?
    reg [9:0] cnt_clk_baud;
    reg [5:0] cnt_clk_sample;

    //初始�?
    initial begin
        clk_baud <= 1'b1;
        clk_baud_sample <= 1'b1;
        cnt_clk_baud <= 10'b0;
        cnt_clk_sample <= 6'b0;
    end

    localparam change1 = 10'b 01_1011_0010,
                restart1 = 10'b 11_0110_0100,
                change2 = 6'b 01_1011,
                restart2 = 6'b 11_0110;


    always @(posedge clk) begin
        case (cnt_clk_baud)
           change1 : begin 
                clk_baud <= ~clk_baud;  // 占空�?50%
                cnt_clk_baud <= cnt_clk_baud + 10'b1;
            end        
           restart1 : begin 
                 clk_baud <= ~clk_baud;
                 cnt_clk_baud <= 0;
            end
            default: cnt_clk_baud <= cnt_clk_baud + 10'b1;
        endcase 
    end


    always @(posedge clk) begin
        case (cnt_clk_sample)
           change2 : begin 
                clk_baud_sample <= ~clk_baud_sample;  // 占空�?50%
                cnt_clk_sample <= cnt_clk_sample + 6'b1;
            end        
           restart2 : begin 
                 clk_baud_sample <= ~clk_baud_sample;
                 cnt_clk_sample <= 0;
            end
            default: cnt_clk_sample <= cnt_clk_sample + 6'b1;
        endcase  
    end

endmodule