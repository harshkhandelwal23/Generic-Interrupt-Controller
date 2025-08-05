//---------------------------------------------
// File: intc_reg_block.sv
//---------------------------------------------

// Individual Register Classes
`include "uvm_macros.svh"
import uvm_pkg::*;
class INT_ENABLE #(int N = 10) extends uvm_reg;
  rand uvm_reg_field enable;
  `uvm_object_utils(INT_ENABLE #(N))

  function new(string name = "INT_ENABLE");
    super.new(name, N, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
      enable = uvm_reg_field::type_id::create("enable");
      enable.configure(this, N , 0, "RW", 0, 0, 1, 1, 0);
  endfunction
endclass

class INT_MASK #(int N = 10) extends uvm_reg;
  rand uvm_reg_field mask;
  `uvm_object_utils(INT_MASK #(N))

  function new(string name = "INT_MASK");
    super.new(name, N, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    mask = uvm_reg_field::type_id::create("mask");
    mask.configure(this, N, 0, "RW", 0, 0, 1, 1, 0);
  endfunction
endclass

/*class INT_PRIORITY #(int N = 10, int P = 3) extends uvm_reg;
  rand uvm_reg_field prior;
  `uvm_object_utils(INT_PRIORITY)

  function new(string name = "INT_PRIORITY");
    super.new(name, N*P, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    prior = uvm_reg_field::type_id::create("prior");
    prior.configure(this, N*P, 0, "RW", 0, 0, 1, 1, 0);
  endfunction
endclass*/
class int_priority_reg #(int P = 3) extends uvm_reg;
  rand uvm_reg_field prior;
  `uvm_object_utils(int_priority_reg)
  function new(string name = "int_priority_reg");
    super.new(name, P, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    prior = uvm_reg_field::type_id::create("prior");
    prior.configure(this, P, 0, "RW", 0, 0, 1, 0, 0);
  endfunction
endclass


class INT_STATUS #(int N = 10) extends uvm_reg;
  rand uvm_reg_field status;
  `uvm_object_utils(INT_STATUS)

  function new(string name = "INT_STATUS");
    super.new(name, N, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
      status = uvm_reg_field::type_id::create("status");
      status.configure(this, N, 0, "RO", 0, 0, 1, 1, 0);
  endfunction
endclass

class INT_CLEAR #(int N = 10) extends uvm_reg;
  rand uvm_reg_field clr;
  `uvm_object_utils(INT_CLEAR)

  function new(string name = "INT_CLEAR");
    super.new(name, N, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
      clr = uvm_reg_field::type_id::create("clr");
      clr.configure(this, N, 0, "WO", 0, 0, 1, 1, 0);
  endfunction
endclass

class OUT_MODE extends uvm_reg;
  rand uvm_reg_field mode;
  `uvm_object_utils(OUT_MODE)

  function new(string name = "OUT_MODE");
    super.new(name, 1, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    mode = uvm_reg_field::type_id::create("mode");
    mode.configure(this, 1, 0, "RW", 0, 0, 1, 1, 0);
  endfunction
endclass

class OUT_POLARITY extends uvm_reg;
  rand uvm_reg_field polarity;
  `uvm_object_utils(OUT_POLARITY)

  function new(string name = "OUT_POLARITY");
    super.new(name, 1, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    polarity = uvm_reg_field::type_id::create("polarity");
    polarity.configure(this, 1, 0, "RW", 0, 0, 1, 1, 0);
  endfunction
endclass

class PULSE_WIDTH #(int W = 4) extends uvm_reg;
  rand uvm_reg_field width;
  `uvm_object_utils(PULSE_WIDTH)

  function new(string name = "PULSE_WIDTH");
    super.new(name, W, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    width = uvm_reg_field::type_id::create("width");
    width.configure(this, W, 0, "RW", 0, 0, 1, 1, 0);
  endfunction
endclass

// Register Block Class
class intc_reg_block extends uvm_reg_block;
  `uvm_object_utils(intc_reg_block)
  localparam int N = 10;
  rand INT_ENABLE int_enable;
  rand INT_MASK int_mask;
  rand int_priority_reg priority_regs[N];
  INT_STATUS int_status;
  rand INT_CLEAR int_clear;
  rand OUT_MODE out_mode;
  rand OUT_POLARITY out_polarity;
  rand PULSE_WIDTH pulse_width;

  //localparam int N = 10;
  localparam int P = 3;
  localparam int W = 4;

  function new(string name = "intc_reg_block");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    int_enable = INT_ENABLE#(N)::type_id::create("int_enable");
    int_enable.build();
    int_enable.configure(this);

    int_mask = INT_MASK#(N)::type_id::create("int_mask");
    int_mask.build();
    int_mask.configure(this);

    /*int_priority = INT_PRIORITY#(N,P)::type_id::create("int_priority");
    int_priority.build();
    int_priority.configure(this);*/

    // Priority (multiple registers)
    for (int i = 0; i < N; i++) begin
      priority_regs[i] = int_priority_reg#(P)::type_id::create($sformatf("priority_%0d", i));
      priority_regs[i].build();
      priority_regs[i].configure(this);
    end

    int_status = INT_STATUS#(N)::type_id::create("int_status");
    int_status.build();
    int_status.configure(this);

    int_clear = INT_CLEAR#(N)::type_id::create("int_clear");
    int_clear.build();
    int_clear.configure(this);

    out_mode = OUT_MODE::type_id::create("out_mode");
    out_mode.build();
    out_mode.configure(this);

    out_polarity = OUT_POLARITY::type_id::create("out_polarity");
    out_polarity.build();
    out_polarity.configure(this);

    pulse_width = PULSE_WIDTH#(W)::type_id::create("pulse_width");
    pulse_width.build();
    pulse_width.configure(this);
    
    default_map = create_map("my_map", 0, 4, UVM_LITTLE_ENDIAN);
    default_map.add_reg(int_enable,'h00, "RW");
    default_map.add_reg(int_mask,'h04, "RW");
    //default_map.add_reg(int_priority,'h20, "RW");
    default_map.add_reg(int_status,'h18, "RO");
    default_map.add_reg(int_clear,'h08, "WO");
    default_map.add_reg(out_mode,'h0C, "RW");
    default_map.add_reg(out_polarity,'h10, "RW");
    default_map.add_reg(pulse_width,'h14, "RW");
     // Add priority registers at base 'h20
    for (int i = 0; i < N; i++) begin
      default_map.add_reg(priority_regs[i], 'h20 + 4*i, "RW");
    end
    lock_model();
  endfunction
endclass
