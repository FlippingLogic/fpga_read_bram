`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/03 14:10:04
// Design Name: 
// Module Name: test_uart_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_uart(
    input           sys_clk_p,
    input           sys_clk_n,
    input [7:0]     switch,
    input           rst,
    input           send_enable,
    output          uart_txd,
    output [7:0]    led
    );
    
    /*****************************Register*********************************/
    reg         r_en            ;
    reg [7:0]   r_data          ;
    reg [25:0]  r_stop_counter  ;
    reg [1:0]   r_exec_state    ;
    reg [1:0]   r_next_state    ;

    /*****************************Wire************************************/
    wire        w_clk           ;
    wire        w_resetn        ;
    wire        w_en            ;

    /*************************Combinational Logic************************/
    assign w_resetn =   ~rst            ;
    assign w_en     =   r_en            ;
    assign led[0]   =   switch[0]       ;
    assign led[1]   =   switch[1]       ;
    assign led[2]   =   switch[2]       ;
    assign led[3]   =   switch[3]       ;
    assign led[4]   =   switch[4]       ;
    assign led[5]   =   switch[5]       ;
    assign led[6]   =   switch[6]       ;
    assign led[7]   =   switch[7]       ;

    /****************************Instanation*****************************/
   clk_wiz_0 clock
   (
    .clk_out1(w_clk),
    .clk_in1_p(sys_clk_p),   // input clk_in1_p
    .clk_in1_n(sys_clk_n)    // input clk_in1_n
   );
    
    new_uart_tx new_uart(
        .CLK_50M(w_clk),  
        .rst_n(w_resetn),   
        .bps_sel(3'd4),
        .check_sel(1'b0), // Even
        .din(switch),      
        .req(w_en),  
        .TX(uart_txd)
    );

    /****************************Processing*****************************/
    // always @(posedge w_clk) begin
    //     if(!w_resetn) begin
    //         r_data <= 8'hAA;
    //     end
    // end

    /*******************************FSM************************************/
    parameter   IDLE = 2'b00,
                SEND = 2'b01,
                STOP = 2'b10,
                WAIT = 2'b11; // Wait 0.5s to get next request
    
    always@(posedge w_clk)begin
    case(r_exec_state)
        IDLE: begin
            r_en <= 1'b0;
            if(send_enable)begin
                r_next_state <= SEND;
            end else begin
                r_next_state <= IDLE;
            end
        end
        SEND: begin
            r_en <= 1'b1;
            r_next_state <= STOP;
        end
        STOP: begin
            r_en <= 1'b0;
            r_stop_counter <= 26'b0;
            r_next_state <= WAIT;
        end
        WAIT: begin
            if(r_stop_counter==26'd50_000_000/2-1)begin
                r_next_state <= IDLE;
            end else begin
                r_next_state <= WAIT;
                r_stop_counter <= r_stop_counter + 1;
            end
        end
        default: r_next_state <= r_next_state;
    endcase
    end
    
    always @(posedge w_clk) begin
        if(!w_resetn) begin
            r_exec_state <= IDLE;
        end else begin
            r_exec_state <= r_next_state;
        end
    end
    
endmodule

    //  uart_tx uart(
    // .clk(clk),
    // .resetn(resetn),
    // .uart_txd(uart_txd),    // OUTPUT
    // .uart_tx_busy(busy),   // OUTPUT
    // .uart_tx_en(en_wire),
    // .uart_tx_data(switch)
    // );

    //    always@(*)begin
    //        en <= 1'b1;
    //        data <= 8'b11001101;
    //    end