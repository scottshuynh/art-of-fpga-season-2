library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.standard_package.all;
use work.array_package.all;

package filter_package is
  ------------------------------------------------------------------------------
  -- Returns an array of cumulative summing of the value `num_pipe`. Each element 
  -- in the array accumulates `m_pipe` until the very last element, which 
  -- accumulates `m_pipe_rem` instead of `m_pipe` if `m_pipe_rem` > 0.
  ------------------------------------------------------------------------------
  function get_pipe_cumsum(num_pipe : natural; m_pipe : natural; m_pipe_rem : natural) return array_integer_t;

  ------------------------------------------------------------------------------
  -- Returns an array of slice widths. Each width calculated on how `slice_w` 
  -- divides into `num_taps`. 
  ------------------------------------------------------------------------------
  function get_slice_widths(num_taps : natural; slice_w : natural) return array_integer_t;

  ------------------------------------------------------------------------------
  -- Returns a 2D array of taps representing the input 1D array of taps into 
  -- divided into `slice_len` parts.
  --
  -- num_rows = len(taps) / slice_len
  -- num_cols = slice_len
  --
  -- If `len(taos)` is not divisible by `slice_len`, the final row of remainder 
  -- taps are zero padded.
  ------------------------------------------------------------------------------
  function get_sliced_taps(taps : array_integer_t; slice_len : natural) return array2_integer_t;

end package filter_package;

package body filter_package is

  function get_pipe_cumsum(num_pipe : natural; m_pipe : natural; m_pipe_rem : natural) return array_integer_t is
    variable result : array_integer_t(0 to num_pipe-1) := (others => 1);
  begin
    l_slices_lengths : for IDX in 0 to num_pipe-1 loop
      if (IDX = 0) then
        result(IDX) := m_pipe;
      else
        result(IDX) := m_pipe + result(IDX-1);
      end if;
    end loop;

    if (m_pipe_rem > 0) then
      result(result'high) := m_pipe_rem + result(result'length-2);
    end if;

    return result;
  end function;

  function get_slice_widths(num_taps : natural; slice_w : natural) return array_integer_t is
    constant NUM_SLICES : natural := ceil_divide(num_taps, slice_w);
    constant REM_SLICE  : natural := num_taps rem slice_w;
    variable result     : array_integer_t(0 to NUM_SLICES-1);
  begin
    l_num_slice : for IDX in 0 to NUM_SLICES-1 loop
      result(IDX) := NUM_SLICES;
    end loop;
    if (REM_SLICE > 0) then
      result(result'high) := REM_SLICE;
    end if;
    return result;
  end function;

  function get_sliced_taps(taps : array_integer_t; slice_len : natural) return array2_integer_t is
    constant NUM_TAP_SLICES     : natural := ceil_divide(taps'length, slice_len);
    constant TAP_SLICE_REM_LEN  : natural := taps'length rem slice_len;
    constant TAP_SLICE_REM_LOW  : natural := (NUM_TAP_SLICES-1)*slice_len;
    constant TAP_SLICE_REM_HIGH : natural := TAP_SLICE_REM_LOW+TAP_SLICE_REM_LEN-1;

    variable result : array2_integer_t(0 to NUM_TAP_SLICES-1)(0 to slice_len-1) := (others => (others => 0));
  begin
    l_sliced_taps : for IDX in 0 to NUM_TAP_SLICES-2 loop
      result(IDX)(0 to slice_len-1) := taps(IDX*slice_len to (IDX+1)*slice_len-1);
    end loop;
    result(result'high)(0 to TAP_SLICE_REM_LEN-1) := taps(TAP_SLICE_REM_LOW to TAP_SLICE_REM_HIGH);
    return result;
  end function;

end package body filter_package;
