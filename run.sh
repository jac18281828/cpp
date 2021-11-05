#!/usr/bin/env bash

VERSION=$(date +%m%d%y)

docker build . -t cppdev:${VERSION} && \
	docker run --rm -i -t cppdev:${VERSION}
