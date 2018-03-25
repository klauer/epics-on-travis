#!/bin/bash
#
# Usage: source setup_local_dev_env.sh

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
# export BASE=R7.0.1.1
# export BASE=R3.15.5
export BASE=R3.14.12.6
export BUSY=1-6-1
export SEQ=2.2.5
export ASYN=4-32
export CALC=3-7
export MOTOR=6-10
export AUTOSAVE=5-9
export SSCAN=2-11-1
export AREADETECTOR=3-2

if [[ "$BASE" == R3.14* ]]; then
    export PVA=
    export WITH_PVA=NO
elif [[ "$BASE" == R7* ]]; then
    export PVA=
    export WITH_PVA=NO
else
    export PVA=4.7.0
    export WITH_PVA=YES
fi
# mock Travis
export TRAVIS_BUILD_DIR=${PWD}
export CI_SCRIPTS=${PWD}/ci-scripts
source ${CI_SCRIPTS}/epics-config.sh
