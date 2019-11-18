#!/bin/bash

export PATH="$HOME/miniconda3/bin:$PATH"

npm update -g npm
npm update -g browser-sync
gem update bundler

conda update conda -c conda-forge
conda env update

git submodule update --recursive --remote

(
conda activate notebook
jupyter labextension update --all
)


(cd ./docs; bundle update;)
