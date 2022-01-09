
module AND(out,sda_1,sda_2);
  input sda_1,sda_2;
  output  out;
  assign out=sda_1&sda_2;
endmodule 

module Slave(SDA,SCL,DATA_out,DATA_read,sample_sda,sample_sda1);

//inout triand SDA;
input triand SCL;
inout triand SDA;
output reg [7:0]DATA_out;
output reg [7:0] DATA_read;
output reg sample_sda;
output reg sample_sda1;  
 
  
  
  assign sample_sda=SDA;
  assign sample_sda1=SDA;
  reg [3:0] IDLE 			= 4'b0000;   // idle state 0 
 // reg [3:0] START 			= 4'b0001;   // start state 1
  reg [3:0] READ_ADDRESS 	= 4'b0010;       // read address state 2
  reg [3:0] READ_WRITE 	    = 4'b0011;       // read_write state 3   
  reg [3:0] READ            = 4'b0100;       // read data from slave state 4 
  reg [3:0] DATA 			= 4'b0101;       // write data to slave state 5   
  reg [3:0] DATA_ACK   		= 4'b0110;       // send ack to master state 6 
  reg [3:0] READ_ACK   		= 4'b0111;       // send ack to slave state 7 
  reg [3:0] STOP 			= 4'b1110;       // stop condition 
  reg [3:0] ADDRESS_ACK 	= 4'b1000;      // adress ack to master 8
  
  reg [3:0] state 			= 4'b0010;        // initial in read adress mode 
  
  reg [6:0] slaveAddress 	= 7'b1010_111;    // slave address is set as 0x28 
  reg [6:0] addr			= 7'b000_0000;    // adress register to store address  
  reg [6:0] addressCounter 	= 7'b000_0000;    //address counter    
  
  reg [7:0] read_reg;       // = 8'b01010101;   // to send the data to master (during read operation)
  reg [7:0] data			= 8'b0000_0000;  // so store the data that is sent by the master
  reg [6:0] dataCounter 	= 7'b000_0000;   // data counter
  reg [6:0] readCounter 	= 7'b000_0000;   // read counter
  
  reg readWrite			= 1'b0;       // to store read write bit 
  reg start 			= 0;          // start condition flag is set means that start condition is occtred
  reg write_ack			= 0;          // write_ack flag to access SDA line at time of ACK   
  reg sda_reg           = 0;          // data register while putting any data on the sda ny slave  
  
  assign SDA = (write_ack == 1) ? sda_reg : 1'b1;   // putting data on SDA line

  always @(negedge SDA) begin    // to detect start condition 
    if ((start == 0) && (SCL == 1) && (write_ack == 0)) 
    begin
		start <= 1;  
        state <= READ_ADDRESS;// start flag is set
        addressCounter <= 0;  // reseting counters
      	dataCounter <= 0;
        readCounter <= 0;       
	end
  end
  
  always @(posedge SDA) begin   // to detect the stop condition 
    if (SCL == 1 && (write_ack == 0))
      begin
        start <= 0;        // start flag is reset 
		state <= READ_ADDRESS;  // initially READ_ADDRESS mode 
	  end
	end
  
  always @(posedge SCL)     // main FSM
    begin
    	if (start == 1)   // flag bit is set then operation will be perfomed 
    	begin
    	  case (state)
    	    READ_ADDRESS: 
    	      begin
                write_ack = 0;
                addr[6-addressCounter] = SDA; //  address sampling 
    	        
                if (addressCounter == 6) 
    	            begin
                      //$display("address %h =", addr);
                      if(addr==slaveAddress )   // comparing the address 
                        begin
     	             		state = READ_WRITE;  // go in to read_write cheking state
                        end
                      else
                        begin
                        	    state = IDLE;    // if address don't match then go in idle state
                        end
     	            end
                      addressCounter = addressCounter + 1;  
     	        end
               
                
     	   READ_WRITE:     // sampling of read_write  bit
     	     begin
                readWrite <= SDA;           
              	state <= ADDRESS_ACK;
    	      end
            ADDRESS_ACK:    // taking decision for  read or write state 
              begin
                sda_reg <= 0;     // giving ack to master 
                write_ack <= 1;   // taking the access of the sda line
                if(readWrite==0)
                begin
                    state <= DATA;
                    @(negedge SCL);
                    write_ack <= 0; //giving acess back to master
                end
                else begin
                    state <= READ;
                    read_reg<=$urandom();
                end
                
              end
            DATA:
              begin
                write_ack <= 0;    // giving the access back to master
    	        dataCounter <= dataCounter + 1;  
                if (dataCounter == 7)  // going in to ACK state
    	            begin
                        state <= DATA_ACK;                      
     	            end
                else begin
                        state <= DATA;
                end 
                    data[7-(dataCounter)] <= SDA;  // data storing in the data reg
                 
              end
            READ:        // read state to read data from slave 
                begin
                  if(readCounter<=7)
                    begin
                        write_ack <= 1;   // tking access of SDA line   
                        sda_reg <= read_reg[7-readCounter];   // sending data to master bit by bit (first msb)
                        readCounter <= readCounter + 1;   // read
                    end
                  if (readCounter == 7)
    	            begin
     	                state <= READ_ACK;   // going to read ACK state
     	            end
                end
            DATA_ACK:
     	     begin
                state <= DATA; 
                DATA_out<=data; 
                dataCounter <= 0; //  reset the counter
                write_ack <= 1;  // taking access back from master
                sda_reg <= 0;  // giving the ACK 
                @(negedge SCL); // taking access back at negative edge 
                write_ack <= 0; //giving acess back to master
    	      end
            READ_ACK:
            begin
                write_ack <= 0;
                readCounter <= 0;
                if(SDA==0)   // cheking the ack of data read
                begin
                  	DATA_read<=read_reg;
                    state<=READ_ADDRESS;   
                end
                @(negedge SCL);
                write_ack <= 1; // 
            end
    	  endcase
    	end
    end
endmodule 

