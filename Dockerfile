ARG VERSION=stable-slim

FROM debian:${VERSION} 

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt -y install build-essential cmake \
        gdb python3 clang-format

CMD echo "C++ Dev"
