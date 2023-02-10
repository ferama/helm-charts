# rospo

sample custom conf

```
authorizedKeysURLS: 
  - https://github.com/ferama.keys

authorizedPassword: your_password
customUserId: 1001
extraVolumeMounts: 
  - name: wordpress
    mountPath: /home/rospo/wordpress
    subPath: wordpress
serverKey: |
     -----BEGIN RSA PRIVATE KEY-----
     ...
     ...
     -----END RSA PRIVATE KEY-----
```

With a service account enabled, you can easily configure kubectl for cluster management:

```
kubectl config set-cluster rospo --server=https://kubernetes.default --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
kubectl config set-context rospo --cluster=rospo
kubectl config set-credentials user --token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
kubectl config set-context rospo --user=user
kubectl config use-context rospo
```