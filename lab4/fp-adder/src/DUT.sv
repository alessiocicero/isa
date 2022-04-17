module DUT(dut_if.port_in in_inter, dut_if.port_out out_inter, output enum logic [1:0] {INITIAL,WAIT,SEND,WAIT_PIP} state);
    
    FPmul multiplier_under_test(.FP_A(in_inter.A),.FP_B(in_inter.B),.CLK(in_inter.clk),.rst_p(in_inter.rst),.FP_Z(out_inter.data));
    //int out_file = $fopen("file.csv"); 
    int pip_counter;
    always_ff @(posedge in_inter.clk)
    begin
        if(in_inter.rst) begin
            pip_counter <= 0;
            in_inter.ready <= 0;
            out_inter.data <= 'x;
            out_inter.valid <= 0;
            state <= INITIAL;
        end
        else case(state)
                INITIAL: begin
                    in_inter.ready <= 1;
                    state <= WAIT;
                end
                WAIT: begin
                    if(in_inter.valid) begin
                        in_inter.ready <= 0;
                        //out_inter.data <= in_inter.A + in_inter.B;
                        $display("FP_mult_hex: input A = %x, input B = %x",in_inter.A,in_inter.B);
                        $display("FP_mult_float: input A = %3.9f, input B = %3.9f",$bitstoshortreal(in_inter.A), $bitstoshortreal(in_inter.B));
                        //$fwrite(out_file,"%3.9f,%3.9f\n", $bitstoshortreal(in_inter.A), $bitstoshortreal(in_inter.B));
                        out_inter.valid <= 0; 
                        pip_counter <= pip_counter + 1;
                        state <= WAIT_PIP;
                    end
                end
                
                WAIT_PIP: begin
                    in_inter.ready <= 0;
                    if (pip_counter < 4) begin
                        pip_counter <= pip_counter +1;
                        out_inter.valid <= 0;
                        state <= WAIT_PIP;
                    end
                    else begin
                        pip_counter <= 0;
                        out_inter.valid <= 1;
                        state <= SEND;
                    end
                end

                SEND: begin
                    if(out_inter.ready) begin
                        pip_counter <= 0;
                        $display("FP_mult_float_pip: output OUT = %x | %3.9f",out_inter.data, $bitstoshortreal(out_inter.data));
                        out_inter.valid <= 0;
                        in_inter.ready <= 1;
                        state <= WAIT;
                    end
                end
        endcase
    end
endmodule: DUT
