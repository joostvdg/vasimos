minikube start --memory 3072 \
    && minikube addons enable heapster \
    && minikube addons enable ingress
# minikube start --kubernetes-version v1.9.4 --vm-driver=virtualbox \
#     && minikube addons enable heapster \
#     && minikube addons enable ingress
# minikube start --memory 4096
# --bootstrapper kubeadm \
# --cpus 2 --memory 4096


#  --vm-driver=virtualbox
# minikube addons enable heapster
# minikube addons enable ingress
# minikube addons enable efk
# minikube dashboard

