`timescale 1ns / 1ps

module uart_top(
    input rst,
    input [7:0] data_in,
    input wr_en,
    input clk,
    input rdy_clr,

    output busy,
    output rdy,
    output [7:0] data_out
);

// Internal signals
wire rx_clk_en;
wire tx_clk_en;
wire tx_temp;


// Baud Rate Generator
baud_rate_generator bg(
    .clk(clk),
    .rst(rst),
    .tx_enb(tx_clk_en),
    .rx_enb(rx_clk_en)
);


// UART Transmitter
uart_tx us(
    .clk(clk),
    .rst(rst),
    .enb(tx_clk_en),
    .wr_en(wr_en),
    .data_in(data_in),
    .tx(tx_temp),
    .busy(busy)
);


// UART Receiver
uart_rx ur(
    .clk(clk),
    .rst(rst),
    .rx(tx_temp),
    .rdy_clr(rdy_clr),
    .clk_en(rx_clk_en),
    .rdy(rdy),
    .data_out(data_out)
);

endmodule
