`timescale 1ns/1ps
 
 // 回环测试

 module tb_uart_loopback ();

    reg [7:0] bus_in;
    reg clk;

    wire [7:0] bus_out;
    wire tx_out;

    // 
    initial begin
        bus_in <= 8'b0;
        clk <= 1'b1;
    end

    // 时钟，T=10ns
    always #5 clk <= ~clk;

    // 输入数据
    initial begin
                    bus_in <= 8'b0;  // 5个波特周期空闲
        #(8680*5)   bus_in <= 8'b0101_0101;  // 2个波特周期输入
        #(8680*2)    bus_in <= 8'b0; 
    end

    // 发送
    UART      tb_UART_tx (
    .clk        (clk),
    .model      (1'b0),
    .rst        (1'b1),
    .bus_in     (bus_in),
    .tx_out     (tx_out));


    // 接收
    UART      tb_UART_rx (
    .clk        (clk),
    .model      (1'b1),
    .rst        (1'b1),
    .rx_in      (tx_out),
    .bus_out    (bus_out) );
 
 endmodule