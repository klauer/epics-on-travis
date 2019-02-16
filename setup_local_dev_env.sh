#!/bin/bash
#
# Usage: source setup_local_dev_env.sh

if [[ "$(uname)" == "Darwin" ]]; then
    export EPICS_HOST_ARCH=darwin-x86
else
    export EPICS_HOST_ARCH=linux-x86_64
fi

if [ -z "$CI_TOP" ]; then
    export CI_TOP=$PWD
    echo "CI_TOP is now set to: $CI_TOP"
fi

echo "EPICS_HOST_ARCH=$EPICS_HOST_ARCH"

export EPICS_CA_ADDR_LIST=127.255.255.255
export EPICS_CA_AUTO_ADDR_LIST=NO
export EPICS_CA_MAX_ARRAY_BYTES=10000000

if [[ -z "$PVA" ]]; then
    export WITH_PVA=NO
else
    export WITH_PVA=YES
fi

if [ -z "$TRAVIS_BUILD_DIR" ]; then
    export TRAVIS_BUILD_DIR=${CI_TOP}
fi 

export CI_SCRIPTS=${CI_TOP}/ci-scripts
source ${CI_SCRIPTS}/epics-config.sh

pushd $CI_TOP
if [ -f "epics_on_travis_custom_env.sh" ]; then
    echo "Sourcing epics-on-travis custom environment settings..."
    source epics_on_travis_custom_env.sh
fi
popd
