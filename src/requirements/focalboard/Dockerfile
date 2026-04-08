FROM alpine:3.21.5

RUN <<EOF
apk update
apk add --no-cache \
	wget \
	tar \
	openrc \
	gettext
EOF

RUN <<EOF
wget https://github.com/mattermost-community/focalboard/releases/download/v7.10.6/focalboard-server-linux-amd64.tar.gz 
tar -xvzf focalboard-server-linux-amd64.tar.gz
mv focalboard /opt/focalboard
EOF

COPY focalboard.service /etc/systemd/system/

RUN rc-update add /opt/focalboard default

EXPOSE 8000

# COPY config.json /opt/focalboard/config.json

CMD ["rc-service", "/opt/focalboard", "restart"]
