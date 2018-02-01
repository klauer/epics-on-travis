#!/bin/bash
set -e -x

. $CI_SCRIPTS/epics-config.sh

run_ioc "$PYEPICS_IOC_PIPE" "pyepics-test-ioc" "${PYEPICS_IOC}/iocBoot/iocTestioc" \
    "${PYEPICS_IOC}/bin/${EPICS_HOST_ARCH}/testioc ./st.cmd" "Py:ao1"

run_ioc "$MOTORSIM_IOC_PIPE" "motorsim-ioc" "${MOTORSIM_IOC}/iocBoot/ioclocalhost" \
    "${MOTORSIM_IOC}/bin/${EPICS_HOST_ARCH}/mtrSim ./st.cmd" "sim:mtr1"

echo "All IOCs are running!"
