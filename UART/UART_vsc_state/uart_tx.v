// Moore型三段式状态机实现uart发送模块
/*
一帧bus_in数据的存在时间必须不小于一个clk_baud周期,且不大于12个clk_baud周期才能正确传输。

clk_baud:_/ 1\__/ 2\__/ 3\__······__/11\__/12\__/13\_
bus_in:  _/xx/¯¯¯¯¯¯¯¯¯¯¯¯¯¯······¯¯¯¯¯¯¯¯¯¯¯\xxxx\__

过短时，状态机无法进入下一状态去发送数据；过长时，状态机会重复发送这一帧数据。
可以通过修改bus_arrival参数的生成逻辑来解决，这里忽略这个问题。
*/
module uart_tx_moore (
    input rst,  // 异步复位信号（高电平有效）
    input clk_baud,  // 波特率时钟
    input [7:0] bus_in,  // 输入总线
    output reg serial_out  // 串行输出
);

    // 状态寄存器
    reg [3:0] current_state;  // 当前状态
    reg [3:0] next_state;  // 下一状态
    // 数据寄存器
    reg [7:0] bus_buff;
    reg parity_even;

    wire bus_arrival;

    // 状态码
    localparam 
    state_0 = 4'b0000,  state_1 = 4'b0001,  state_2 = 4'b0010,
    state_3 = 4'b0011,  state_4 = 4'b0100,  state_5 = 4'b0101,
    state_6 = 4'b0110,  state_7 = 4'b0111,  state_8 = 4'b1000,
    state_9 = 4'b1001,  state_10= 4'b1010,  state_11= 4'b1011; 


    // 如何判断总线数据到来？
    // 我的思路是非全零时表示总线数据到来
    assign bus_arrival = | bus_in;
    always @(*) begin
        if (rst)  
            bus_buff = 8'b0;
        else begin
            // 在空闲状态获取总线数据，
            if(current_state == state_0) begin
                if(bus_arrival)  begin
                    bus_buff = bus_in;                  
                    parity_even = ^ bus_buff;  // 偶校验
                end 
                else begin
                    bus_buff = 8'b0;
                    parity_even = 1'b0;
                end
            end
            // 在其他状态保持缓存的总线数据，不需要else语句
        end
    end

////////////////////////三段式状态机///////////////////////////


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
            state_0 : begin  // 等待状态
                    if(bus_arrival) 
                        next_state = state_1;
                    else
                        next_state = state_0;
                    end
            state_1 : begin  // 起始位发送状态
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
            serial_out = 1'b1;
        else begin
            case (current_state) 
                state_0 : serial_out = 1'b1;
                state_1 : serial_out = 1'b0;
                state_2 : serial_out = bus_buff[7];
                state_3 : serial_out = bus_buff[6];
                state_4 : serial_out = bus_buff[5];
                state_5 : serial_out = bus_buff[4];
                state_6 : serial_out = bus_buff[3];
                state_7 : serial_out = bus_buff[2];
                state_8 : serial_out = bus_buff[1];
                state_9 : serial_out = bus_buff[0];
                state_10: serial_out = parity_even;
                state_11: serial_out = 1'b1;
                default: serial_out = 1'b1;
            endcase
        end
                
    end

///////////////////////////////////////////////////////////////

endmodule