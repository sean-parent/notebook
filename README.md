# notebook

[![Binder](https://mybinder.org/badge.svg)](https://mybinder.org/v2/gh/sean-parent/notebook/master)

## Mac installation instructions to run locally

- clone this repo and cd to the directory
- if you don't already have the xcode command line tools installed, install them
```
xcode-select --install
```
- install miniconda for Python 3.6
	- download the install script [here](https://conda.io/miniconda.html)
	- execute the downloaded script
	- when prompted `Do you wish the installer to prepend the Miniconda3 install location to PATH in your /Users/<name>/.bash_profile ? [yes|no]` answer no
```
chmod +x ~/Downloads/Miniconda3-latest-MacOSX-x86_64.sh
~/Downloads/Miniconda3-latest-MacOSX-x86_64.sh
```
- Create the conda environment
```
export PATH="$HOME/miniconda3/bin:$PATH"
conda env create
```

## To run the notebook
```
export PATH="$HOME/miniconda3/bin:$PATH"
source activate sean-parent-notebook
jupyter notebook
```
- use control-c and `source deactivate` to exit

## To setup complete environment with interactive slide editing and jekyl pages

- install [homebrew](https://brew.sh/)
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
- install utilities
```
brew install npm
brew install fswatch
brew install ruby
npm install -g browser-sync
```

## Run update to complete installation
```
./tools/update.sh
```

## To run complete environment
```
./tools/start.sh
```
- use control-c to exit

## To update environment
```
./tools/update.sh
```
## To prepare all slides before pushing to github
```
./tools/prepare.sh
```
