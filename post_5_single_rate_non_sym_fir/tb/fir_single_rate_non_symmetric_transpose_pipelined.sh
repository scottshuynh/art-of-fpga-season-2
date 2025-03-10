# Device under test is the filename
DUT=$(basename "$0")
DUT="${DUT%.*}"

ROOTDIR=$(git rev-parse --show-toplevel)
CORE=${DUT%"_tb"}

# Get arguments to sim workflow
source $ROOTDIR/scripts/sim_argparse.sh

PYTHONPATH=$ROOTDIR/post_5_single_rate_non_sym_fir/tb
export PYTHONPATH

# Path to compile order
COMPILE_ORDER=$ROOTDIR/post_5_single_rate_non_sym_fir/tb/compile_order.txt
source $ROOTDIR/scripts/nvc/nvc_cocotb_workflow.sh 

if [ $wave = true ]; then
  gtkwave $DUT$generics_flat.fst -a $DUT$generics_flat.gtkw
fi