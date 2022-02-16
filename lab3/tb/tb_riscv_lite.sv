//`timescale 1ns

module tb_riscv_lite ();

   const int DRAM_ADDRESS_LENGTH = 5;
   const int IRAM_ADDRESS_LENGTH = 8;
   const time CLK_PHASE_HI       = 5ns;
   const time CLK_PHASE_LO       = 5ns;
   const time CLK_PERIOD         = CLK_PHASE_HI + CLK_PHASE_LO;
   const time STIM_APPLICATION_DEL = CLK_PERIOD * 0.1;
   const time RESP_ACQUISITION_DEL = CLK_PERIOD * 0.9;
   const time RESET_DEL = STIM_APPLICATION_DEL;
   const int  RESET_WAIT_CYCLES  = 4;

   logic CLK_i;
   logic RST_n_i;
   logic RST_n_ram;
   wire [31:0]DRAM_datao_i;
   wire [31:0]IRAM_datao_i;
   wire [31:0]DRAM_addr_i;
   wire [31:0]IRAM_addr_i;
   wire [31:0]DRAM_datai_i;
   wire [31:0]IRAM_datai_i;
   logic DRAM_read_en_i;
   logic DRAM_write_en_i;
   logic IRAM_read_en_i;
   logic IRAM_write_en_i;

 initial begin
        if ($test$plusargs("vcd")) begin
            $dumpfile("riscv_tb.vcd");
            $dumpvars(2, tb_riscv_lite);
        end
 end
string firmware,data;

// we load the firmware in the instruction memory
// and fill the data memory
initial begin: load_prog
    repeat (RESET_WAIT_CYCLES - 2) begin
        @(posedge CLK_i); 
    end
    if($value$plusargs("firmware=%s", firmware)) begin
        if($test$plusargs("verbose"))
            $display("[TESTBENCH] %t: loading firmware %0s ...",
                     $time, firmware);
        //Command to read the firmware, it will save it in the instruction memory
        //starting from the first cell ('h0)
        $readmemh(firmware, iram.mem,'h0);
    end else begin
        $display("No firmware specified");
        $finish;
    end
    if($value$plusargs("data=%s", data)) begin
        if($test$plusargs("verbose"))
            $display("[TESTBENCH] %t: loading data %0s ...",
                     $time, data);
        //Command to read the data, it will save it in the data memory
        //starting from the first cell ('h0)
        $readmemh(data, dram.mem,'h0);
    end else begin
        $display("No data specified");
        $finish;
    end

end


 initial begin: clock_gen
        forever begin
            #CLK_PHASE_HI CLK_i = 1'b0;
            #CLK_PHASE_LO CLK_i = 1'b1;
        end
    end: clock_gen

    // reset generation
    initial begin: reset_gen
        RST_n_i          = 1'b0;
        RST_n_ram          = 1'b0;
        IRAM_write_en_i = '0;
        //IRAM_read_en_i = '1;
        // wait a few cycles
        repeat (1) begin
            @(posedge  CLK_i);
        end
        RST_n_ram = 1'b1;
        repeat (RESET_WAIT_CYCLES - 1) begin
            @(posedge CLK_i); 
        end

        // start running
        #RESET_DEL RST_n_i = 1'b1;
           
           

        if($test$plusargs("verbose"))
            $display("reset deasserted", $time);

    end: reset_gen

  RISCV_lite UUT(.clock(CLK_i),
      .reset_n(RST_n_i),
      .DRAM_data_out(DRAM_datao_i),
      .IRAM_data_out(IRAM_datao_i) ,
      .DRAM_addr(DRAM_addr_i),     
      .IRAM_addr(IRAM_addr_i),
      .DRAM_data_in(DRAM_datai_i),  
      .DRAM_Read_EN(DRAM_read_en_i),  
      .DRAM_Write_EN(DRAM_write_en_i), 
      .IRAM_Read_EN(IRAM_read_en_i));
   

//We use a reduced address in order to simulate a smaller memory, but the RISCV can support memories with up to 32
//bits of addressing
wire[5:0] dram_reduced_addr;
assign dram_reduced_addr = DRAM_addr_i[5:0];
    ram_mem
   #( .ADDR_WIDTH(6))
   dram
   (  .clk(CLK_i),
      .reset_n(RST_n_ram),
      .mem_write(DRAM_write_en_i),
      .mem_read(DRAM_read_en_i),
      .addr(dram_reduced_addr),
      .DATA_In(DRAM_datai_i),
      .DATA_Out(DRAM_datao_i));

//We use a reduced address in order to simulate a smaller memory, but the RISCV can support memories with up to 32
//bits of addressing
wire[6:0] iram_shifted_addr;
assign iram_shifted_addr = IRAM_addr_i[6:0];
    ram_mem
   #( .ADDR_WIDTH(7))
   iram
   (  .clk(CLK_i),
      .reset_n(RST_n_ram),
      .mem_write(IRAM_write_en_i),
      .mem_read(IRAM_read_en_i),
      .addr(iram_shifted_addr),
      .DATA_In(IRAM_datai_i),
      .DATA_Out(IRAM_datao_i));

endmodule

