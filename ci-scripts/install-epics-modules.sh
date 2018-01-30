#!/bin/bash

download_archive_and_configure() {
    archive_url=$1
    package_name=$2
    build_path=$3
    install_path=$4
    
    echo "Build $package_name"
    install -d $build_path
    curl -L "${archive_url}" | tar -C $build_path -xvz --strip-components=1
    cp $RELEASE_PATH $build_path/configure/RELEASE
}

install_from_github_archive() {
    archive_url=$1
    package_name=$2
    build_path=$3
    install_path=$4

    if [ ! -e "$install_path/built" ]; then
        download_archive_and_configure $1 $2 $3 $4
        make -C "$build_path" INSTALL_LOCATION=$install_path
        touch $install_path/built
    else
        echo "Using cached $package_name"
    fi
    
}

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
if [ ! -e "$SUPPORT/motor/built" ]; then
    echo "Build motor"
    build_path=$BUILD_ROOT/motor
    install_path=$SUPPORT/motor
    download_archive_and_configure "https://github.com/epics-modules/motor/archive/R${MOTOR}.tar.gz" "motor" \
        "$build_path" "$SUPPORT/motor"

    if [ "$MOTOR" = "6-9" ]; then
        # not building ipac support
        sed -ie s/^.*Hytec.*$// $build_path/motorApp/Makefile
    fi
    # aerotech requires sequencer
    sed -ie s/^.*Aerotech.*$// $build_path/motorApp/Makefile
	if [[ "$BASE" =~ ^R3\.16.* ]]; then
        # pretty much everything fails under 3.16 -- replace the Makefile
        cat > "$build_path/motorApp/Makefile" <<'EOF'
TOP = ..
include $(TOP)/configure/CONFIG
DIRS += MotorSrc SoftMotorSrc MotorSimSrc Db
SoftMotorSrc_DEPEND_DIRS = MotorSrc
MotorSimSrc_DEPEND_DIRS = MotorSrc
include $(TOP)/configure/RULES_DIRS
EOF
    fi
    make -C "$build_path" INSTALL_LOCATION=$install_path
    touch $install_path/built
else
    echo "Using cached motor"
fi
