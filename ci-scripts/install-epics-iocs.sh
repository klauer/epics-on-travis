#!/bin/bash
set -e -x

source $CI_SCRIPTS/epics-config.sh

# -- pyepics test ioc --

fix_pyepics() {
    # no sscan support for now
    sed -ie "s/^.*sscan.*$//" $pyepics_build_path/testiocApp/src/Makefile
    # # it's late and sequencer+calc is giving issues...
    # sed -ie "s/^SNCSEQ.*$//" $pyepics_build_path/configure/RELEASE
}

pyepics_build_path="${BUILD_ROOT}/pyepics-testioc"
install_from_git "https://github.com/pyepics/testioc.git" "pyepics-testioc" \
    "$pyepics_build_path" "${PYEPICS_IOC}" "master" fix_pyepics
cp -R "$pyepics_build_path/simulator.py" "$pyepics_build_path/iocBoot" "${PYEPICS_IOC}"


# -- motorsim --

fix_motorsim() {
    sed -ie "s/^.*asSupport.*$//" ${motorsim_build_path}/motorSimApp/src/Makefile
    sed -ie "s/autosave //" ${motorsim_build_path}/motorSimApp/src/Makefile
    sed -ie "s/^ARCH.*$/ARCH=${EPICS_HOST_ARCH}/" ${motorsim_build_path}/iocBoot/ioclocalhost/Makefile
}

motorsim_build_path="${BUILD_ROOT}/motorsim-ioc"

install_from_git "https://github.com/klauer/motorsim.git" "motorsim" \
    "$motorsim_build_path" "${MOTORSIM_IOC}" "homebrew-epics" fix_motorsim
cp -R "$motorsim_build_path/iocBoot" "${MOTORSIM_IOC}"
