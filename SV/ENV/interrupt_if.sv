//----------------------------------------------------------------------------------------------------//
// File Name : int_if.sv
// ---------------------------------------------------------------------------------------------------//
interface int_if #(parameter int N = 10) (input logic clk,rst_n);

    //Input Signal declaration
    logic [N-1:0] int_in;

    //Output signal declaration
    logic int_out;


//----------------------------------------------------------------------------------------------------//
// Clocking Block for the driver of the Interrupt agent
// ---------------------------------------------------------------------------------------------------//
    clocking cb_drv @(posedge clk); //interrupt agent driver clocking block
        default input #1 output #1;
        output int_in;
    endclocking

//----------------------------------------------------------------------------------------------------//
// Clocking Block for the monitor of the Interrupt agent
// ---------------------------------------------------------------------------------------------------//
    clocking cb_mon @(posedge clk); //interrupt agent monitor clocking block
        default input #1 output #1;
        input int_in;
        input int_out;
    endclocking

//----------------------------------------------------------------------------------------------------//
// Modport for the driver of interrupt agent
// ---------------------------------------------------------------------------------------------------//
    modport DRV (clocking cb_drv);

//----------------------------------------------------------------------------------------------------//
// Modport for the Monitor of interrupt agent
// ---------------------------------------------------------------------------------------------------//
    modport MON (clocking cb_mon);
//---------------------------ASSERTION----------------------------------------------------------------//
    //property p_int_in_to_out;
    //@(posedge clk) disable iff (!reset_n)
    //(|int_in) |=> int_out;
    //endproperty
    //a_int_in_to_out: assert property(p_int_in_to_out)
    //else $error("int_out did not assert on next clock after int_in");

endinterface
