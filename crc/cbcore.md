# CloudBees Core on CRC

## Install CRC

* download distribution
  * https://github.com/code-ready/crc/releases
* follow the guide to get a pull secret
* crc setup
* crc start
* fix networking if required

### Start CRC Libvirt Machine

```bash
crc start \
  -c 6 -m 16384 \
 --pull-secret-file ~/crc-pull-secret.json \
 --log-level info
```

### Fix Netwok Issues

* install tool for managing resolv config
* https://datawookie.netlify.com/blog/2018/10/dns-on-ubuntu-18.04/
* set nameserver to ip of libvirt machine
* `virsh list` -> then `sudo virsh domifaddr {$ID}` where ID is the id of the machine in the list
* `sudo vim /etc/resolvconf/resolv.conf.d/head`
* sudo service resolvconf restart  

### Login as admin

```bash
oc login -u kubeadmin -p BMLkR-NjA28-v7exC-8bwAk https://api.crc.testing:6443
```

### See Existing Routes

```bash
kubectl get route -A 
```

### Open OpenShift Console

```bash
open http://console-openshift-console.apps-crc.testing 
```


## Prepare A Storage Class

```bash
oc new-project vasimos
oc project vasimos
```

### NFS

#### RBAC

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nfs-client-provisioner
  namespace: vasimos
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: nfs-client-provisioner-runner
rules:
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["list", "watch", "create", "update", "patch"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: run-nfs-client-provisioner
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    namespace: vasimos
roleRef:
  kind: ClusterRole
  name: nfs-client-provisioner-runner
  apiGroup: rbac.authorization.k8s.io
```

#### Provisioner

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-nfs-storage
provisioner: wolkje # or choose another name, must match deployment's env PROVISIONER_NAME'
---
  kind: Deployment
  apiVersion: extensions/v1beta1
  metadata:
    name: nfs-client-provisioner
    namespace: vasimos
  spec:
    replicas: 1
    strategy:
      type: Recreate
    template:
      metadata:
        labels:
          app: nfs-client-provisioner
      spec:
        serviceAccountName: nfs-client-provisioner
        containers:
          - name: nfs-client-provisioner
            image: quay.io/external_storage/nfs-client-provisioner:latest
            volumeMounts:
              - name: nfs-client-root
                mountPath: /persistentvolumes
            env:
              - name: PROVISIONER_NAME
                value: wolkje
              - name: NFS_SERVER
                value: 192.168.178.42
              - name: NFS_PATH
                value: /nfs/kubernetes
        volumes:
          - name: nfs-client-root
            nfs:
              server: 192.168.178.42
              path: /nfs/kubernetes
```

#### Give Provisioner Enough Rights

```bash
oc policy add-role-to-user admin system:serviceaccount:vasimos:nfs-client-provisioner
```

#### Test With Example PVC

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: nginx-data
  labels:
    app: read-write-many
spec:
  storageClassName: managed-nfs-storage
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
```

## Prepare Helm & Tiller

```bash
export TILLER_NAMESPACE=tiller
export HELM_VERSION=v2.9.1
oc new-project tiller
oc project tiller
```

```bash
oc process -f https://raw.githubusercontent.com/openshift/origin/master/examples/helm/tiller-template.yaml -p TILLER_NAMESPACE="${TILLER_NAMESPACE}" HELM_VERSION="${HELM_VERSION}" | oc create -f -

oc rollout status deployment tiller
```

```bash
oc policy add-role-to-user admin "system:serviceaccount:${TILLER_NAMESPACE}:tiller"
oc adm policy add-cluster-role-to-user cluster-admin "system:serviceaccount:${TILLER_NAMESPACE}:tiller"

```

And to confirm the Helm version on both client and server is good:

```bash
helm version
```

## Helm Install

```bash
export OC_PROJECT=cbcore
export OC_HOSTNAME="core.crc.testing"
```

### Create OC Project

```bash
oc new-project ${OC_PROJECT}
oc project ${OC_PROJECT}
```

### Setup CloudBees Helm Repo

```bash
helm repo add cloudbees https://charts.cloudbees.com/public/cloudbees
helm repo list
helm repo update
```

### Create Helm Values Yaml

```yaml
OperationsCenter:
  RunAsUser: 1000520000
  FsGroup: 1000520000
  Platform: "openshift"
  CSRF:
    ProxyCompatibility: true
  HostName: "core.apps-crc.testing"
  Project:
    name: "cbcore"
  ServiceType: NodePort
Persistence:
  Size: 10Gi
  StorageClass: managed-nfs-storage
```

### Install

```bash
helm install --name cloudbees-core \
  -f cloudbees-core-values.yaml \
  --version 2.176.203 \
  cloudbees/cloudbees-core
```

### Change User Permission

```bash
Warning  FailedCreate      20s (x17 over 110s)  statefulset-controller  create Pod cjoc-0 in StatefulSet cjoc failed error: pods "cjoc-0" is forbidden: unable to validate against any security context constraint: [fsGroup: Invalid value: []int64{1000}: 1000 is not an allowed group spec.containers[0].securityContext.securityContext.runAsUser: Invalid value: 1000: must be in the ranges: [1000520000, 1000529999]]
```

Change from:

```yaml
      securityContext:
        fsGroup: 1000
        runAsUser: 1000
```

To something like this, or remove alltogether.

```yaml
      securityContext:
        fsGroup: 1000520000
        runAsUser: 1000520000
```

### Fix env values

In chart `3.4.1` there's a mistake with the OC environment variables.

```yaml
    spec:
      containers:
      - env:
        - name: MASTER_GLOBAL_JAVA_OPTIONS
        - name: ""
          value: -Djenkins.model.Jenkins.crumbIssuerProxyCompatibility=true
```

Should be:

```yaml
    spec:
      containers:
      - env:
        - name: MASTER_GLOBAL_JAVA_OPTIONS
          value: -Djenkins.model.Jenkins.crumbIssuerProxyCompatibility=true
```

```bash
Error: [unable to recognize "": no matches for kind "ClusterRole" in version "v1", unable to recognize "": no matches for kind "ClusterRoleBinding" in version "v1", unable to recognize "": no matches for kind "Role" in version "v1", unable to recognize "": no matches for kind "Role" in version "v1", unable to recognize "": no matches for kind "RoleBinding" in version "v1", unable to recognize "": no matches for kind "RoleBinding" in version "v1"]
```

## Enter CJOC

### With Nameserver working

```bash
open http://core.apps-crc.testing/cjoc
```

### Without Nameserver working

```bash
open http://192.168.130.11:30131/cjoc
```

### Configure Master Provisioning

We have to change the storage class.

Go to Operations Center -> `Manage Jenkins` -> `Configure System` -> `Kubernetes Master Provisioning` -> Hit `Advanced` button -> set `Default Storage Class Name` to `managed-nfs-storage`.
