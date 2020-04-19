# Nginx proxy

Create config map:
```
kubectl delete configmap dogcam-nginx-config
kubectl create configmap dogcam-nginx-config --from-file=nginx.conf
```

Create htpass file:
```
htpasswd -c ./auth <username>
kubectl create secret generic dogcam-auth --from-file auth
```