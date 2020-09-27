# Nginx proxy

Create config map:
```
kubectl delete configmap dogcam2-nginx-config
kubectl create configmap dogcam2-nginx-config --from-file=nginx.conf
```

Create htpass file:
```
htpasswd -c ./auth <username>
kubectl create secret generic dogcam2-auth --from-file auth
```