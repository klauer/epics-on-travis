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
fi

echo "EPICS_HOST_ARCH=$EPICS_HOST_ARCH"

export EPICS_CA_ADDR_LIST=127.255.255.255
export EPICS_CA_AUTO_ADDR_LIST=NO
export EPICS_CA_MAX_ARRAY_BYTES=10000000
# example build matrix variables
export BASE_VER=R7.0.1.1
# export BASE_VER=R3.15.5
# export BASE_VER=R3.14.12.6
export BUSY_VER=1-6-1
export SEQ_VER=2.2.5
export ASYN_VER=4-32
export CALC_VER=3-7
export MOTOR_VER=6-10
export AUTOSAVE_VER=5-9
export SSCAN_VER=2-11-1
export AREADETECTOR_VER=3-2
export STATIC_BUILD=YES

if [[ "$BASE_VER" == R3.14* ]]; then
    export PVA=
    export WITH_PVA=NO
elif [[ "$BASE_VER" == R7* ]]; then
    export PVA=
    export WITH_PVA=NO
else
    export PVA=4.7.0
    export WITH_PVA=YES
fi
# mock Travis
export TRAVIS_BUILD_DIR=${CI_TOP}
export CI_SCRIPTS=${CI_TOP}/ci-scripts
source ${CI_SCRIPTS}/epics-config.sh

pushd $CI_TOP
if [ -f "epics_on_travis_custom_env.sh" ]; then
    echo "Sourcing epics-on-travis custom environment settings..."
    source epics_on_travis_custom_env.sh
fi
popd
