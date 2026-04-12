# Credits to jimmymasaru
ARG FOCALBOARD_TAG=v7.1.0
ARG FOCALBOARD_DOCKER_TAG=7.1.0
ARG TARGETPLATFORM=linux/arm64
ARG TARGETARCH=arm64

FROM alpine/git AS repo
ARG FOCALBOARD_TAG
RUN git clone -b ${FOCALBOARD_TAG} --depth 1 https://github.com/mattermost/focalboard.git /focalboard

# Cannot create FrontEnd on raspverry so grabbing it from dockerhub
FROM --platform=${TARGETPLATFORM} mattermost/focalboard:${FOCALBOARD_DOCKER_TAG} AS frontend_official

FROM --platform=${TARGETPLATFORM} golang:1.18.3 AS backend
ARG TARGETARCH
WORKDIR /focalboard
COPY --from=repo /focalboard .
RUN sed -i "s/GOARCH=amd64/GOARCH=${TARGETARCH}/g" Makefile
RUN EXCLUDE_PLUGIN=true EXCLUDE_ENTERPRISE=true make server-linux

FROM --platform=${TARGETPLATFORM} debian:buster-slim
WORKDIR /opt/focalboard
COPY --from=backend --chown=nobody:nobody /focalboard/bin/linux/focalboard-server ./bin/
COPY --from=backend --chown=nobody:nobody /focalboard/LICENSE.txt ./LICENSE.txt
# COPY --from=frontend /webapp/pack ./pack
COPY --from=frontend_official --chown=nobody:nobody /opt/focalboard/pack ./pack

EXPOSE 8000
COPY ./config.json /opt/focalboard/config.json

CMD ["/opt/focalboard/bin/focalboard-server"]
