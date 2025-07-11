#!/usr/bin/env bash
TEST_MODULE="fir_single_rate_even_symmetric"

# Setting generics
DATA_W="DATA_W=16"

# Get compile order
ROOTDIR=$(git rev-parse --show-toplevel)
hdldepends $ROOTDIR/hdldepends_config.toml --top-entity $TEST_MODULE --compile-order-vhdl-lib work:compile_order.txt

# Run simulation
hdlworkflow nvc $TEST_MODULE compile_order.txt -g $DATA_W --cocotb $TEST_MODULE --wave gtkwave