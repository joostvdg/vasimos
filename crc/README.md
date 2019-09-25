# CRC

## Prepare

* get RedHat Account
    * because you need to copy credentials for pulling docker images
* get CRC and Virtual Box
    * https://mirror.openshift.com/pub/openshift-v4/clients/crc/1.0.0-beta.3/
    * download and untar crc distribution
    * download crc virtualbox

## Resources

* https://www.cnblogs.com/ericnie/p/11080687.html
* https://github.com/code-ready/crc/releases
* https://cloud.redhat.com/openshift/install/crc/installer-provisioned
* https://code-ready.github.io/crc/
* https://mirror.openshift.com/pub/openshift-v4/clients/crc/1.0.0-beta.3/

## Prepare

### Ubuntu

```bash
sudo usermod -aG libvirtd $(whoami)
newgrp libvirtd
systemctl is-active libvirtd
```

```bash
sudo apt install qemu-kvm libvirt-daemon libvirt-daemon-system network-manager -y
```

```bash
crc setup
```

## Start

### Get Number Of CPUs

```bash
lscpu | egrep 'Model name|Socket|Thread|NUMA|CPU\(s\)'
```

### VirtualBox

```bash
crc start \
    --cpus 6 \
    --memory 16384 \
    --vm-driver virtualbox \
    --bundle crc_virtualbox_4.1.11.crcbundle
```

### Error

```bash
INFO Checking if NetworkManager is installed
INFO Checking if NetworkManager service is running
INFO Checking if oc binary is cached
INFO Checking if Virtualization is enabled
INFO Checking if KVM is enabled
INFO Checking if libvirt is installed
INFO Checking if user is part of libvirt group
INFO Checking if libvirt is enabled
INFO Checking if libvirt daemon is running
INFO Checking if crc-driver-libvirt is installed
INFO Checking if libvirt 'crc' network is available
INFO Checking if libvirt 'crc' network is active
INFO Checking if /etc/NetworkManager/conf.d/crc-nm-dnsmasq.conf exists
INFO Checking if /etc/NetworkManager/dnsmasq.d/crc.conf exists
INFO Checking if CRC bundle is cached in '$HOME/.crc'
INFO Loading bundle: crc_virtualbox_4.1.11.crcbundle ...
INFO Extracting bundle: crc_virtualbox_4.1.11.crcbundle ...
INFO Creating VM ...
ERRO Error occurred: Error creating host: Error creating the VM. Error creating machine: Error in driver during machine creation: Error setting up host only network on machine start: host-only cidr conflicts with the network address of a host interface
```

### Fix

Change the value of `HostOnlyCIDR` in `~/.crc/machines/crc/config.json` to something else.

For example: `"HostOnlyCIDR": "172.15.0.1/24"`

## VirtualBox

```bash
vboxmanage list runningvms --long
```

## Error 2

```bash
INFO Checking if NetworkManager is installed
INFO Checking if NetworkManager service is running
INFO Checking if oc binary is cached
INFO Checking if Virtualization is enabled
INFO Checking if KVM is enabled
INFO Checking if libvirt is installed
INFO Checking if user is part of libvirt group
INFO Checking if libvirt is enabled
INFO Checking if libvirt daemon is running
INFO Checking if crc-driver-libvirt is installed
INFO Checking if libvirt 'crc' network is available
INFO Checking if libvirt 'crc' network is active
INFO Checking if /etc/NetworkManager/conf.d/crc-nm-dnsmasq.conf exists
INFO Checking if /etc/NetworkManager/dnsmasq.d/crc.conf exists
INFO Checking if CRC bundle is cached in '$HOME/.crc'
INFO Starting stopped VM ...
INFO Verifying validity of the cluster certificates ...
INFO Check internal and public dns query ...
INFO Starting OpenShift cluster ... [waiting 3m]
INFO To access the cluster using 'oc', run 'eval $(crc oc-env) && oc login -u kubeadmin -p 78UVa-zNj5W-YB62Z-ggxGZ https://api.crc.testing:6443'
INFO Access the OpenShift web-console here: https://console-openshift-console.apps-crc.testing
INFO Login to the console with user: kubeadmin, password: 78UVa-zNj5W-YB62Z-ggxGZ
ERRO Error occurred: Error approving the node csr Not able to get csr names (exit status 1 : error: stat /home/joostvdg/.crc/machines/crc/kubeconfig: no such file or directory
```

### Fix?

Add nameserver entry to `/etc/resolv.conf`

```bash
nameserver 192.168.130.1
```

## Connect with OC

```bash
INFO Starting OpenShift cluster ... [waiting 3m]
INFO To access the cluster using 'oc', run 'eval $(crc oc-env) && oc login -u kubeadmin -p 78UVa-zNj5W-YB62Z-ggxGZ https://api.crc.testing:6443'
INFO Access the OpenShift web-console here: https://console-openshift-console.apps-crc.testing
INFO Login to the console with user: kubeadmin, password: 78UVa-zNj5W-YB62Z-ggxGZ
```