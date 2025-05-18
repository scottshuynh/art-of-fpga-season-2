--------------------------------------------------------------------------------
-- Description: Single clock rate FIR, even symmetric, transpose, pipelined.
-- Consumes half DSPs by exploiting filter symmetry.
-- 
-- The filter can be pipelined to alleviate fan-out timing of `data_i`.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.standard_package.all;
use work.array_package.all;
use work.filter_package.all;

use work.fir_single_rate_even_symmetric_pipelined_taps_package.all;

entity fir_single_rate_even_symmetric_transpose_pipelined is
  generic (
    DATA_W : natural;
    TAPS   : array_integer_t := EXAMPLE_TAPS;
    M_PIPE : natural
  );
  port (
    clk_i  : in  std_logic;
    data_i : in  signed(DATA_W-1 downto 0);
    data_o : out signed(2*(DATA_W+1)+1-1 downto 0)
  );
end entity fir_single_rate_even_symmetric_transpose_pipelined;

architecture rtl of fir_single_rate_even_symmetric_transpose_pipelined is
  constant LATENCY : natural := 4 + M_PIPE;

begin
  assert (TAPS'length mod 2 = 0) report "Length of `TAPS` must be even." severity FAILURE;

  g_valid_pipe : if (M_PIPE+1 <= TAPS'length/4) generate
    g_no_pipe : if (M_PIPE = 0) generate
      constant HALF_TAPS          : array_integer_t(0 to TAPS'length/2-1) := TAPS(0 to TAPS'length/2-1);
      constant HALF_TAPS_REVERSED : array_integer_t                       := reverse_array(HALF_TAPS);
    begin
      i_fir_signel_rate_even_symmetric_transpose : entity work.fir_single_rate_even_symmetric_transpose
        generic map (
          DATA_W             => DATA_W,
          HALF_TAPS_REVERSED => HALF_TAPS_REVERSED
        )
        port map (
          clk_i         => clk_i,
          data_i        => data_i,
          preadd_pipe_i => resize(data_i, DATA_W+1),
          data_o        => data_o
        );
    end generate;

    g_pipe : if (M_PIPE > 0) generate
      constant HALF_TAPS          : array_integer_t(0 to TAPS'length/2-1) := TAPS(0 to TAPS'length/2-1);
      constant HALF_TAPS_REVERSED : array_integer_t                       := reverse_array(HALF_TAPS);

      constant HALF_TAP_SLICE_W       : natural         := ceil_divide(HALF_TAPS'length, M_PIPE+1);
      constant M_PIPE_REM             : natural         := HALF_TAPS'length rem (M_PIPE+1);
      constant HALF_TAP_SLICE_WS      : array_integer_t := get_slice_widths(HALF_TAPS'length, HALF_TAP_SLICE_W);
      constant HALF_TAP_M_PIPE_CUMSUM : array_integer_t := get_pipe_cumsum(M_PIPE+1, HALF_TAP_SLICE_W, M_PIPE_REM);
      constant OUTPUT_W               : natural         := 2*(DATA_W+1)+1;

      signal z_data  : array_signed_t(0 to TAPS'length-1)(DATA_W-1 downto 0) := (others => (others => '0'));
      signal outputs : array_signed_t(0 to M_PIPE)(OUTPUT_W-1 downto 0)      := (others => (others => '0'));
    begin
      g_pipe_transpose : for IDX in 0 to M_PIPE generate
        g_first : if (IDX = 0) generate
          i_fir_single_rate_even_symmetric_transpose : entity work.fir_single_rate_even_symmetric_transpose
            generic map (
              DATA_W             => DATA_W,
              HALF_TAPS_REVERSED => HALF_TAPS_REVERSED(0 to HALF_TAP_M_PIPE_CUMSUM(IDX)-1)
            )
            port map (
              clk_i         => clk_i,
              data_i        => data_i,
              preadd_pipe_i => resize(data_i, DATA_W+1),
              data_o        => outputs(IDX)
            );
        end generate;

        g_pipe : if (IDX > 0) generate
          i_fir_single_rate_even_symmetric_transpose : entity work.fir_single_rate_even_symmetric_transpose
            generic map (
              DATA_W             => DATA_W,
              HALF_TAPS_REVERSED => normalise_range(HALF_TAPS_REVERSED(HALF_TAP_M_PIPE_CUMSUM(IDX-1) to HALF_TAP_M_PIPE_CUMSUM(IDX)-1))
            )
            port map (
              clk_i          => clk_i,
              data_i         => z_data(2*HALF_TAP_M_PIPE_CUMSUM(IDX-1)+IDX-1),
              preadd_pipe_i  => resize(z_data(IDX-1), DATA_W+1),
              postadd_pipe_i => outputs(IDX-1),
              data_o         => outputs(IDX)
            );
        end generate;
      end generate;

      p_z_data : process (clk_i)
      begin
        if rising_edge(clk_i) then
          z_data(0) <= data_i;
          l_z_data : for IDX in 1 to z_data'length-1 loop
            z_data(IDX) <= z_data(IDX-1);
          end loop;
        end if;
      end process;

      data_o <= outputs(outputs'high);
    end generate;

  else generate
    assert (False) 
      report "M_PIPE+1="&integer'image(M_PIPE+1)&" must not exceed TAPS'length/4="&integer'image(TAPS'length/4)
      severity FAILURE;
  end generate;

end architecture rtl;
