
call activate notebook
start jupyter lab

#start fswatch --print0 --event=Updated --exclude=".*/\..*" ./better-code-class | xargs -0 -I % \
#    jupyter nbconvert % --to=slides --reveal-prefix=../reveal.js --execute \
#    --output-dir=./docs/better-code-class --config=./slides-config/slides_config.py

start browser-sync start --config bs-config.js
