module fifo_1#(
    parameter depth = 16,
    parameter width = 8
)(
    clk,
    rst,
    wr_en,
    rd_en,
    data_in,
    data_out,
    empty,
    full
);

input clk;
input rst;
input wr_en;
input rd_en;
input [width-1:0]data_in;
output reg [width-1:0]data_out;
output empty;
output full;

localparam powdepth = $clog(depth);
reg [width-1:0]mem[depth-1:0];

reg [powdepth-1:0]wptr;
reg [powdepth-1:0]rptr;
reg [powdepth-1:0]cnt;

assign full = (cnt == depth-1) ? 1'b1 : 1'b0;
assign empty = (cnt == 0) ? 1'b1 : 1'b0;

always@(posedge clk)
    if(!rst)
        begin
            cnt <= 0;
            wptr <= 0;
            rptr <= 0;
            data_out <= 0;
        end
    else 
        begin
            case({full, wr_en, empty, rd_en})
                4'b0000,4'b1000,4'b0010:
                        begin //
                            cnt <= cnt;
                        end
                4'b0001,4'b1101,4'b1001:
                        begin //
                            cnt <= cnt - 1;
                            data_out <= mem[rptr];
                            if(rptr == depth-1)
                                rptr <= 0;
                            else 
                                rptr <= rptr + 1;
                        end
                4'b0100,4'b0111,4'b0110:
                        begin
                            cnt <= cnt + 1;
                            mem[wptr] <= data_in;
                            if(wptr == depth+1)
                                wptr <= 0;
                            else 
                                wptr <= wptr + 1;                
                        end
                4'b0101:
                        begin
                            data_out <= mem[rptr];
                            if(rptr == depth-1)
                                rptr <= 0;
                            else 
                                rptr <= rptr + 1;

                            mem[wptr] <= data_in;
                            if(wptr == depth+1)
                                wptr <= 0;
                            else 
                                wptr <= wptr + 1;                 
                        end                        
                default:begin
                
                        end
        end



endmodule 


/*

module fifo(clock,reset,read,write,fifo_in,fifo_out,fifo_empty,fifo_half,fifo_full);
  input clock,reset,read,write;
  input [15:0]fifo_in;
  output[15:0]fifo_out;
  output fifo_empty,fifo_half,fifo_full;//标志位
  reg [15:0]fifo_out;
  reg [15:0]ram[15:0];
  reg [3:0]read_ptr,write_ptr,counter;//指针与计数
  wire fifo_empty,fifo_half,fifo_full;

  always@(posedge clock)
  if(reset)
    begin
      read_ptr=0;
      write_ptr=0;
      counter=0;
      fifo_out=0;                    //初始值
    end
  else
    case({read,write})
      2'b00:
            counter=counter;        //没有读写指令
      2'b01:                            //写指令，数据输入fifo
            begin
              ram[write_ptr]=fifo_in;
              counter=counter+1;
              write_ptr=(write_ptr==15)?0:write_ptr+1;
            end
      2'b10:                          //读指令，数据读出fifo
            begin
              fifo_out=ram[read_ptr];
              counter=counter-1;
              read_ptr=(read_ptr==15)?0:read_ptr+1;
            end
      2'b11:                        //读写指令同时，数据可以直接输出
            begin
              if(counter==0)
                fifo_out=fifo_in;
              else
                begin
                  ram[write_ptr]=fifo_in;
                  fifo_out=ram[read_ptr];
                  write_ptr=(write_ptr==15)?0:write_ptr+1;
                  read_ptr=(read_ptr==15)?0:write_ptr+1;
                end
              end
        endcase

        assign fifo_empty=(counter==0);    //标志位赋值 组合电路
        assign fifo_half=(counter==8);
        assign fifo_full=(counter==15);

    endmodule

///////////////////////////////////////////////////////////////////////////////

module fifo
(
    clk, rst, wr_en, rd_en, data_in, data_out, empty, full
);
input clk, rst;
input wr_en, rd_en;
input [7:0] data_in;
output [7:0] data_out;
output empty,full;

wire empty, full;
reg [7:0] data_out;

reg   [7:0] ram[15:0];    //双端口ram
reg   [3:0] wr_ptr, rd_ptr; //写和读指针
reg   [3:0] counter;     //用来判断空满

always @(posedge clk)
      begin
           if (!rst)
                begin
                     counter=0;
                     data_out=0;
                     wr_ptr=0;
                     rd_ptr=0;
                end
           else
                begin
                   case({wr_en, rd_en})
                       2’b00: counter=counter;
                       2’b01: 
                             begin
                                  data_out=ram[rd_ptr];  //先进先出，因此读的话依旧按照次序来
                                  counter=counter-1;
                                  rd_ptr=(rd_ptr==15) ?0: rd_ptr+1;
                                  end
                       2’b10：
                             begin
                                  ram[wr_ptr]=data_in;   //写操作
                                  counter=counter+1;
                                  wr_ptr=(wr_ptr==15) ?0: wr_ptr+1;
                                  end
                       2’b11
                             begin
                                  ram[wr_ptr]=data_in; //读写同时进行，此时counter不增加
                                  data_out=ram[rd_ptr];
                                  wr_ptr=(wr_ptr==15) ?0:wr_ptr+1;
                                  rd_ptr=(rd_ptr==15) ?0: rd_ptr+1;
                             end
                         endcase
                    end
                end
assign  empty=(counter==0)?1:0;
assign  full=(counter==15) ?1:0;
endmodule



*/