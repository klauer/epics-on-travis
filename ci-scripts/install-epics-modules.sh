#!/bin/bash

install_from_github_archive() {
    archive_url=$1
    package_name=$2
    build_path=$3
    install_path=$4

    if [ ! -e "$install_path/built" ]; then
        echo "Build $package_name"
        install -d $build_path
        curl -L "${archive_url}" | tar -C $build_path -xvz --strip-components=1
        cp $RELEASE_PATH $build_path/configure/RELEASE
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


# # sequencer
# if [ ! -e "$SUPPORT/seq/built" ]; then
#     echo "Build sequencer"
#     install -d $SUPPORT/seq
#     curl -L "http://www-csr.bessy.de/control/SoftDist/sequencer/releases/seq-${SEQ}.tar.gz" | tar -C $SUPPORT/seq -xvz --strip-components=1
#     cp $RELEASE_PATH $SUPPORT/seq/configure/RELEASE
#     make -C $SUPPORT/seq
#     touch $SUPPORT/seq/built
# else
#     echo "Using cached seq"
# fi


# asyn
install_from_github_archive "https://github.com/epics-modules/asyn/archive/R${ASYN}.tar.gz" "asyn" \
    "$BUILD_ROOT/asyn" "$SUPPORT/asyn"

exit 0


# busy
if [ ! -e "$SUPPORT/busy/built" ]; then
    echo "Build busy"
    install -d $SUPPORT/busy
    curl -L "https://github.com/epics-modules/busy/archive/R${BUSY}.tar.gz" | tar -C $SUPPORT/busy -xvz --strip-components=1
    cp $RELEASE_PATH $SUPPORT/busy/configure/RELEASE
    make -C $SUPPORT/busy all clean
    touch $SUPPORT/busy/built
else
    echo "Using cached busy"
fi


# calc
if [ ! -e "$SUPPORT/calc/built" ]; then
    echo "Build calc"
    install -d $SUPPORT/calc
    git clone https://github.com/epics-modules/calc ${SUPPORT}/calc
    ( cd ${SUPPORT}/calc && git checkout ${CALC} )
    cp $RELEASE_PATH $SUPPORT/calc/configure/RELEASE
    make -C "$SUPPORT/calc" all clean
    touch $SUPPORT/calc/built
else
    echo "Using cached calc"
fi


# motor
if [ ! -e "$SUPPORT/motor/built" ]; then
    echo "Build motor"
    install -d $SUPPORT/motor
    curl -L "https://github.com/epics-modules/motor/archive/R${MOTOR}.tar.gz" | tar -C $SUPPORT/motor -xvz --strip-components=1
    cp $RELEASE_PATH $SUPPORT/motor/configure/RELEASE
    if [ "$MOTOR" = "6-9" ]; then
        # not building ipac support
        sed -ie s/^.*Hytec.*$// $SUPPORT/motor/motorApp/Makefile
    fi
    # aerotech requires sequencer
    sed -ie s/^.*Aerotech.*$// $SUPPORT/motor/motorApp/Makefile
	if [[ "$BASE" =~ ^R3\.16.* ]]; then
        # pretty much everything fails under 3.16 -- replace the Makefile
        cat > "$SUPPORT/motor/motorApp/Makefile" <<'EOF'
TOP = ..
include $(TOP)/configure/CONFIG
DIRS += MotorSrc SoftMotorSrc MotorSimSrc Db
SoftMotorSrc_DEPEND_DIRS = MotorSrc
MotorSimSrc_DEPEND_DIRS = MotorSrc
include $(TOP)/configure/RULES_DIRS
EOF
    fi
    make -C "$SUPPORT/motor" -j2
    make -C "$SUPPORT/motor" clean
    touch $SUPPORT/motor/built
else
    echo "Using cached motor"
fi
