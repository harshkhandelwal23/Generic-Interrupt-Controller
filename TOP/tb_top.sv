//----------------------------------------------------------------------------------------------------//
// File Name : tb_top.sv
// ---------------------------------------------------------------------------------------------------//
//`timescale 1ns / 1ps

// TODO add into command
`include "uvm_macros.svh"
import uvm_pkg::*;
import pkg::*;
 
module tb_top;

  //clock declaration

  logic clk;

  //reset declaration
  logic rst_n;

//----------------------------------------------------------------------------------------------------//
// DUT Instantiation : 
// ---------------------------------------------------------------------------------------------------//
  reg_core #(.N(10),
      .P(3),
      .W(8) 
      ) dut (
      .clk (intf.clk), 
      .rst_n (intf.rst_n),
      .int_in (intf.int_in),
      .int_out (intf.int_out),
      .wr_en (reg_vif.wr_en),
      .rd_en (reg_vif.rd_en),
      .addr (reg_vif.addr),
      .wdata (reg_vif.wdata),
      .rdata (reg_vif.rdata)
      );
//----------------------------------------------------------------------------------------------------//
// Interface Instantiation
// ---------------------------------------------------------------------------------------------------//
  int_if #(10) intf (.clk(clk), .rst_n(rst_n));

//----------------------------------------------------------------------------------------------------//
// Register Interface Instantiation
// ---------------------------------------------------------------------------------------------------//
  reg_if reg_vif(.clk(clk), .rst_n(rst_n)); // Actual instance of the interface

  //Clock Generation
  initial begin
  forever #5 clk = ~clk; //TODO : variable frequency
  end

  initial 
    begin
      clk = 0;
      rst_n = 1; //TODO: RESET ON FLY
      //#10 rst_n = 0;
      //#20 rst_n = 1;
    end
 
//----------------------------------------------------------------------------------------------------//
// Config_db Set and Run_test
// ---------------------------------------------------------------------------------------------------//
  initial 
    begin
      uvm_config_db#(virtual int_if)::set(null, "*", "vif", intf);
      uvm_config_db#(virtual reg_if)::set(null, "*", "reg_vif", reg_vif);
    end

  initial begin
    run_test();
  end 

  //initial begin
      //#1000;
      //$finish;
  //end
endmodule
