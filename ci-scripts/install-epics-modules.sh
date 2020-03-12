#!/bin/bash

set -e -x

source $CI_SCRIPTS/epics-config.sh

[ -z "$EPICS_BASE" ] && echo "EPICS_BASE unset" && exit 1;
[ -z "$SUPPORT" ] && echo "SUPPORT unset" && exit 1;
[ -z "$EPICS_BUILD_ROOT" ] && echo "EPICS_BUILD_ROOT unset" && exit 1;

update_release "sequencer" "${SNCSEQ_PATH}"
update_release "asyn" "${ASYN_PATH}"
update_release "busy" "${BUSY_PATH}"
update_release "autosave" "${AUTOSAVE_PATH}"
update_release "sscan" "${SSCAN_PATH}"
update_release "calc" "${CALC_PATH}"
update_release "motor" "${MOTOR_PATH}"
update_release "area_detector" "${AREA_DETECTOR_PATH}"

# sequencer
install_from_github_archive "http://www-csr.bessy.de/control/SoftDist/sequencer/releases/seq-${SEQ_VER}.tar.gz" "sequencer" \
    "$EPICS_BUILD_ROOT/seq/${SEQ_VER}" ${SNCSEQ_PATH}

# asyn

fix_asyn() {
    # disable building tests, this is requiired to avoid tirpc / xdr related ilnking issues
    sed -i -e 's/^#EPICS_LIBCOM_ONLY=.*$/EPICS_LIBCOM_ONLY=YES/' configure/CONFIG_SITE
}

install_from_github_archive "https://github.com/epics-modules/asyn/archive/R${ASYN_VER}.tar.gz" "asyn" \
    "$EPICS_BUILD_ROOT/asyn/${ASYN_VER}" "${ASYN_PATH}" fix_asyn

# autosave
install_from_github_archive "https://github.com/epics-modules/autosave/archive/R${AUTOSAVE_VER}.tar.gz" "autosave" \
    "$EPICS_BUILD_ROOT/autosave/${AUTOSAVE_VER}" "${AUTOSAVE_PATH}"

# busy
install_from_github_archive "https://github.com/epics-modules/busy/archive/R${BUSY_VER}.tar.gz" "busy" \
    "$EPICS_BUILD_ROOT/busy/${BUSY_VER}" "${BUSY_PATH}"

# sscan
install_from_github_archive "https://github.com/epics-modules/sscan/archive/R${SSCAN_VER}.tar.gz" "sscan" \
    "$EPICS_BUILD_ROOT/sscan/${SSCAN_VER}" "${SSCAN_PATH}"

# calc
fix_calc() {
    # build calc without sncseq/sscan
    sed -i -e 's/^SNCSEQ=.*$/# no SNCSEQ/' configure/RELEASE
    sed -i -e 's/^SSCAN=.*$/# no SSCAN/' configure/RELEASE
    sed -i -e 's/^\(swaitRecord.*\)$/# \1/' calcApp/src/Makefile
}

install_from_github_archive "https://github.com/epics-modules/calc/archive/R${CALC_VER}.tar.gz" "calc" \
    "$EPICS_BUILD_ROOT/calc/${CALC_VER}" "${CALC_PATH}" fix_calc

# motor
fix_motor() {
    # only build MotorSim, SoftMotor, and MotorSrc
    cat > motorApp/Makefile <<'EOF'
TOP = ..
include $(TOP)/configure/CONFIG
DIRS += MotorSrc SoftMotorSrc MotorSimSrc Db
SoftMotorSrc_DEPEND_DIRS = MotorSrc
MotorSimSrc_DEPEND_DIRS = MotorSrc
include $(TOP)/configure/RULES_DIRS
EOF
}

install_from_github_archive "https://github.com/epics-modules/motor/archive/R${MOTOR_VER}.tar.gz" "motor" \
    "$EPICS_BUILD_ROOT/motor/${MOTOR_VER}" "${MOTOR_PATH}" fix_motor
