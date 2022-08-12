FROM debian:bullseye-20220801-slim AS source
ADD https://api.github.com/repos/erikkaashoek/Comskip/git/refs/heads/master /tmp/Comskip.json
RUN apt-get update \
    && apt-get full-upgrade -y \
    && apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
    && git clone https://github.com/erikkaashoek/Comskip /app

FROM debian:bullseye-20220801-slim AS build
WORKDIR /app
RUN apt-get update \
    && apt-get full-upgrade -y \
    && apt-get install -y --no-install-recommends \
      autoconf \
      automake \
      libtool \
      libargtable2-dev \
      pkg-config \
      libavutil-dev \
      libavformat-dev \
      libavcodec-dev \
      libswscale-dev \
      libsdl2-dev \
      make
COPY --from=source /app/ /app/
RUN ./autogen.sh \
    && ./configure \
    && make

FROM debian:bullseye-20220801-slim AS runtime
RUN apt-get update \
    && apt-get full-upgrade -y \
    && apt-get install -y --no-install-recommends \
      libargtable2-0 \
      ffmpeg \
      libsdl2-2.0-0 \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/comskip /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/comskip"]
