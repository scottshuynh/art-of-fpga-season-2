from pathlib import Path
from py_art_of_fpga.utils import generate_example_taps


if __name__ == "__main__":
    data_w = 16  # NOTE - Change for target data width
    num_taps = 16  # NOTE - Change for any even number of taps
    filename = "fir_single_rate_even_symmetric_pipelined_taps_package"

    assert num_taps % 2 == 0, f"num_taps must be even. Got: {num_taps}"
    taps = generate_example_taps(data_w, num_taps, Path(__file__).name, filename)
