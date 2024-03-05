FROM debian:stable-slim as go-builder
# defined from build kit
# DOCKER_BUILDKIT=1 docker build . -t ...
ARG TARGETARCH

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt install -y -q --no-install-recommends \
    git curl gnupg2 build-essential coreutils \
    openssl libssl-dev pkg-config \
    ca-certificates apt-transport-https \
    python3 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

## Go Lang
ARG GO_VERSION=1.22.0
ADD https://go.dev/dl/go${GO_VERSION}.linux-$TARGETARCH.tar.gz /goinstall/go${GO_VERSION}.linux-$TARGETARCH.tar.gz
RUN echo 'SHA256 of this go source package...'
RUN cat /goinstall/go${GO_VERSION}.linux-$TARGETARCH.tar.gz | sha256sum 
RUN tar -C /usr/local -xzf /goinstall/go${GO_VERSION}.linux-$TARGETARCH.tar.gz
WORKDIR /yamlfmt
ENV GOBIN=/usr/local/go/bin
ENV PATH=$PATH:${GOBIN}
RUN go install github.com/google/yamlfmt/cmd/yamlfmt@latest
RUN ls -lR /usr/local/go/bin/yamlfmt && strip /usr/local/go/bin/yamlfmt && ls -lR /usr/local/go/bin/yamlfmt
RUN yamlfmt --version

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
COPY --chown=${USER}:${USER} --from=go-builder /usr/local/go/bin/yamlfmt /usr/local/go/bin/yamlfmt

USER cpp
RUN g++ --version

LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="cpp" \
    org.label-schema.description="C++ Development Container" \
    org.label-schema.url="https://github.com/jac18281828/cpp" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="git@github.com:jac18281828/cpp.git" \
    org.label-schema.vendor="John Cairns" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0" \
    org.opencontainers.image.description="C++ Development Container"
