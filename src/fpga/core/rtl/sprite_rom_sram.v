//
// Sprite character ROM in Analogue Pocket on-board SRAM (128KB).
// Blackwine map $20000-$3FFFF. Frees the 32KB on-chip sprchr M10Ks.
//
module sprite_rom_sram (
	input  wire        clk,

	// ROM download
	input  wire [24:0] ROMAD,
	input  wire  [7:0] ROMDT,
	input  wire        ROMEN,

	// Sprite engine (byte address into the 128KB window)
	input  wire [17:0] spr_addr,
	output reg   [7:0] spr_data,

	// Pocket SRAM pins (1Mbit x16 → 64K x16 = 128KB)
	output wire [16:0] sram_a,
	inout  wire [15:0] sram_dq,
	output wire        sram_oe_n,
	output wire        sram_we_n,
	output wire        sram_ub_n,
	output wire        sram_lb_n
);

wire spr_dl = ROMEN & (ROMAD[18:17] == 2'b01);

// Byte offset within $20000-$3FFFF → word address + lane
wire [15:0] dl_word = ROMAD[16:1];
wire        dl_odd  = ROMAD[0];

wire [15:0] rd_word = spr_addr[16:1];
wire        rd_odd  = spr_addr[0];

// Register download so address/data are stable for a full WE pulse.
reg        wr_act;
reg [15:0] wr_word;
reg        wr_odd;
reg  [7:0] wr_data;

always @(posedge clk) begin
	wr_act <= spr_dl;
	if (spr_dl) begin
		wr_word <= dl_word;
		wr_odd  <= dl_odd;
		wr_data <= ROMDT;
	end
end

assign sram_a    = wr_act ? {1'b0, wr_word} : {1'b0, rd_word};
assign sram_oe_n = wr_act ? 1'b1 : 1'b0;
assign sram_we_n = wr_act ? 1'b0 : 1'b1;
assign sram_lb_n = wr_act ? wr_odd  : 1'b0;
assign sram_ub_n = wr_act ? ~wr_odd : 1'b0;

assign sram_dq = wr_act
	? (wr_odd ? {wr_data, 8'hzz} : {8'hzz, wr_data})
	: 16'hzzzz;

// Same 1-cycle registered read latency as on-chip DLROM.
always @(posedge clk) begin
	if (!wr_act)
		spr_data <= rd_odd ? sram_dq[15:8] : sram_dq[7:0];
end

endmodule
