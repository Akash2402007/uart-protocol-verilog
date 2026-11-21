`timescale 1ns / 1ps

module uart_tx(
    input clk,
    input rst,
    input enb,
    input wr_en,
    input [7:0] data_in,

    output reg tx,
    output busy
);

// State Declaration
parameter idle_state  = 2'b00,
          start_state = 2'b01,
          data_state  = 2'b10,
          stop_state  = 2'b11;


// Registers
reg [1:0] state;
reg [7:0] data;
reg [2:0] index;


always @(posedge clk)
begin

    // ================= RESET =================
    if(rst)
    begin
        state <= idle_state;
        tx <= 1'b1;
        data <= 8'b0;
        index <= 3'd0;
    end

    else
    begin

        case(state)

        // ================= IDLE STATE =================
        idle_state:
        begin
            tx <= 1'b1;

            if(wr_en)
            begin
                data <= data_in;
                index <= 3'd0;
                state <= start_state;
            end

            else
                state <= idle_state;
        end


        // ================= START BIT =================
        start_state:
        begin
            if(enb)
            begin
                tx <= 1'b0;
                state <= data_state;
            end
        end


        // ================= DATA BITS =================
        data_state:
        begin
            if(enb)
            begin
                tx <= data[index];

                if(index == 3'd7)
                    state <= stop_state;

                else
                    index <= index + 1'b1;
            end
        end


        // ================= STOP BIT =================
        stop_state:
        begin
            if(enb)
            begin
                tx <= 1'b1;
                state <= idle_state;
            end
        end


        default:
        begin
            state <= idle_state;
            tx <= 1'b1;
        end

        endcase

    end

end


// Busy Signal
assign busy = (state != idle_state);

endmodule
