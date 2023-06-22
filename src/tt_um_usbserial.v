/*
 * tt_um_usbserial.v
 *
 * USB Serial for Tiny Tapeout
 *
 * Author: Uri Shaked
 */

`default_nettype none

module tt_um_urish_usbserial (
	input  wire [7:0] ui_in,	// Dedicated inputs
	output wire [7:0] uo_out,	// Dedicated outputs
	input  wire [7:0] uio_in,	// IOs: Input path
	output wire [7:0] uio_out,	// IOs: Output path
	output wire [7:0] uio_oe,	// IOs: Enable path (active high: 0=input, 1=output)
	input  wire       ena,
	input  wire       clk,
	input  wire       rst_n
);

	wire usb_tx_en;
	assign uio_oe = { 6'b100110, usb_tx_en, usb_tx_en };
	
	/* Debug interface */
	wire [11:0] debug;
	wire dbg_rst = uio_in[6];
	reg [3:0] dbg_cnt;
	assign uio_out[7] = debug[dbg_cnt];

	always @(posedge clk) begin
		if (rst_n == 1'b0) begin
			dbg_cnt <= 4'b0;
		end else begin
			if (dbg_rst) begin
				dbg_cnt <= 4'b0;
			end else begin
				dbg_cnt <= dbg_cnt + 1;
			end
		end
	end

	/* USB Serial */
  usb_uart_core uart (
    .clk_48mhz  (clk),
    .reset      (~rst_n),

    // pins - these must be connected properly to the outside world.  See below.
    .usb_p_tx(uio_out[0]),
    .usb_n_tx(uio_out[1]),
    .usb_p_rx(uio_in[0]),
    .usb_n_rx(uio_in[1]),
    .usb_tx_en(usb_tx_en),

    // uart pipeline in
    .uart_in_data( ui_in ),
    .uart_in_valid( uio_in[2] ),
    .uart_in_ready( uio_out[3] ),

    // uart pipeline out
    .uart_out_data( uo_out ),
    .uart_out_valid( uio_out[4] ),
    .uart_out_ready( uio_in[5] ),

    .debug( debug )
  );

endmodule // tt_um_test
