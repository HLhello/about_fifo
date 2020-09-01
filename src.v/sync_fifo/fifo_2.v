module scfifo #(
    parameter    ND    = 16,
    parameter    DW    = 16 ) (
    input                clk,
    input                rst_n,
    input                wren,
    input                rden,
    input    [DW-1:0]    din,
    output   [DW-1:0]    dout,
    output               full,
    output               empty
);

localparam    AW    =    $clog2(ND);

// Memory Registers
reg        [DW-1:0]    mem[ND-1:0];
reg        [AW-1:0]    wadr, radr;
reg                    wr_full;
reg                    rd_empty;

// Write Memory Data
always@(posedge clk)
    if(wren & ~wr_full) mem[wadr] <= din;

// Write Pointer
always@(posedge clk, negedge rst_n)
begin
    if(~rst_n)
        wadr <= 'd0;
    else begin
        if(wren & ~wr_full)
            wadr <= wadr + 1'd1;
    end
end

// Read Pointer
always@(posedge clk, negedge rst_n)
begin
    if(~rst_n)
        radr <= 'd0;
    else begin
        if(rden & ~rd_empty)
            radr <= radr + 1'd1;
    end
end

// Write Full Status
always@(posedge clk, negedge rst_n)
begin
    if(~rst_n)
        wr_full <= 1'b0;
    else begin
        if(~rden & wren & ((wadr == radr - 1'd1) || (~|radr && &wadr)))
            wr_full <= 1'b1;
        else if(rden & wr_full)
            wr_full <= 1'b0;
    end
end

// Read Empty Status
always@(posedge clk, negedge rst_n)
begin
    if(~rst_n)
        rd_empty <= 1'b1;
    else begin
        if(rden & ~wren & ((radr == wadr - 1'd1) || (~|wadr && &radr)))
            rd_empty <= 1'b1;
        else if(wren & rd_empty)
            rd_empty <= 1'b0;
    end
end

// Read Data and FIFO Status
assign    dout    =    mem[radr];
assign    full    =    wr_full;
assign    empty   =    rd_empty;

endmodule