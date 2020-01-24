# Install Helm Tiller
kubectl create serviceaccount tiller --namespace=kube-system
kubectl create clusterrolebinding tiller-admin --serviceaccount=kube-system:tiller --clusterrole=cluster-admin
helm init --tiller-image=jessestuart/tiller --service-account tiller
helm repo update

