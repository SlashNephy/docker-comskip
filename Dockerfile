FROM alpine:3.16.2

ARG ARGTABLE_VERSION=2-13
RUN apk add --update --no-cache --virtual .build-deps \
        build-base \
        linux-headers \
        autoconf \
        automake \
        libtool \
        git \
        ffmpeg-dev \
        curl \
        tar \
    # Runtime
    && apk add --no-cache \
        ffmpeg \
    \
    # Build: argtable
    && mkdir /tmp/argtable \
    && cd /tmp/argtable \
    && curl -sLO https://prdownloads.sourceforge.net/argtable/argtable${ARGTABLE_VERSION}.tar.gz \
    && tar -ax --strip-components=1 -f argtable${ARGTABLE_VERSION}.tar.gz \
    && ./configure \
    && make \
    && make install \
    \
    # Build: Comskip
    && cd /tmp \
    && git clone https://github.com/erikkaashoek/Comskip \
    && cd Comskip \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    \
    # Clean
    && apk del --purge .build-deps \
    && rm -rf \
        /tmp/argtable \
        /tmp/Comskip

ENTRYPOINT ["/usr/local/bin/comskip"]
