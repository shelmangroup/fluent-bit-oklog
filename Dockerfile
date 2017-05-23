FROM debian:jessie-slim as fluent-bit
ENV FLB_MAJOR 0
ENV FLB_MINOR 11
ENV FLB_PATCH 0
ENV FLB_VERSION 0.11.6
ENV OKLOG_VERSION 0.2.1
ENV OKLOG_URL https://github.com/oklog/oklog/releases/download/v${OKLOG_VERSION}/oklog-${OKLOG_VERSION}-linux-amd64
ENV FLB_TARBALL https://github.com/fluent/fluent-bit/archive/v${FLB_VERSION}.tar.gz
RUN mkdir -p /build
RUN apt-get -qq update \
    && apt-get install -y -qq \
       ca-certificates \
       build-essential \
       cmake \
       make \
       sudo \
       wget \
    && apt-get install -y -qq --reinstall lsb-base lsb-release
RUN wget --no-check-certificate -O - ${FLB_TARBALL} | tar -C /tmp -xz \
    && cd "/tmp/fluent-bit-$FLB_VERSION"/build/ \
    && cmake -DFLB_DEBUG=On -DFLB_TRACE=On -DFLB_JEMALLOC=On -DFLB_BUFFERING=On ../ \
    && make \
    && install -s bin/fluent-bit /build/
RUN wget --no-check-certificate -O /build/oklog ${OKLOG_URL} \
    && strip /build/oklog \
    && chmod +x /build/oklog

FROM debian:jessie-slim
RUN mkdir -p /fluent-bit/bin /fluent-bit/etc
COPY --from=fluent-bit /build/* /fluent-bit/bin/
COPY *.conf /fluent-bit/etc/
COPY run.sh /run.sh
CMD ["/run.sh"]


