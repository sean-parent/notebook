#!/bin/bash

export PATH="$HOME/miniconda3/bin:$PATH";

source activate sean-parent-notebook;
jupyter nbconvert ./better-code-class/*.ipynb --to=notebook --execute \
        --output-dir=./better-code-class/;
jupyter nbconvert ./better-code-class/*.ipynb --to=slides --output-dir=./docs \
        --config=./slides-config/slides_config.py;

