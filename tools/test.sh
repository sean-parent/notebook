#!/bin/bash

last_path=""

function last_f {
    if [[ "$1" == "NoOp" ]]
    then echo "$last_path"
    else
        last_path="$1"
        echo "last_path=$1"
    fi
}

export -f last_f


fswatch --print0 --event=Updated "." | xargs -0 -I % echo %
