#!/bin/bash

export PATH="$HOME/miniconda3/bin:$PATH";

brew update
brew upgrade npm
brew upgrade fswatch
npm update -g browser-sync
conda update conda
conda env update -n sean-parent-notebook

(cd ./docs; bundle update)
