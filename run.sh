#!/usr/bin/env bash

VERSION=$(date +%s)

docker build . -t cppdev:${VERSION} && \
	docker run --rm -i -t cppdev:${VERSION}
