#!/bin/bash

export PATH="$HOME/miniconda3/bin:$PATH";

trap "source activate sean-parent-notebook; jupyter notebook stop 8888;" EXIT;

{
    source activate sean-parent-notebook;
    jupyter notebook;
} & {
    source activate sean-parent-notebook;
    jupyter nbconvert ./better-code-class/*.ipynb --to=slides --execute --output-dir=./docs \
        --config=./slides-config/slides_config.py;
    fswatch --print0 --exclude=".*/\..*"  ./better-code-class | xargs -0 -I % \
    jupyter nbconvert % --to=slides --execute --output-dir=./docs \
        --config=./slides-config/slides_config.py;
} & {
    cd ./docs;
    bundle exec jekyll build --baseurl "";
    bundle exec jekyll build --baseurl "" --watch --incremental;
} & {
    browser-sync start --config bs-config.js;
} & wait;
