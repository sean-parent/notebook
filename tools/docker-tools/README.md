# Using the docker image

## Setup
### Install Docker
If you don't already have Docker installed, [install Docker](https://docs.docker.com/get-docker/).

### Login to GitHub package registry
Login to docker with a GitHub token. Generate a token [here](https://github.com/settings/tokens) with read/write/delete permissions for packages.

Copy the generated token and paste it as the password (use your GitHub USERNAME).
```
docker login docker.pkg.github.com --username USERNAME
```
## Running the tools

### Pull the latest docker image

```
docker pull docker.pkg.github.com/sean-parent/notebook/notebook-tools:latest
```

### Running the Docker image

To run the docker image, execute the following.

```
VOLUME="docker.pkg.github.com/sean-parent/notebook/notebook-tools:latest"
docker run --mount type=bind,source="$(pwd)",target=/mnt/host  --tty --interactive \
    --publish 3000:3000 --publish 3001:3001 --publish 8888:8888 $VOLUME bash
```

This should leave you at a bash prompt that looks like:

```
app@fc7590a63ba3:~$
```

The hex number is the docker image container ID and may be different. Going forward I refer to this as the _docker_ prompt to distinguish it from the _local_ prompt.

### Build the documentation site

To build or rebuild the complete documentation site locally execute the following from the docker prompt:

```
cd /mnt/host
./tools/prepare.sh
```

### Run a local server for the site

Once the site has been prepared, you can run it to see how it looks. From the Docker prompt enter:

```
cd /mnt/host
./tools/start.sh --lab --server --no-token
```

To view the site, open a browser to `http://localhost:3000`. The site will auto rebuild and refresh as files are changed. The [Atom editor](https://atom.io/) has a nice [language package for markdown](https://atom.io/packages/language-markdown) that understand the YAML front matter that Jekyll uses, as well as a core package for markdown previews that uses the GitHub style (great for editing readme files).

## Tips

If you want to open another terminal on the running image use:

```
docker ps
docker exec -it <container id> bash
```

## Updating Docker package


### Building the docker image

To build the Docker image, first, update the VERSION variable below (please use semantic versioning). Add a [release note](#release-notes).

#### Linux, WSL 2, MacOS
```
VERSION="1.0.12"
VOLUME="docker.pkg.github.com/sean-parent/notebook/notebook-tools:latest"

# The ruby version should match what GitHub Pages requires: https://pages.github.com/versions/
RUBY_VERSION=2.7.1

echo $VERSION > ./tools/docker-tools/VERSION

# build the base image, no-cache is used, so the latest tools are installed

docker build --no-cache --build-arg RUBY_VERSION=$RUBY_VERSION \
    --file ./tools/docker-tools/Dockerfile --target base --tag $VOLUME .

# update the docs environment
docker run --mount type=bind,source="$(pwd)",target=/mnt/host --tty --interactive $VOLUME bash

# from docker prompt
cd /mnt/host
./tools/update.sh --lock
exit

# build the final image
docker build --build-arg RUBY_VERSION=$RUBY_VERSION --file ./tools/docker-tools/Dockerfile \
    --target full --tag $VOLUME .
```

If you are editing the Dockerfile you might want to build the base image from cache.

```
docker build --build-arg RUBY_VERSION=$RUBY_VERSION --file ./tools/docker-tools/Dockerfile \
    --target base --tag $VOLUME .
```

### Pushing the packages

```
# Tag the image with the version
docker tag docker.pkg.github.com/sean-parent/notebook/notebook-tools:latest docker.pkg.github.com/sean-parent/notebook/notebook-tools:$VERSION

# Push the image
docker push docker.pkg.github.com/sean-parent/notebook/notebook-tools:latest

docker push docker.pkg.github.com/sean-parent/notebook/notebook-tools:$VERSION
```

### Release Notes

- 1.0.0 - Initial release
- 1.0.1 - Rebuilt without external dependencies
- 1.0.2 - Rebuilding without lock files
- 1.0.3 - offline notebook extension added
- 1.0.12 - adding tbb support for parallel algorithms
