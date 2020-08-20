# notebook

You can browse and play with the notebooks online via [![Binder](https://mybinder.org/badge.svg)](https://mybinder.org/v2/gh/sean-parent/notebook/master?urlpath=lab).

The slides are available at http://sean-parent.stlab.cc/notebook/

## Running locally

\[ _Note: I've moved to Docker for consistent, cross platform use. Platform specific instructions are no longer included._ \]

### Setup

- [Install Docker](https://docs.docker.com/get-docker/).
- Clone this repo and `cd` to the repo directory.

### Running Tools

```
docker run --env JUPYTER_CONFIG_DIR=/mnt/home/_jupyter --mount type=bind,source="$(pwd)",target=/mnt/home  -t -i -p 3000:3000 -p 3001:3001 -p 8888:8888 docker.pkg.github.com/sean-parent/notebook/notebook-tools:latest  bash
```

From the Docker prompt

```
cd /mnt/home
./tools/prepare.sh
./tools/start.sh --lab --server --no-token
```

- Jupyter Lab is available at http://localhost:8888
- The slides are available at http://localhost:3000

## Tips

If you want to open another terminal on the running image use:

```
docker ps
docker exec -it <container id> bash
```

## Updating the tools image

See [./tools/docker-tools/README.md](./tools/docker-tools/README.md)
