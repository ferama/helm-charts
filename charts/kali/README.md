# kali

## sample custom conf

```
authorizedKeysURLS: 
  - https://github.com/ferama.keys

authorizedPassword: your_password

vncDisplay: "1280x800"

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
