echo "Adding Kube DNS resource"
kubectl create -f https://storage.googleapis.com/kubernetes-the-hard-way/kube-dns.yaml
kubectl rollout status deployment kube-dns -n kube-system
