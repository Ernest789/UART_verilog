// 状态机实现接收

module uart_rx_moore (
    input rst,
    input clk_baud,
    input clk_sample,
    input serial_in,
    output reg [7:0] bus_out
);

    // 状态寄存器
    reg [3:0] current_state;
    reg [3:0] next_state;
    // 并行数据缓存器
    reg [8:0] bus_buff;
    // 采样数据缓存
    reg signal_sample;
    // 校验指示
    reg parity_ture;
    // 采样点数
    reg [3:0] cnt_sample;

    // 接收指示
    reg serial_arrival; 

    // 接收机状态码
    localparam 
    state_0 = 4'b0000,  state_1 = 4'b0001,  state_2 = 4'b0010,
    state_3 = 4'b0011,  state_4 = 4'b0100,  state_5 = 4'b0101,
    state_6 = 4'b0110,  state_7 = 4'b0111,  state_8 = 4'b1000,
    state_9 = 4'b1001,  state_10= 4'b1010,  state_11= 4'b1011; 


    // 采样机
    always @(posedge clk_sample, posedge rst) begin
        if(rst) begin
            serial_arrival <= 1'b0;
            cnt_sample <= 4'b0;
            signal_sample <= 1'b0;
        end
        else begin
            // 在空闲状态寻找起始位
            if(current_state == state_0) begin
                case (serial_in)
                    1'b0 :  begin  // 出现低电平
                        // 8进制计数
                        if(cnt_sample == 4'b0111) begin
                            cnt_sample <= 4'b0;
                            serial_arrival <= 1'b1;
                        end
                        else begin
                            cnt_sample <= cnt_sample + 4'b1;
                        end
                    end
                    default : cnt_sample <= 4'b0;
                endcase
            end
            // 在接收状态对信号采样
            else begin
                serial_arrival <= 1'b0;
                // 16进制计数
                 if(cnt_sample == 4'b1111) begin
                    signal_sample <= serial_in;
                    cnt_sample <= 4'b0;
                 end
                 else begin
                     cnt_sample <= cnt_sample + 4'b1;
                 end   
            end 
        end
        
    end

////////////////////////接收状态机(三段式)///////////////////////////


    // 时序逻辑部分（当前状态）
    always @(posedge clk_baud, posedge rst) begin
        if(rst) begin
            current_state <= state_0; 
        end
        else begin
            current_state <= next_state;
        end    
    end


    // 组合逻辑部分（状态转换）
    always @(*) begin
        next_state = state_0;
        case (current_state)
            state_0 : begin
                    if (serial_arrival) begin
                        next_state <= state_1;
                    end
                    else 
                        next_state <= state_0;
                    end
            state_1 : begin  // 接收第一位
                    next_state = state_2;
                    end
            state_2 : begin
                    next_state = state_3;
                    end
            state_3 : begin
                    next_state = state_4;
                    end
            state_4 : begin
                    next_state = state_5;
                    end
            state_5 : begin
                    next_state = state_6;
                    end
            state_6 : begin
                    next_state = state_7;
                    end
            state_7 : begin
                    next_state = state_8;
                    end
            state_8 : begin
                    next_state = state_9;
                    end
            state_9 : begin 
                    next_state = state_10;
                    end
            state_10 : begin 
                    next_state = state_11;
                    end 
            state_11 : begin
                    next_state = state_0;
                    end        
            default: next_state = state_0;
        endcase    
    end


    // 组合逻辑部分（输出）
    always @(*) begin
        if(rst) 
            bus_out = 8'b0;
        else begin
            case (current_state) 
                state_0 : begin 
                          bus_buff = 9'b0;
                          bus_out = 8'b0;
                end
                state_1 : bus_buff[8] = signal_sample;
                state_2 : bus_buff[7] = signal_sample;
                state_3 : bus_buff[6] = signal_sample;
                state_4 : bus_buff[5] = signal_sample;
                state_5 : bus_buff[4] = signal_sample;
                state_6 : bus_buff[3] = signal_sample;
                state_7 : bus_buff[2] = signal_sample;
                state_8 : bus_buff[1] = signal_sample;
                state_9 : bus_buff[0] = signal_sample;
                state_10: begin  // 数据校验
                          if(bus_buff[0] != ^bus_buff[8:1])
                                bus_buff = 9'b0;
                          end
                state_11: bus_out = bus_buff[8:1];
                default: current_state = state_0;
            endcase
        end
                
    end
 
/////////////////////////////////////////////////////////////////
endmodule