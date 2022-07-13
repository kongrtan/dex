#FROM golang:1.18.3-alpine3.15 AS builder
FROM kongrtan/dex:gobase-0.1 AS builder

WORKDIR /usr/local/src/dex

RUN apk add --no-cache --update alpine-sdk ca-certificates openssl

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT=""

ENV GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOARM=${TARGETVARIANT}

ARG GOPROXY

COPY . .

RUN go build -mod vendor -o /go/bin/dex -v -ldflags "-w -X main.version=sec-2.32 -extldflags '-static'" ./cmd/dex
RUN go build -mod vendor -o /go/bin/docker-entrypoint -v -ldflags "-w -X main.version=sec-2.32 -extldflags '-static'" ./cmd/docker-entrypoint


FROM ghcr.io/dexidp/dex:v2.32.0

COPY --from=builder /go/bin/dex /usr/local/bin/dex
COPY --from=builder /go/bin/docker-entrypoint /usr/local/bin/docker-entrypoint

USER 1001:1001

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
CMD ["dex", "serve", "/etc/dex/config.docker.yaml"]