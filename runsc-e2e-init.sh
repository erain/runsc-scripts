#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail

# CONTAINERD_HOME is the directory for containerd.                                                                                 
CONTAINERD_HOME="/home/containerd"

# CONTAINERD_CONFIG_PATH is the path of containerd config file.
CONTAINERD_CONFIG_PATH=${CONTAINERD_CONFIG_PATH:-"/etc/containerd/config.toml"}

# DEPLOY_PATH is the path to deploy runsc binary.
DEPLOY_PATH=${DEPLOY_PATH:-"cri-containerd-staging/runsc"}

# Download runsc.
runsc_bin_name=$(curl -f --ipv4 --retry 6 --retry-delay 3 --silent --show-error \
	"https://storage.googleapis.com/${DEPLOY_PATH}/latest")
runsc_bin_path="${CONTAINERD_HOME}/usr/local/sbin/runsc" 
curl -f --ipv4 -Lo "${runsc_bin_path}" --connect-timeout 20 --max-time 300 \
	--retry 6 --retry-delay 10 "https://storage.googleapis.com/${DEPLOY_PATH}/${runsc_bin_name}"
chmod 755 "${runsc_bin_path}"

# Update containerd config to use runsc.
sed -i 's/runc/runsc/g' "${CONTAINERD_CONFIG_PATH}"
