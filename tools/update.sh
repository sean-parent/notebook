#!/bin/bash

export PATH="$HOME/miniconda3/bin:$PATH"
# export PATH="/usr/local/opt/node@8/bin:$PATH"

brew update
brew upgrade npm
brew upgrade fswatch
brew upgrade ruby
npm update -g npm
npm update -g browser-sync
gem update bundler
conda update conda -c conda-forge
conda env update
git submodule update --recursive --remote

(
source activate notebook
jupyter labextension install --no-build @ijmbarr/jupyterlab_spellchecker
jupyter labextension install --no-build @jupyterlab/toc
jupyter labextension install --no-build @jupyterlab/celltags
jupyter lab build
)

(cd ./docs; bundle update;)
