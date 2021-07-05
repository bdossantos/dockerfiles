FROM golang:1.12.7-buster as build

ENV DNSMASQ_EXPORTER_VERSION=v0.2.0

RUN go get -d -v github.com/google/dnsmasq_exporter

WORKDIR /go/src/github.com/google/dnsmasq_exporter

RUN set -x \
  && git pull --quiet \
  && git checkout "tags/${DNSMASQ_EXPORTER_VERSION}" \
  && env CGO_ENABLED=0 GOOS=linux go build -o dnsmasq_exporter

FROM scratch

WORKDIR /app

COPY --from=build /go/src/github.com/google/dnsmasq_exporter/dnsmasq_exporter /app/

USER 65534

EXPOSE 9153/tcp

ENTRYPOINT ["/app/dnsmasq_exporter"]
