FROM ubuntu:22.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        bpfcc-tools \
        python3-bpfcc \
        python3-pip \
        iproute2 \
        netcat \
        sudo \
        git \
        curl \
        vim \
        build-essential \
    && apt-get clean

WORKDIR /opt/scripts

COPY scripts/ /opt/scripts/
RUN chmod +x /opt/scripts/*.sh