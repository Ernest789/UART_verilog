`timescale 10ns/1ns

module tb_uart_tx ();

    reg clk_baud;
    reg rst;  // 清零，低电平有效
    reg [7:0] bus_in;
    
    wire tx_out;

    initial begin
        clk_baud <= 1'b1;
        rst <= 1;  
        bus_in <= 0;
    end

    always #5 clk_baud <= ~clk_baud;

    initial begin
            bus_in <= 8'b0;  // 4个周期空�?
        #40  bus_in <= 8'b1111_1111;  // 1个周期输�?
        #10  bus_in <= 8'b0;  // 11个周期等�?
        #110 bus_in <= 8'b1010_1010;  // 11个周期输�?
        #20  bus_in <= 8'b0;  // 无数据输�?
    end

    initial begin
            rst <= 1;
        #200 rst <= 0; // �?20个周期时清零
        #10  rst <= 1;
    end

    uart_tx  tb_uart_tx_ins (
        .clk_baud  (clk_baud),
        .bus_in    (bus_in),
        .tx_out    (tx_out) );


endmodule