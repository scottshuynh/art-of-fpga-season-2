# Post 6 - Single Rate even symmetric FIR, direct architecture
Latency of `N/2+3` clock cycles, where number of taps is `N`.

The data output is full precision - bitgrowth of all multiply and add operations are carried to the output.

For a comprehensive explanation of this filter, see fpgaguru's post on [element14](https://community.element14.com/technologies/fpga-group/b/blog/posts/the-art-of-fpga-design-season-2---post-5).

## Testbench
A testbench is available to observe the behaviour of the filter.

An impulse signal is driven into the input of the filter in order to output the coefficients (taps) of the filter. By default, the taps are defined in the `fir_single_rate_even_symmetric_taps_package.vhd` file, generated using `post_6_generate_taps.py`.

If generating new filter taps is desired, installing [py_art_of_fpga](https://github.com/scottshuynh/art-of-fpga-season-2/tree/main/python) Python package is required before running:
```sh
python3 post_6_generate_taps.py
```