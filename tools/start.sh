#!/bin/bash

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -l|--lab)
    LAB=YES
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# end command processing

export PATH="$HOME/miniconda3/bin:$PATH"

trap "source activate notebook; jupyter notebook stop 8888" EXIT
trap 'for pid in $BKPIDS; do kill $pid; done; exit' SIGINT

{
    source activate notebook
    if [[ $LAB = YES ]]; then
        jupyter lab
    else
        jupyter notebook
    fi
} &

source activate notebook;
jupyter nbconvert ./better-code-class/*.ipynb --to=slides --reveal-prefix=../reveal.js \
    --execute --output-dir=./docs/better-code-class --config=./slides-config/slides_config.py

jupyter nbconvert ./better-code-new/*.ipynb --to=slides --reveal-prefix=../reveal.js \
    --execute --output-dir=./docs/better-code-new --config=./slides-config/slides_config.py

jupyter nbconvert ./better-code-test/*.ipynb --to=slides --reveal-prefix=../reveal.js \
    --execute --output-dir=./docs/better-code-test --config=./slides-config/slides_config.py

{
    fswatch --print0 --event=Updated --exclude=".*/\..*" ./better-code-test | xargs -0 -I % \
    jupyter nbconvert % --to=slides --reveal-prefix=../reveal.js --execute \
        --output-dir=./docs/better-code-test --config=./slides-config/slides_config.py
} &
BKPIDS=($!)
{
    fswatch --print0 --event=Updated --exclude=".*/\..*" ./better-code-class | xargs -0 -I % \
    jupyter nbconvert % --to=slides --reveal-prefix=../reveal.js --execute \
        --output-dir=./docs/better-code-class --config=./slides-config/slides_config.py
} &
BKPIDS=($!)
{
    fswatch --print0 --event=Updated --exclude=".*/\..*" ./better-code-new | xargs -0 -I % \
    jupyter nbconvert % --to=slides --reveal-prefix=../reveal.js --execute \
        --output-dir=./docs/better-code-new --config=./slides-config/slides_config.py
} &
BKPIDS+=($!)
{
    cd ./docs
    bundle exec jekyll build --baseurl ""
    bundle exec jekyll build --baseurl "" --watch --incremental
} &
BKPIDS+=($!)

browser-sync start --config bs-config.js


