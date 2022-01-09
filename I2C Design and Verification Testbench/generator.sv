//generator class generates the data according to the defination of the transaction class and puts it into the mailboxes for driver

`ifndef GEN  //guard to avoid recompilation
`define GEN
class generator;

    mailbox gen2drv; // mailbox to connect the generator and driver
    transaction tr;  //instance of transaction class
    int no_tr;
  function new(mailbox gen2drv); //constructor for mailbox
        this.gen2drv=gen2drv;
    endfunction //new()

    event ended;

    task main();

      repeat (no_tr)begin  //no_tr times generates the input
        tr=new();  //constructiong thr tr object
        if(!tr.randomize())$fatal("gen:: trans randomization failed");  //cheking that randimization process is sucessfull or not
        tr.display("[generator]"); //display generated data
        gen2drv.put(tr);  //putting generated data into mailbox so it can reach at driver
        end
        ->ended; //triggering indicatesthe end of generation
    endtask

endclass //generator
`endif
   