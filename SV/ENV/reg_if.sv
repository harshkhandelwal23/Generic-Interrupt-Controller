interface reg_if(input logic clk, rst_n);

  logic [7:0]  addr;
  logic        wr_en;
  logic        rd_en;
  logic [31:0] wdata;
  logic [31:0] rdata;

  clocking driver_cb @(posedge clk);
    default input #0 output #0;
    output addr;
    output wr_en;
    output rd_en;
    output wdata;
    input  rdata;
  endclocking

  clocking monitor_cb @(posedge clk);
    default input #0 output #0;
    input addr;
    input wr_en;
    input rd_en;
    input wdata;
    input rdata;
  endclocking

  modport DRIVER  (clocking driver_cb);
  modport MONITOR (clocking monitor_cb);

endinterface
