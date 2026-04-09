FROM debian:bookworm-slim

ARG TARGETPLATFORM
ARG BUILDPLATFORM

RUN echo "Building for $TARGETPLATFORM on $BUILDPLATFORM"

RUN apt-get update \
	&& apt-get install -y --no-install-recommends wget tar ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

RUN <<EOF
wget https://github.com/mattermost-community/focalboard/releases/download/v7.10.6/focalboard-server-linux-amd64.tar.gz 
tar -xvzf focalboard-server-linux-amd64.tar.gz
mv focalboard /opt/focalboard
EOF

RUN <<EOF
source /run/secrets/db_credentials
export POSTGRES_NAME POSTGRES_USER POSTGRES_PASSWORD
EOF

COPY config.json /opt/focalboard/
RUN chmod +x /opt/focalboard/bin/focalboard-server

WORKDIR /opt/focalboard

EXPOSE 8000

CMD ["./bin/focalboard-server"]
