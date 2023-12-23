# syntax=docker/dockerfile:1@sha256:ac85f380a63b13dfcefa89046420e1781752bab202122f8f50032edf31be0021

ARG DEPENDENCIES="autoconf automake libtool libargtable2-dev pkg-config libavutil-dev libavformat-dev libavcodec-dev libswscale-dev libsdl2-dev make"
ARG RUNTIMES="libargtable2-0 ffmpeg libsdl2-2.0-0"

FROM public.ecr.aws/bitnami/git:2.43.0@sha256:9b69e477c0db91107bc299e2342edf90fa6e7529535b703c9fa206a426a099ed AS source

ADD https://api.github.com/repos/erikkaashoek/Comskip/git/refs/heads/master /tmp/Comskip.json
RUN git clone https://github.com/erikkaashoek/Comskip /app

FROM public.ecr.aws/debian/debian:stable-slim@sha256:0e215c8d2daffb411d383f26ee0bd460c7743dce5d1b2d7f597b4e41a5d2dd09 AS build
WORKDIR /app
ARG DEPENDENCIES

RUN apt-get update && apt-get install -y --no-install-recommends ${DEPENDENCIES}

COPY --from=source /app/ ./
RUN ./autogen.sh && ./configure && make

FROM public.ecr.aws/debian/debian:stable-slim@sha256:0e215c8d2daffb411d383f26ee0bd460c7743dce5d1b2d7f597b4e41a5d2dd09
ARG RUNTIMES

RUN apt-get update && apt-get install -y --no-install-recommends ${RUNTIMES} && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/comskip /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/comskip"]
