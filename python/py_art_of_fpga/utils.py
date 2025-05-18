import numpy as np
import matplotlib.pyplot as plt
import os
from scipy import signal
from typing import List


def generate_example_taps(data_w: int, num_taps: int, author: str, filename: str) -> List[int]:
    """Generate an example filter.

    Args:
        data_w (int): Data width
        num_taps (int): Number of coefficients (taps)
        author (str): Python file that called this function
        filename (str): Filename of VHDL file to export taps

    Returns:
        List[int]: List of coefficients (taps)
    """
    bands: List[float] = [0, 0.1, 0.3, 0.5]

    taps = None
    try:
        taps = create_arbitrary_filter_taps(bands, num_taps)
    except:
        print("Transition `bands` requirements may be too difficult to meet. Consider widening transition bands")
        print("`num_taps` may be too small to meet requirements of `bands`. Consider increasing to a larger number")

    if taps is not None and taps.any():
        taps = to_integer_list(taps, data_w)
        if filename:
            export_to_vhdl_package(taps, filename, author)
            print(f"Finished generating {filename}")

    return taps


def create_arbitrary_filter_taps(bands: List[float], num_taps: int) -> List[float]:
    """Creates an arbitrary set of filter taps using scipy.signal.remez.

    Args:
        band (List[float]): Bands of filter, fs = 1 (normalised frequency).
        num_taps (int): Number of taps in filter.

    Returns:
        List[float]: Filter taps
    """
    taps = signal.remez(num_taps, bands, [1, 0], fs=1)
    return taps


def to_integer_list(taps: List[float], data_w: int) -> List[int]:
    """Converts taps to fixed point based on `data_w` bitwidth.

    Args:
        taps (List[float]): Taps (remez output)
        data_w (int): Target data bitwidth

    Returns:
        List[int]: Fixed point taps
    """
    result = [__signed_integer_clip((tap * 2 ** (data_w - 1)), data_w) for tap in taps]
    return result


def __signed_integer_clip(val: int, val_w: int) -> int:
    """Clips value to maximum signed positive number if it exceeds full scale

    Args:
        val (int): Value to clip
        val_w (int): Number width of value

    Returns:
        int: Clipped value
    """
    if val > 2 ** (val_w - 1) - 1:
        return int(2 ** (val_w - 1) - 1)
    return int(val)


def plot(x: np.ndarray, y: np.ndarray, title: str = "", grid_on: bool = True) -> None:
    """Plots x vs y in a new figure.
    Plot grid lines are turned on for both axis.

    Args:
        x (np.ndarray): Numpy array of x-axis data
        y (np.ndarray): Numpy array of y-axis data
        title (str, optional): Title of plot. Defaults to "".
    """
    plt.figure()
    plt.plot(x, y)
    if grid_on:
        plt.grid("both")
    plt.title(title)


def export_to_vhdl_package(
    taps: List[int],
    package_name: str,
    author: str = __package__ + ": " + os.path.basename(__file__),
) -> None:
    """Creates a VHDL package declaring filter taps as an array of integers.
    The VHDL package file will be placed in the current working directory.

    Args:
        taps (List[int]): Filter taps (fixed point)
        package_name (str): Name of package
    """
    with open(f"{package_name}.vhd", "w") as f:
        f.write(
            f"-- This file was auto-generated using: `{author}`\n"
            f"use work.array_package.all;\n"
            f"\npackage {package_name} is\n"
            f"\tconstant EXAMPLE_TAPS : array_integer_t := ("
        )
        for idx, tap in enumerate(taps):
            if idx == len(taps) - 1:
                f.write(f"{tap});\n")
            else:
                f.write(f"{tap},")
        f.write(f"end package {package_name};")
