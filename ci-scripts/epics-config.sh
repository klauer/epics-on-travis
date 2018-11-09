default_addr=127.0.0.1
default_bcast_addr=127.255.255.255

# V3 network settings
if [ -z "$EPICS_CA_ADDR_LIST" ]; then
    export EPICS_CA_ADDR_LIST=$default_bcast_addr
    echo "Set EPICS_CA_ADDR_LIST to $EPICS_CA_ADDR_LIST"
fi

export EPICS_CA_AUTO_ADDR_LIST=NO
export EPICS_CA_MAX_ARRAY_BYTES=10000000

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

export EPICS_ROOT=$HOME/epics/${BASE_VER}
export EPICS_BUILD_ROOT=$HOME/epics-build
export SUPPORT=${EPICS_ROOT}/support
export IOCS=${EPICS_ROOT}/iocs
export EPICS_BASE=${EPICS_ROOT}/base
export RELEASE_PATH=${SUPPORT}/RELEASE

if [ -z "$EPICS_HOST_ARCH" ]; then
    export EPICS_HOST_ARCH=linux-x86_64
fi

install -d $SUPPORT
install -d $IOCS
install -d $EPICS_BUILD_ROOT
install -d $EPICS_ROOT

export SNCSEQ_PATH=$SUPPORT/seq/${SEQ_VER}
export AUTOSAVE_PATH=$SUPPORT/autosave/${AUTOSAVE_VER}
export SSCAN_PATH=$SUPPORT/sscan/${SSCAN_VER}
export BUSY_PATH=$SUPPORT/busy/${BUSY_VER}
export ASYN_PATH=$SUPPORT/asyn/${ASYN_VER}
export CALC_PATH=$SUPPORT/calc/${CALC_VER}
export MOTOR_PATH=$SUPPORT/motor/${MOTOR_VER}
export AREA_DETECTOR_PATH=$SUPPORT/areadetector/${AREADETECTOR_VER}

export PYEPICS_IOC="$IOCS/pyepics-test-ioc"
export MOTORSIM_IOC="$IOCS/motorsim"
export ADSIM_IOC="$AREA_DETECTOR_PATH/ADSimDetector/iocs/simDetectorIOC/"

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
EPICS_BASE=${EPICS_BASE}
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

export EPICS_LIB_ARCH=${EPICS_BASE}/lib/${EPICS_HOST_ARCH}/
export PYEPICS_LIBCA=${EPICS_LIB_ARCH}/libca.so

if [[ ":$LD_LIBRARY_PATH:" != *":${EPICS_LIB_ARCH}:"* ]]; then
    export LD_LIBRARY_PATH="${EPICS_LIB_ARCH}:${LD_LIBRARY_PATH}"
    echo "${EPICS_LIB_ARCH} added to LD_LIBRARY_PATH"
fi

# include utility functions for other scripts
. ${CI_SCRIPTS}/utils.sh
