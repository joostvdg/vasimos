KUBE_CONFIG_PROTO_ROOT=../kube-configs-proto

echo "### KUBECONFIG CREATION SCRIPT"
echo " ## Removing kube-configs from folder if exists"
rm *.kubeconfig

echo " ## Check if certs exists"
echo ls -lath worker-*.pem

KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
    --region $(gcloud config get-value compute/region) \
    --format 'value(address)')

echo " ## KUBERNETES_PUBLIC_ADDRESS=${KUBERNETES_PUBLIC_ADDRESS}"

echo " ## Generating kubeconfigs for each worker node"
for instance in worker-0 worker-1 worker-2; do
    echo " # Creating kubeconfig for ${instance}"
    kubectl config set-cluster kubernetes-the-hard-way \
        --certificate-authority=ca.pem \
        --embed-certs=true \
        --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
        --kubeconfig=${instance}.kubeconfig
    echo "  - created initial config"

    kubectl config set-credentials system:node:${instance} \
        --client-certificate=${instance}.pem \
        --client-key=${instance}-key.pem \
        --embed-certs=true \
        --kubeconfig=${instance}.kubeconfig
    echo "  - set certificate as key"

    kubectl config set-context default \
        --cluster=kubernetes-the-hard-way \
        --user=system:node:${instance} \
        --kubeconfig=${instance}.kubeconfig
    echo "  - set user"

    kubectl config use-context default --kubeconfig=${instance}.kubeconfig
    echo "  - test config by using it"
done
ls -lath worker-*.kubeconfig

echo " # Generating kubeconfig for kube-proxy"
kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kube-proxy.kubeconfig
echo "  - created initial config"

kubectl config set-credentials system:kube-proxy \
    --client-certificate=kube-proxy.pem \
    --client-key=kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig
echo "  - set certificate as key"

kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig
echo "  - set user"

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
echo "  - test config by using it"
ls -lath kube-proxy.kubeconfig

echo " # Generating kubeconfig for controller-manager"
kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig
echo "  - created initial config"

kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=kube-controller-manager.pem \
    --client-key=kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig
echo "  - set certificate as key"

kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig
echo "  - set user"

kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
echo "  - test config by using it"
ls -lath kube-controller-manager.kubeconfig

echo " # Generating kubeconfig for kube-scheduler"
kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-scheduler.kubeconfig
echo "  - created initial config"

kubectl config set-credentials system:kube-scheduler \
    --client-certificate=kube-scheduler.pem \
    --client-key=kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig
echo "  - set certificate as key"

kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig
echo "  - set user"

kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
echo "  - test config by using it"zs
ls -lath kube-scheduler.kubeconfig

echo " # Generating kubeconfig for admin user"
kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig
echo "  - created initial config"

kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig
echo "  - set certificate as key"

kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig
echo "  - set user"

kubectl config use-context default --kubeconfig=admin.kubeconfig
echo "  - test config by using it"
ls -lath admin.kubeconfig

echo " # Distribute the kubeconfigs to worker nodes"
for instance in worker-0 worker-1 worker-2; do
    echo " # Distributing to ${instance} - ${instance}.kubeconfig, kube-proxy.kubeconfig"
    gcloud compute scp ${instance}.kubeconfig kube-proxy.kubeconfig ${instance}:~/
done

echo " # Distribute the kubeconfigs to controller nodes"
for instance in controller-0 controller-1 controller-2; do
    echo " # Distributing to ${instance} - admin.kubeconfig, kube-controller-manager.kubeconfig, kube-scheduler.kubeconfig"
    gcloud compute scp admin.kubeconfig kube-controller-manager.kubeconfig \
        kube-scheduler.kubeconfig ${instance}:~/
done
