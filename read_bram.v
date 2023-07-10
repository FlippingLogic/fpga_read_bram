`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/07 20:07:11
// Design Name: 
// Module Name: read_bram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Read one block RAM's memory, RAM config: 8*2k
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
// Problem Unsolved:
//  1. FSM never stop. That is, addr==WRITE_DEPTH*WRITE_WIDTH is never met.
//     IDEA: An overload may exist. addr is only 12 bits indeed.
//  2. SEND not completed. LSM constructing in progress. 
//     Now seperate sending part to another file.
//////////////////////////////////////////////////////////////////////////////////


module read_bram(
    input           sys_clk_p,
    input           sys_clk_n,
    input           rst,
    input           send_enable,
    input  [7:0]    switch,
    output          uart_txd,
    output [7:0]    led
    );
    /*****************************Parameter*********************************/
    parameter   WRITE_LENTH =   8;
    parameter   WRITE_DEPTH =   2048;

    /*****************************Register*********************************/
    reg         r_uart_enable   ;
    reg         r_lsm_enable    ;
    reg         r_lsm_counter   ;
    reg [11:0]  r_bram_addr     ;
    reg [1:0]   r_exec_state    ;
    reg [1:0]   r_next_state    ;
    reg [7:0]   r_bram_dout     ;
    reg [7:0]   r_led           ;

    /*****************************Wire************************************/
    wire        w_clk           ;
    wire        w_resetn        ;
    wire [7:0]  w_bram_dout     ;
    wire [7:0]  w_uart_txdata   ;

    /*************************Combinational Logic************************/
    assign w_resetn         =   ~rst        ;
    assign w_uart_txdata    =   r_bram_dout ;
    assign led              =   r_led       ;

    /****************************Processing*****************************/
    // always @(posedge w_clk) begin
    //     if(!w_resetn) begin
    //     end
    // end

    /*******************************FSM************************************/

    // WRITE BLOCK MEMORY FSM



    // READ BLOCK MEMORY FSM
    parameter   IDLE = 2'b00,
                READ = 2'b01,
                SEND = 2'b10,
                NEXT = 2'b11;
    
    always@(posedge w_clk)begin
    case(r_exec_state)
        IDLE: begin
            r_led <= 8'b11000000;
            r_uart_enable <= 1'b0;
            r_bram_addr <= 12'd0;
            if(send_enable)begin
                r_next_state <= SEND;
            end else begin
                r_next_state <= IDLE;
            end
        end
        READ: begin
            r_led <= 8'b00110000;
            r_bram_dout <= w_bram_dout;
            r_next_state <= SEND;
        end
        SEND: begin
            r_led <= 8'b00001100;
            r_uart_enable <= 1'b1;
            r_lsm_enable <= 1'b1;
            r_next_state <= NEXT;
        end
        NEXT: begin
            r_led <= 8'b00000011;
            r_uart_enable <= 1'b0;
            if(r_bram_addr==WRITE_DEPTH)begin
                r_next_state <= IDLE;
            end else begin
                r_next_state <= READ;
                r_bram_addr <= r_bram_addr + 1;
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

    /****************************Instanation*****************************/
    clk_wiz_0 clock
    (
        .clk_out1(w_clk),
        .clk_in1_p(sys_clk_p),  
        .clk_in1_n(sys_clk_n)   
    );
        
    new_uart_tx new_uart(
        .CLK_50M(w_clk),  
        .rst_n(w_resetn),   
        .bps_sel(3'd4),     // 9600, DONT CHANGE
        .check_sel(1'b0),   // Even
        .din(w_uart_txdata),      
        .req(r_uart_enable),
        .TX(uart_txd)
    );

    blk_mem_gen_0 bram (
    .clka(w_clk),  
    .wea(1'b0),
    .addra(r_bram_addr),
    .dina({8{1'b1}}),
    .douta(w_bram_dout) 
    );

endmodule
