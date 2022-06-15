`timescale 10ns/1ns

module uart_tx #(
    parameter WIDTH = 8
)
(
    input clk_baud,
    input rst,  // 异步清零，低电平有效
    input [WIDTH-1:0] bus_in,
    output reg tx_out );

    // 寄存�?
    reg [WIDTH-1:0] in_buff;
    reg  tx_state;
    reg [3:0] cnt_bits;
    
    reg bus_start;
    reg parity_even;
    
    // 初始�?
    initial begin
        in_buff <= 0;
        tx_state <= 1'b0;
        tx_out <= 1'b1;
        cnt_bits <= 0;
        bus_start <= 1'b0;
        parity_even <= 1'b0;
    end

    // 异步清零
    always @(negedge rst) begin
        if(!rst) begin
            in_buff <= 0;
            tx_state <= 1'b0;
            tx_out <= 1'b1;
            cnt_bits <= 4'b0;
            bus_start <= 1'b0;
            parity_even <= 1'b0;            
        end
    end

    // 状�?�机
    always @(posedge clk_baud) begin
        case (tx_state)
            1'b0 : begin  // 等待状�
                in_buff <= bus_in;  // 数据缓存
                bus_start <= | in_buff; // �?单软流控? ?
                case(bus_start)  // �?始接�?
                    1'b1: begin 
                        parity_even <= ^ in_buff;   // 偶校�? 
                        bus_start <= 1'b0;  // 停止接收
                        tx_state <= 1'b1;  // 下一状�??
                        end
                    default: tx_state <= 1'b0;  
                endcase
            end

            default :begin  // 串行发�??                
                case (cnt_bits)
                   4'b0000 : tx_out <= 1'b0;  // 起始�?
                   4'b0001 : tx_out <= in_buff[7];  // 高位�?始发�?
                   4'b0010 : tx_out <= in_buff[6];
                   4'b0011 : tx_out <= in_buff[5];
                   4'b0100 : tx_out <= in_buff[4];
                   4'b0101 : tx_out <= in_buff[3];
                   4'b0110 : tx_out <= in_buff[2];
                   4'b0111 : tx_out <= in_buff[1];
                   4'b1000 : tx_out <= in_buff[0];
                   4'b1001 : tx_out <= parity_even;
                   4'b1010 : begin 
                                tx_out <= 1'b1;  // 结束�?
                                in_buff <= 8'b0;  // 缓存清空
                                tx_state <= 1'b0;  // 等待状�??
                            end
                    default: cnt_bits <= 4'b0000;
                endcase
            end 
        endcase
        
    end


    //11进制计数�?
    always@(posedge clk_baud)  begin
        case(tx_state)
            1'b1: begin
                case (cnt_bits)
                   4'b1010 : cnt_bits <= 4'b0000; 
                    default: cnt_bits <= cnt_bits + 4'b0001;
                endcase
            end
            default: cnt_bits <= 4'b0000;
        endcase
    end


endmodule