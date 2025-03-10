library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.array_package.all;

entity fir_single_rate_non_symmetric_transpose is
  generic (
    DATA_W        : natural;
    TAPS_REVERSED : array_integer_t
  );
  port (
    clk_i          : in  std_logic;
    data_i         : in  signed(DATA_W-1 downto 0);
    postadd_pipe_i : in  signed(2*DATA_W+1-1 downto 0) := (others => '0');
    data_o         : out signed(2*DATA_W+1-1 downto 0)
  );
end entity fir_single_rate_non_symmetric_transpose;

architecture rtl of fir_single_rate_non_symmetric_transpose is
  constant MULTIPLY_W : natural := 2*DATA_W;
  constant POSTADD_W  : natural := MULTIPLY_W+1;

  signal z1_data         : signed(DATA_W-1 downto 0)    := (others => '0');
  signal z1_postadd_pipe : signed(POSTADD_W-1 downto 0) := (others => '0');

  signal multiply : array_signed_t(TAPS_REVERSED'range)(MULTIPLY_W-1 downto 0) := (others => (others => '0'));
  signal postadd  : array_signed_t(TAPS_REVERSED'range)(POSTADD_W-1 downto 0)  := (others => (others => '0'));

begin
  p_filter_transpose : process (clk_i)
  begin
    if rising_edge(clk_i) then
      z1_data         <= data_i;
      z1_postadd_pipe <= postadd_pipe_i;

      -- Infers DSP for each filter tap
      l_multiply_add : for IDX in TAPS_REVERSED'range loop
        multiply(IDX) <= TAPS_REVERSED(IDX) * z1_data;

        if (IDX = 0) then
          postadd(IDX) <= z1_postadd_pipe + multiply(IDX);
        else
          postadd(IDX) <= postadd(IDX-1) + multiply(IDX);
        end if;
      end loop;
    end if;
  end process;

  data_o <= postadd(postadd'high);
  
end architecture;