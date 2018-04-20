FROM debian:stretch-slim 

ENV DEBIAN_FRONTEND noninteractive

VOLUME watch output process error archive

RUN apt-get update \
 && apt-get install -y ffmpeg \
 && apt-get autoremove -y --purge \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && rm -rf /var/lib/{apt,dpkg,cache,log}/

ADD process.sh .
CMD ["/process.sh"]
