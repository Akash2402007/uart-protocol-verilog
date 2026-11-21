`timescale 1ns / 1ps

module uart_rx(
    input clk,
    input rst,
    input rx,
    input rdy_clr,
    input clk_en,

    output reg rdy,
    output reg [7:0] data_out
);


parameter start_state    = 2'b00,
          data_out_state = 2'b01,
          stop_state     = 2'b10;


reg [1:0] state;

reg [3:0] sample;
reg [3:0] index;

reg [7:0] temp_register;


always @(posedge clk)
begin

    // ================= RESET =================
    if(rst)
    begin
        state <= start_state;
        sample <= 0;
        index <= 0;
        temp_register <= 0;
        data_out <= 0;
        rdy <= 0;
    end

    else
    begin

        if(rdy_clr)
            rdy <= 0;


        if(clk_en)
        begin

            case(state)


            // ================= START STATE =================
            start_state:
            begin

                if(rx)
                    sample <= 0;

                else
                begin

                    if(sample == 7)
                    begin
                        sample <= 0;
                        index <= 0;
                        state <= data_out_state;
                    end

                    else
                        sample <= sample + 1'b1;

                end

            end


            // ================= DATA STATE =================
            data_out_state:
            begin

                if(sample == 8)
                begin
                    temp_register[index] <= rx;
                    index <= index + 1'b1;
                end


                if(index == 8 && sample == 15)
                begin
                    state <= stop_state;
                    sample <= 0;
                end

                else
                    sample <= sample + 1'b1;

            end


            // ================= STOP STATE =================
            stop_state:
            begin

                if(sample == 15)
                begin

                    // Accept received data only if stop bit is high
                    if(rx)
                    begin
                        data_out <= temp_register;
                        rdy <= 1'b1;
                    end

                    state <= start_state;
                    sample <= 0;

                end

                else
                    sample <= sample + 1'b1;

            end


            default:
            begin
                state <= start_state;
                sample <= 0;
            end


            endcase

        end

    end

end

endmodule
