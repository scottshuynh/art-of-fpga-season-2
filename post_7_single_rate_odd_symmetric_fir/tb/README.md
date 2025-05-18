# Simulation and Synthesis
To simulate `fir_single_rate_odd_symmetric`, run the script:
```sh
./simulate_nvc_cocotb.sh
```

To create a Vivado project to synthesise `fir_single_rate_odd_symmetric`, run the script:
```sh
./create_vivado_project.sh
```
Make sure that the dependencies below are all met before running the scripts.

## Dependencies
Operating system is Linux.

Vivado must be installed and added to `$PATH` environment variable.

Python 3.8 is the minimum Python version to run the simulation and synthesis scripts.

Install the following Python packages: `hdldepends`, `hdlworkflow`, `cocotb`.

### `hdldepends` and `hdlworkflow`
These Python packages are included as submodules in this repo. Follow the steps below to install.

```sh
git submodule update --init
cd sub/hdldepends
pip install .
cd ../hdlworkflow
pip install .
```

### `cocotb`
```sh
pip install cocotb
```

## `nvc`
The simulator of choice is [nvc](https://www.nickg.me.uk/nvc/readme.html). Follow the installation steps outlined [here](https://www.nickg.me.uk/nvc/readme.html#Installing).

## `gtkwave`
The waveform viewer of choice is [gtkwave](https://gtkwave.github.io/gtkwave/). Follow the installation steps outlined [here](https://gtkwave.github.io/gtkwave/install/unix_linux.html).