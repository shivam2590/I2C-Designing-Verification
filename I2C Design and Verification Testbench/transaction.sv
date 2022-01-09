//creating the buch of inputs and binding it in class

`ifndef TRANS  //guard to avoid recompilation
`define TRANS

class transaction;
  bit [6:0]address= 7'b1010111;  //slave adress  the inputs
  bit [6:0]address1=7'b1011111; 
  rand bit rw;   //randomizing the inputs
  rand bit rw1;
  rand bit [7:0] data;  //randomizing the inputs
  rand bit [7:0] data1; 
  bit [7:0] r_data;
  bit [7:0] r_data1;
  bit[7:0] smp_data;
  bit[7:0] smp_data1;
  bit[7:0] smp_read;
  bit[7:0] smp_read1;

  function void display(string name);  //display function to observe the data

    $display("-------------------------");
    $display("- %s ",name);
    $display("-------------------------");
    $display("- address = %0d, r_w = %0b",address,rw);
    $display("- data = %0d",data);
    $display("- address1 = %0d, r_w1 = %0b",address1,rw1);
    $display("- data1 = %0d",data1);
    $display("-------------------------");
    if(rw)
        begin
        $display("- r_data=%d",r_data);
        $display("-------------------------");
         
    end
    if(rw1)
        begin
          $display("- r_data1 =%d",r_data1);
        $display("-------------------------");
         
    end

    endfunction
endclass //transection
`endif 