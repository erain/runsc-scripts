#!/bin/bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

# CONTAINERD_HOME is the directory for containerd.
CONTAINERD_HOME=${CONTAINERD_HOME:-"/home/containerd"}

# KUBE_ENV_METADATA is the metadata key for kubernetes envs.
KUBE_ENV_METADATA="kube-env"
if [ -f "${CONTAINERD_HOME}/${KUBE_ENV_METADATA}" ]; then
  source "${CONTAINERD_HOME}/${KUBE_ENV_METADATA}"
fi

# CONTAINERD_ENV_METADATA is the metadata key for containerd envs.
CONTAINERD_ENV_METADATA="containerd-env"
if [ -f "${CONTAINERD_HOME}/${CONTAINERD_ENV_METADATA}" ]; then
  source "${CONTAINERD_HOME}/${CONTAINERD_ENV_METADATA}"
fi

# CONTAINERD_CONFIG_PATH is the path of containerd config file.
CONTAINERD_CONFIG_PATH=${CONTAINERD_CONFIG_PATH:-"/etc/containerd/config.toml"}

# RUNSC_DEPLOY_PATH is the path to deploy runsc binary.
RUNSC_DEPLOY_PATH=${RUNSC_DEPLOY_PATH:-"cri-containerd-staging/runsc"}

# Download runsc.
runsc_bin_name=$(curl -f --ipv4 --retry 6 --retry-delay 3 --silent --show-error \
  "https://storage.googleapis.com/${RUNSC_DEPLOY_PATH}/latest")
runsc_bin_path="${CONTAINERD_HOME}/usr/local/sbin/runsc"
curl -f --ipv4 -Lo "${runsc_bin_path}" --connect-timeout 20 --max-time 300 \
  --retry 6 --retry-delay 10 "https://storage.googleapis.com/${RUNSC_DEPLOY_PATH}/${runsc_bin_name}"
chmod 755 "${runsc_bin_path}"

# Update containerd config to use runsc.
sed -i 's/runc/runsc/g' "${CONTAINERD_CONFIG_PATH}"
