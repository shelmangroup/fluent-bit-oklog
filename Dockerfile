FROM debian:jessie-slim

ENV FLB_MAJOR 0
ENV FLB_MINOR 11
ENV FLB_PATCH 0
ENV FLB_VERSION 0.11.6
ENV OKLOG_VERSION 0.2.1

ENV FLB_TARBALL https://github.com/fluent/fluent-bit/archive/v${FLB_VERSION}.tar.gz
ENV OKLOG_URL https://github.com/oklog/oklog/releases/download/v${OKLOG_VERSION}/oklog-${OKLOG_VERSION}-linux-amd64

RUN mkdir -p /fluent-bit/bin /fluent-bit/etc

RUN apt-get -qq update \
    && apt-get install -y -qq \
       ca-certificates \
       build-essential \
       cmake \
       make \
       sudo \
       wget \
    && apt-get install -y -qq --reinstall lsb-base lsb-release \
    && wget --no-check-certificate -O - ${FLB_TARBALL} | tar -C /tmp -xz \
    && cd "/tmp/fluent-bit-$FLB_VERSION"/build/ \
    && cmake -DFLB_DEBUG=On -DFLB_TRACE=On -DFLB_JEMALLOC=On -DFLB_BUFFERING=On ../ \
    && make \
    && install bin/fluent-bit /fluent-bit/bin/ \
    && wget --no-check-certificate -O /fluent-bit/bin/oklog ${OKLOG_URL} \
    && chmod +x /fluent-bit/bin/oklog \
    && apt-get remove --purge --auto-remove -y -qq \
       build-essential \
       cmake \
       make \
       wget \
    && rm -rf /tmp/* /var/cache /var/lib/dpkg

# Configuration files
COPY *.conf /fluent-bit/etc/
COPY run.sh /run.sh

# Entry point
CMD ["/run.sh"]


