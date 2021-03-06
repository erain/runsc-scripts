#!/bin/bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

# CONTAINERD_HOME is the directory for containerd.
CONTAINERD_HOME="/home/containerd"

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

# containerd_config_path is the path of containerd config file.
containerd_config_path=${CONTAINERD_CONFIG_PATH:-"/etc/containerd/config.toml"}

# containerd_config_path is the path of runsc containerd-shim config file.
runsc_config_path=${RUNSC_CONFIG_PATH:-"/etc/containerd/runsc.toml"}

# runsc_deploy_path is the path to deploy runsc binary.
runsc_deploy_path=${RUNSC_DEPLOY_PATH:-"cri-containerd-staging/runsc"}

# containerd_shim_deploy_path is the path to deploy gvisor-containerd-shim
# binary.
containerd_shim_deploy_path=${CONTAINERD_SHIM_DEPLOY_PATH:-"cri-containerd-staging/gvisor-containerd-shim"}

cat > "${runsc_config_path}" <<EOF
multi-container = "${RUNSC_MULTI_CONTAINER:-"false"}"
EOF

# Download runsc.
runsc_bin_name=$(curl -f --ipv4 --retry 6 --retry-delay 3 --silent --show-error \
  "https://storage.googleapis.com/${runsc_deploy_path}/latest")
runsc_bin_path="${CONTAINERD_HOME}/usr/local/sbin/runsc"
curl -f --ipv4 -Lo "${runsc_bin_path}" --connect-timeout 20 --max-time 300 \
  --retry 6 --retry-delay 10 "https://storage.googleapis.com/${runsc_deploy_path}/${runsc_bin_name}"
chmod 755 "${runsc_bin_path}"

# Update containerd config to use runsc.
sed -i 's/runc/runsc/g' "${containerd_config_path}"

# Download gvisor-containerd-shim.
containerd_shim_bin_path="${CONTAINERD_HOME}/usr/local/bin/containerd-shim"
curl -f --ipv4 -Lo "${containerd_shim_bin_path}" --connect-timeout 20 --max-time 300 \
  --retry 6 --retry-delay 10 "https://storage.googleapis.com/${containerd_shim_deploy_path}/containerd-shim"
chmod 755 "${containerd_shim_bin_path}"
