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

if [ $SECTION == "all" ] || [ $SECTION == "class" ]; then
jupyter nbconvert ./better-code-class/*.ipynb --to=notebook --execute \
        --output-dir=./better-code-class/
jupyter nbconvert ./better-code-class/*.ipynb --to=slides --reveal-prefix=../reveal.js \
    --output-dir=./docs/better-code-class --config=./slides-config/slides_config.py
fi


if [ $SECTION == "all" ] || [ $SECTION == "test" ]; then
jupyter nbconvert ./better-code-test/*.ipynb --to=notebook --execute \
        --output-dir=./better-code-test/
jupyter nbconvert ./better-code-test/*.ipynb --to=slides --reveal-prefix=../reveal.js \
    --output-dir=./docs/better-code-test --config=./slides-config/slides_config.py
fi

if [ $SECTION == "all" ] || [ $SECTION == "new" ]; then
jupyter nbconvert ./better-code-new/*.ipynb --to=notebook --execute \
        --output-dir=./better-code-new/
jupyter nbconvert ./better-code-new/*.ipynb --to=slides --reveal-prefix=../reveal.js \
    --output-dir=./docs/better-code-new --config=./slides-config/slides_config.py
fi

( cd ./docs; bundle exec jekyll build --profile )
