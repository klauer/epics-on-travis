#!/bin/bash
# Runs EPICS IOCs in background with no dependencies using pipes
# NOTE: generally not recommended; use procserv or tmux where possible.

set -e -x

. $CI_SCRIPTS/epics-config.sh

export PYEPICS_IOC_PIPE="${IOCS}/pyepics_ioc_pipe"
export MOTORSIM_IOC_PIPE="${IOCS}/motorsim_ioc_pipe"
export ADSIM_IOC_PIPE="${IOCS}/adsim_ioc_pipe"

run_ioc "$PYEPICS_IOC_PIPE" "pyepics-test-ioc" "${PYEPICS_IOC}/iocBoot/iocTestioc" \
    "${PYEPICS_IOC}/bin/${EPICS_HOST_ARCH}/testioc ./st.cmd" "Py:ao1"

run_ioc "$MOTORSIM_IOC_PIPE" "motorsim-ioc" "${MOTORSIM_IOC}/iocBoot/ioclocalhost" \
    "${MOTORSIM_IOC}/bin/${EPICS_HOST_ARCH}/mtrSim ./st.cmd" "sim:mtr1"

run_ioc "$ADSIM_IOC_PIPE" "adsim-ioc" "${ADSIM_IOC}/iocBoot/iocSimDetector" \
    "${ADSIM_IOC}/bin/${EPICS_HOST_ARCH}/simDetectorApp ./st.cmd" "13SIM1:image1:PluginType_RBV"

# run_ioc "$PVA_IOC_PIPE" "pva-combined-ioc" "${IOCS}/pva2pva/iocBoot/iocwfdemo" \
#     "${PVA_PATH}/bin/${EPICS_HOST_ARCH}/softIocPVA ./st.cmd" ""

echo "All IOCs are running!"
