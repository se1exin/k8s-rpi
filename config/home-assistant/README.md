# Home Assistant
Create config map:
```
kubectl delete configmap hass-nginx-config
kubectl create configmap hass-nginx-config --from-file=nginx.conf


## Philips Hue lights

Manual config in Hass UI

## Mirabella LED Light Strip

Using Tasmota firmware installed via [tuya-convert](https://github.com/ct-Open-Source/tuya-convert), integrated to Home Assistant using MQTT.


Tasmota Config:
```
{"NAME":"Mirabella LED 0","GPIO":[17,0,0,0,37,40,0,0,38,0,39,0,0],"FLAG":0,"BASE":18}
```

Enable Tasmota MQTT > Home Assistant device discovery by running the following command in Tasmota Console (Web UI):

```
SetOption19 1
```
