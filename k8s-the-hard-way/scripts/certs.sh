CERT_PROTO_ROOT=../certificates-proto

echo "### CERTIFICATE CREATION SCRIPT"
echo " ## Removing certs if exists"
rm *.pem

echo " # CA"
cfssl gencert -initca ${CERT_PROTO_ROOT}/ca-csr.json | cfssljson -bare ca
echo " # Cleanup CA files"
rm ca.csr
ls -lath ca*.pem

echo " # Admin client"
cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=${CERT_PROTO_ROOT}/ca-config.json \
    -profile=kubernetes \
    ${CERT_PROTO_ROOT}/admin-csr.json | cfssljson -bare admin
echo " # Cleanup Admin client files"
rm *.csr
ls -lath admin*.pem

echo " # Kubelet certificates"
for instance in worker-0 worker-1 worker-2; do
    EXTERNAL_IP=$(gcloud compute instances describe ${instance} \
        --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')

    INTERNAL_IP=$(gcloud compute instances describe ${instance} \
        --format 'value(networkInterfaces[0].networkIP)')
    
    echo " # Doing instace ${instance}"
    echo " # EXTERNAL_IP=${EXTERNAL_IP}"
    echo " # INTERNAL_IP=${INTERNAL_IP}"

    cfssl gencert \
        -ca=ca.pem \
        -ca-key=ca-key.pem \
        -config=${CERT_PROTO_ROOT}/ca-config.json \
        -hostname=${instance},${EXTERNAL_IP},${INTERNAL_IP} \
        -profile=kubernetes \
        ${CERT_PROTO_ROOT}/${instance}-csr.json | cfssljson -bare ${instance}
done

echo " # Cleanup of kubelet certificate files"
rm *.csr
ls -lath worker-*.pem

echo " # Controller manager"
cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=${CERT_PROTO_ROOT}/ca-config.json \
    -profile=kubernetes \
    ${CERT_PROTO_ROOT}/kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager
echo " # Cleanup Controller manager files"
rm *.csr
ls -lath kube-controller-manager*.pem

echo " # Kube-Proxy"
cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=${CERT_PROTO_ROOT}/ca-config.json \
    -profile=kubernetes \
    ${CERT_PROTO_ROOT}/kube-proxy-csr.json | cfssljson -bare kube-proxy
echo " # Cleanup kube proxy files"    
rm *.csr
ls -lath kube-proxy*.pem

echo " # Kube-Scheduler"
cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=${CERT_PROTO_ROOT}/ca-config.json \
    -profile=kubernetes \
    ${CERT_PROTO_ROOT}/kube-scheduler-csr.json | cfssljson -bare kube-scheduler
echo " # Cleanup kube scheduler files"
rm *.csr
ls -lath kube-scheduler*.pem


echo " # API Server"
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
    --region $(gcloud config get-value compute/region) \
    --format 'value(address)')
echo " # KUBERNETES_PUBLIC_ADDRESS=${KUBERNETES_PUBLIC_ADDRESS}"

cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=${CERT_PROTO_ROOT}/ca-config.json \
    -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,kubernetes.default \
    -profile=kubernetes \
    ${CERT_PROTO_ROOT}/kubernetes-csr.json | cfssljson -bare kubernetes
echo " # Cleanup API server files"
rm *.csr
ls -lath kubernetes*.pem

echo " # Service Account"
cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=${CERT_PROTO_ROOT}/ca-config.json \
    -profile=kubernetes \
    ${CERT_PROTO_ROOT}/service-account-csr.json | cfssljson -bare service-account
echo " # Cleanup Service Account files"
rm *.csr
ls -lath service-account*.pem

echo " # Distributing Worker certificate files"
for instance in worker-0 worker-1 worker-2; do
    echo " # Distributing to ${instance}"
    gcloud compute scp ca.pem ${instance}-key.pem ${instance}.pem ${instance}:~/
done

echo " # Distributing Controller certificate files"
for instance in controller-0 controller-1 controller-2; do
    echo " # Distributing to ${instance}"
    gcloud compute scp ca.pem ca-key.pem \
        kubernetes-key.pem kubernetes.pem \
        service-account-key.pem service-account.pem ${instance}:~/
done
