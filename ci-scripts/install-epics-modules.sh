#!/bin/bash

set -e -x

source $CI_SCRIPTS/epics-config.sh

[ -z "$EPICS_BASE" ] && echo "EPICS_BASE unset" && exit 1;
[ -z "$SUPPORT" ] && echo "SUPPORT unset" && exit 1;
[ -z "$BUILD_ROOT" ] && echo "BUILD_ROOT unset" && exit 1;

# sequencer
install_from_github_archive "http://www-csr.bessy.de/control/SoftDist/sequencer/releases/seq-${SEQ}.tar.gz" "sequencer" \
    "$BUILD_ROOT/seq/${SEQ}" ${SNCSEQ_PATH}

# asyn

# fix_asyn() {
#     # disable building tests
#     sed -ie 's/^#EPICS_LIBCOM_ONLY=.*$/EPICS_LIBCOM_ONLY=YES/' configure/CONFIG_SITE
# }

install_from_github_archive "https://github.com/epics-modules/asyn/archive/R${ASYN}.tar.gz" "asyn" \
    "$BUILD_ROOT/asyn/${ASYN}" "${ASYN_PATH}"

# busy
install_from_github_archive "https://github.com/epics-modules/busy/archive/R${BUSY}.tar.gz" "busy" \
    "$BUILD_ROOT/busy/${BUSY}" "${BUSY_PATH}"

# autosave
install_from_github_archive "https://github.com/epics-modules/autosave/archive/R${AUTOSAVE}.tar.gz" "autosave" \
    "$BUILD_ROOT/autosave/${AUTOSAVE}" "${AUTOSAVE_PATH}"

# sscan
install_from_github_archive "https://github.com/epics-modules/sscan/archive/R${SSCAN}.tar.gz" "sscan" \
    "$BUILD_ROOT/sscan/${SSCAN}" "${SSCAN_PATH}"

# calc
install_from_github_archive "https://github.com/epics-modules/calc/archive/R${CALC}.tar.gz" "calc" \
    "$BUILD_ROOT/calc/${CALC}" "${CALC_PATH}"

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

install_from_github_archive "https://github.com/epics-modules/motor/archive/R${MOTOR}.tar.gz" "motor" \
    "$BUILD_ROOT/motor/${MOTOR}" "${MOTOR_PATH}" fix_motor
