from pathlib import Path
from py_art_of_fpga.utils import generate_example_taps


if __name__ == "__main__":
    data_w = 16  # NOTE - Change for target data width
    num_taps = 9  # NOTE - Change for any odd number of taps
    filename = "fir_single_rate_odd_symmetric_taps_package"

    assert num_taps % 2 == 1, f"num_taps must be odd. Got: {num_taps}"
    taps = generate_example_taps(data_w, num_taps, Path(__file__).name, filename)
