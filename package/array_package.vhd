library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package array_package is
  type array_integer_t is array (natural range <>) of integer;
  type array_signed_t is array (natural range <>) of signed;

  type array2_integer_t is array (natural range <>) of array_integer_t;

  function reverse_array(arr : array_integer_t) return array_integer_t;
  function normalise_range(arr : array_integer_t) return array_integer_t;
end package array_package;

package body array_package is
  function reverse_array(arr : array_integer_t) return array_integer_t is
    variable result : array_integer_t(arr'range);
  begin
    l_reverse : for IDX in result'range loop
      result(IDX) := arr(arr'high-IDX);
    end loop;
    return result;
  end function;

  function normalise_range(arr : array_integer_t) return array_integer_t is
    variable result : array_integer_t(0 to arr'length-1);
  begin
    l_normalise : for IDX in 0 to arr'length-1 loop
      result(IDX) := arr(IDX+arr'low);
    end loop;
    return result;
  end function;
end package body array_package;