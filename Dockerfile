# syntax=docker/dockerfile:1@sha256:fe40cf4e92cd0c467be2cfc30657a680ae2398318afd50b0c80585784c604f28

ARG DEPENDENCIES="autoconf automake libtool libargtable2-dev pkg-config libavutil-dev libavformat-dev libavcodec-dev libswscale-dev libsdl2-dev make"
ARG RUNTIMES="libargtable2-0 ffmpeg libsdl2-2.0-0"

FROM public.ecr.aws/bitnami/git:2.45.2@sha256:13d9d5ea90e8d7c6184e2a1702ed32106a5a3af8074940c5fdd7cf0383b6a37a AS source

ADD https://api.github.com/repos/erikkaashoek/Comskip/git/refs/heads/master /tmp/Comskip.json
RUN git clone https://github.com/erikkaashoek/Comskip /app

FROM public.ecr.aws/debian/debian:stable-slim@sha256:290bfbe90b75918a9e324c172573810c1e877f581c4cfa6fb758366251908623 AS build
WORKDIR /app
ARG DEPENDENCIES

RUN apt-get update && apt-get install -y --no-install-recommends ${DEPENDENCIES}

COPY --from=source /app/ ./
RUN ./autogen.sh && ./configure && make

FROM public.ecr.aws/debian/debian:stable-slim@sha256:290bfbe90b75918a9e324c172573810c1e877f581c4cfa6fb758366251908623
ARG RUNTIMES

RUN apt-get update && apt-get install -y --no-install-recommends ${RUNTIMES} && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/comskip /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/comskip"]
