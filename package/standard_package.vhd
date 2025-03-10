library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package standard_package is
  function ceil_divide(n : natural; d : natural) return natural;
end package standard_package;

package body standard_package is
  function ceil_divide(n : natural; d : natural) return natural is
  begin
    return (n + (d-1)) / d;
  end function;
end package body standard_package;