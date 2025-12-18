FROM ubuntu:noble AS builder

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y eatmydata \
    && eatmydata apt-get install -y --no-install-recommends \
        ca-certificates cpio xxd \
        build-essential cmake git pkg-config rsync unzip wget zip \
        bc bison flex liblzma-dev libncurses-dev libssl-dev device-tree-compiler \
        ninja-build tcl \
        dosfstools file mtools \
        fuse2fs shellcheck \
        python3




FROM builder AS build_image
WORKDIR /builder
ADD scripts/ /builder/

CMD ["/bin/bash"]
