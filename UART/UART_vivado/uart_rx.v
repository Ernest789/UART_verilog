`timescale 10ns/1ns

module uart_rx #(
    parameter WIDTH = 4'b1000
)
(   
    input clk_baud,
    input clk_baud_sample,
    input rst,
    input rx_in,
    output reg [WIDTH-1:0] bus_out );

    // 寄存�?
    reg rx_in_buff;  // 输入缓存
    reg [WIDTH+1:0] rx_out_buff;  // 不接收起始位和结束位
    reg [3:0] cnt_bits;  // bit计数
    reg [3:0] cnt_samples;  // 样本计数
    reg [1:0] state;  // 状�?�标�?
    reg rx_start;  // 接收指示
    reg parity_ture;  // 校验正确标识
    reg sample_model;  // 采样计数器模式控�?


    // 初始�?
    initial begin
        rx_in_buff <= 0;
        rx_out_buff <= 0;
        cnt_bits <= 0;
        cnt_samples <= 0;
        state <= 0; 
        rx_start <= 0;
        parity_ture <= 0;
        sample_model <= 0;
        bus_out <= 0;
    end

    // 异步清零
    always@(negedge rst) begin
        rx_in_buff <= 0;
        rx_out_buff <= 0;
        cnt_bits <= 0;
        cnt_samples <= 0;
        state <= 0; 
        rx_start <= 0;
        parity_ture <= 0;
        sample_model <= 0;
        bus_out <= 0;
    end


    // 状�?�机
    always @(posedge clk_baud) begin
        case (state)

            2'b00 : begin  // 等待状�??
              case(rx_start)
                1'b1 : state <= 1'b1;  // 状�?�转�?
                default:  state <= 1'b0;  // 状�?�保�?
              endcase
            end

            2'b01 : begin  // 接收状�??
                case(cnt_bits)
                    4'b0000 : rx_out_buff[9] <= rx_in_buff ;
                    4'b0001 : rx_out_buff[8] <= rx_in_buff ; 
                    4'b0010 : rx_out_buff[7] <= rx_in_buff ; 
                    4'b0011 : rx_out_buff[6] <= rx_in_buff ; 
                    4'b0100 : rx_out_buff[5] <= rx_in_buff ; 
                    4'b0101 : rx_out_buff[4] <= rx_in_buff ; 
                    4'b0110 : rx_out_buff[3] <= rx_in_buff ; 
                    4'b0111 : rx_out_buff[2] <= rx_in_buff ;
                    4'b1000 : rx_out_buff[1] <= rx_in_buff ; 
                    4'b1001 : begin 
                        rx_out_buff[0] <= rx_in_buff ;  // 接收校验�?
                        state <= 2'b11;  // 状�?�转�?
                    end
                endcase
            end

            2'b11 : begin // 校验状�??  
                    parity_ture <= (rx_out_buff[0] == ^rx_out_buff[8:1]) ? 1'b1 : 1'b0;  // �?始校�?
                    state <= 2'b10;  // 状�?�转�?
            end

            2'b10 : begin  // 输出状�?? 
                        case(parity_ture)
                            1'b1 : bus_out <= rx_out_buff[8:1];  // 校验正确发�?�数�?
                            default : rx_out_buff <= 9'b0;  // 校验错误，清空缓�?
                        endcase
                        state <= 2'b00;  // 状�?�转�?
            end

        endcase 
    end


    // 接收计数�?
    always@(posedge clk_baud)  begin
        case(state)
            2'b01 : begin  // 接收状�?�，9进制计数�?
                case (cnt_bits)  
                   4'b1001 : cnt_bits <= 4'b0000; 
                    default: cnt_bits <= cnt_bits + 4'b0001;
                endcase
            end
            default: cnt_bits <= 4'b0000;  // 其他状�?�，不计�?
        endcase
    end


    // 采样计数�?
    always @(posedge clk_baud_sample) begin
        case (sample_model)
            1'b0 : begin  // 等待状�?�，8进制计数�?
                case (cnt_samples)
                    4'b1000 : cnt_samples <= 4'b0000;  // 采样计数器复�? 
                    default: cnt_samples <= cnt_samples + 4'b0001;
                endcase
            end 
            default: begin  // 接收状�?�，16进制计数�?
                cnt_samples <= cnt_samples + 4'b0001;
            end
        endcase
    end


    // 过采�?
    always @(posedge clk_baud_sample) begin
        case(state)
            2'b00 : begin  // 等待状�??
                case(rx_in)  
                    1'b0 : begin  // 出现起始�?
                        sample_model <= 1'b0;  // 8进制计数
                        case(cnt_samples)
                            4'b0111 : begin
                                state <= 2'b01;  // �?始接收数�?
                                rx_start <= 1'b1;
                                cnt_samples <= 4'b0000;  // 计数器复�?
                            end
                            default : rx_start <= 1'b0; 
                        endcase
                    end

                    default : begin  // 未出现起始位
                        rx_start <= 1'b0;  // 不接收数�?  
                        cnt_samples <= 4'b0000;  // 计数器复�?
                    end
                endcase
            end

            2'b01 : begin  // 接收状�
                rx_start <= 1'b0;  // ���ձ�ʶ��λ??
                sample_model <= 1'b1;  // 16进制计数
                case (cnt_samples)
                    4'b1111 : rx_in_buff <= rx_in;  // 自开始后�?16个周期采样一个数�? 
                    //default :   
                endcase
            end

            default : begin  // 其他状�??
                cnt_samples <= 4'b0000;  // 不计�?
            end

        endcase
        
    end


endmodule