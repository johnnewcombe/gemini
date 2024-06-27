## Custom Dockerfile
#
# USE: 
#    docker build --no-cache --tag johnnewcombe/xbeaver:latest --tag johnnewcombe/xbeaver:<ver> .

FROM consol/centos-icewm-vnc
ENV REFRESHED_AT 2022-09-18

# Switch to root user to install additional software
USER 0

# base image has a dodgy repo so remove it
RUN yum-config-manager --disable tigervnc-el7 & yum clean all

# Install the dependancies and a few utils
RUN yum install -y make gcc wget ncurses-devel libXt-devel libXpm-devel minicom nano alsa-lib-devel & yum clean all

# Build XBeaver
RUN mkdir /headless/xbeaver
WORKDIR /headless/xbeaver
RUN wget http://81.98.24.96/download/xbeaver.tgz # http://www.cccplusplus.co.uk/download/xbeaver.tgz # http://81.98.24.96/download/xbeaver.tgz
RUN tar -xzvf xbeaver.tgz
RUN make

## to switch to a default non root user, use the following
#USER 1000
