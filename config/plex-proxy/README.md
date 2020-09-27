# Nginx proxy

Create config map:
```
kubectl delete configmap plex-proxy-nginx-config
kubectl create configmap plex-proxy-nginx-config --from-file=nginx.conf
```
