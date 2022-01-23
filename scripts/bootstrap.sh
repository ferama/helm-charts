#! /bin/bash
set -x

export DEBIAN_FRONTEND=noninteractive

setup_packages() {
    apt update
    apt install -y \
        vim \
        byobu \
        psmisc \
        iputils-ping \
        netcat \
        dnsutils \
        bash-completion

    # cleanup
    rm -r /var/lib/apt/lists /var/cache/apt/archives
}

setup_k8sutils() {
    cd /tmp

    # kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl && sudo mv kubectl /usr/local/bin
}

############
setup_packages
setup_k8sutils

