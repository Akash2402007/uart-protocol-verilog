`timescale 1ns / 1ps

module uart_top_test;

reg clk;
reg rst;
reg [7:0] data_in;
reg wr_en;
reg rdy_clr;

wire busy;
wire rdy;
wire [7:0] data_out;


// DUT
uart_top uut(
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .wr_en(wr_en),
    .rdy_clr(rdy_clr),
    .busy(busy),
    .rdy(rdy),
    .data_out(data_out)
);


// Clock: 50 MHz
initial
begin
    clk = 0;
    forever #10 clk = ~clk;
end


// Test stimulus
initial
begin

    rst = 1;
    wr_en = 0;
    rdy_clr = 0;
    data_in = 8'hA5;

    repeat(5) @(negedge clk);

    rst = 0;

    // Transmit data
    @(negedge clk);
    wr_en = 1;

    @(negedge clk);
    wr_en = 0;

    // Wait for receiver
    wait(rdy == 1);

    #1;

    if(data_out == 8'hA5)
        $display("PASS: UART transmission and reception successful");

    else
        $display("FAIL: Expected A5, Received %h", data_out);

    @(negedge clk);
    rdy_clr = 1;

    @(negedge clk);
    rdy_clr = 0;

    #100;
    $finish;

end

endmodule