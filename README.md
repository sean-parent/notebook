# notebook

[![Binder](https://mybinder.org/badge.svg)](https://mybinder.org/v2/gh/sean-parent/notebook/master)

_Note: This instructions currently omit install brew, npm, browser-sync, fswatch... needed for ./start.sh, however this installation instructions are sufficient to get jupyter notebook running.

## Mac intallation instructions to run locally

```
# download Python 3.6 install script for miniconda from https://conda.io/miniconda.html
# make the script executable and invoke it:
chmod +x ~/Downloads/Miniconda3-latest-MacOSX-x86_64.sh
~/Downloads/Miniconda3-latest-MacOSX-x86_64.sh
# when asked to add the path to your .bash_profile, enter "no"

# add conda to you path for this session
export PATH="$HOME/miniconda3/bin:$PATH"

# create the conda environment and activate it
conda env create
source activate sean-parent-notebook

# <patch>
  # Update pyzmq
  conda install pyzmq=16.0.2 -c conda-forge

  # Necessary step for now to workaround for now.
  ln -s ~/miniconda3/envs/sean-parent-notebook/lib/libzmq.5.1.3.dylib \
      ~/miniconda3/envs/sean-parent-notebook/lib/libzmq.5.1.2.dylib
# </patch>

# exit the environment
source deactivate
```

## Running the environment

```
./start.sh
```
