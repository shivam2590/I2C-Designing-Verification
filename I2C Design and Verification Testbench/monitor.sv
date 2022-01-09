// monitor class is for to monitor the output of the dut according to the input ans send it into the scoreboard so it can check the correctness of the functionality

`ifndef MON   //guard to avoid recompilation
`define MON
class monitor;
    virtual intf m_intf;  //interface to get the input and output  information from the DUT
     mailbox mon2scb;  // maibox to send the monitored data in to the scoreboard
    
  function new(virtual intf m_intf,mailbox m_mbox);  //constructor for mailbox and interface
    this.m_intf = m_intf;
    this.mon2scb = m_mbox; 
    endfunction //new()

    task main;
        transaction tr;  //instance of transaction class
      forever begin
            @(negedge m_intf.mon.cb_monitor.sda);
            if(m_intf.mon.cb_monitor.scl==1)
            begin
                tr=new();
                @(negedge m_intf.mon.cb_monitor.scl);
                for(int i=0;i<7;i++)begin
                    @(negedge m_intf.mon.cb_monitor.scl);
                    tr.address[6-i]= m_intf.mon.cb_monitor.sda;
                end
                @(negedge m_intf.mon.cb_monitor.scl);
                 tr.rw = m_intf.mon.cb_monitor.sda;

                @(negedge m_intf.mon.cb_monitor.scl);  //skip adress ack

                if(tr.rw==0)begin
                    for(int i=0;i<8;i++)begin
                        @(negedge m_intf.mon.cb_monitor.scl);
                        tr.data[7-i] = m_intf.mon.cb_monitor.sda;
                        
                    end
                     @(negedge m_intf.mon.cb_monitor.scl); 
                    tr.smp_data = m_intf.mon.cb_monitor.out;

                end
                else begin
                    for(int i=0;i<8;i++)begin
                        @(negedge m_intf.mon.cb_monitor.scl);
                      tr.r_data[7-i] = m_intf.mon.cb_monitor.SDA;   
                    end
                    @(negedge m_intf.mon.cb_monitor.scl); 
                  @(posedge m_intf.mon.cb_monitor.scl);
                    tr.smp_read=m_intf.mon.cb_monitor.read;
                  $display("r_data=%d time=%d",tr.smp_read,$time);
                end

                //skip data ack

                mon2scb.put(tr);
        end
      end
        //  tr.display("monitor");  //display the content of the monitor.
    endtask
endclass //monitor
`endif