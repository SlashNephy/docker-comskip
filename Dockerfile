# syntax=docker/dockerfile:1@sha256:2780b5c3bab67f1f76c781860de469442999ed1a0d7992a5efdf2cffc0e3d769

ARG DEPENDENCIES="autoconf automake libtool libargtable2-dev pkg-config libavutil-dev libavformat-dev libavcodec-dev libswscale-dev libsdl2-dev make"
ARG RUNTIMES="libargtable2-0 ffmpeg libsdl2-2.0-0"

FROM public.ecr.aws/bitnami/git:2.54.0@sha256:a07a98224637272b16cae709fe9fc09beec6d31e7bf2acbc467177306a0b0284 AS source

ADD https://api.github.com/repos/erikkaashoek/Comskip/git/refs/heads/master /tmp/Comskip.json
RUN git clone https://github.com/erikkaashoek/Comskip /app

FROM public.ecr.aws/debian/debian:stable-slim@sha256:5d29f77029cbba2506c02f9b3573fd5024b3d97340905d4153cf096738a51934 AS build
WORKDIR /app
ARG DEPENDENCIES

RUN apt-get update && apt-get install -y --no-install-recommends ${DEPENDENCIES}

COPY --from=source /app/ ./
RUN ./autogen.sh && ./configure && make

FROM public.ecr.aws/debian/debian:stable-slim@sha256:5d29f77029cbba2506c02f9b3573fd5024b3d97340905d4153cf096738a51934
ARG RUNTIMES

RUN apt-get update && apt-get install -y --no-install-recommends ${RUNTIMES} && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/comskip /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/comskip"]
