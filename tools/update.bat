

call gem update --system
call gem update bundler
call npm update -g npm
call npm update -g brower-sync
call npm update -g fswatch
call bundle update --bundler

call conda update conda -c conda-forge
call conda env update

call git submodule update --recursive --remote
