library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.standard_package.all;
use work.array_package.all;

use work.fir_single_rate_even_symmetric_taps_package.all;

entity fir_single_rate_even_symmetric is
  generic (
    DATA_W : natural;
    TAPS   : array_integer_t := EXAMPLE_TAPS
  );
  port (
    clk_i  : in  std_logic;
    data_i : in  signed(DATA_W-1 downto 0);
    data_o : out signed(2*(DATA_W+1)+1-1 downto 0)
  );
end entity fir_single_rate_even_symmetric;

architecture rtl of fir_single_rate_even_symmetric is
  constant PREADD_W   : natural := DATA_W+1;
  constant MULTIPLY_W : natural := 2*PREADD_W;
  constant POSTADD_W  : natural := MULTIPLY_W+1;

  signal z_data   : array_signed_t(0 to TAPS'length)(DATA_W-1 downto 0)         := (others => (others => '0'));
  signal preadd   : array_signed_t(0 to TAPS'length/2-1)(PREADD_W-1 downto 0)   := (others => (others => '0'));
  signal multiply : array_signed_t(0 to TAPS'length/2-1)(MULTIPLY_W-1 downto 0) := (others => (others => '0'));
  signal postadd  : array_signed_t(0 to TAPS'length/2)(POSTADD_W-1 downto 0)    := (others => (others => '0'));

begin
  assert (TAPS'length mod 2 = 0) report "Taps must be even." severity FAILURE;

  p_even_sym_filter : process (clk_i)
  begin
    if rising_edge(clk_i) then
      z_data(0) <= data_i;
      l_z_data : for IDX in 1 to TAPS'length-1 loop
        z_data(IDX) <= z_data(IDX-1);
      end loop;

      -- Infers DSP for half of the taps
      l_dsp : for IDX in 0 to TAPS'length/2-1 loop
        preadd(IDX)    <= resize(z_data(2*IDX), PREADD_W) + z_data(TAPS'length-1);
        multiply(IDX)  <= preadd(IDX) * TAPS(IDX);
        postadd(IDX+1) <= resize(postadd(IDX), POSTADD_W) + multiply(IDX);
      end loop;
    end if;
  end process;

  data_o <= postadd(postadd'high);

end architecture rtl;