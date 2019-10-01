FROM python:3.7.4-buster

RUN set -x \
  && python3 -m pip install github-backup==0.26.0 \
  && mkdir -p /data

VOLUME /data

USER nobody

ENTRYPOINT ["/usr/local/bin/github-backup"]
CMD ["--help"]
