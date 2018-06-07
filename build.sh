#!/bin/sh

# DEPLOY_PATH is the path to deploy runsc binary.
DEPLOY_PATH=${DEPLOY_PATH:-"cri-containerd-staging/runsc"}

# Check GOPATH
if [ -z "${GOPATH}" ] ; then
  echo "GOPATH is not set"
  exit 1
fi

cd "$GOPATH/src/github.com/google/gvisor"
version="$(git describe --tags --always)"
bazel build runsc
runsc="runsc-${version}"
gsutil cp ./bazel-bin/runsc/linux_amd64_pure_stripped/runsc "gs://${DEPLOY_PATH}/${runsc}"
echo "runsc is uploaded to:
  https://storage.googleapis.com/${DEPLOY_PATH}/${runsc}"

echo "${runsc}" | gsutil cp - "gs://${DEPLOY_PATH}/latest"
echo "Latest version is uploaded to:
  https://storage.googleapis.com/${DEPLOY_PATH}/latest"
