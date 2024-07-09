## Custom Dockerfile
#
# USE: 
#    docker build --no-cache --tag johnnewcombe/xbeaver:latest --tag johnnewcombe/xbeaver:<ver> .

FROM johnnewcombe/xbeaver:base
# FROM consol/rocky-icewm-vnc:latest
ENV REFRESHED_AT 2024-07-09

# Switch to root user to install additional software
USER 0

# base image has a dodgy repo so remove it
#RUN yum-config-manager --disable tigervnc-el7 & yum clean all

# Install the dependancies and a few utils
#RUN yum install -y gcc wget libXt-devel ncurses-devel libXpm-devel minicom make nano alsa-lib-devel & yum clean all

# Build XBeaver
WORKDIR /headless/xbeaver
RUN wget https://www.cccplusplus.co.uk/download/xbeaver.tgz
RUN tar -xzvf xbeaver.tgz
RUN make

## to switch to a default non root user, use the following
#USER 1000
