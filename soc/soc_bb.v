
module soc (
	clk_clk,
	drum_sound_sound,
	gpio_1_gpio,
	gpio_2_gpio,
	gpio_3_gpio,
	hex_digits_export,
	key_wire_export,
	keycode_export,
	led_wire_export,
	nios2_gen2_0_custom_instruction_master_readra,
	reset_reset_n,
	sdram_clk_clk,
	sdram_wire_addr,
	sdram_wire_ba,
	sdram_wire_cas_n,
	sdram_wire_cke,
	sdram_wire_cs_n,
	sdram_wire_dq,
	sdram_wire_dqm,
	sdram_wire_ras_n,
	sdram_wire_we_n,
	spi_MISO,
	spi_MOSI,
	spi_SCLK,
	spi_SS_n,
	sw_wire_export,
	usb_gpx_export,
	usb_irq_export,
	usb_rst_export);	

	input		clk_clk;
	output		drum_sound_sound;
	output	[15:0]	gpio_1_gpio;
	output	[15:0]	gpio_2_gpio;
	output	[15:0]	gpio_3_gpio;
	output	[15:0]	hex_digits_export;
	input	[1:0]	key_wire_export;
	output	[7:0]	keycode_export;
	output	[13:0]	led_wire_export;
	output		nios2_gen2_0_custom_instruction_master_readra;
	input		reset_reset_n;
	output		sdram_clk_clk;
	output	[12:0]	sdram_wire_addr;
	output	[1:0]	sdram_wire_ba;
	output		sdram_wire_cas_n;
	output		sdram_wire_cke;
	output		sdram_wire_cs_n;
	inout	[15:0]	sdram_wire_dq;
	output	[1:0]	sdram_wire_dqm;
	output		sdram_wire_ras_n;
	output		sdram_wire_we_n;
	input		spi_MISO;
	output		spi_MOSI;
	output		spi_SCLK;
	output		spi_SS_n;
	input	[9:0]	sw_wire_export;
	input		usb_gpx_export;
	input		usb_irq_export;
	output		usb_rst_export;
endmodule
