#!/bin/bash
set -e -x

. $CI_SCRIPTS/epics-config.sh

run_on_procserv 20000 "pyepics_test_ioc" "${PYEPICS_IOC}/iocBoot/iocTestioc" \
    "${PYEPICS_IOC}/bin/${EPICS_HOST_ARCH}/testioc ./st.cmd" "Py:ao1" /dev/stderr

run_on_procserv 20001 "motorsim-ioc" "${MOTORSIM_IOC}/iocBoot/ioclocalhost" \
    "${MOTORSIM_IOC}/bin/${EPICS_HOST_ARCH}/mtrSim ./st.cmd" "sim:mtr1" /dev/stderr
 
run_on_procserv 20002 "adsim-ioc" "${ADSIM_IOC}/iocBoot/iocSimDetector" \
    "${ADSIM_IOC}/bin/${EPICS_HOST_ARCH}/simDetectorApp ./st.cmd" "13SIM1:image1:PluginType_RBV" /dev/stderr

# run_on_procserv 20003 "pva-combined-ioc" "${IOCS}/pva2pva/iocBoot/iocwfdemo" \
#     "${PVA_PATH}/bin/${EPICS_HOST_ARCH}/softIocPVA ./st.cmd" "?" 1

echo "All IOCs are running on procServ!"
