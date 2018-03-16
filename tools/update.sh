#!/bin/bash

export PATH="$HOME/miniconda3/bin:$PATH";

brew update
brew upgrade npm
brew upgrade fswatch
brew upgrade ruby
npm update -g npm
npm update -g browser-sync
gem update bundler
conda update conda
conda env update -n sean-parent-notebook

(cd ./docs; bundle update;)