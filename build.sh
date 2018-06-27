#!/bin/sh

# runsc_deploy_path is the path to deploy runsc binary.
runsc_deploy_path=${RUNSC_DEPLOY_PATH:-"cri-containerd-staging/runsc"}

# Check GOPATH
if [ -z "${GOPATH}" ] ; then
  echo "GOPATH is not set"
  exit 1
fi

cd "$GOPATH/src/github.com/google/gvisor"
version="$(git describe --tags --always)"
bazel build runsc
runsc="runsc-${version}"
gsutil cp ./bazel-bin/runsc/linux_amd64_pure_stripped/runsc "gs://${runsc_deploy_path}/${runsc}"
echo "runsc is uploaded to:
  https://storage.googleapis.com/${runsc_deploy_path}/${runsc}"

echo "${runsc}" | gsutil cp - "gs://${runsc_deploy_path}/latest"
echo "Latest version is uploaded to:
  https://storage.googleapis.com/${runsc_deploy_path}/latest"
