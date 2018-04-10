#!/bin/bash

export PATH="$HOME/miniconda3/bin:$PATH";

trap "source activate notebook; jupyter notebook stop 8888;" EXIT;

{
    source activate notebook;
    jupyter lab;
} & {
    source activate notebook;
    jupyter nbconvert ./notes/*.ipynb --to=slides --execute --output-dir=./docs \
        --config=./slides-config/slides_config.py;
    {
		fswatch --print0 --exclude=".*/\..*" ./notes | xargs -0 -I % \
		jupyter nbconvert % --to=slides --execute --output-dir=./docs \
			--config=./slides-config/slides_config.py;
	} & {
		cd ./docs;
		bundle exec jekyll build --baseurl "";
		bundle exec jekyll build --baseurl "" --watch --incremental;
	} & {
		browser-sync start --config bs-config.js;
	}
} & wait;
