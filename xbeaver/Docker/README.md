# XBeaver Docker Container

The Docker image is available from https://hub.docker.com/r/johnnewcombe/xbeaver. The notes below are for those who wish to build/modify the image from scratch.

## Example: Build and Upload Docker Image

    docker build --no-cache --tag <user>/xbeaver:latest --tag <user>/xbeaver:<tag> .
    docker login
    docker push <user>/xbeaver:<ver>
    docker push <user>/xbeaver:latest

## Example: Run Docker Container

    docker run -d -p 5901:5901 -p 6901:6901 -v /Users/<user>/.xbeaver:/root/xbeaver <user>/xbeaver:<tag>

## Example: Docker Compose

A suitable Docker compose file is available in this repository.

        