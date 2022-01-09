

`include "environment.sv" //including the file 
`include "test.sv"
`include "interface.sv"


module tb;

bit clk;  
bit rst;

    always #1250 clk=~clk;  //clock generator


initial begin
    rst=1;    //reseting the DUT
    #2500 rst=0;
end

  intf tb_intf(clk,rst);
  //intf tbm_intf(clk,rst);
//intf.DUT dut_intf(clk);
  intf tb_intf1(clk,rst);

  rd_test t(tb_intf,tb_intf1);  //creating the instance of the test and giving it's interface  as argument 
  
  AND a(.out(tb_intf.sda_out),.sda_1(tb_intf.sda),.sda_2(tb_intf1.sda));
  
  Slave DUT(.SCL(tb_intf.scl&tb_intf1.scl),.SDA(tb_intf.sda_out),.DATA_out(tb_intf.out),.DATA_read(tb_intf.read),.sample_sda(tb_intf.SDA),.sample_sda1(tb_intf1.SDA));

  

  initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
	end 
  
  
endmodule