# syntax=docker/dockerfile:1@sha256:fe40cf4e92cd0c467be2cfc30657a680ae2398318afd50b0c80585784c604f28

ARG DEPENDENCIES="autoconf automake libtool libargtable2-dev pkg-config libavutil-dev libavformat-dev libavcodec-dev libswscale-dev libsdl2-dev make"
ARG RUNTIMES="libargtable2-0 ffmpeg libsdl2-2.0-0"

FROM public.ecr.aws/bitnami/git:2.46.0@sha256:7a8a80367986ef28d8e72b50ebcac14f870e71c9ff16871b17e18f4958a7206f AS source

ADD https://api.github.com/repos/erikkaashoek/Comskip/git/refs/heads/master /tmp/Comskip.json
RUN git clone https://github.com/erikkaashoek/Comskip /app

FROM public.ecr.aws/debian/debian:stable-slim@sha256:dcf7318b55ff446622951f631b69fbee828d922e67223bd2ddbf8f692b1bcf83 AS build
WORKDIR /app
ARG DEPENDENCIES

RUN apt-get update && apt-get install -y --no-install-recommends ${DEPENDENCIES}

COPY --from=source /app/ ./
RUN ./autogen.sh && ./configure && make

FROM public.ecr.aws/debian/debian:stable-slim@sha256:dcf7318b55ff446622951f631b69fbee828d922e67223bd2ddbf8f692b1bcf83
ARG RUNTIMES

RUN apt-get update && apt-get install -y --no-install-recommends ${RUNTIMES} && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/comskip /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/comskip"]
