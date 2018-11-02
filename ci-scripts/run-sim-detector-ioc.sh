#!/bin/bash

if [ ! -z "${CI_TOP}" ]; then
    cd $CI_TOP
fi

pwd
source setup_local_dev_env.sh
cd "${ADSIM_IOC}/iocBoot/iocSimDetector"
${ADSIM_IOC}/bin/${EPICS_HOST_ARCH}/simDetectorApp ./st.cmd
