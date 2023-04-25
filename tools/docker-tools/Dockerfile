# Build from the latest ubuntu release
FROM --platform=linux/amd64 ubuntu:latest AS base

# Install items requiring root access

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    apt-utils \
    curl \
    fswatch \
    g++ \
    git \
    libreadline-dev \
    libtbb-dev \
    lsof \
    make \
    npm \
    rbenv \
    wget

# https://stackoverflow.com/questions/62464422/facing-issue-while-installing-ruby-2-7-1
# RUN apt-get install -y software-properties-common
# RUN add-apt-repository --remove ppa:sethj/silentcast

# https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
# RUN curl -fsSL https://deb.nodesource.com/setup_15.x | bash -
# RUN apt-get install -y nodejs

# install node for browser-sync
RUN npm install -g n
# nodejs v18 fails with:
#8 0.200 node: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.28' not found (required by node)
# so version is temporarily set to 17
RUN n 16.13.0

RUN npm update -g
RUN npm install -g browser-sync@2.24.1

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
RUN wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh -O ./miniconda.sh
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
WORKDIR /home/app/install
COPY ./docs/Gemfile .
COPY ./docs/Gemfile.lock .
COPY ./environment.yml .
COPY ./.ruby-version .

RUN (eval "$(rbenv init -)"; \
    rbenv install `cat .ruby-version`; \
    gem install bundler; \
    rbenv rehash; \
    bundle install)

RUN ~/miniconda3/bin/mamba env create

ENV BASH_ENV ~/.bashrc
SHELL ["/bin/bash", "-c"]

RUN eval "$(~/miniconda3/bin/conda shell.bash hook)"; conda activate notebook;  \
  jupyter labextension install --no-build jupyterlab-slide-mode-keyboard-shortcuts; \
  jupyter lab build; \
   conda deactivate

WORKDIR /home/app

EXPOSE 8888 3000 3001

# Add version file last to avoid cache invalidation for minor releases
ADD ./tools/docker-tools/VERSION .
