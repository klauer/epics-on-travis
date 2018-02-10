#!/bin/bash
set -e -x

source $CI_SCRIPTS/epics-config.sh

[ -z "$PVA" ] && echo "PVA unset" && exit 1;

BUILD_DIR=$BUILD_ROOT/pva
INSTALL_DIR=${PVA_PATH}

if [ ! -e "$INSTALL_DIR/built" ]
then
    mkdir -p $BUILD_DIR
    download_and_extract "https://github.com/epics-base/bundleCPP/releases/download/${PVA}/EPICS-CPP-${PVA}.tar.gz" \
        $BUILD_DIR

    pushd $BUILD_DIR
    make EPICS_BASE=$EPICS_BASE INSTALL_LOCATION=$INSTALL_DIR
    popd

    touch $INSTALL_DIR/built
else
    echo "Using cached epics-base!"
fi
