`timescale 10ns/1ns

module UART (
    input clk,
    input rst,
    input rx_in,
    output tx_out,
    output [7:0] bus_out,
    input [7:0] bus_in );


    //中间连线
    wire clk_baud;
    wire clk_baud_sample;


    //波特时钟实例化
    uart_baud     uart_baud_ins (
        .clk             (clk),
        .clk_baud        (clk_baud),
        .clk_baud_sample (clk_baud_sample) );


    uart_tx        uart_tx_ins (
        .clk_baud    (clk_baud),
        .rst         (rst),
        .bus_in      (bus_in),
        .tx_out      (tx_out) );


    // 接收模块实例化
    uart_rx        uart_rx_ins (
        .clk_baud     (clk_baud),
        .clk_baud_sample (clk_baud_sample),
        .rst          (rst),
        .rx_in        (rx_in),
        .bus_out      (bus_out) );


endmodule