#!/bin/bash

#
# This script assumes the tooling is already installed (see docker image). This only
# installs the local dependencies.

conda env create
(cd ./docs; bundle install;)
