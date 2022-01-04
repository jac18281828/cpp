ARG VERSION=stable-slim

FROM debian:${VERSION} 

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
        apt install -y -q --no-install-recommends \
        build-essential cmake git gdb python3 clang-format

RUN apt clean
RUN rm -rf /var/lib/apt/lists/*

CMD echo "C++ Dev"
