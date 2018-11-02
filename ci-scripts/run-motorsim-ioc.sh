#!/bin/bash

if [ ! -z "${CI_TOP}" ]; then
    cd $CI_TOP
fi

pwd
source setup_local_dev_env.sh
cd "${MOTORSIM_IOC}/iocBoot/ioclocalhost"
${MOTORSIM_IOC}/bin/${EPICS_HOST_ARCH}/mtrSim ./st.cmd
