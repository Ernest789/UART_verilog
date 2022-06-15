`timescale 10ns/1ns
`include "uart_baud.v"
`include "uart_tx.v"
`include "uart_rx.v"

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


    uart_tx_moore        uart_tx_ins (
        .clk_baud    (clk_baud),
        .rst         (rst),
        .bus_in      (bus_in),
        .serial_out      (tx_out) );


    // 接收模块实例化
    uart_rx_moore        uart_rx_ins (
        .clk_baud     (clk_baud),
        .clk_sample   (clk_baud_sample),
        .rst          (rst),
        .serial_in    (rx_in),
        .bus_out      (bus_out) );


endmodule