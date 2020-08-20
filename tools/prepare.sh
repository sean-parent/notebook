#!/bin/bash

cp -Rf ./better-code-new/img ./docs/better-code-new/
cp -Rf ./better-code-test/img ./docs/better-code-test/
cp -Rf ./better-code-class/img ./docs/better-code-class/

#export PATH="/usr/local/Caskroom/miniconda/base/bin:$PATH"
eval "$(conda shell.bash hook)"
conda activate notebook

jupyter nbconvert ./better-code-class/*.ipynb --to=notebook --execute \
        --output-dir=./better-code-class/
jupyter nbconvert ./better-code-class/*.ipynb --to=slides --reveal-prefix=../reveal.js \
    --output-dir=./docs/better-code-class --config=./slides-config/slides_config.py

jupyter nbconvert ./better-code-test/*.ipynb --to=notebook --execute \
        --output-dir=./better-code-test/
jupyter nbconvert ./better-code-test/*.ipynb --to=slides --reveal-prefix=../reveal.js \
    --output-dir=./docs/better-code-test --config=./slides-config/slides_config.py

jupyter nbconvert ./better-code-new/*.ipynb --to=notebook --execute \
        --output-dir=./better-code-new/
jupyter nbconvert ./better-code-new/*.ipynb --to=slides --reveal-prefix=../reveal.js \
    --output-dir=./docs/better-code-new --config=./slides-config/slides_config.py

( cd ./docs; bundle exec jekyll build --profile )
