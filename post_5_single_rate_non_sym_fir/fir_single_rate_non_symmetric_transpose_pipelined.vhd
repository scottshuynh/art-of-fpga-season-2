library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.standard_package.all;
use work.array_package.all;
use work.filter_package.all;
use work.fir_single_rate_non_symmetric_taps_package.all;

entity fir_single_rate_non_symmetric_transpose_pipelined is
  generic (
    DATA_W : natural;
    TAPS   : array_integer_t := EXAMPLE_TAPS;
    M_PIPE : natural
  );
  port (
    clk_i  : in  std_logic;
    data_i : in  signed(DATA_W-1 downto 0);
    data_o : out signed(2*DATA_W+1-1 downto 0)
  );
end entity fir_single_rate_non_symmetric_transpose_pipelined;

architecture rtl of fir_single_rate_non_symmetric_transpose_pipelined is

begin
  g_valid_pipe : if M_PIPE <= TAPS'length generate
    g_no_pipe : if (M_PIPE = 0) generate
      i_fir_single_rate_non_symmetric_transpose : entity work.fir_single_rate_non_symmetric_transpose
        generic map (
          DATA_W        => DATA_W,
          TAPS_REVERSED => reverse_array(TAPS)
        )
        port map (
          clk_i  => clk_i,
          data_i => data_i,
          data_o => data_o
        );
    end generate;

    g_pipe : if (M_PIPE > 0) generate
      constant NUM_TAP_SLICES    : natural         := ceil_divide(TAPS'length, M_PIPE);
      constant M_PIPE_REM        : natural         := TAPS'length rem M_PIPE;
      constant TAP_M_PIPE_CUMSUM : array_integer_t := get_pipe_cumsum(NUM_TAP_SLICES, M_PIPE, M_PIPE_REM);
      constant OUTPUT_W          : natural         := 2*DATA_W+1;
      constant TAPS_REVERSED     : array_integer_t := reverse_array(TAPS);

      signal z_data  : array_signed_t(0 to NUM_TAP_SLICES-1)(DATA_W-1 downto 0)   := (others => (others => '0'));
      signal outputs : array_signed_t(0 to NUM_TAP_SLICES-1)(OUTPUT_W-1 downto 0) := (others => (others => '0'));

    begin

      g_pipe_transpose : for IDX in 0 to NUM_TAP_SLICES-1 generate
        g_first : if (IDX = 0) generate
          i_fir_single_rate_non_symmetric_transpose_pipe : entity work.fir_single_rate_non_symmetric_transpose
            generic map (
              DATA_W        => DATA_W,
              TAPS_REVERSED => TAPS_REVERSED(0 to TAP_M_PIPE_CUMSUM(IDX)-1)
            )
            port map (
              clk_i  => clk_i,
              data_i => data_i,
              data_o => outputs(IDX)
            );
        end generate;

        g_pipe : if (IDX > 0) generate
          i_fir_single_rate_non_symmetric_transpose_pipe : entity work.fir_single_rate_non_symmetric_transpose
            generic map (
              DATA_W        => DATA_W,
              TAPS_REVERSED => normalise_range(TAPS_REVERSED(TAP_M_PIPE_CUMSUM(IDX-1) to TAP_M_PIPE_CUMSUM(IDX)-1))
            )
            port map (
              clk_i          => clk_i,
              data_i         => z_data(IDX-1),
              postadd_pipe_i => outputs(IDX-1),
              data_o         => outputs(IDX)
            );
        end generate;
      end generate;

      data_o <= outputs(outputs'high);

      p_z_data : process (clk_i)
      begin
        if rising_edge(clk_i) then
          z_data(0) <= data_i;
          l_z_data : for IDX in 1 to NUM_TAP_SLICES-1 loop
            z_data(IDX) <= z_data(IDX-1);
          end loop;
        end if;
      end process;

    end generate;

  else generate
  begin
    assert (False) report "M_PIPE: " & integer'image(M_PIPE) & " must be lower than number of taps: " & integer'image(TAPS'length) severity FAILURE;
  end generate;

end architecture;