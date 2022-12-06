	component soc is
		port (
			clk_clk                                       : in    std_logic                     := 'X';             -- clk
			drum_sound_sound                              : out   std_logic;                                        -- sound
			gpio_1_gpio                                   : out   std_logic_vector(15 downto 0);                    -- gpio
			gpio_2_gpio                                   : out   std_logic_vector(15 downto 0);                    -- gpio
			gpio_3_gpio                                   : out   std_logic_vector(15 downto 0);                    -- gpio
			hex_digits_export                             : out   std_logic_vector(15 downto 0);                    -- export
			key_wire_export                               : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- export
			keycode_export                                : out   std_logic_vector(7 downto 0);                     -- export
			led_wire_export                               : out   std_logic_vector(13 downto 0);                    -- export
			nios2_gen2_0_custom_instruction_master_readra : out   std_logic;                                        -- readra
			reset_reset_n                                 : in    std_logic                     := 'X';             -- reset_n
			sdram_clk_clk                                 : out   std_logic;                                        -- clk
			sdram_wire_addr                               : out   std_logic_vector(12 downto 0);                    -- addr
			sdram_wire_ba                                 : out   std_logic_vector(1 downto 0);                     -- ba
			sdram_wire_cas_n                              : out   std_logic;                                        -- cas_n
			sdram_wire_cke                                : out   std_logic;                                        -- cke
			sdram_wire_cs_n                               : out   std_logic;                                        -- cs_n
			sdram_wire_dq                                 : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
			sdram_wire_dqm                                : out   std_logic_vector(1 downto 0);                     -- dqm
			sdram_wire_ras_n                              : out   std_logic;                                        -- ras_n
			sdram_wire_we_n                               : out   std_logic;                                        -- we_n
			spi_MISO                                      : in    std_logic                     := 'X';             -- MISO
			spi_MOSI                                      : out   std_logic;                                        -- MOSI
			spi_SCLK                                      : out   std_logic;                                        -- SCLK
			spi_SS_n                                      : out   std_logic;                                        -- SS_n
			sw_wire_export                                : in    std_logic_vector(9 downto 0)  := (others => 'X'); -- export
			usb_gpx_export                                : in    std_logic                     := 'X';             -- export
			usb_irq_export                                : in    std_logic                     := 'X';             -- export
			usb_rst_export                                : out   std_logic                                         -- export
		);
	end component soc;

	u0 : component soc
		port map (
			clk_clk                                       => CONNECTED_TO_clk_clk,                                       --                                    clk.clk
			drum_sound_sound                              => CONNECTED_TO_drum_sound_sound,                              --                             drum_sound.sound
			gpio_1_gpio                                   => CONNECTED_TO_gpio_1_gpio,                                   --                                 gpio_1.gpio
			gpio_2_gpio                                   => CONNECTED_TO_gpio_2_gpio,                                   --                                 gpio_2.gpio
			gpio_3_gpio                                   => CONNECTED_TO_gpio_3_gpio,                                   --                                 gpio_3.gpio
			hex_digits_export                             => CONNECTED_TO_hex_digits_export,                             --                             hex_digits.export
			key_wire_export                               => CONNECTED_TO_key_wire_export,                               --                               key_wire.export
			keycode_export                                => CONNECTED_TO_keycode_export,                                --                                keycode.export
			led_wire_export                               => CONNECTED_TO_led_wire_export,                               --                               led_wire.export
			nios2_gen2_0_custom_instruction_master_readra => CONNECTED_TO_nios2_gen2_0_custom_instruction_master_readra, -- nios2_gen2_0_custom_instruction_master.readra
			reset_reset_n                                 => CONNECTED_TO_reset_reset_n,                                 --                                  reset.reset_n
			sdram_clk_clk                                 => CONNECTED_TO_sdram_clk_clk,                                 --                              sdram_clk.clk
			sdram_wire_addr                               => CONNECTED_TO_sdram_wire_addr,                               --                             sdram_wire.addr
			sdram_wire_ba                                 => CONNECTED_TO_sdram_wire_ba,                                 --                                       .ba
			sdram_wire_cas_n                              => CONNECTED_TO_sdram_wire_cas_n,                              --                                       .cas_n
			sdram_wire_cke                                => CONNECTED_TO_sdram_wire_cke,                                --                                       .cke
			sdram_wire_cs_n                               => CONNECTED_TO_sdram_wire_cs_n,                               --                                       .cs_n
			sdram_wire_dq                                 => CONNECTED_TO_sdram_wire_dq,                                 --                                       .dq
			sdram_wire_dqm                                => CONNECTED_TO_sdram_wire_dqm,                                --                                       .dqm
			sdram_wire_ras_n                              => CONNECTED_TO_sdram_wire_ras_n,                              --                                       .ras_n
			sdram_wire_we_n                               => CONNECTED_TO_sdram_wire_we_n,                               --                                       .we_n
			spi_MISO                                      => CONNECTED_TO_spi_MISO,                                      --                                    spi.MISO
			spi_MOSI                                      => CONNECTED_TO_spi_MOSI,                                      --                                       .MOSI
			spi_SCLK                                      => CONNECTED_TO_spi_SCLK,                                      --                                       .SCLK
			spi_SS_n                                      => CONNECTED_TO_spi_SS_n,                                      --                                       .SS_n
			sw_wire_export                                => CONNECTED_TO_sw_wire_export,                                --                                sw_wire.export
			usb_gpx_export                                => CONNECTED_TO_usb_gpx_export,                                --                                usb_gpx.export
			usb_irq_export                                => CONNECTED_TO_usb_irq_export,                                --                                usb_irq.export
			usb_rst_export                                => CONNECTED_TO_usb_rst_export                                 --                                usb_rst.export
		);

