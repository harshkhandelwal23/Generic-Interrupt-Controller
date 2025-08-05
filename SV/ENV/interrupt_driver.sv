//----------------------------------------------------------------------------------------------------//
// File Name : interrupt_driver.sv
// ---------------------------------------------------------------------------------------------------//
class interrupt_driver extends uvm_driver#(interrupt_seq_item);
  // Factory registration
  `uvm_component_utils(interrupt_driver)

  //Virtual Interface Handle
  virtual int_if vif;

//----------------------------------------------------------------------------------------------------//
// New constructor
// ---------------------------------------------------------------------------------------------------//
  function new(string name = "interrupt_driver",uvm_component parent = null);
    super.new(name,parent);
  endfunction

//----------------------------------------------------------------------------------------------------//
// Build Phase
// ---------------------------------------------------------------------------------------------------//
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual int_if) :: get (this, "", "vif", vif)) 
      begin
        `uvm_fatal (get_type_name(), "Didn't get the virtual interface handle int_if");
      end
  endfunction

//----------------------------------------------------------------------------------------------------//
// Run Phase
// ---------------------------------------------------------------------------------------------------//
  virtual task run_phase (uvm_phase phase);
      super.run_phase(phase);
      forever begin
        if (!vif.rst_n) 
          begin
            //seq_item_port.get_next_item(req);
            vif.cb_drv.int_in <= 0;
            //seq_item_port.item_done();
            `uvm_info(get_type_name(), $sformatf("Driver has been reset %0t", $time), UVM_NONE);
            //wait(vif.rst_n);
          end
        else
          begin
            //`uvm_info(get_type_name(), $sformatf("Before driver: get_next_item at time %0t", $time), UVM_NONE);
            seq_item_port.get_next_item(req);
            //`uvm_info(get_type_name(), $sformatf("After driver: get_next_item = %b at time %0t",req.int_in, $time), UVM_NONE);
            @(posedge vif.cb_drv)
            vif.cb_drv.int_in <= req.int_in;
            `uvm_info(get_type_name(), $sformatf("before item done driving int_in = %0h",req.int_in),UVM_LOW);
            seq_item_port.item_done();
            //`uvm_info(get_type_name(), $sformatf("after item done int_in = %b",req.int_in),UVM_LOW);
          end
      end
  endtask
endclass
