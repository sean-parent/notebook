#!/bin/bash

POSITIONAL=()
OPTIONS=""
while [[ $# -gt 0 ]]
do
key="$1"

SLIDES=YES

case $key in
    -l|--lab)
        LAB=YES
        shift # past argument
    ;;
    -n|--notebook)
        LAB=NO
        shift
    ;;
    -n|--no-slides)
        SLIDES=NO
        shift
    ;;
    -s|--server)
        OPTIONS+=" --ip=0.0.0.0 --no-browser"
        shift
    ;;
    -t|--no-token)
        OPTIONS+=" --NotebookApp.token=''"
        shift
    ;;
    *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# end command processing

#export PATH="/usr/local/Caskroom/miniconda/base/bin:$PATH"
eval "$(conda shell.bash hook)"

trap "conda activate notebook; jupyter notebook stop 8888" EXIT
trap 'for pid in $BKPIDS; do kill $pid; done; exit' SIGINT

conda activate notebook

# copy/pasted from prepare.sh
function md_to_slides {
    basename=$(basename -- "$1")
    filename="${basename%.*}"
    echo "converting $1 to slides in $2/$filename"
    jupytext --to notebook --execute --output - "$1" \
        | jupyter nbconvert --stdin --to=slides --reveal-prefix=../reveal.js \
            --output="$2/$filename" --config=./slides-config/slides_config.py
}

export -f md_to_slides

function auto_generate_slides {
    # watch for changes to markdown files and regenerate slides
    # inotify_monitor is not working in docker
    directory=$1
    fswatch --print0 --event=Updated --monitor=poll_monitor ./$directory/*.md \
        | xargs -0 -I % bash -c 'md_to_slides "%" "./docs/$0"' $directory || true
}

if [[ $SLIDES = YES ]]; then
    {
        auto_generate_slides "better-code-test"
    } &
    BKPIDS=($!)
    {
        echo "watching better-code-class"
        auto_generate_slides "better-code-class"
    } &
    BKPIDS+=($!)
    {
        auto_generate_slides "better-code-new"
    } &
    BKPIDS+=($!)
    {
        cd ./docs
        bundle exec jekyll build --watch --incremental
    } &
    BKPIDS+=($!)
    {
        browser-sync start --config bs-config.js
    } &
    BKPIDS+=($!)
fi

{
    conda activate notebook
    if [[ $LAB = NO ]]; then
        jupyter notebook $OPTIONS
    else
        (
            export JUPYTERLAB_SETTINGS_DIR='/mnt/host/_jupyter/lab/user-settings/';
            export JUPYTERLAB_WORKSPACES_DIR='/mnt/host/_jupyter/lab/workspaces/';
            jupyter lab $OPTIONS
        )
    fi
}

# if [[ $SLIDES = YES ]]; then
#     browser-sync start --config bs-config.js
#     {
#         cd ./docs
#         bundle exec jekyll serve --watch --incremental --force_polling --detach
#     }
# fi
