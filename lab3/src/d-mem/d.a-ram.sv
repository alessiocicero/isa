module ram_mem
   #( parameter ADDR_WIDTH = 20)
   (  input logic clk,
      input logic reset_n,
      input logic mem_write,
      input logic mem_read,
      input logic [ADDR_WIDTH - 1:0]addr,
      input logic [31:0]DATA_In,
      output logic [31:0]DATA_Out);

   localparam MEM_SIZE = 2 ** ADDR_WIDTH;
   logic [7:0] mem[MEM_SIZE];

   always @(posedge clk) begin
      if (!reset_n) begin
         for(int i=0; i < MEM_SIZE;i++) begin   
            mem[i] <= 8'b0;
         end
      end // if (reset_n)
      else begin
         if (mem_read) begin 
            DATA_Out[7:0]     <= mem [addr]; 
            DATA_Out[15:8]    <= mem [addr + 1];
            DATA_Out[23:16]   <= mem [addr + 2];
            DATA_Out[31:24]   <= mem [addr + 3];
         end // if (mem_read)
         if (mem_write) begin
            //mem [addr] <= DATA_In;
            mem[addr] <= DATA_In[ 0+:8];
            mem[addr + 1] <= DATA_In[ 8+:8];
            mem[addr + 2] <= DATA_In[16+:8];
            mem[addr + 3] <= DATA_In[24+:8];
         end // if (mem_write)
      end
   end // always @(posedge clk)
endmodule