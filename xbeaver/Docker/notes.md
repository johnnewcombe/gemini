## Build and Upload Docker Image

    docker build --no-cache --tag johnnewcombe/xbeaver:latest --tag johnnewcombe/xbeaver:<ver> .
    docker login
    docker push johnnewcombe/xbeaver:<ver>
    docker push johnnewcombe/xbeaver:latest

## Run Docker Container

    docker run -d -p 5901:5901 -p 6901:6901 -v /Users/john/.xbeaver:/root/xbeaver johnnewcombe/xbeaver:<tag>

