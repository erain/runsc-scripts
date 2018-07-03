#!/bin/bash

# TODO(random-liu): Remove this after gvisor-containerd-shim is enabled
# in test.

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Set multi-container to true.
sed -i 's/flag.Bool("multi-container", false/flag.Bool("multi-container", true/g' \
  "$GOPATH/src/github.com/google/gvisor/runsc/main.go"

RUNSC_DEPLOY_PATH="cri-containerd-staging/runsc-mc" ${ROOT}/build.sh
