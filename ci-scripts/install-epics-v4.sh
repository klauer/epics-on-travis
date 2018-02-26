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
    make -j2 EPICS_BASE=$EPICS_BASE INSTALL_LOCATION=$INSTALL_DIR
    popd

    pushd $BUILD_DIR/pvaPy
    make configure EPICS_BASE=$EPICS_BASE EPICS4_DIR=$PVA_PATH INSTALL_LOCATION=$INSTALL_DIR/pvaPy PYTHON=3
    make install -j2
    make clean
    popd
    
    # install pvaPy
    cp -R $BUILD_DIR/pvaPy $INSTALL_DIR/

    # copy pva2pva IOCs over
    install -d $IOCS/pva2pva
    cp -R $BUILD_DIR/pva2pva/iocBoot $IOCS/pva2pva/

    touch $INSTALL_DIR/built
else
    echo "Using cached v4!"
fi
