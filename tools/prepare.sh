#!/bin/bash

export PATH="$HOME/miniconda3/bin:$PATH";

source activate notebook;
jupyter nbconvert ./better-code-class/*.ipynb --to=notebook --execute \
        --output-dir=./better-code-class/
jupyter nbconvert ./better-code-class/*.ipynb --to=slides --reveal-prefix=../reveal.js \
    --output-dir=./docs/better-code-class --config=./slides-config/slides_config.py

jupyter nbconvert ./better-code-test/*.ipynb --to=notebook --execute \
        --output-dir=./better-code-test/
jupyter nbconvert ./better-code-test/*.ipynb --to=slides --reveal-prefix=../reveal.js \
    --output-dir=./docs/better-code-test --config=./slides-config/slides_config.py
