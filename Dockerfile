FROM ubuntu:latest

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		openssl; \
    rm -r /var/lib/apt/lists /var/cache/apt/archives


RUN curl -fsSL https://get.docker.com | sh

VOLUME /var/lib/docker

RUN \
	cd /tmp; \ 
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"; \
    chmod +x kubectl && mv kubectl /usr/local/bin 



COPY ./entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]