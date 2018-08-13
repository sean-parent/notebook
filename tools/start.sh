#!/bin/bash

export PATH="$HOME/miniconda3/bin:$PATH"

trap "source activate notebook; jupyter notebook stop 8888" EXIT

{
    source activate notebook
    jupyter notebook
} & {
    source activate notebook;
    jupyter nbconvert ./better-code-class/*.ipynb --to=slides --reveal-prefix=../reveal.js \
        --execute --output-dir=./docs/better-code-class --config=./slides-config/slides_config.py

    jupyter nbconvert ./better-code-test/*.ipynb --to=slides --reveal-prefix=../reveal.js \
        --execute --output-dir=./docs/better-code-test --config=./slides-config/slides_config.py

    {
		fswatch --print0 --event=Updated --exclude=".*/\..*" ./better-code-test | xargs -0 -I % \
		jupyter nbconvert % --to=slides --reveal-prefix=../reveal.js --execute \
		    --output-dir=./docs/better-code-test --config=./slides-config/slides_config.py
	} & {
		fswatch --print0 --event=Updated --exclude=".*/\..*" ./better-code-class | xargs -0 -I % \
		jupyter nbconvert % --to=slides --reveal-prefix=../reveal.js --execute \
		    --output-dir=./docs/better-code-class --config=./slides-config/slides_config.py
	} & {
		cd ./docs
		bundle exec jekyll build --baseurl ""
		bundle exec jekyll build --baseurl "" --watch --incremental
	} & {
		browser-sync start --config bs-config.js
	}
} & wait
