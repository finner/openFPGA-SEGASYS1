//
// User core top-level
//
// Instantiated by the real top-level: apf_top
//

`default_nettype none

module core_top (

//
// physical connections
//

///////////////////////////////////////////////////
// clock inputs 74.25mhz. not phase aligned, so treat these domains as asynchronous

input   wire            clk_74a, // mainclk1
input   wire            clk_74b, // mainclk1 

///////////////////////////////////////////////////
// cartridge interface
// switches between 3.3v and 5v mechanically
// output enable for multibit translators controlled by pic32

// GBA AD[15:8]
inout   wire    [7:0]   cart_tran_bank2,
output  wire            cart_tran_bank2_dir,

// GBA AD[7:0]
inout   wire    [7:0]   cart_tran_bank3,
output  wire            cart_tran_bank3_dir,

// GBA A[23:16]
inout   wire    [7:0]   cart_tran_bank1,
output  wire            cart_tran_bank1_dir,

// GBA [7] PHI#
// GBA [6] WR#
// GBA [5] RD#
// GBA [4] CS1#/CS#
//     [3:0] unwired
inout   wire    [7:4]   cart_tran_bank0,
output  wire            cart_tran_bank0_dir,

// GBA CS2#/RES#
inout   wire            cart_tran_pin30,
output  wire            cart_tran_pin30_dir,
// when GBC cart is inserted, this signal when low or weak will pull GBC /RES low with a special circuit
// the goal is that when unconfigured, the FPGA weak pullups won't interfere.
// thus, if GBC cart is inserted, FPGA must drive this high in order to let the level translators
// and general IO drive this pin.
output  wire            cart_pin30_pwroff_reset,

// GBA IRQ/DRQ
inout   wire            cart_tran_pin31,
output  wire            cart_tran_pin31_dir,

// infrared
input   wire            port_ir_rx,
output  wire            port_ir_tx,
output  wire            port_ir_rx_disable, 

// GBA link port
inout   wire            port_tran_si,
output  wire            port_tran_si_dir,
inout   wire            port_tran_so,
output  wire            port_tran_so_dir,
inout   wire            port_tran_sck,
output  wire            port_tran_sck_dir,
inout   wire            port_tran_sd,
output  wire            port_tran_sd_dir,
 
///////////////////////////////////////////////////
// cellular psram 0 and 1, two chips (64mbit x2 dual die per chip)

output  wire    [21:16] cram0_a,
inout   wire    [15:0]  cram0_dq,
input   wire            cram0_wait,
output  wire            cram0_clk,
output  wire            cram0_adv_n,
output  wire            cram0_cre,
output  wire            cram0_ce0_n,
output  wire            cram0_ce1_n,
output  wire            cram0_oe_n,
output  wire            cram0_we_n,
output  wire            cram0_ub_n,
output  wire            cram0_lb_n,

output  wire    [21:16] cram1_a,
inout   wire    [15:0]  cram1_dq,
input   wire            cram1_wait,
output  wire            cram1_clk,
output  wire            cram1_adv_n,
output  wire            cram1_cre,
output  wire            cram1_ce0_n,
output  wire            cram1_ce1_n,
output  wire            cram1_oe_n,
output  wire            cram1_we_n,
output  wire            cram1_ub_n,
output  wire            cram1_lb_n,

///////////////////////////////////////////////////
// sdram, 512mbit 16bit

output  wire    [12:0]  dram_a,
output  wire    [1:0]   dram_ba,
inout   wire    [15:0]  dram_dq,
output  wire    [1:0]   dram_dqm,
output  wire            dram_clk,
output  wire            dram_cke,
output  wire            dram_ras_n,
output  wire            dram_cas_n,
output  wire            dram_we_n,

///////////////////////////////////////////////////
// sram, 1mbit 16bit

output  wire    [16:0]  sram_a,
inout   wire    [15:0]  sram_dq,
output  wire            sram_oe_n,
output  wire            sram_we_n,
output  wire            sram_ub_n,
output  wire            sram_lb_n,

///////////////////////////////////////////////////
// vblank driven by dock for sync in a certain mode

input   wire            vblank,

///////////////////////////////////////////////////
// i/o to 6515D breakout usb uart

output  wire            dbg_tx,
input   wire            dbg_rx,

///////////////////////////////////////////////////
// i/o pads near jtag connector user can solder to

output  wire            user1,
input   wire            user2,

///////////////////////////////////////////////////
// RFU internal i2c bus 

inout   wire            aux_sda,
output  wire            aux_scl,

///////////////////////////////////////////////////
// RFU, do not use
output  wire            vpll_feed,


//
// logical connections
//

///////////////////////////////////////////////////
// video, audio output to scaler
output  wire    [23:0]  video_rgb,
output  wire            video_rgb_clock,
output  wire            video_rgb_clock_90,
output  wire            video_de,
output  wire            video_skip,
output  wire            video_vs,
output  wire            video_hs,
    
output  wire            audio_mclk,
input   wire            audio_adc,
output  wire            audio_dac,
output  wire            audio_lrck,

///////////////////////////////////////////////////
// bridge bus connection
// synchronous to clk_74a
output  wire            bridge_endian_little,
input   wire    [31:0]  bridge_addr,
input   wire            bridge_rd,
output  reg     [31:0]  bridge_rd_data,
input   wire            bridge_wr,
input   wire    [31:0]  bridge_wr_data,

///////////////////////////////////////////////////
// controller data
// 
// key bitmap:
//   [0]    dpad_up
//   [1]    dpad_down
//   [2]    dpad_left
//   [3]    dpad_right
//   [4]    face_a
//   [5]    face_b
//   [6]    face_x
//   [7]    face_y
//   [8]    trig_l1
//   [9]    trig_r1
//   [10]   trig_l2
//   [11]   trig_r2
//   [12]   trig_l3
//   [13]   trig_r3
//   [14]   face_select
//   [15]   face_start
// joy values - unsigned
//   [ 7: 0] lstick_x
//   [15: 8] lstick_y
//   [23:16] rstick_x
//   [31:24] rstick_y
// trigger values - unsigned
//   [ 7: 0] ltrig
//   [15: 8] rtrig
//
input   wire    [15:0]  cont1_key,
input   wire    [15:0]  cont2_key,
input   wire    [15:0]  cont3_key,
input   wire    [15:0]  cont4_key,
input   wire    [31:0]  cont1_joy,
input   wire    [31:0]  cont2_joy,
input   wire    [31:0]  cont3_joy,
input   wire    [31:0]  cont4_joy,
input   wire    [15:0]  cont1_trig,
input   wire    [15:0]  cont2_trig,
input   wire    [15:0]  cont3_trig,
input   wire    [15:0]  cont4_trig
    
);

// not using the IR port, so turn off both the LED, and
// disable the receive circuit to save power
assign port_ir_tx = 0;
assign port_ir_rx_disable = 1;

// bridge endianness
assign bridge_endian_little = 0;

// cart is unused, so set all level translators accordingly
// directions are 0:IN, 1:OUT
assign cart_tran_bank3 = 8'hzz;
assign cart_tran_bank3_dir = 1'b0;
assign cart_tran_bank2 = 8'hzz;
assign cart_tran_bank2_dir = 1'b0;
assign cart_tran_bank1 = 8'hzz;
assign cart_tran_bank1_dir = 1'b0;
assign cart_tran_bank0 = 4'hf;
assign cart_tran_bank0_dir = 1'b1;
assign cart_tran_pin30 = 1'b0;      // reset or cs2, we let the hw control it by itself
assign cart_tran_pin30_dir = 1'bz;
assign cart_pin30_pwroff_reset = 1'b0;  // hardware can control this
assign cart_tran_pin31 = 1'bz;      // input
assign cart_tran_pin31_dir = 1'b0;  // input

// link port is input only
assign port_tran_so = 1'bz;
assign port_tran_so_dir = 1'b0;     // SO is output only
assign port_tran_si = 1'bz;
assign port_tran_si_dir = 1'b0;     // SI is input only
assign port_tran_sck = 1'bz;
assign port_tran_sck_dir = 1'b0;    // clock direction can change
assign port_tran_sd = 1'bz;
assign port_tran_sd_dir = 1'b0;     // SD is input and not used

// tie off the rest of the pins we are not using
assign cram0_a = 'h0;
assign cram0_dq = {16{1'bZ}};
assign cram0_clk = 0;
assign cram0_adv_n = 1;
assign cram0_cre = 0;
assign cram0_ce0_n = 1;
assign cram0_ce1_n = 1;
assign cram0_oe_n = 1;
assign cram0_we_n = 1;
assign cram0_ub_n = 1;
assign cram0_lb_n = 1;

assign cram1_a = 'h0;
assign cram1_dq = {16{1'bZ}};
assign cram1_clk = 0;
assign cram1_adv_n = 1;
assign cram1_cre = 0;
assign cram1_ce0_n = 1;
assign cram1_ce1_n = 1;
assign cram1_oe_n = 1;
assign cram1_we_n = 1;
assign cram1_ub_n = 1;
assign cram1_lb_n = 1;

assign dram_a = 'h0;
assign dram_ba = 'h0;
assign dram_dq = {16{1'bZ}};
assign dram_dqm = 'h0;
assign dram_clk = 'h0;
assign dram_cke = 'h0;
assign dram_ras_n = 'h1;
assign dram_cas_n = 'h1;
assign dram_we_n = 'h1;

// Sprite ROM SRAM wired below (near GameCore / rom_download_wr).

assign dbg_tx = 1'bZ;
assign user1 = 1'bZ;
assign aux_scl = 1'bZ;
assign vpll_feed = 1'bZ;


// for bridge write data, we just broadcast it to all bus devices
// for bridge read data, we have to mux it
// add your own devices here
always @(*) begin
    casex(bridge_addr)
    default: begin
        bridge_rd_data <= 0;
    end
    32'hF8xxxxxx: begin
        bridge_rd_data <= cmd_bridge_rd_data;
    end
    endcase
end


//
// host/target command handler
//
    wire            reset_n;                // driven by host commands, can be used as core-wide reset
    wire    [31:0]  cmd_bridge_rd_data;
    
// bridge host commands
// synchronous to clk_74a
    wire            status_boot_done = pll_core_locked; 
    wire            status_setup_done = pll_core_locked; // rising edge triggers a target command
    wire            status_running = reset_n; // we are running as soon as reset_n goes high

    wire            dataslot_requestread;
    wire    [15:0]  dataslot_requestread_id;
    wire            dataslot_requestread_ack = 1;
    wire            dataslot_requestread_ok = 1;

    wire            dataslot_requestwrite;
    wire    [15:0]  dataslot_requestwrite_id;
    wire            dataslot_requestwrite_ack = 1;
    wire            dataslot_requestwrite_ok = 1;

    wire            dataslot_allcomplete;

    wire            savestate_supported;
    wire    [31:0]  savestate_addr;
    wire    [31:0]  savestate_size;
    wire    [31:0]  savestate_maxloadsize;

    wire            savestate_start;
    wire            savestate_start_ack;
    wire            savestate_start_busy;
    wire            savestate_start_ok;
    wire            savestate_start_err;

    wire            savestate_load;
    wire            savestate_load_ack;
    wire            savestate_load_busy;
    wire            savestate_load_ok;
    wire            savestate_load_err;
    
    wire            osnotify_inmenu;

// bridge target commands
// synchronous to clk_74a


// bridge data slot access

    wire    [9:0]   datatable_addr;
    wire            datatable_wren;
    wire    [31:0]  datatable_data;
    wire    [31:0]  datatable_q;

core_bridge_cmd icb (

    .clk                ( clk_74a ),
    .reset_n            ( reset_n ),

    .bridge_endian_little   ( bridge_endian_little ),
    .bridge_addr            ( bridge_addr ),
    .bridge_rd              ( bridge_rd ),
    .bridge_rd_data         ( cmd_bridge_rd_data ),
    .bridge_wr              ( bridge_wr ),
    .bridge_wr_data         ( bridge_wr_data ),
    
    .status_boot_done       ( status_boot_done ),
    .status_setup_done      ( status_setup_done ),
    .status_running         ( status_running ),

    .dataslot_requestread       ( dataslot_requestread ),
    .dataslot_requestread_id    ( dataslot_requestread_id ),
    .dataslot_requestread_ack   ( dataslot_requestread_ack ),
    .dataslot_requestread_ok    ( dataslot_requestread_ok ),

    .dataslot_requestwrite      ( dataslot_requestwrite ),
    .dataslot_requestwrite_id   ( dataslot_requestwrite_id ),
    .dataslot_requestwrite_ack  ( dataslot_requestwrite_ack ),
    .dataslot_requestwrite_ok   ( dataslot_requestwrite_ok ),

    .dataslot_allcomplete   ( dataslot_allcomplete ),

    .savestate_supported    ( savestate_supported ),
    .savestate_addr         ( savestate_addr ),
    .savestate_size         ( savestate_size ),
    .savestate_maxloadsize  ( savestate_maxloadsize ),

    .savestate_start        ( savestate_start ),
    .savestate_start_ack    ( savestate_start_ack ),
    .savestate_start_busy   ( savestate_start_busy ),
    .savestate_start_ok     ( savestate_start_ok ),
    .savestate_start_err    ( savestate_start_err ),

    .savestate_load         ( savestate_load ),
    .savestate_load_ack     ( savestate_load_ack ),
    .savestate_load_busy    ( savestate_load_busy ),
    .savestate_load_ok      ( savestate_load_ok ),
    .savestate_load_err     ( savestate_load_err ),

    .osnotify_inmenu        ( osnotify_inmenu ),
    
    .datatable_addr         ( datatable_addr ),
    .datatable_wren         ( datatable_wren ),
    .datatable_data         ( datatable_data ),
    .datatable_q            ( datatable_q ),

);

///////////////////////////////////////////////
// System
///////////////////////////////////////////////

wire osnotify_inmenu_s;

synch_3 OSD_S (osnotify_inmenu, osnotify_inmenu_s, clk_sys);

///////////////////////////////////////////////
// ROM
///////////////////////////////////////////////

reg         ioctl_download = 0;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire  [7:0] ioctl_dout;

always @(posedge clk_74a) begin
    if (dataslot_requestwrite)     ioctl_download <= 1;
    else if (dataslot_allcomplete) ioctl_download <= 0;
end

data_loader #(
    .ADDRESS_MASK_UPPER_4(4'h0),
    .ADDRESS_SIZE(25)
) rom_loader (
    .clk_74a(clk_74a),
    .clk_memory(clk_sys),

    .bridge_wr(bridge_wr),
    .bridge_endian_little(bridge_endian_little),
    .bridge_addr(bridge_addr),
    .bridge_wr_data(bridge_wr_data),

    .write_en(ioctl_wr),
    .write_addr(ioctl_addr),
    .write_data(ioctl_dout)
);

// Interact / bridge settings
// 0x10000000 SYSMODE[0] (MiSTer MRA rom index=1 byte0)
// 0x11000000 SYSMODE[1] quirks (MRA index=1 byte1)
// 0x20000000 DSW0
// 0x30000000 DSW1
// 0x40000000 flip screen
// 0x80000000 reset pulse
// Also: data slot id=2 loads SYSMODE bytes to 0x003FF000 (MiSTer index=1)
//
// SYSMODE[0]: [0]=SYS2,[1]=vertical,[2]=H240,[3]=Water Match,
//             [4]=CW,[5]=spinner,[6]=SYS2 rowscroll,[7]=swap trig1/trig2
reg        cs_reset;
reg  [7:0] cs_sysmode = 8'h00;
reg  [7:0] cs_quirks  = 8'h00;
reg  [7:0] cs_dsw0    = 8'hFF;
reg  [7:0] cs_dsw1    = 8'h7C;
reg        cs_flip    = 1'b0;

// Accept either byte lane — APF memory_writes endian is ambiguous across paths.
wire [7:0] bridge_wr_byte = bridge_wr_data[7:0] | bridge_wr_data[31:24];

always @(posedge clk_74a) begin
  if (bridge_wr) begin
    casex (bridge_addr)
      32'h10xxxxxx: cs_sysmode <= bridge_wr_byte;
      32'h11xxxxxx: cs_quirks  <= bridge_wr_byte;
      32'h20xxxxxx: cs_dsw0    <= bridge_wr_byte;
      32'h30xxxxxx: cs_dsw1    <= bridge_wr_byte;
      32'h40xxxxxx: cs_flip    <= bridge_wr_byte[0];
      32'h80xxxxxx: cs_reset   <= ~cs_reset;
    endcase
  end
end

// Prefer SYSMODE from data slot @ 0x3FF000 when present (same bytes as MRA rom index=1).
reg [7:0] ioctl_sysmode0 = 8'h00;
reg [7:0] ioctl_sysmode1 = 8'h00;
reg [7:0] ioctl_sysmode2 = 8'h00;
reg [7:0] ioctl_sysmode3 = 8'h00;
reg       ioctl_sysmode_valid = 1'b0;
reg       ioctl_download_s_d;

wire ioctl_download_s;
synch_3 ioctl_dl_s (ioctl_download, ioctl_download_s, clk_sys);

always @(posedge clk_sys) begin
	ioctl_download_s_d <= ioctl_download_s;
	if (ioctl_download_s & ~ioctl_download_s_d) begin
		ioctl_sysmode_valid <= 1'b0; // new download started
		ioctl_sysmode0 <= 8'h00;
		ioctl_sysmode1 <= 8'h00;
		ioctl_sysmode2 <= 8'h00;
		ioctl_sysmode3 <= 8'h00;
	end
	if (ioctl_wr && (ioctl_addr[24:2] == 23'h0FFC00)) begin
		case (ioctl_addr[1:0])
			2'd0: begin ioctl_sysmode0 <= ioctl_dout; ioctl_sysmode_valid <= 1'b1; end
			2'd1: ioctl_sysmode1 <= ioctl_dout;
			2'd2: ioctl_sysmode2 <= ioctl_dout;
			2'd3: ioctl_sysmode3 <= ioctl_dout;
		endcase
	end
end

wire [7:0] SYSMODE_bridge;
wire [7:0] QUIRKS_bridge;
wire [7:0] DSW0;
wire [7:0] DSW1;
wire       flip_screen;

synch_3 #(.WIDTH(8)) sysmode_s (cs_sysmode, SYSMODE_bridge, clk_sys);
synch_3 #(.WIDTH(8)) quirks_s  (cs_quirks,  QUIRKS_bridge,  clk_sys);
synch_3 #(.WIDTH(8)) dsw0_s    (cs_dsw0,    DSW0,    clk_sys);
synch_3 #(.WIDTH(8)) dsw1_s    (cs_dsw1,    DSW1,    clk_sys);
synch_3              flip_s    (cs_flip,    flip_screen, clk_sys);

wire [7:0] SYSMODE = ioctl_sysmode_valid ? ioctl_sysmode0 : SYSMODE_bridge;
wire [7:0] quirks  = ioctl_sysmode_valid ? ioctl_sysmode1 : QUIRKS_bridge;

reg last_do_reset;
reg manual_reset = 1'b0;
reg [24:0] reset_count = 25'b0;

always @(posedge clk_sys) begin
	last_do_reset <= cs_reset;
	if (~manual_reset && (cs_reset != last_do_reset)) begin
		reset_count <= 25'd1;
		manual_reset <= 1'b1;
	end else if (reset_count == 25'b0001111111111111111111111) begin
		reset_count <= 25'b0;
		manual_reset <= 1'b0;
	end else if (manual_reset) begin
		reset_count <= reset_count + 25'd1;
	end
end

///////////////////////////////////////////////
// Control
///////////////////////////////////////////////

wire [15:0] joy;
wire [15:0] joy2;

synch_3 #(.WIDTH(16)) cont1_key_s (cont1_key, joy,  clk_sys);
synch_3 #(.WIDTH(16)) cont2_key_s (cont2_key, joy2, clk_sys);

wire m_up     = joy[0];
wire m_down   = joy[1];
wire m_left   = joy[2];
wire m_right  = joy[3];
wire m_trig_1 = joy[4];
wire m_trig_2 = joy[5];
wire m_trig_3 = joy[6];
wire m_coin   = joy[14] | joy2[14];
wire m_start1 = joy[15];
wire m_start2 = joy2[15];
wire m_pause  = joy[8] | joy2[8];

wire m_lup    = joy[0];
wire m_ldown  = joy[1];
wire m_lleft  = joy[2];
wire m_lright = joy[3];
wire m_rup    = joy2[0] | joy[7];
wire m_rdown  = joy2[1] | joy[6];
wire m_rleft  = joy2[2] | joy[5];
wire m_rright = joy2[3] | joy[4];
wire m_trig   = joy[4];

wire iRST = ~reset_n | ioctl_download | manual_reset;

wire [7:0] spin;
wire vs;
spinner #(15,25,5) spinner (
	.clk(clk_sys),
	.reset(iRST),
	.minus(m_left),
	.plus(m_right),
	.fast(m_trig_2),
	.strobe(vs),
	.spin1_in(9'd0),
	.spin2_in(9'd0),
	.spin_out(spin)
);

wire [2:0] triggers = {SYSMODE[7] ? {m_trig_2, m_trig_1} : {m_trig_1, m_trig_2}, m_trig_3};

reg [7:0] INP0, INP1, INP2;
always @(posedge clk_sys) begin
	if (SYSMODE[5]) begin
		INP0 <= ~spin;
		INP1 <= ~spin;
		INP2 <= ~{m_trig_1, m_trig_1, m_start2, m_start1, 3'b000, m_coin};
	end else if (SYSMODE[3]) begin
		INP0 <= ~{m_lleft, m_lright, m_lup, m_ldown, m_rleft, m_rright, m_rup, m_rdown};
		INP1 <= ~{m_lleft, m_lright, m_lup, m_ldown, m_rleft, m_rright, m_rup, m_rdown};
		INP2 <= ~{m_trig, m_trig, m_start2, m_start1, 3'b000, m_coin};
	end else begin
		INP0 <= ~{m_left, m_right, m_up, m_down, 1'b0, triggers};
		INP1 <= ~{m_left, m_right, m_up, m_down, 1'b0, triggers};
		INP2 <= ~{2'b00, m_start2, m_start1, 3'b000, m_coin};
	end
end

///////////////////////////////////////////////
// Pause
///////////////////////////////////////////////

reg pause_toggle = 1'b0;
reg m_pause_d;
always @(posedge clk_sys) begin
	m_pause_d <= m_pause;
	if (~m_pause_d & m_pause) pause_toggle <= ~pause_toggle;
end

wire pause_cpu = osnotify_inmenu_s | pause_toggle;

///////////////////////////////////////////////
// Core + HVGEN
///////////////////////////////////////////////

wire [8:0] HPOS, VPOS;
wire       PCLK_EN;
wire [7:0] POUT;
wire [15:0] AOUT;
wire [7:0] hsdo_unused;
wire       hblank_core, vblank_core;
wire       hs;
wire [14:0] hv_rgb;
wire       mux_clock_unused;

HVGEN hvgen (
	.HPOS(HPOS),
	.VPOS(VPOS),
	.CLK(clk_sys),
	.PCLK_EN(PCLK_EN),
	.iRGB({7'b0, POUT}),
	.oRGB(hv_rgb),
	.HBLK(hblank_core),
	.VBLK(vblank_core),
	.HSYN(hs),
	.VSYN(vs),
	.H240(SYSMODE[2]),
	.HOFFS(9'd0),
	.VOFFS(9'd0)
);

// Only pass ROM downloads into game BRAM — not SYSMODE @ 0x3FF000.
wire rom_download_wr = ioctl_wr & ~ioctl_addr[21];

// Full 128KB sprite character ROM in on-board SRAM ($20000-$3FFFF).
wire [17:0] sprchad;
wire  [7:0] sprchdt;

sprite_rom_sram sprite_rom (
	.clk(clk_sys),
	.ROMAD(ioctl_addr),
	.ROMDT(ioctl_dout),
	.ROMEN(rom_download_wr),
	.spr_addr(sprchad),
	.spr_data(sprchdt),
	.sram_a(sram_a),
	.sram_dq(sram_dq),
	.sram_oe_n(sram_oe_n),
	.sram_we_n(sram_we_n),
	.sram_ub_n(sram_ub_n),
	.sram_lb_n(sram_lb_n)
);

SEGASYSTEM1 GameCore (
	.clk40M(clk_sys),
	.reset(iRST),

	.INP0(INP0),
	.INP1(INP1),
	.INP2(INP2),
	.DSW0(DSW0),
	.DSW1(DSW1),

	.system2(SYSMODE[0]),
	.rowscroll(SYSMODE[6]),
	.quirks(quirks),
	.mux_clock(mux_clock_unused),

	.PH(HPOS),
	.PV(VPOS),
	.PCLK_EN(PCLK_EN),
	.POUT(POUT),
	.SOUT(AOUT),

	.ROMCL(clk_sys),
	.ROMAD(ioctl_addr),
	.ROMDT(ioctl_dout),
	.ROMEN(rom_download_wr),
	.sprchdt_ext(sprchdt),
	.sprchad(sprchad),

	.PAUSE_N(~pause_cpu),
	.HSAD(16'h0),
	.HSDO(hsdo_unused),
	.HSDI(8'h0),
	.HSWE(1'b0),

	.show_banks(1'b0),
	.flip_screen(flip_screen),
	.test1(3'b0),
	.test2(3'b0),
	.test3(3'b0),
	.test4(3'b0)
);

///////////////////////////////////////////////
// Video output
///////////////////////////////////////////////

// Same path as working Pocket 0.16: capture on PCLK_EN, present on clk_pix.
reg [7:0]  pix_rgb;
reg        pix_hb, pix_vb;
reg        pix_hs_n, pix_vs_n;
reg [2:0]  pix_scaler_slot;

always @(posedge clk_sys) begin
	if (PCLK_EN) begin
		pix_rgb  <= POUT;
		pix_hb   <= hblank_core;
		pix_vb   <= vblank_core;
		pix_hs_n <= hs;
		pix_vs_n <= vs;
		pix_scaler_slot <= SYSMODE[1]
			? {1'b0, SYSMODE[4], SYSMODE[2]}
			: {2'b10, SYSMODE[2]};
	end
end

// POUT == {B[1:0], G[2:0], R[2:0]}
wire [2:0] r = pix_rgb[2:0];
wire [2:0] g = pix_rgb[5:3];
wire [1:0] b = pix_rgb[7:6];

wire [23:0] scaler_slot_cmd = {8'h0, pix_scaler_slot, 13'h0};

reg video_de_reg;
reg video_hs_reg;
reg video_vs_reg;
reg [23:0] video_rgb_reg;
reg hs_prev;
reg vs_prev;

wire video_active = ~(pix_vb | pix_hb);

assign video_rgb_clock = clk_pix;
assign video_rgb_clock_90 = clk_pix_90;
assign video_de = video_de_reg;
assign video_hs = video_hs_reg;
assign video_vs = video_vs_reg;
assign video_rgb = video_rgb_reg;
assign video_skip = 1'b0;

always @(posedge clk_pix) begin
	video_de_reg  <= 1'b0;
	video_rgb_reg <= scaler_slot_cmd;

	if (video_active) begin
		video_de_reg <= 1'b1;
		video_rgb_reg[23:16] <= {r, r, r[2:1]};
		video_rgb_reg[15:8]  <= {g, g, g[2:1]};
		video_rgb_reg[7:0]   <= {b, b, b, b};
	end

	video_hs_reg <= hs_prev & ~pix_hs_n;
	video_vs_reg <= vs_prev & ~pix_vs_n;
	hs_prev <= pix_hs_n;
	vs_prev <= pix_vs_n;
end

///////////////////////////////////////////////
// Audio
///////////////////////////////////////////////

sound_i2s #(
	.CHANNEL_WIDTH(15),
	.SIGNED_INPUT(0)
) sound_i2s (
	.clk_74a(clk_74a),
	.clk_audio(clk_sys),
	.audio_l(AOUT[15:1]),
	.audio_r(AOUT[15:1]),
	.audio_mclk(audio_mclk),
	.audio_lrck(audio_lrck),
	.audio_dac(audio_dac)
);

///////////////////////////////////////////////
// Clocks
///////////////////////////////////////////////

wire clk_sys;
wire clk_pix;
wire clk_pix_90;
wire clk_sys_b;
wire pll_core_locked;

mf_pllbase mp1 (
	.refclk   ( clk_74a ),
	.rst      ( 1'b0 ),
	.outclk_0 ( clk_sys ),
	.outclk_1 ( clk_pix ),
	.outclk_2 ( clk_pix_90 ),
	.outclk_3 ( clk_sys_b ),
	.locked   ( pll_core_locked )
);

endmodule
