FROM ubuntu:latest

# image extra binaries and utils
COPY bin/* /usr/local/bin/

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		iptables \
		curl \
		openssl; \
    rm -r /var/lib/apt/lists /var/cache/apt/archives


RUN curl -fsSL https://get.docker.com | sh

VOLUME /var/lib/docker

COPY ./scripts/bootstrap.sh /
RUN /bootstrap.sh && rm /bootstrap.sh

COPY ./scripts/entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]