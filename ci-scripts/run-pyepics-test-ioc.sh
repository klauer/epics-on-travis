#!/bin/bash

if [ ! -z "${CI_TOP}" ]; then
    cd $CI_TOP
fi

pwd
source setup_local_dev_env.sh
cd "${PYEPICS_IOC}/iocBoot/iocTestioc"

while true; do
    ${PYEPICS_IOC}/bin/${EPICS_HOST_ARCH}/testioc ./st.cmd
    sleep 2
done
