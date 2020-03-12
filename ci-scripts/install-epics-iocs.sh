#!/bin/bash
set -e -x

source $CI_SCRIPTS/epics-config.sh

# -- pyepics test ioc --

fix_pyepics() {
    # no sscan support for now
    sed -i -e "s/^.*sscan.*$//" $pyepics_build_path/testiocApp/src/Makefile
}

pyepics_build_path="${EPICS_BUILD_ROOT}/pyepics-testioc"
install_from_git "https://github.com/pyepics/testioc.git" "pyepics-testioc" \
    "$pyepics_build_path" "${PYEPICS_IOC}" "master" fix_pyepics

if [ -f "$pyepics_build_path/simulator.py" ]; then
    cp -R "$pyepics_build_path/simulator.py" "$pyepics_build_path/iocBoot" "${PYEPICS_IOC}"
fi


# -- motorsim --

fix_motorsim() {
    sed -i -e "s/^.*asSupport.*$//" ${motorsim_build_path}/motorSimApp/src/Makefile
    sed -i -e "s/autosave //" ${motorsim_build_path}/motorSimApp/src/Makefile
    sed -i -e "s/^ARCH.*$/ARCH=${EPICS_HOST_ARCH}/" ${motorsim_build_path}/iocBoot/ioclocalhost/Makefile
}

motorsim_build_path="${EPICS_BUILD_ROOT}/motorsim-ioc"
install_from_git "https://github.com/klauer/motorsim.git" "motorsim" \
    "$motorsim_build_path" "${MOTORSIM_IOC}" "master" fix_motorsim
if [ -d "$motorsim_build_path/iocBoot" ]; then
    cp -R "$motorsim_build_path/iocBoot" "${MOTORSIM_IOC}"
fi
