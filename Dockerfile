FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-20.04
WORKDIR /rose

# Set up environment
ENV ROSE_HOME=/rose
ENV NUM_PROCESSORS=4
ENV BOOST_ROOT=/usr/include/boost
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu

# Set tar options to preserve file permissions
# This fixes an issue with the ROSE EDG decompression script, which uses gzip
# This is the env variable set by the script: 
# GZIP= gunzip -c EDG.tar.gz |tar -xf -
ARG TAR_OPTIONS="--no-same-owner --no-same-permissions"

# Install ROSE dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y \
    git \
    wget \
    make \
    automake \
    libtool \
    gcc \
    g++ \
    libboost-all-dev \
    flex \
    bison \
    ghostscript \
    iputils-ping

# Download ROSE 
RUN git clone -b weekly https://github.com/rose-compiler/rose.git ${ROSE_HOME}/src
RUN cd ${ROSE_HOME}/src && ./build

# Configure ROSE
RUN mkdir ${ROSE_HOME}/build

RUN cd ${ROSE_HOME}/build && ${ROSE_HOME}/src/configure --prefix=${ROSE_HOME}/install \
                  --enable-languages=c,c++ \
                  --with-boost="/usr" --with-boost-libdir="/usr/lib/x86_64-linux-gnu"

# Compile 
RUN cd ${ROSE_HOME}/build && make core -j${NUM_PROCESSORS} && make install-core -j${NUM_PROCESSORS} && make check-core -j${NUM_PROCESSORS}
