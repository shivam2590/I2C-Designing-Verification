//interface is connection between the DUT and the 

// Code your testbench here
// or browse Examples
`ifndef INTF ////guard to avoid recompilation
`define INTF
interface intf(input logic clk,rst);  //interface argument we are providing the clk and rst externally ..
  
  logic scl; //interface connection
  logic sda;
  logic [7:0] out;
  logic [7:0] read;
  logic SDA ; // to sample the data
   // bit rst;
  wire sda_out;
  clocking cb_test @(clk);
    	inout sda;
        output scl;
        input SDA;
  endclocking 
 
  clocking cb_driver @(clk);  //clcking block for synchronization
    	inout scl;
    	inout sda;
      	input out;
    	input read;
    	input SDA;
  endclocking
  
  clocking cb_monitor @(clk);  //clcking block for synchronization
    input scl;
    input sda;
    input out;
    input read;
    input SDA;
  endclocking 

  //modport DUT ( input a,b,cin,clk,rst, output sum,carry );
  modport drv (clocking cb_driver,input rst);  //modport is usefull to define the direction like input/output for the perticular connection 
  modport mon (clocking cb_monitor,input rst ); //
  modport test (clocking cb_test);  
endinterface 
`endif
    
    