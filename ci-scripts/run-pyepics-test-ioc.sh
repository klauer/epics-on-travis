#!/bin/bash

pwd
source setup_local_dev_env.sh
cd "${PYEPICS_IOC}/iocBoot/iocTestioc"
${PYEPICS_IOC}/bin/${EPICS_HOST_ARCH}/testioc ./st.cmd
