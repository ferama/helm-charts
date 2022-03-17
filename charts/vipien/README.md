# vipien

## Usage

To install the vipien chart:

    helm install vpn ferama/vipien

To uninstall the chart:

    helm delete vpn

## microk8s example
```
helm install vpn ferama/vipien \
    --set dataVolume.enabled=true \
    --set serverUrl=192.168.10.15 \
    --set service.type=NodePort \
    --set allowedips=10.152.183.0/24 \
    --set enableUI=1
```