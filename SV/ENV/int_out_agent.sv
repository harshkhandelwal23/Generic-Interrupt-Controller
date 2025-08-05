// int_out_agent.sv
class int_out_agent extends uvm_agent;
  `uvm_component_utils(int_out_agent)

  int_out_monitor mon2;

  function new(string name = "int_out_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon2 = int_out_monitor::type_id::create("mon2", this);
  endfunction

endclass
