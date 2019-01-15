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
jupyter labextension update --all
)

# create symlinks

(cd ./docs; bundle update;)
