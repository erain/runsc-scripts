#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# CONTAINERD_HOME is the directory for containerd.                                                                                 
CONTAINERD_HOME=${CONTAINERD_HOME:-"/home/containerd"}

# CONTAINERD_CONFIG_PATH is the path of containerd config file.
CONTAINERD_CONFIG_PATH=${CONTAINERD_CONFIG_PATH:-"/etc/containerd/config.toml"}

# DEPLOY_PATH is the path to deploy runsc binary.
DEPLOY_PATH=${DEPLOY_PATH:-"cri-containerd-staging/runsc"}

# Initialize containerized mounter.
mount /tmp /tmp -o remount,exec,suid
usermod -a -G docker jenkins
mkdir -p /var/lib/kubelet
mkdir -p /home/kubernetes/containerized_mounter/rootfs
mount --bind /home/kubernetes/containerized_mounter/ /home/kubernetes/containerized_mounter/
mount -o remount, exec /home/kubernetes/containerized_mounter/
wget https://storage.googleapis.com/kubernetes-release/gci-mounter/mounter.tar -O /tmp/mounter.tar
tar xvf /tmp/mounter.tar -C /home/kubernetes/containerized_mounter/rootfs
mkdir -p /home/kubernetes/containerized_mounter/rootfs/var/lib/kubelet
mount --rbind /var/lib/kubelet /home/kubernetes/containerized_mounter/rootfs/var/lib/kubelet
mount --make-rshared /home/kubernetes/containerized_mounter/rootfs/var/lib/kubelet
mount --bind /proc /home/kubernetes/containerized_mounter/rootfs/proc
mount --bind /dev /home/kubernetes/containerized_mounter/rootfs/dev
rm /tmp/mounter.tar

# Download runsc.
runsc_bin_name=$(curl -f --ipv4 --retry 6 --retry-delay 3 --silent --show-error \
	"https://storage.googleapis.com/${DEPLOY_PATH}/latest")
runsc_bin_path="${CONTAINERD_HOME}/usr/local/sbin/runsc" 
curl -f --ipv4 -Lo "${runsc_bin_path}" --connect-timeout 20 --max-time 300 \
	--retry 6 --retry-delay 10 "https://storage.googleapis.com/${DEPLOY_PATH}/${runsc_bin_name}"
chmod 755 "${runsc_bin_path}"

# Update containerd config to use runsc.
sed -i 's/runc/runsc/g' "${CONTAINERD_CONFIG_PATH}"
