#!/bin/bash

set -e -x

source $CI_SCRIPTS/epics-config.sh

[ -z "$EPICS_BASE" ] && echo "EPICS_BASE unset" && exit 1;
[ -z "$SUPPORT" ] && echo "SUPPORT unset" && exit 1;
[ -z "$BUILD_ROOT" ] && echo "BUILD_ROOT unset" && exit 1;

# # sequencer
# install_from_github_archive "http://www-csr.bessy.de/control/SoftDist/sequencer/releases/seq-${SEQ}.tar.gz" "sequencer" \
#     "$BUILD_ROOT/seq" "$SUPPORT/seq"

# asyn
install_from_github_archive "https://github.com/epics-modules/asyn/archive/R${ASYN}.tar.gz" "asyn" \
    "$BUILD_ROOT/asyn" "$SUPPORT/asyn"

# busy
install_from_github_archive "https://github.com/epics-modules/busy/archive/R${BUSY}.tar.gz" "busy" \
    "$BUILD_ROOT/busy" "$SUPPORT/busy"

# calc
install_from_github_archive "https://github.com/epics-modules/calc/archive/R${CALC}.tar.gz" "calc" \
    "$BUILD_ROOT/calc" "$SUPPORT/calc"

# motor
motor_build_path=$BUILD_ROOT/motor

fix_motor() {
    if [ "$MOTOR" = "6-9" ]; then
        # not building ipac support
        sed -ie s/^.*Hytec.*$// $motor_build_path/motorApp/Makefile
    fi
    # aerotech requires sequencer
    sed -ie s/^.*Aerotech.*$// $motor_build_path/motorApp/Makefile
	if [[ "$BASE" =~ ^R3\.16.* ]]; then
        # pretty much everything fails under 3.16 -- replace the Makefile
        cat > "$motor_build_path/motorApp/Makefile" <<'EOF'
TOP = ..
include $(TOP)/configure/CONFIG
DIRS += MotorSrc SoftMotorSrc MotorSimSrc Db
SoftMotorSrc_DEPEND_DIRS = MotorSrc
MotorSimSrc_DEPEND_DIRS = MotorSrc
include $(TOP)/configure/RULES_DIRS
EOF
    fi
}

install_from_github_archive "https://github.com/epics-modules/motor/archive/R${MOTOR}.tar.gz" "motor" \
    "$motor_build_path" "$SUPPORT/motor" fix_motor
