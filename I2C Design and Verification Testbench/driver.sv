// driver devides buch of tinput(transection) according to the output of the dut it put the input data in the interface.
  
`ifndef DRV   //guard to avoid recompilation
`define DRV
class driver;
    mailbox gen2drv;  // mailbox to connect the generator and driver 
    virtual intf d_intf; //interface instance to connect the testbech to the DUT
    int no_tr;
  	bit m_select;
  	bit reWr;	//read write bit selection
  bit [7:0] data_select ; // data selection bit
  bit [6:0]addbit;	// address selection bit
  
  function new(mailbox gen2drv,virtual intf d_intf,bit m_select);  //constructor for mailbox and interface 
        this.d_intf=d_intf;
        this.gen2drv=gen2drv;
    	this.m_select=m_select;
    endfunction //new()

    task reset;  // testing of reset 

      wait(d_intf.rst);
        $display("[ DRIVER ] ----- Reset Started -----");
        d_intf.drv.cb_driver.sda <= 0;
        d_intf.drv.cb_driver.scl <= 0;
      wait(!d_intf.rst);
        $display("[ DRIVER ] ----- Reset Ended   -----");
    endtask 

    task main;
        transaction tr; //instance of transaction class
        forever begin
          tr=new();
          gen2drv.get(tr);  //getting transection frommailbox of generator
         // d_intf.drv.cb_driver.sda <= 1; //starting condition
        //  d_intf.drv.cb_driver.scl <= 0;

          start_condition();
          address_send(tr);
           check_ack();
           if(tr.rw==1)
           begin
             fork
              generate_scl();  // to generate the scl (clock) for read operation parallaly 
              read_byte(tr); 
             join
               send_ack();
           end
           else begin
            data_send(tr);
             check_ack();
          data_send(tr);
            check_ack();
             
           end
           stop_condition();
            $finish;

         tr.display("[ Driver ]");  //displayig the content of input and output 
            no_tr++;  //incrementing the number  of transection 
        end  
    endtask
  
  task generate_scl();
    for(int i=0;i<8;i++)
      begin
    	 @(negedge d_intf.clk);
     d_intf.drv.cb_driver.scl <= 1;
          @(negedge d_intf.clk);
    d_intf.drv.cb_driver.scl <= 0;
      end
  endtask

    task start_condition();
          		// @(negedge d_intf.clk);
              // $display("st_c = %t ",$time);
      			 @(posedge d_intf.clk);
                d_intf.drv.cb_driver.sda <= 1; //starting condition
                d_intf.drv.cb_driver.scl <= 0;
                  @(negedge d_intf.clk);
                d_intf.drv.cb_driver.scl <= 1;
                  @(posedge d_intf.clk);
                d_intf.drv.cb_driver.sda <= 0;
                  @(negedge d_intf.clk);    // address sending
                d_intf.drv.cb_driver.scl <= 0;
          
    endtask 

  task read_byte( transaction tr);
        for(int i=0;i<8;i++)
        begin
           @(posedge d_intf.clk);
          @(negedge d_intf.drv.cb_driver.scl);
         //  $display("time=%d",$time);
          tr.r_data[7-i]=d_intf.drv.cb_driver.SDA;
          //$display("databit=%b",tr.r_data[7-i]);
         
        end
    endtask
    
    

    task send_ack();
      @(posedge d_intf.clk);
      d_intf.drv.cb_driver.sda <= 0;
      @(negedge d_intf.clk);
      d_intf.drv.cb_driver.scl <= 1;
       @(negedge d_intf.clk);
      d_intf.drv.cb_driver.scl <= 0;
      @(posedge d_intf.clk);
       d_intf.drv.cb_driver.sda <= 1;
      @(posedge d_intf.clk);
    endtask
  
    task address_send(transaction tr);
      if(m_select)
       begin
          addbit <= tr.address1;
          reWr <= tr.rw1;
       end
      else
        begin
      		addbit <= tr.address;
          	reWr <= tr.rw;
        end
        
                     // $display("address send %t ",$time);
                        @(posedge d_intf.clk);
                    d_intf.drv.cb_driver.sda <= addbit[6];
                        @(negedge d_intf.clk);
                    d_intf.drv.cb_driver.scl <= 1;
                        @(negedge d_intf.clk);
                    d_intf.drv.cb_driver.scl <= 0;
                        @(posedge d_intf.clk);
                    d_intf.drv.cb_driver.sda <= addbit[5];
                        @(negedge d_intf.clk);
                    d_intf.drv.cb_driver.scl <= 1;
                        @(negedge d_intf.clk);
                    d_intf.drv.cb_driver.scl <= 0;
                        @(posedge d_intf.clk);
                    d_intf.drv.cb_driver.sda <= addbit[4];
                        @(negedge d_intf.clk);
                    d_intf.drv.cb_driver.scl <= 1;
                        @(negedge d_intf.clk);
                    d_intf.drv.cb_driver.scl <= 0;
                        @(posedge d_intf.clk);
                    d_intf.drv.cb_driver.sda <= addbit[3];
                        @(negedge d_intf.clk);
                    d_intf.drv.cb_driver.scl <= 1;
                        @(negedge d_intf.clk);
                    d_intf.drv.cb_driver.scl <= 0;
                        @(posedge d_intf.clk);
                    d_intf.drv.cb_driver.sda <= addbit[2];
                        @(negedge d_intf.clk);
                    d_intf.drv.cb_driver.scl <= 1;
                        @(negedge d_intf.clk);
                    d_intf.drv.cb_driver.scl <= 0;
                        @(posedge d_intf.clk);
                    d_intf.drv.cb_driver.sda <= addbit[1];
                        @(negedge d_intf.clk);
                    d_intf.drv.cb_driver.scl <= 1;
                        @(negedge d_intf.clk)
                    d_intf.drv.cb_driver.scl <= 0;
                        @(posedge d_intf.clk);
                    d_intf.drv.cb_driver.sda <= addbit[0];
                   		@(negedge d_intf.clk); 
                    d_intf.drv.cb_driver.scl <= 1;
                   		@(negedge d_intf.clk);
                    d_intf.drv.cb_driver.scl <= 0;
                        @(posedge d_intf.clk);
                    d_intf.drv.cb_driver.sda <= reWr;
                        @(negedge d_intf.clk); 
                    d_intf.drv.cb_driver.scl <= 1;
                        @(negedge d_intf.clk);
                    d_intf.drv.cb_driver.scl <= 0;
      					@(posedge d_intf.clk);
     			    d_intf.drv.cb_driver.sda <= 1; 
      				//	$finish;
    // wire end property 
    					
      //for reading if we not put one cause problem...
    				  	
        endtask   
              //ack

        task check_ack();
           			
                    @(negedge d_intf.clk);	
          //$display("ACK time=%d",$time);
                    d_intf.drv.cb_driver.scl <= 1;
          			@(posedge d_intf.clk);
         // $display("_time=%t------value=%b",$time,d_intf.drv.cb_driver.SDA);
            wait(!d_intf.drv.cb_driver.SDA); #0;
          			@(negedge d_intf.clk);
          		//	$display("time=%d",$time);
                  	d_intf.drv.cb_driver.scl <= 0;
          			d_intf.drv.cb_driver.sda <= 0;
          			@(posedge d_intf.clk);
          			d_intf.drv.cb_driver.sda <= 1;
         			@(posedge d_intf.clk);
                    //$display("end_time=%d",$time);		
                	//d_intf.drv.cb_driver.sda <= 0;
            		//$finish;
          
        endtask 
  
        task data_send(transaction tr);
          if(m_select)
          data_select = tr.data1;
          else
          data_select = tr.data;
          
    				
         
                @(posedge d_intf.clk);
              //  $display("time_data_driver=%d",$time);
                d_intf.drv.cb_driver.sda <= data_select[7];
                @(negedge d_intf.clk);
                d_intf.drv.cb_driver.scl <= 1;
                @(negedge d_intf.clk);
                d_intf.drv.cb_driver.scl <= 0;
                @(posedge d_intf.clk);
                d_intf.drv.cb_driver.sda <= data_select[6];
                @(negedge d_intf.clk);
                d_intf.drv.cb_driver.scl <= 1;
                @(negedge d_intf.clk);
                d_intf.drv.cb_driver.scl <= 0;
                @(posedge d_intf.clk);
                d_intf.drv.cb_driver.sda <= data_select[5];
                @(negedge d_intf.clk);
                d_intf.drv.cb_driver.scl <= 1;
                @(negedge d_intf.clk);
                d_intf.drv.cb_driver.scl <= 0;
                @(posedge d_intf.clk);
                d_intf.drv.cb_driver.sda <= data_select[4];
                @(negedge d_intf.clk);
                d_intf.drv.cb_driver.scl <= 1;
                @(negedge d_intf.clk);
                d_intf.drv.cb_driver.scl <= 0;
                @(posedge d_intf.clk);
                d_intf.drv.cb_driver.sda <= data_select[3];
                @(negedge d_intf.clk);
                d_intf.drv.cb_driver.scl <= 1;
                @(negedge d_intf.clk);
                d_intf.drv.cb_driver.scl <= 0;
                @(posedge d_intf.clk);
                d_intf.drv.cb_driver.sda <= data_select[2];
                @(negedge d_intf.clk);
                d_intf.drv.cb_driver.scl <= 1;
                @(negedge d_intf.clk);
                d_intf.drv.cb_driver.scl <= 0;
                @(posedge d_intf.clk);
                d_intf.drv.cb_driver.sda <= data_select[1];
                @(negedge d_intf.clk);
                d_intf.drv.cb_driver.scl <= 1;
                @(negedge d_intf.clk);
                d_intf.drv.cb_driver.scl <= 0;
                @(posedge d_intf.clk);
                d_intf.drv.cb_driver.sda <= data_select[0];
                @(negedge d_intf.clk);
                d_intf.drv.cb_driver.scl <= 1;
                @(negedge d_intf.clk);
                d_intf.drv.cb_driver.scl <= 0;
                @(posedge d_intf.clk);
          		 d_intf.drv.cb_driver.sda <=0;
        endtask
        task stop_condition();
            		//$display("stop_condition=%d",$time);
           			d_intf.drv.cb_driver.sda <= 0;
                    @(negedge d_intf.clk);
                    d_intf.drv.cb_driver.scl <= 1;
                    @(posedge d_intf.clk);
                    d_intf.drv.cb_driver.sda <= 1;
                    @(negedge d_intf.clk);
                    d_intf.drv.cb_driver.scl <= 0;
          			//$display("stop_condition=%d",$time);
        endtask
 
endclass //driver
`endif