#!/bin/bash
#
# Usage: setup_local_dev_env.sh [--submodule]

if [[ "$(uname)" == "Darwin" ]]; then
    export EPICS_HOST_ARCH=darwin-x86
else
    export EPICS_HOST_ARCH=linux-x86_64
fi

echo "EPICS_HOST_ARCH=$EPICS_HOST_ARCH"

export EPICS_CA_ADDR_LIST=127.255.255.255
export EPICS_CA_AUTO_ADDR_LIST=NO
export EPICS_CA_MAX_ARRAY_BYTES=10000000
# example build matrix variables
export BASE=R3.14.12.6
export BUSY=1-6-1
export SEQ=2.2.5
export ASYN=4-31
export CALC=3-6-1
export MOTOR=6-9

# mock Travis
export TRAVIS_BUILD_DIR=${PWD}
export CI_SCRIPTS=${PWD}/ci-scripts
source ${CI_SCRIPTS}/epics-config.sh
