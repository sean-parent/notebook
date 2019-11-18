#!/bin/bash

# export PATH="$HOME/miniconda3/bin:$PATH"
# export PATH="/usr/local/opt/node@8/bin:$PATH"

# export PATH="/usr/local/Caskroom/miniconda/base/bin:$PATH"

cp ~/.rbenv/version .ruby-version
# rbenv install $(rbenv install -l | grep -v - | tail -1)
# gem install bundler
# rbenv rehash
(cd ./docs; bundle update)

conda env create
conda env update
(
eval "$(conda shell.bash hook)"
conda activate notebook
jupyter labextension update --all
)

# brew update
# brew upgrade npm
# brew upgrade fswatch
# npm update -g npm
# npm update -g browser-sync
# gem update bundler
# conda update conda -c conda-forge
# conda env update
# git submodule update --recursive --remote
# 
# (
# eval "$(conda shell.bash hook)"
# conda activate notebook
# jupyter labextension update --all
# )
# 
# # create symlinks
# 
# (cd ./docs; bundle update;)
