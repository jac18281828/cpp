# Stage 1: Build yamlfmt
FROM golang:1 AS go-builder
# defined from build kit
# DOCKER_BUILDKIT=1 docker build . -t ...
ARG TARGETARCH

# Install yamlfmt
WORKDIR /yamlfmt
RUN go install github.com/google/yamlfmt/cmd/yamlfmt@latest && \
    strip $(which yamlfmt) && \
    yamlfmt --version

# Stage 2: Build C++ Container
FROM debian:stable-slim

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt install -y -q --no-install-recommends \
    sudo ca-certificates curl git gnupg2 \
    build-essential lld cmake \
    gdb python3 clang-format \
    valgrind \
    && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --create-home -s /bin/bash cpp
RUN usermod -a -G sudo cpp
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV USER=cpp
ENV PATH=${PATH}:/go/bin
COPY --chown=${USER}:${USER} --from=go-builder /go/bin/yamlfmt /go/bin/yamlfmt
USER cpp
RUN g++ --version

LABEL \
    org.label-schema.name="cpp" \
    org.label-schema.description="C++ Development Container" \
    org.label-schema.url="https://github.com/jac18281828/cpp" \
    org.label-schema.vcs-url="git@github.com:jac18281828/cpp.git" \
    org.label-schema.vendor="John Cairns" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0" \
    org.opencontainers.image.description="C++ Development Container"
