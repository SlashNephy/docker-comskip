# syntax=docker/dockerfile:1@sha256:a57df69d0ea827fb7266491f2813635de6f17269be881f696fbfdf2d83dda33e

ARG DEPENDENCIES="autoconf automake libtool libargtable2-dev pkg-config libavutil-dev libavformat-dev libavcodec-dev libswscale-dev libsdl2-dev make"
ARG RUNTIMES="libargtable2-0 ffmpeg libsdl2-2.0-0"

FROM public.ecr.aws/bitnami/git:2.45.0@sha256:cac86351299889ae2f3c0971fd4da9c8df40d79cdf2a8340a02db142bdb6ad91 AS source

ADD https://api.github.com/repos/erikkaashoek/Comskip/git/refs/heads/master /tmp/Comskip.json
RUN git clone https://github.com/erikkaashoek/Comskip /app

FROM public.ecr.aws/debian/debian:stable-slim@sha256:861b2d6a8c1b892d711c9e79dd93736ffb73b3759a5a49cb5b6ad498464254e0 AS build
WORKDIR /app
ARG DEPENDENCIES

RUN apt-get update && apt-get install -y --no-install-recommends ${DEPENDENCIES}

COPY --from=source /app/ ./
RUN ./autogen.sh && ./configure && make

FROM public.ecr.aws/debian/debian:stable-slim@sha256:861b2d6a8c1b892d711c9e79dd93736ffb73b3759a5a49cb5b6ad498464254e0
ARG RUNTIMES

RUN apt-get update && apt-get install -y --no-install-recommends ${RUNTIMES} && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/comskip /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/comskip"]
