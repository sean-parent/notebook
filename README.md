# notebook

You can browse and play with the notebooks online via [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/sean-parent/notebook/master?urlpath=lab).

The slides are available at https://sean-parent.stlab.cc/notebook/

## Running locally

\[ _Note: I've moved to Docker for consistent, cross-platform use. Platform-specific instructions are no longer included._ \]

### Setup

- [Install Docker](https://docs.docker.com/get-docker/).
- Clone this repo and `cd` to the repo directory.

\[ _Note: Currently browser-sync is not working with VirtioFS in Docker. I recommend using gRBC FUSE for now._ \]

### Running Tools

```
VOLUME="docker.pkg.github.com/sean-parent/notebook/notebook-tools:latest"
PLATFORM="linux/amd64"

docker run --platform=$PLATFORM --mount type=bind,source="$(pwd)",target=/mnt/host  --tty --interactive \
    --publish 4000:3000 --publish 4001:3001 --publish 8888:8888 $VOLUME bash
```

From the Docker prompt

```
cd /mnt/host
./tools/prepare.sh
./tools/start.sh --lab --server --no-token
```

\[ _Note: If a browser window is open to JupyterLab when you start the server, it will report errors about the kernel not being available. Close the browser window and open a new one._ \]

- Jupyter Lab is available at http://localhost:8888
- The slides are available at http://localhost:4000/notebook/

## Tips

If you want to open another terminal on the running image use:

```
docker ps
docker exec -it <container id> bash
```

## Updating the tools image

See [./tools/docker-tools/README.md](./tools/docker-tools/README.md)


jupytext --to notebook --output - ./better-code-new/05-auto.md | jupyter nbconvert --stdin --to=slides --reveal-prefix=../reveal.js --output-dir=./docs/better-code-class --config=./slides-config/slides_config.py
