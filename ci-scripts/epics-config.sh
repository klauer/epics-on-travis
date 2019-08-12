default_addr=127.0.0.1
default_bcast_addr=127.255.255.255

# V3 network settings
if [ -z "$EPICS_CA_ADDR_LIST" ]; then
    export EPICS_CA_ADDR_LIST=$default_bcast_addr
    echo "Set EPICS_CA_ADDR_LIST to $EPICS_CA_ADDR_LIST"
fi

export EPICS_CA_AUTO_ADDR_LIST=NO
export EPICS_CA_MAX_ARRAY_BYTES=1000000000

# V4 network settings
if [ -z "$EPICS_PVA_ADDR_LIST" ]; then
    export EPICS_PVA_ADDR_LIST=$default_bcast_addr
    echo "Set EPICS_PVA_ADDR_LIST to $EPICS_PVA_ADDR_LIST"
fi

if [ -z "$EPICS_PVAS_INTF_LIST" ]; then
    export EPICS_PVAS_INTF_LIST=$default_addr
    echo "Set EPICS_PVAS_INTF_LIST to $EPICS_PVAS_INTF_LIST"
fi

export EPICS_PVA_AUTO_ADDR_LIST=NO
# export EPICS_PVA_BROADCAST_PORT

export BUILD_ROOT=$HOME/build/epics/${BASE}
export EPICS_ROOT=$HOME/.cache/epics/${BASE}
export SUPPORT=${EPICS_ROOT}/support
export IOCS=${EPICS_ROOT}/iocs
export EPICS_BASE=${EPICS_ROOT}/base
export RELEASE_PATH=${SUPPORT}/RELEASE

if [ -z "$EPICS_HOST_ARCH" ]; then
    export EPICS_HOST_ARCH=linux-x86_64
fi

export PYEPICS_IOC="$IOCS/pyepics-test-ioc"
export MOTORSIM_IOC="$IOCS/motorsim"
export ADSIM_IOC="$AREA_DETECTOR_PATH/ADSimDetector/iocs/simDetectorIOC/"

install -d $SUPPORT
install -d $IOCS
install -d $BUILD_ROOT
install -d $EPICS_ROOT

export SNCSEQ_PATH=$SUPPORT/seq/${SEQ}
export AUTOSAVE_PATH=$SUPPORT/autosave/${AUTOSAVE}
export SSCAN_PATH=$SUPPORT/sscan/${SSCAN}
export BUSY_PATH=$SUPPORT/busy/${BUSY}
export ASYN_PATH=$SUPPORT/asyn/${ASYN}
export CALC_PATH=$SUPPORT/calc/${CALC}
export MOTOR_PATH=$SUPPORT/motor/${MOTOR}
export AREA_DETECTOR_PATH=$SUPPORT/areadetector/${AREADETECTOR}

cat << EOF > $RELEASE_PATH
SUPPORT=${SUPPORT}
SNCSEQ=${SNCSEQ_PATH}
AUTOSAVE=${AUTOSAVE_PATH}
SSCAN=${SSCAN_PATH}
BUSY=${BUSY_PATH}
ASYN=${ASYN_PATH}
CALC=${CALC_PATH}
MOTOR=${MOTOR_PATH}
AREA_DETECTOR=${AREA_DETECTOR_PATH}
EPICS_BASE=$EPICS_BASE
EOF

if [ ! -z "$PVA" ]; then
    export PVA_PATH=$SUPPORT/pva/${PVA}
    cat << EOF >> $RELEASE_PATH
PVA=${PVA_PATH}
EOF
    export WITH_PVA=YES

    PVA_BIN_PATH="${PVA_PATH}/bin/${EPICS_HOST_ARCH}"
    if [[ ":$PATH:" != *":${PVA_BIN_PATH}:"* ]]; then
        export PATH="${PVA_BIN_PATH}:${PATH}"
        echo "${PVA_BIN_PATH} added to path"
    fi
else
    export WITH_PVA=NO
fi

echo "Created release file: ${RELEASE_PATH}"
echo "------------------------"
cat $RELEASE_PATH
echo "------------------------"

EPICS_BIN_PATH="${EPICS_BASE}/bin/${EPICS_HOST_ARCH}"

if [[ ":$PATH:" != *":${EPICS_BIN_PATH}:"* ]]; then
    export PATH="${EPICS_BIN_PATH}:${PATH}"
    echo "${EPICS_BIN_PATH} added to path"
fi

export PYEPICS_LIBCA=${EPICS_BASE}/lib/${EPICS_HOST_ARCH}/libca.so

# include utility functions for other scripts
. ${CI_SCRIPTS}/utils.sh
