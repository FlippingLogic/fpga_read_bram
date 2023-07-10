`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/09 22:20:49
// Design Name: 
// Module Name: formatted_send
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

// NOIICE: IT'S RESONPIBLE TO WAIT CYCLES FOR UART SENDING PROCESS.
// USE ASC-II to encode
// Turn both ADDR AND DATA into hexadecimal

module formatted_send(
    output          uart_txd,
    input           CLK_50M,
    input           rst_n,
    input           send_enable,
    input [11:0]    addr,
    input [7:0]     data
    );

    /*****************************Parameter*********************************/
    parameter       END_LSM             =   3'd7    ;   // 6 or 7? NEED TO BE DECIDED
    parameter       ASCII_COLON         =   8'h3A   ;
    parameter       ASCII_SPACE         =   8'h20   ;
    parameter       ASCII_LINEFEED      =   8'h0A   ;
    parameter       ASCII_NUM_BIAS      =   8'h30   ;
    parameter       ASCII_ALPHA_BIAS    =   8'h41   ;

    /*****************************Register*********************************/
    reg             r_lsm_flag      ;
    reg [2:0]       r_lsm_cnt       ;
    reg [7:0]       r_uart_txdata   ;

    /*****************************Wire************************************/
    wire            w_uart_enable   ;
    wire            w_uart_busy     ;
    wire [7:0]      w_uart_txdata   ;

    /*************************Combinational Logic************************/
    assign  w_uart_enable   =   r_lsm_flag      ;
    assign  w_uart_txdata   =   r_uart_txdata   ;

    /****************************Processing*****************************/
    always@(posedge CLK_50M or negedge rst_n)
    if(~rst_n)
        r_lsm_flag <= 1'b0;
    else if(r_lsm_cnt == END_LSM)  // NEED MODIFICATION! Accourding to ADDR and DATA.
        r_lsm_flag <= 1'b0; 
    else if(send_enable)
        r_lsm_flag <= 1'b1;

    always@(posedge CLK_50M or negedge rst_n)	
    if(~rst_n)
        r_lsm_cnt <= 'd0;
    else if(r_lsm_flag) begin
        if(!w_uart_busy)
        r_lsm_cnt <= r_lsm_cnt + 1'b1;
        else
        r_lsm_cnt <= r_lsm_cnt; end 
    else
        r_lsm_cnt <= 'd0;

    /*******************************FSM************************************/


    /*******************************LSM************************************/
    // trasfer DATA!
    always@(*)begin
    if(r_lsm_flag)
    case(r_lsm_cnt)
        0: r_uart_txdata = 
        1: r_uart_txdata = 
        2: r_uart_txdata = ASCII_COLON;
        3: r_uart_txdata = ASCII_SPACE;
        4: r_uart_txdata = 
        5: r_uart_txdata = 
        6: r_uart_txdata = ASCII_LINEFEED;
        default r_uart_txdata = 1'b1;
    endcase
    else
        r_uart_txdata = 
    end	

    /*****************************Instanation*****************************/
    new_uart_tx new_uart(
        .CLK_50M(CLK_50M),  
        .rst_n(rst_n),   
        .bps_sel(3'd4),     // 9600, DONT CHANGE
        .check_sel(1'b0),   // Even
        .din(w_uart_txdata),      
        .req(r_uart_enable),
        .busy(w_uart_busy),
        .TX(uart_txd)
    );

endmodule
