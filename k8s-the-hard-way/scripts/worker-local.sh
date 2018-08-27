echo "### WORKER LOCAL INSTALL SCRIPT"

# https://github.com/kubernetes-incubator/cri-tools/releases/download/v1.0.0-beta.0/crictl-v1.0.0-beta.0-linux-amd64.tar.gz \

POD_CIDR=$(curl -s -H "Metadata-Flavor: Google" \
    http://metadata.google.internal/computeMetadata/v1/instance/attributes/pod-cidr)
K8S_VERSION=1.10.6
CNI_VERSION=0.7.1
CONTAINERD_VERSION=1.1.3
CRICTL_VERSION=1.11.1

echo " # HOSTNAME=${HOSTNAME}"
echo " # POD_CIDR=${POD_CIDR}"
echo " # VERSIONS:"
echo "  - K8S_VERSION       =${K8S_VERSION}"
echo "  - CNI_VERSION       =${CNI_VERSION}"
echo "  - CONTAINERD_VERSION=${CONTAINERD_VERSION}"
echo "  - CRICTL_VERSION    =${CRICTL_VERSION}"

echo " ## Install network tools"
sudo apt-get update && sudo apt-get -y install socat conntrack ipset

echo " # Prepare landing folders"
sudo mkdir -p \
    /etc/cni/net.d \
    /opt/cni/bin \
    /var/lib/kubelet \
    /var/lib/kube-proxy \
    /var/lib/kubernetes \
    /var/run/kubernetes \
    /etc/containerd/

echo " # Move certificates to their required locations"
sudo mv ${HOSTNAME}-key.pem ${HOSTNAME}.pem /var/lib/kubelet/
ls -lath /var/lib/kubelet/
sudo mv ${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig
ls -lath /var/lib/kubelet/kubeconfig
sudo mv ca.pem /var/lib/kubernetes/
ls -lath /var/lib/kubernetes/

echo " # Download all required binaries"
wget -q --show-progress --https-only --timestamping \
    https://github.com/kubernetes-incubator/cri-tools/releases/download/v${CRICTL_VERSION}/crictl-v${CRICTL_VERSION}-linux-amd64.tar.gz \
    https://storage.googleapis.com/kubernetes-the-hard-way/runsc \
    https://github.com/opencontainers/runc/releases/download/v1.0.0-rc5/runc.amd64 \
    https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/cni-plugins-amd64-v${CNI_VERSION}.tgz \
    https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}.linux-amd64.tar.gz \
    https://storage.googleapis.com/kubernetes-release/release/v${K8S_VERSION}/bin/linux/amd64/kubectl \
    https://storage.googleapis.com/kubernetes-release/release/v${K8S_VERSION}/bin/linux/amd64/kube-proxy \
    https://storage.googleapis.com/kubernetes-release/release/v${K8S_VERSION}/bin/linux/amd64/kubelet
    
sleep 10

echo " ## Extract binaries to landing folders"
ls -lath
chmod +x kubectl kube-proxy kubelet runc.amd64 runsc
sudo mv runc.amd64 runc
sudo mv kubectl kube-proxy kubelet runc runsc /usr/local/bin/
sudo tar -xvf crictl-v${CRICTL_VERSION}-linux-amd64.tar.gz -C /usr/local/bin/
sudo tar -xvf cni-plugins-amd64-v${CNI_VERSION}.tgz -C /opt/cni/bin/
sudo tar -xvf containerd-${CONTAINERD_VERSION}.linux-amd64.tar.gz -C /

echo " ## CONTAINERD CONFIG"
echo "  # Create containerd config (/etc/containerd/config.toml)"
cat << EOF | sudo tee /etc/containerd/config.toml
[plugins]
  [plugins.cri.containerd]
    snapshotter = "overlayfs"
    [plugins.cri.containerd.default_runtime]
      runtime_type = "io.containerd.runtime.v1.linux"
      runtime_engine = "/usr/local/bin/runc"
      runtime_root = ""
    [plugins.cri.containerd.untrusted_workload_runtime]
      runtime_type = "io.containerd.runtime.v1.linux"
      runtime_engine = "/usr/local/bin/runsc"
      runtime_root = "/run/containerd/runsc"
EOF

echo "  # Create containerd systemd service definition (/etc/systemd/system/containerd.service)"
cat <<EOF | sudo tee /etc/systemd/system/containerd.service
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=/sbin/modprobe overlay
ExecStart=/bin/containerd
Restart=always
RestartSec=5
Delegate=yes
KillMode=process
OOMScoreAdjust=-999
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF

echo " ## KUBELET CONFIGURATION"
echo "  # create kubelet config yaml (/var/lib/kubelet/kubelet-config.yaml)"
cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "${POD_CIDR}"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/${HOSTNAME}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/${HOSTNAME}-key.pem"
EOF

echo " # create kubelet systemd service definition (/etc/systemd/system/kubelet.service)"
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --allow-privileged=true \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --resolv-conf=/run/systemd/resolve/resolv.conf \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo " ## KUBE-PROXY CONFIGURATION"
echo "  # move kubeconfig to the correct location"
sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
ls -lath /var/lib/kube-proxy/kubeconfig

echo "  # create kube-proxy config yaml"
cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
    kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "10.200.0.0/16"
EOF

echo "  # create kube-proxy systemd service definition (/etc/systemd/system/kube-proxy.service)"
cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
    --config=/var/lib/kube-proxy/kube-proxy-config.yaml \\
    --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo " ## RELOAD AND START SYSTEMD SERVICES"
echo "  # containerd, kubelet, kube-proxy"
sudo systemctl daemon-reload
sudo systemctl enable containerd kubelet kube-proxy
sudo systemctl start containerd kubelet kube-proxy

