#!/bin/bash

POSITIONAL=()
SECTION="all"
while [[ $# -gt 0 ]] ;
do
key="$1";
shift;

case $key in
    -s|--section)
        SECTION="$1"
        shift # past argument
    ;;
    "-s="*|"--section="*)
        SECTION="${key#*=}"
    ;;
    *)    # unknown option
        POSITIONAL+=("$key") # save it in an array for later
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

cp -ru ./better-code-new/img ./docs/better-code-new/
cp -ru ./better-code-test/img ./docs/better-code-test/
cp -ru ./better-code-class/img ./docs/better-code-class/

#export PATH="/usr/local/Caskroom/miniconda/base/bin:$PATH"
eval "$(conda shell.bash hook)"
conda activate notebook

# copy/pasted from start.sh
function md_to_slides {
    basename=$(basename -- "$1")
    filename="${basename%.*}"
    jupytext --to notebook --output - "$1" \
        | jupyter nbconvert --stdin --to=slides --reveal-prefix=../reveal.js \
    --output="$2/$filename" --config=./slides-config/slides_config.py
}

function generate_slides {
    for file in $1/*.md
    do
        md_to_slides "$file" "$2"
    done
}

# if [ $SECTION == "all" ] || [ $SECTION == "notes" ]; then
#    generate_slides ./notes ./docs/notes
# fi

if [ $SECTION == "all" ] || [ $SECTION == "class" ]; then
    generate_slides ./better-code-class ./docs/better-code-class
fi

if [ $SECTION == "all" ] || [ $SECTION == "test" ]; then
    generate_slides ./better-code-test ./docs/better-code-test
fi

if [ $SECTION == "all" ] || [ $SECTION == "new" ]; then
    generate_slides ./better-code-new ./docs/better-code-new
fi

( cd ./docs; bundle exec jekyll build --profile )
