# Nginx proxy

Create config map:
```
kubectl delete configmap archie-proxy-nginx-config
kubectl create configmap archie-proxy-nginx-config --from-file=nginx.conf
```