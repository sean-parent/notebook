# Build from the latest ubuntu release
FROM ubuntu:latest AS base

# Install items requiring root access

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --no-install-recommends -y \
    apt-utils \
    fswatch \
    g++ \
    git \
    libreadline-dev \
    make \
    npm \
    rbenv \
    wget \
    zlib1g-dev

RUN npm install -g npm@latest
RUN npm install -g browser-sync

# Create a user "app" so everything is not running at root
RUN useradd -ms /bin/bash app
USER app
WORKDIR /home/app

# Set UTF language (assumed by jekyll)
ENV LC_ALL "C.UTF-8"
ENV LANG "en_US.UTF-8"
ENV LANGUAGE "en_US.UTF-8"

# Install ruby environment
RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc
RUN mkdir -p "$(rbenv root)"/plugins
RUN git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

#  Install ruby
ARG RUBY_VERSION
RUN if [ -z ${RUBY_VERSION+x} ]; then \
      rbenv install $(rbenv install -l | grep -v - | tail -1); \
      rbenv global  $(rbenv install -l | grep -v - | tail -1); \
    else \
      rbenv install $RUBY_VERSION; \
      rbenv global $RUBY_VERSION; \
    fi

#  Install bundler in global ruby
RUN (eval "$(rbenv init -)"; gem install bundler)

# Install conda
RUN mkdir $HOME/.conda
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ./miniconda.sh
RUN chmod +x ./miniconda.sh
# https://docs.anaconda.com/anaconda/install/silent-mode/
RUN bash ./miniconda.sh -b -p ./miniconda3
RUN eval "$(~/miniconda3/bin/conda shell.bash hook)"; conda init; \
    conda update -n base -c defaults conda

# build the final files
FROM base AS full
USER app
WORKDIR /home/app

RUN mkdir ./install
WORKDIR ./install
COPY ./docs/Gemfile .
COPY ./docs/Gemfile.lock .
COPY ./environment.yml .
COPY ./.ruby-version .

RUN (eval "$(rbenv init -)"; \
    rbenv install `cat .ruby-version`; \
    gem install bundler; \
    rbenv rehash; \
    bundle install)

RUN ~/miniconda3/bin/conda env create

ENV BASH_ENV ~/.bashrc
SHELL ["/bin/bash", "-c"]

RUN eval "$(~/miniconda3/bin/conda shell.bash hook)"; conda activate notebook;  \
  jupyter labextension install --no-build @ijmbarr/jupyterlab_spellchecker; \
  jupyter labextension install --no-build @jupyterlab/toc; \
  jupyter lab build; \
   conda deactivate

WORKDIR /home/app

EXPOSE 8888 3000 3001

# Add version file last to avoid cache invalidation for minor releases
ADD ./tools/docker-tools/VERSION .
