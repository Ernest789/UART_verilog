`timescale 10ns/1ns

module tb_uart_rx ();

    reg clk_baud;
    reg clk_baud_sample;
    reg rst;

    reg rx_in;

    wire bus_out;

    initial begin
        clk_baud <= 1'b1;
        clk_baud_sample <= 1'b1;
        rst <= 1'b1;
        rx_in <= 1'b1;    
    end

    always #80 clk_baud <= ~clk_baud;  // 周期1600ns
    always #5  clk_baud_sample <= ~clk_baud_sample;  // 周期100ns

    // 0_0101_0101_0_1
    initial begin
               rx_in <= 1'b1;  // 等待四个周期
        #640  rx_in <= 1'b0;  // 起始位
        #160  rx_in <= 1'b0;
        #160  rx_in <= 1'b1;   
        #160  rx_in <= 1'b0;  
        #160  rx_in <= 1'b1;  
        #160  rx_in <= 1'b0;  
        #160  rx_in <= 1'b1;  
        #160  rx_in <= 1'b0;   
        #160  rx_in <= 1'b1;  
        #160  rx_in <= 1'b0;  // 校验位 
        #160  rx_in <= 1'b1;  // 结束位
    end


    uart_rx             tb_uart_rx_ins (
        .clk_baud         (clk_baud),
        .clk_baud_sample, (clk_baud_sample),
        .rst              (rst),
        .rx_in            (rx_in),
        .bus_out          (bus_out) );


endmodule