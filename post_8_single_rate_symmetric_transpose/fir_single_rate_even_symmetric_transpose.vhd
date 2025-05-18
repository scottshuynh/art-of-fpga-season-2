--------------------------------------------------------------------------------
-- Description: Single clock rate FIR, even symmetric, transpose.
-- Consumes half DSPs by exploiting filter symmetry.
-- 
-- NOTE: If this component is used without pipelining, drive input data into 
-- both `data_i` and `preadd_pipe_i`, and leave `postadd_pipe_i` input unconnected.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.standard_package.all;
use work.array_package.all;

entity fir_single_rate_even_symmetric_transpose is
  generic (
    DATA_W             : natural;
    HALF_TAPS_REVERSED : array_integer_t
  );
  port (
    clk_i          : in  std_logic;
    data_i         : in  signed(DATA_W-1 downto 0);
    preadd_pipe_i  : in  signed(DATA_W+1-1 downto 0);
    postadd_pipe_i : in  signed(2*(DATA_W+1)+1-1 downto 0) := (others => '0');
    data_o         : out signed(2*(DATA_W+1)+1-1 downto 0)
  );
end entity fir_single_rate_even_symmetric_transpose;

architecture rtl of fir_single_rate_even_symmetric_transpose is

  constant PREADD_W   : natural := DATA_W+1;
  constant MULTIPLY_W : natural := 2*PREADD_W;
  constant POSTADD_W  : natural := MULTIPLY_W+1;

  signal z_preadd : signed(PREADD_W-1 downto 0)                                             := (others => '0');
  signal z_data   : array_signed_t(0 to 2*HALF_TAPS_REVERSED'length-1)(DATA_W-1 downto 0)   := (others => (others => '0'));
  signal preadd   : array_signed_t(0 to HALF_TAPS_REVERSED'length-1)(PREADD_W-1 downto 0)   := (others => (others => '0'));
  signal multiply : array_signed_t(0 to HALF_TAPS_REVERSED'length-1)(MULTIPLY_W-1 downto 0) := (others => (others => '0'));
  signal postadd  : array_signed_t(0 to HALF_TAPS_REVERSED'length)(POSTADD_W-1 downto 0)    := (others => (others => '0'));

begin
  p_transpose_even_sym_filter : process (clk_i)
  begin
    if rising_edge(clk_i) then
      z_data(0) <= data_i;
      l_z_data : for IDX in 1 to z_data'length-1 loop
        z_data(IDX) <= z_data(IDX-1);
      end loop;

      z_preadd   <= preadd_pipe_i;
      postadd(0) <= postadd_pipe_i;

      l_dsp : for IDX in 0 to HALF_TAPS_REVERSED'length-1 loop
        preadd(IDX)    <= z_data(2*(IDX+1)-1) + resize(z_preadd, PREADD_W);
        multiply(IDX)  <= preadd(IDX) * HALF_TAPS_REVERSED(IDX);
        postadd(IDX+1) <= resize(postadd(IDX), POSTADD_W) + multiply(IDX);
      end loop;
    end if;
  end process;

  data_o <= postadd(postadd'high);

end architecture rtl;