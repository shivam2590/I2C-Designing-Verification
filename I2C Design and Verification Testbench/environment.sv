//environment class combines all the classes ..it create environmet for the test

//import package files::*;

`include "transaction.sv"//including files
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

`ifndef ENV  ////guard to avoid recompilation
`define ENV
class environment;

   generator gen;  //instance of the generator
   driver drv;  //instance of the driver
   monitor mon;//instance of the monitor
   scoreboard scb; //instance of the  scoreboard

    mailbox gen2drv; //mailboxes for constructor
    mailbox mon2scb; //

    virtual intf e_intf;
 
	bit m_select;
  function new(virtual intf e_intf,bit m_select);  //constructor (Master selection)
        this.e_intf=e_intf;
        this.m_select=m_select;
        gen2drv=new();
        mon2scb=new();

    gen=new(gen2drv);      //constructiong all the instance 
    drv=new(gen2drv,e_intf,m_select);
    mon=new(e_intf,mon2scb);
    scb=new(mon2scb);
    endfunction

  task pre_test();    //testing the functionality of the reset
            drv.reset();
        endtask

  task test();   //running all the things in parallel like applying input by driver then generation of output according to the input, capturing the responces in the monitor and chaking it by scoreboard..
            fork
                gen.main();
                drv.main();
                mon.main();
                scb.main();
            join_any  
        endtask

 task post_test();//cheking that desired number of stimulus is generated or not..
            wait(gen.ended.triggered);
            wait(gen.no_tr == drv.no_tr); //Optional
          //  wait(gen.no_tr == scb.no_tr);
        endtask  
  
        
        task automatic run;
        
           begin
              pre_test(); //run all test one by one 
                test();
                post_test();
                $finish;
           end
        
        endtask

endclass //environment
`endif