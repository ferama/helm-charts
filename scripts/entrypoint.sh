#! /bin/sh

# setup kubectl
kubectl config set-cluster fermo --server=https://kubernetes.default --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
kubectl config set-context fermo --cluster=fermo
kubectl config set-credentials user --token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
kubectl config set-context fermo --user=user
kubectl config use-context fermo

SERVERURL=$(kubectl get svc proxy -o=jsonpath="{.status.loadBalancer.ingress[0].ip}")
DNS=$(cat /etc/resolv.conf  | grep nameserver | awk '{print $2}')

docker run -d \
    --name wireguard \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_MODULE \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ="Europe/Rome" \
    -e SERVERURL=${SERVERURL} \
    -e PEERS="user1,user2" \
    -e PEERDNS=${DNS} \
    -e ALLOWEDIPS="172.21.0.0/16" \
    -e INTERNAL_SUBNET="10.13.16.0" \
    -p 51820:51820/udp \
    -v "$(pwd)"/config:/config \
    -v /lib/modules:/lib/modules \
    --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
    --restart=unless-stopped \
    linuxserver/wireguard