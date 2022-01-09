// test case for teating the DUT

//import package files::*;
`include "environment.sv"

program rd_test(intf t_intf,intf t_intf1);  //  program module which is creating the test
    bit flag =0;
    environment env,env1;
    virtual intf tbm,tbm1;
    
initial begin
    tbm=t_intf;
    tbm1=t_intf1;
  env = new(t_intf,0);  //constructor for environment 
    env.gen.no_tr=1; // number of transections are 7
  env1 = new(t_intf1,1);
   	env1.gen.no_tr=1;
  fork
    begin :master1
    	env.run();
    end//3in the environment 
    begin :master2
    	env1.run();
    end  
  join_none
   forever
     begin
       @(tbm.clk)
       begin
            if(tbm.test.cb_test.sda!=tbm.test.cb_test.SDA || tbm1.test.cb_test.sda!=tbm1.test.cb_test.SDA)
             begin
               if(tbm.test.cb_test.sda==1 && flag==0)
                 begin
                   tbm.test.cb_test.sda<=1;
                   tbm.test.cb_test.scl<=1;
                   disable master1;
                   flag=1;
                   $display("arbitration of master 1");
                 end
               else
                 begin
                   if(flag==0)
                   begin  
                     tbm1.test.cb_test.sda<=1;
                     tbm1.test.cb_test.scl<=1;
                     disable master2;
                     flag=1;
                     $display("arbitration of master 2");
                   end
                 end
             end 
       end
     end
end
endprogram
//$display(" sda = %b SDA = %b time = %t",tbm.sda,tbm1.SDA,$time);