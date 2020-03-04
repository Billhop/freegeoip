FROM golang:1.14

COPY cmd/freegeoip/public /var/www

ADD . /go/src/github.com/fiorix/freegeoip
RUN GO111MODULE=on  CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN \
	cd /go/src/github.com/fiorix/freegeoip/cmd/freegeoip && \
	go get -d && go install && \
	apt-get clean && apt-get update && apt-get install -y libcap2-bin && \
	setcap cap_net_bind_service=+ep /go/bin/freegeoip && \
	apt-get clean && rm -rf /var/lib/apt/lists/* && \
	useradd -ms /bin/bash freegeoip

USER freegeoip
ENTRYPOINT ["/go/bin/freegeoip"]

EXPOSE 8080

# CMD instructions:
# Add  "-use-x-forwarded-for"      if your server is behind a reverse proxy
# Add  "-public", "/var/www"       to enable the web front-end
# Add  "-internal-server", "8888"  to enable the pprof+metrics server
#
# Example:
# CMD ["-use-x-forwarded-for", "-public", "/var/www", "-internal-server", "8888"]
