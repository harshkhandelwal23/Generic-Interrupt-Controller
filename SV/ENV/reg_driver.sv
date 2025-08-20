//----------------------------------------------------------------------------------------------------//
// File Name : Reg driver.sv
// ---------------------------------------------------------------------------------------------------//
class reg_driver extends uvm_driver #(reg_seq_item);
  `uvm_component_utils(reg_driver)

//----------------------------------------------------------------------------------------------------//
// Interface Handle
// ---------------------------------------------------------------------------------------------------//
  virtual reg_if reg_vif;

//----------------------------------------------------------------------------------------------------//
// seq item Handle
// ---------------------------------------------------------------------------------------------------//
  reg_seq_item item;

//----------------------------------------------------------------------------------------------------//
// Constructor
// ---------------------------------------------------------------------------------------------------//
  function new(string name = "reg_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

//----------------------------------------------------------------------------------------------------//
// Build Phase
// ---------------------------------------------------------------------------------------------------//
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual reg_if)::get(this, "", "reg_vif", reg_vif))
      `uvm_fatal("REG_DRIVER", "reg_vif not set")
  endfunction

//----------------------------------------------------------------------------------------------------//
// Run Phase
// ---------------------------------------------------------------------------------------------------//
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever 
      begin
        if (!reg_vif.rst_n) 
        //if (0) 
          begin 
            //`uvm_info(get_type_name(), $sformatf("Before Reset"), UVM_MEDIUM)
            reg_vif.addr  <= 0; //Reset condition
            reg_vif.wr_en <= 0;
            reg_vif.rd_en <= 0;
            reg_vif.wdata <= 0;
            //`uvm_info(get_type_name(), $sformatf("After Reset"), UVM_MEDIUM)
            wait(reg_vif.rst_n);
          end
        else 
          begin
            //`uvm_info(get_type_name(), $sformatf("Before Get next item"), UVM_MEDIUM)
            seq_item_port.get_next_item(item);
            //`uvm_info(get_type_name(), $sformatf("after Get next item = %0h %0h",item.addr,item.we), UVM_MEDIUM)
            @(posedge reg_vif.clk);
            //`uvm_info(get_type_name(), $sformatf("after2 Get next item"), UVM_MEDIUM)
            reg_vif.addr  <= item.addr;
            reg_vif.wdata <= item.wdata;
            if (item.we) 
              begin
              reg_vif.wr_en <= 1;
              reg_vif.rd_en <= 0;
              //`uvm_info(get_type_name(), $sformatf("Sending WRITE to addr: 0x%0h data: 0x%0h", item.addr, item.wdata), UVM_MEDIUM)
              end 
            else 
              begin
              reg_vif.rd_en <= 1;
              reg_vif.wr_en <= 0;
              //`uvm_info(get_type_name(), $sformatf("Sending READ to addr: 0x%0h", item.addr), UVM_MEDIUM)
              end
            //`uvm_info(get_type_name(), $sformatf("after3 Get next item"), UVM_MEDIUM)
            //@(reg_vif.driver_cb);
            // Capture rdata for READ
            //if (!item.we) 
            //  begin
            //    item.rdata = reg_vif.rdata;
            //   end
            // Deassert controls
            //reg_vif.wr_en <= 0;
            //reg_vif.rd_en <= 0;
            //@(reg_vif.driver_cb); // Ensure signals settle
            seq_item_port.item_done();
          end
    end
  endtask
endclass
