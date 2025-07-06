#!/usr/bin/env bash
TEST_MODULE="fir_single_rate_even_symmetric_transpose_pipelined"

# Setting generics
DATA_W="DATA_W=16"
M_PIPE="M_PIPE=1"


# Get compile order
ROOTDIR=$(git rev-parse --show-toplevel)
hdldepends $ROOTDIR/hdldepends_config.toml --top-entity $TEST_MODULE --compile-order-vhdl-lib work:compile_order.txt

# Run simulation
hdlworkflow nvc $TEST_MODULE compile_order.txt -g $DATA_W -g $M_PIPE --cocotb $TEST_MODULE --wave gtkwave