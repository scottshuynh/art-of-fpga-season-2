# Post 5 - Single Rate non-symmetric FIR, transpose architecture
Latency of `3` clock cycles independent of number of taps `N`.

A generic port is available to pipeline the transpose implementation by `M`. The resultant latency is `ceil(N/M)+2` clock cycles.

The data output is full precision - bitgrowth of all multiply and add operations are carried to the output.

For a comprehensive explanation of this filter, see fpgaguru's post on [element14](https://community.element14.com/technologies/fpga-group/b/blog/posts/the-art-of-fpga-design-season-2---post-5).

## Testbench
A testbench is available to observe the behaviour of the filter.

An impulse signal is driven into the input of the filter in order to output the coefficients (taps) of the filter. By default, the taps are defined in the `fir_single_rate_non_symmetric_filter_taps_package.vhd` file, generated using `post_5_generate_taps.py`.