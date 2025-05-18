from pathlib import Path
from py_art_of_fpga.utils import generate_example_taps

if __name__ == "__main__":
    data_w = 16  # NOTE - Change for target data width
    num_taps = 8  # NOTE - Change for any number of taps
    filename = "fir_single_rate_non_symmetric_taps_package"

    taps = generate_example_taps(data_w, num_taps, Path(__file__).name, filename)
