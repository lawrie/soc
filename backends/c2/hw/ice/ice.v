module uartmm(input clk,
              input             rst,

              input             RX,
              output            TX,
              
              output reg [31:0] data_b,
              output reg        strobe_b,
              input [31:0]      addr_b,
              input [31:0]      data_b_in,
              input [31:0]      data_b_we);

   wire [7:0]                uart_din;
   wire                      uart_valid;
   wire                      uart_ready;
   reg                       uart_wr;
   reg                       uart_rd;
   reg [7:0]                 uart_dout;

   reg [7:0]                 uart_din_r;
   reg                      uart_valid_r;
   reg                      uart_ready_r;
   
   
   wire                 uart_RXD;
   inpin _rcxd(.clk(clk), .pin(RX), .rd(uart_RXD));

   wire                     uart_busy;

   assign uart_ready = ~uart_busy;
   
   buart _uart (
                .clk(clk),
                .resetq(1'b1),
                .rx(uart_RXD),
                .tx(TX),
                .rd(uart_rd),
                .wr(uart_wr),
                .valid(uart_valid),
                .busy(uart_busy),
                .tx_data(uart_dout),
                .rx_data(uart_din));

   wire                     strobe_b_next;
   wire [31:0]              data_b_next;
   

   assign strobe_b_next =   (addr_b == 65537) | (addr_b == 65538) | (addr_b == 65539);
   assign data_b_next = (addr_b == 65537)?uart_valid_r:
                        (addr_b == 65538)?uart_ready_r:
                        (addr_b == 65539)?uart_din_r:0;

   always @(posedge clk)
     if (~rst) begin
        uart_wr <= 0;
        uart_rd <= 0;
        uart_valid_r <= 0;
        uart_din_r <= 0;
        uart_dout <= 0;
        strobe_b <= 0;
        data_b <= 0;
        
     end else begin
        strobe_b <= strobe_b_next;
        data_b <= data_b_next;
        
        if (uart_wr) begin
           uart_wr <= 0;
        end
        
        if (uart_valid & ~uart_rd) begin
           uart_rd <= 1; // TODO: read into a FIFO / raise an IRQ (when we had a support for them)
        end

        uart_ready_r <= uart_ready; // delay

        if (uart_rd) begin
           uart_rd <= 0;
           uart_din_r <= uart_din;
           uart_valid_r <= 1;
        end else if ((addr_b == 65539) & ~data_b_we & uart_valid_r) begin
           uart_valid_r <= 0;
        end else if ((addr_b == 65539) & data_b_we & uart_ready & ~uart_wr) begin
           uart_dout <= data_b[7:0];
           uart_wr <= 1;
        end
     end
   

endmodule

module ledwriter (input clk,
                  input rst,

                  output reg [7:0] LED,
                  
                  input [31:0]     addr_b,
                  input [31:0]     data_b_in,
                  input [31:0]     data_b_we);

   always @(posedge clk)
     if (~rst) begin
        LED <= 0;
     end else begin
        if (addr_b == 65540)
          LED <= data_b_in[7:0];
     end

endmodule


// TODO:
// implement a 2-port RAM by using a double clock frequency + a single port
module socram(input clk,
              input             rst,

              output reg [31:0] data_a,
              input [31:0]      addr_a,
              
              output reg [31:0] data_b,
              output reg        strobe_b,
              input [31:0]      addr_b,
              input [31:0]      data_b_in,
              input [31:0]      data_b_we);

   parameter RAM_DEPTH = 1024;
`ifdef ENABLE_EXT
   parameter INIT_FILE = "../../custom_ice.hex";
`else
   parameter INIT_FILE = "ram.hex";
`endif
   
   reg [31:0]                   mem [0:RAM_DEPTH-1];
   
   initial begin
      if (INIT_FILE != "")
         $readmemh(INIT_FILE, mem);
   end

   
   always @(posedge clk)
     begin
        if (data_b_we & (addr_b[31:16] == 0)) begin
           mem[addr_b] <= data_b_in;
        end
        data_a <= mem[addr_a];
        data_b <= mem[addr_b];
        strobe_b <= (addr_b[31:16] == 0);
     end
   
endmodule
