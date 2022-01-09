// scoreboard is for to check the correctens of the operation perfomed by the DUT on inputs..

`ifndef SB ////guard to avoid recompilation
`define SB
class scoreboard;

    mailbox mon2scb;  //mailbox toget the data from the monitor
   
    int no_tr;  // no of trnasection for the scoreboard.. 
  function new(mailbox mon2scb);  //constructor  for mailbox.
    this.mon2scb=mon2scb;//
    endfunction //new()

    task main;
		  transaction tr;  //transaction instance for the scoreboard
  
          tr = new();
        
        forever begin
         
          mon2scb.get(tr);
          
        // compare logic.....
          if(tr.rw==0)
            begin
                if(tr.smp_data==tr.data)
                  begin
                    $display("------------------write_test_pass-----------------");
                    $display("actual data=%d   expected data=%d",tr.smp_data,tr.data);
                    $display("---------------------------------------------");
                   // $display("check_time=%d",$time);
                  end
                  else begin
                    $display("***********write_test_fail***********");
                    $display("actual data=%d   expected data=%d",tr.smp_data,tr.data);
                  end
            end
          else
            begin
              if(tr.r_data==tr.smp_read)
                  begin
                    $display("------------------read_test_pass-----------------");
                    $display("actual data=%d   expected data=%d",tr.r_data,tr.smp_read);
                    $display("---------------------------------------------");
                   // $display("check_time=%d",$time);
                  end
                  else begin
                    $display("**********read_test_fail**********");
                    $display("actual data=%d   expected data=%d",tr.r_data,tr.smp_read);
                  end
            end
          no_tr++;
        end
        
    endtask

endclass //scoreboard
`endif