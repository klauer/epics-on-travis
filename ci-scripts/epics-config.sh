export EPICS_CA_ADDR_LIST=127.255.255.255
export EPICS_CA_AUTO_ADDR_LIST=NO
export EPICS_CA_MAX_ARRAY_BYTES=10000000

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
export PYEPICS_IOC_PIPE="${IOCS}/pyepics_ioc_pipe"
export MOTORSIM_IOC="$IOCS/motorsim"
export MOTORSIM_IOC_PIPE="${IOCS}/motorsim_ioc_pipe"

install -d $SUPPORT
install -d $IOCS

# if [ ! -f "$RELEASE_PATH" ]; then
    cat << EOF > $RELEASE_PATH
SUPPORT=$SUPPORT
SNCSEQ=$SUPPORT/seq
AUTOSAVE=$SUPPORT/autosave
SSCAN=$SUPPORT/sscan
BUSY=$SUPPORT/busy
ASYN=$SUPPORT/asyn
CALC=$SUPPORT/calc
MOTOR=$SUPPORT/motor
EPICS_BASE=$EPICS_BASE
AREA_DETECTOR=$SUPPORT/areadetector
EOF
    echo "Created release file: ${RELEASE_PATH}"
    cat $RELEASE_PATH
# fi

EPICS_BIN_PATH="${EPICS_BASE}/bin/${EPICS_HOST_ARCH}"

if [[ ":$PATH:" != *":${EPICS_BIN_PATH}:"* ]]; then
    export PATH="${EPICS_BIN_PATH}:${PATH}"
    echo "${EPICS_BIN_PATH} added to path"
fi

export PYEPICS_LIBCA=${EPICS_BASE}/lib/${EPICS_HOST_ARCH}/libca.so

# include utility functions for other scripts
. ${CI_SCRIPTS}/utils.sh
