FROM docker.pkg.github.com/sean-parent/jupyter-docker/docs-tool-cpp-base:latest
USER app

RUN mkdir ./install
WORKDIR ./install
COPY ./docs/Gemfile .
COPY ./docs/Gemfile.lock .
COPY ./environment.yml .

RUN  (eval "$(rbenv init -)"; bundle install)
RUN ~/miniconda3/bin/conda env create

ENV BASH_ENV ~/.bashrc
SHELL ["/bin/bash", "-c"]

RUN eval "$(~/miniconda3/bin/conda shell.bash hook)"; conda activate notebook;  \
  jupyter labextension install --no-build @ijmbarr/jupyterlab_spellchecker; \
  jupyter labextension install --no-build @jupyterlab/toc; \
  jupyter lab build; \
   conda deactivate

WORKDIR ../

ADD VERSION .

EXPOSE 8888 3000 3001
