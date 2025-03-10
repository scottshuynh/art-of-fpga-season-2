import matplotlib.pyplot as plt
import numpy as np
import os
from scipy import signal
from typing import List


def create_arbitrary_integer_filter_taps(data_w:int, bands:List[float], num_taps:int) -> List[int]:
    """Creates an arbitrary set of filter taps using scipy.signal.remez. 
    Taps are converted to fixed point based on data bit-width.

    Args:
        data_w (int): Data bit-width.
        band (List[float]): Bands of filter, fs = 1 (normalised frequency).
        num_taps (int): Number of taps in filter.

    Returns:
        List[int]: Filter taps (fixed point)
    """
    taps = signal.remez(num_taps, bands, [1, 0], fs=1)
    w, h = signal.freqz(taps, [1], worN=2048, fs=1)
    freq_response = 20*np.log10(np.abs(h))

    __plot(w, freq_response, "Frequency Response")

    taps = [int(tap * 2**(data_w-1)) for tap in taps]
    return taps

def export_to_vhdl_package(taps:List[int], package_name:str) -> None:
    """Creates a VHDL package declaring filter taps as an array of integers. 
    The VHDL package file will be placed in the current working directory.

    Args:
        taps (List[int]): Filter taps (fixed point)
        package_name (str): Name of package
    """
    with open(f"{package_name}.vhd", "w") as f:
        f.write(f"-- This file was auto-generated using: `{os.path.basename(__file__)}`\n"
                f"use work.array_package.all;\n"
                f"\npackage {package_name} is\n"
                f"\tconstant EXAMPLE_TAPS : array_integer_t := (")
        for idx, tap in enumerate(taps): 
            if idx == len(taps)-1:
                f.write(f"{tap});\n")
            else:
                f.write(f"{tap},")
        f.write(f"end package {package_name};")
        
        

def __plot(x:np.ndarray, y:np.ndarray, title:str="") -> None:
    """Plots x vs y in a new figure.
    Plot grid lines are turned on for both axis.

    Args:
        x (np.ndarray): Numpy array of x-axis data
        y (np.ndarray): Numpy array of y-axis data
        title (str, optional): Title of plot. Defaults to "".
    """
    plt.figure()
    plt.plot(x, y)
    plt.grid("both")
    plt.title(title)

def generate_example_taps(data_w:int) -> List[int]:
    """Generate some arbitrary taps from hard coded params.

    Args:
        data_w (int): Data bit width

    Returns:
        List[int]: Fixed point integer taps
    """
    bands = [0, 0.1, 0.3, 0.5]
    num_taps = 35
    taps = create_arbitrary_integer_filter_taps(data_w, bands, num_taps)
    return taps
    
if __name__ == "__main__":
    data_w = 16
    taps = generate_example_taps(data_w)
    filename="fir_single_rate_non_symmetric_filter_taps_package"
    export_to_vhdl_package(taps, filename)
    # plt.show()