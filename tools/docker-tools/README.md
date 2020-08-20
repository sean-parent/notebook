# Using the docker image

## Setup

### Install Docker
If you don't already have docker installed, [install Docker](https://docs.docker.com/get-docker/).

### Building the docker image

To build the docker image, first update the VERSION variable below (please use semantic versioning). Add a [release note](#release-notes).

#### Using Windows PowerShell
```
$VERSION='1.0.1'
$VOLUME="docker.pkg.github.com/sean-parent/notebook/notebook-tools:latest"
```

#### Linux or macOS
```
VERSION="1.0.1"
VOLUME="docker.pkg.github.com/sean-parent/notebook/notebook-tools:latest"
```

### Common
```
echo $VERSION > ./tools/docker-tools/VERSION

# build the base image, no-cache is used so the latest tools are installed
docker build --no-cache --file ./tools/docker-tools/Dockerfile --target base --tag $VOLUME .

# update the docs environment
docker run --mount type=bind,source="$(pwd)",target=/mnt/host --tty --interactive $VOLUME bash

# from docker prompt (v2.6.6 is needed until Jekyll is updated to 4.1).
cd /mnt/host
./tools/update.sh --lock --ruby-version 2.6.6
exit

# build the final image
docker build --file ./tools/docker-tools/Dockerfile --target full --tag $VOLUME .
```

## Running the Docker image

To run the docker image, execute the following.

```
$VOLUME="docker.pkg.github.com/sean-parent/notebook/notebook-tools:latest"
```

```
VOLUME="docker.pkg.github.com/sean-parent/notebook/notebook-tools:latest"
```
```
docker run --mount type=bind,source="$(pwd)",target=/mnt/host  --tty --interactive --publish 3000-3001:3000 --publish 8888:8888 $VOLUME bash
```

This should leave you at bash prompt that looks like:

```
app@fc7590a63ba3:~$
```

The hex number is the docker image container ID and may be different. Going forward I refer to this as the _docker_ prompt to distinguish it from the _local_ promt.

## Build the documentation site

To build or rebuild the complete documentation site locally execute the following from the docker prompt:

```
cd /mnt/host
./tools/prepare.sh
```

## Run a local server for the site

Once the site has been prepared, you can run it to see how it looks. From the docker promt enter:

```
./tools/start.sh --lab --server --no-token
```

To view the site, open a browser to `http://localhost:3000`. The site will auto rebuild and refresh as files are changed. The [Atom editor](https://atom.io/) has a nice [language package for markdown](https://atom.io/packages/language-markdown) that understand the YAML front matter that Jekyll uses, as well as a core package for markdown previews that uses the github style (great for editing readme files).

## Tips

If you want to open another terminal on the running image use:

```
docker ps
docker exec -it <container id> bash
```

To test a local copy of the jekyll theme, edit the Gemfile and use:

```
docker run --mount type=bind,source="$(pwd)",target=/mnt/host \
    --mount type=bind,source=$HOME/Projects/github.com/adobe/hyde-theme,target=/mnt/themes \
    --tty --interactive --publish 3000-3001:3000-3001 \
    $VOLUME bash
```

## Updating docker package

### Setup

Login to docker with a github token. Generate a token [here](https://github.com/settings/tokens) with read/write/delete permissions for packages.

Copy the generated token and paste it as the password (use your USERNAME).
```
docker login docker.pkg.github.com --username USERNAME
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
