from typing import List
from py_art_of_fpga import utils


def generate_example_taps(data_w: int, is_generate_package: bool = False) -> List[int]:
    """Generate some arbitrary taps from hard coded params.

    Args:
        data_w (int): Data bit width

    Returns:
        List[int]: Fixed point integer taps
    """
    bands: List[float] = [0, 0.1, 0.3, 0.5]  # TODO - Change transition bands to affect tap coeffs
    num_taps: int = 35  # TODO - Change for any arbitrary number of taps

    taps = None
    try:
        taps = utils.create_arbitrary_filter_taps(bands, num_taps)
    except:
        print("Transition `bands` requirements may be too difficult to meet. Consider widening transition bands")
        print("`num_taps` may be too small to meet requirements of `bands`. Consider increasing to a larger number")

    if taps is not None and taps.any():
        taps = utils.to_integer_list(taps, data_w)
        if is_generate_package:
            filename = "fir_single_rate_non_symmetric_filter_taps_package"
            utils.export_to_vhdl_package(taps, filename)
            print(f"Finished generating {filename}")

    return taps


if __name__ == "__main__":
    data_w = 16
    taps = generate_example_taps(data_w, True)
