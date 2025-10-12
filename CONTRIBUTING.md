# wish**this** Docker project
Building and maintaining this project is solely about the containerization of [wish**this**](https://github.com/wishthis/wishthis/). If you want to contribute to wishthis itself, take a look [here](https://github.com/wishthis/wishthis/?tab=readme-ov-file#trophy-contributing). 

## Building and testing locally

If you contribute to this image, before making a pull request, you should build and run it locally. Here is a guide on how to do this.

### Prerequisites

- `docker` is installed in your development environment.
- `dockerd` the docker deamon is installed (and [started](https://docs.docker.com/config/daemon/start/))
- `buildx` is installed in your development environment.

Although it's possible to build packages without `dockerd` running, using [`buildah`](https://buildah.io/), the focus here is on [`buildx`](https://docs.docker.com/reference/cli/docker/buildx/). You're welcome to contribute with instructions for `buildah`.

### Building the docker image locally

1. Start the docker daemon if it's not already started: `sudo dockerd`
2. Run the build command: 
   ```
   docker buildx build --platform linux/amd64 -t wishthis-local --load .
   ```

    * replace the platform (`linux/amd64`) if you're building on another platform
    * replace `wishthis-local` with any name you would like to give your local image
    * `--load .` loads the image into your local docker, so you can use it as a container image.

#### Building the docker image containing the _non-release_ versions wish**this** 
- Follow the instructions above, but override the build arg: `WISHTHIS_GITBRANCH`. For example, you can build the _develop_ version:
    ```
    docker buildx build --platform linux/amd64 -t wishthis-local-dev \
    --build-arg WISHTHIS_GITBRANCH=develop --load . 
    ```

    This approach may also be used for other [branches of wish**this**](https://github.com/wishthis/wishthis/branches), including the [release-candidate](https://github.com/wishthis/wishthis/tree/release-candidate). Simply replace _develop_ in the above command with the proper branch name.

### Building for multiple architecures locally
1. Start the docker daemon if it's not already started: `sudo dockerd`
2. Create a builder-image `docker buildx create --name mybuilder --use --bootstrap` (see "Building with Buildx" [here](https://www.docker.com/blog/how-to-rapidly-build-multi-architecture-images-with-buildx/) for more details)
3. Run the build command: `docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t wishthis-local .`
    * replace `wishthis-local` with any name you would like to give your local image
    * NOTE: The build process is significantly longer than just building for your local architecture.

### Running the docker image locally
1. Follow the same steps as in [Docker : usage](./README.md#Docker-:-usage), replacing the image name `hiob/wishthis:stable` with your local container name, e.g. `wishthis-local`.