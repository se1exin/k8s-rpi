# K8s RPi

Configs for my Raspberry Pi Kubernetes Cluster (named "rstack") running [k3s](https://k3s.io/).

Glamour shots of the cluster:

![Glamour shots of the cluster](https://selexin.com/assets/img/2019-04-12-rpi-cluster.jpg)

This is the second iteration of my cluster setup ([I wrote a blog post about my first iteration](https://selexin.com/2019/04/12/kubernetes-on-raspberry-pi-cluster.html)).
Previously I was using full K8s with MetalLB for load balancing, now I'm using [k3s](https://k3s.io/) with [Traefik](https://docs.traefik.io/).

## Standing up the Cluster
The `ansible` folder contains playbooks for provisioning and standing up the cluster, as well
as for admin tasks such as bulk upgrading system packages.

### Requirements / Prep steps
 - Install `ansible` and `ansible-playbook`.
 - Download and `dd` rasbian onto the Raspberry Pi SD cards.
 - Mount the `boot` partition of each SD card and `touch` the file `<bootpart>/ssh`.
 - Put SD cards into Raspberry Pis and boot them.
 - Accept SSH signatures and enable password-less SSH by running `ssh-copy-id pi@pi-address` on each of the Pis (will help ansible).
 - SSH into each pi and change the password for the `pi` user.
 - Add static IP assignments to your router for each of the Pis (grab their MAC addresses while you are SSH'd in).
 - Add each pi as a host in `/etc/hosts` (for ansible)
 - Update `ansible/hosts` with each host name.
 - Reboot the Pis so they pick up their static IPs. Double check the IPs have been leased properly by SSHing into each at their static IP/hostname.

### Updating OS and Packages
To perform system updates (which you should to ensure security patches etc are installed), run:
```
ansible-playbook -i ansible/hosts ansible/update-all.yml
```

### Installing k3s
Simply run the ansible playbook and wait:
```
ansible-playbook -i ansible/hosts ansible/provision-k3s.yml
```

## Post Install
### Setting up `kubectl`
The master node will have a kubectl config folder at `/root/.kube`. Copy this folder from the master node
over to your computer somewhere (e.g. with `rsync`) so you can run `kubectl` commands from your computer.

To set this `kubectl` config as your default config, export the `KUBECONFIG` variable in your `.bashrc` file:
```
export KUBECONFIG=/path/to/.kube/config
```

Test `kubectl` to check everything is working (don't forget to `source ~/.bashrc`):
```
kubectl get nodes
```

```
NAME           STATUS   ROLES    AGE   VERSION
rstack-node0   Ready    master   91d   v1.15.4-k3s.1
rstack-node2   Ready    worker   91d   v1.15.4-k3s.1
rstack-node1   Ready    worker   91d   v1.15.4-k3s.1
rstack-node3   Ready    worker   91d   v1.15.4-k3s.1
```

### Setting up Traefik (with LetsEncrypt certs working as well)
[Traefik](https://docs.traefik.io/) works great as an Ingress controller with k3s (I couldn't get ingress-nginx to work).

The LetsEncrypt setup uses DNS validation via Cloudflare, so your domain's DNS needs to hosted with Cloudflare (although other providers do work - see [Traefik's Provider Docs](https://docs.traefik.io/https/acme/#providers)).

#### Install Helm
Traefik is installed via helm, so we need to install helm first. Use the helper script:
```
bash ./install-helm.sh
```

#### Setup Cloudflare API keys
LetsEncrypt needs your Cloudflare API key (the 'Global' one, not an API 'token') to validate DNS challenges.
Add it as a k8s secret:
```
kubectl -n kube-system create secret generic cloudflare-api-key \
  --from-literal=CLOUDFLARE_EMAIL=youremail@incloudflareaccount \
  --from-literal=CLOUDFLARE_API_KEY=cloudflareapikey
```

#### Setup Traefik config
Update the values in `config/traefik/values.yml` - notably `acme.email` to match your CloudFlare email.

You may also want to enable the dashboard with authentication, example yaml:
```
dashboard:
  enabled: true
  domain: customdomain.name
  auth:
    basic:
      customusername: password-generated-with-htpasswd
```
See [Traefik's BasicAuth Docs](https://docs.traefik.io/v2.0/middlewares/basicauth/) for more info.

#### Install Traefik
Finally we can install Traefik:
```
helm install stable/traefik --name traefik --namespace kube-system --values config/traefik/values.yml
```

#### Test Traefik
There is a test nginx deployment/service/ingress at `config/traefik/test-ingress.yml`. Update the domains/host values and apply:
```
kubectl apply -f config/traefik/test-ingress.yml
```

Delete it with:
```
kubectl delete -f config/traefik/test-ingress.yml
```

#### Uninstall Traefik
In case you need to rollback the traefik install, run:
```
helm delete traefik && helm del --purge traefik
kubectl delete secret -n kube-system cloudflare-api-key
kubectl delete -f config/traefik/test-ingress.yml
```

## Kubernetes Deployments/Configs
The `config` folder contains a number of K8s deployments/services.

- `config/dashboard` - (not in use) [Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) deployment files for monitoring the Cluster.
- `config/dnscrypt` - [DNSCrypt](https://www.dnscrypt.org/) service for encrypted DNS (for home network).
- `config/sensor-monitoring` - Contains all the microservices for my IoT [Home Monitoring setup](https://github.com/se1exin/home-monitoring), which monitors the temperature around my house using [MQTT](https://mqtt.org/), [Influxdb](https://www.influxdata.com/products/influxdb-overview/), and [Grafana](https://grafana.com/), and my computer stats using [Prometheus](https://prometheus.io/docs/introduction/overview/).
- `config/docker-cloudflare-ddns.yml` - Dynamic DNS service if you do not have a static IP (uses same Cloudflare API key as traefik).
- `config/hue-im-home.yml` - [Hue-Im-Home](https://github.com/se1exin/Hue-Im-Home) service to automatically turn off/on house lights when leaving for/coming home from work.

## License
I hope this repo is of help to anyone else setting up k3s on a Raspberry Pi Cluster.

MIT - see [LICENSE.md](LICENSE.md)