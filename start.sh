#!/bin/bash

export PATH="$HOME/miniconda3/bin:$PATH"

{
    source activate cling;
    jupyter notebook;
} & {
    source activate cling;
    fswatch -o ./better-code-class | \
    xargs -I{} -n1 jupyter nbconvert ./better-code-class/*.ipynb --to=slides --output-dir=./docs;
} & {
    cd ./docs;
    bundle exec jekyll build --watch --incremental;
} & {
    browser-sync start --config bs-config.js;
}
