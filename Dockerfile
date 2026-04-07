# syntax=docker/dockerfile:1

# ─── Stage 1: Build the web-app ──────────────────────────────────────────────
FROM node:18-alpine AS nodebuild

WORKDIR /webapp
# Only copy the webapp source so this layer is cached independently
COPY webapp/ /webapp/

# CPPFLAGS workaround for optipng on ARM: https://github.com/imagemin/optipng-bin/issues/118
RUN CPPFLAGS="-DPNG_ARM_NEON_OPT=0" npm install --no-optional && \
    npm run pack

# ─── Stage 2: Build the Go server ────────────────────────────────────────────
FROM golang:1.21-alpine AS gobuild

# Cross-compilation variables injected by `docker buildx`
ARG TARGETOS=linux
ARG TARGETARCH=arm64

WORKDIR /go/src/focalboard
COPY . /go/src/focalboard

RUN EXCLUDE_PLUGIN=true EXCLUDE_SERVER=true EXCLUDE_ENTERPRISE=true \
    make server-docker os=${TARGETOS} arch=${TARGETARCH}

# ─── Stage 3: Final minimal runtime image ────────────────────────────────────
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /opt/focalboard/data/files && \
    chown -R nobody:nogroup /opt/focalboard

WORKDIR /opt/focalboard

COPY --from=nodebuild --chown=nobody:nogroup /webapp/pack          pack/
COPY --from=gobuild   --chown=nobody:nogroup \
     /go/src/focalboard/bin/docker/focalboard-server               bin/focalboard-server
COPY --from=gobuild   --chown=nobody:nogroup \
     /go/src/focalboard/LICENSE.txt                                 LICENSE.txt
COPY --from=gobuild   --chown=nobody:nogroup \
     /go/src/focalboard/docker/server_config.json                   config.json

USER nobody

# Focalboard HTTP port
EXPOSE 8000/tcp
# Prometheus metrics port (optional)
EXPOSE 9092/tcp

VOLUME /opt/focalboard/data

CMD ["/opt/focalboard/bin/focalboard-server"]
