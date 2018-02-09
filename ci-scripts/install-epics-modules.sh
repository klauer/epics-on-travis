#!/bin/bash

set -e -x

source $CI_SCRIPTS/epics-config.sh

[ -z "$EPICS_BASE" ] && echo "EPICS_BASE unset" && exit 1;
[ -z "$SUPPORT" ] && echo "SUPPORT unset" && exit 1;
[ -z "$BUILD_ROOT" ] && echo "BUILD_ROOT unset" && exit 1;

# sequencer
install_from_github_archive "http://www-csr.bessy.de/control/SoftDist/sequencer/releases/seq-${SEQ}.tar.gz" "sequencer" \
    "$BUILD_ROOT/seq" "$SUPPORT/seq"

# asyn
install_from_github_archive "https://github.com/epics-modules/asyn/archive/R${ASYN}.tar.gz" "asyn" \
    "$BUILD_ROOT/asyn" "$SUPPORT/asyn"

# busy
install_from_github_archive "https://github.com/epics-modules/busy/archive/R${BUSY}.tar.gz" "busy" \
    "$BUILD_ROOT/busy" "$SUPPORT/busy"

# calc
install_from_github_archive "https://github.com/epics-modules/calc/archive/R${CALC}.tar.gz" "calc" \
    "$BUILD_ROOT/calc" "$SUPPORT/calc"

# autosave
install_from_github_archive "https://github.com/epics-modules/autosave/archive/R${AUTOSAVE}.tar.gz" "autosave" \
    "$BUILD_ROOT/autosave" "$SUPPORT/autosave"

# sscan
install_from_github_archive "https://github.com/epics-modules/sscan/archive/R${SSCAN}.tar.gz" "sscan" \
    "$BUILD_ROOT/sscan" "$SUPPORT/sscan"

# motor
motor_build_path=$BUILD_ROOT/motor

fix_motor() {
    if [ "$MOTOR" = "6-9" ]; then
        # not building ipac support
        sed -ie s/^.*Hytec.*$// motorApp/Makefile
    fi
    # aerotech requires sequencer
    sed -ie s/^.*Aerotech.*$// motorApp/Makefile
	if [[ "$BASE" =~ ^R3\.16.* ]]; then
        # pretty much everything fails under 3.16 -- replace the Makefile
        cat > motorApp/Makefile <<'EOF'
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


fix_areadetector() {
    # Grab additional submodule releases
    if [ ! -d ADCore/configure ]; then
        download_and_extract "https://github.com/areaDetector/ADCore/archive/R${AREADETECTOR}.tar.gz" ADCore
    fi

    # TODO: hard-coded ADSimDetector 2.7
    if [ ! -d ADSimDetector/configure ]; then
        download_and_extract "https://github.com/areaDetector/ADSimDetector/archive/R2-7.tar.gz" ADSimDetector
    fi
    
    # RELEASE
    # Restore the original release file (installed by our bash scripts)
    cat > configure/RELEASE <<'EOF'
-include $(TOP)/../configure/RELEASE_LIBS_INCLUDE
-include $(TOP)/RELEASE.local
-include $(TOP)/configure/RELEASE.local
EOF
    cat configure/RELEASE
    
    # RELEASE_PATHS.local
    cat > configure/RELEASE_PATHS.local <<EOF
SUPPORT=$SUPPORT
AREA_DETECTOR=$SUPPORT/areadetector
EPICS_BASE=$EPICS_BASE
ADSUPPORT=$PWD/ADSupport
ADCORE=$PWD/ADCore
ADSIMDETECTOR=$PWD/ADSimDetector
EOF

    # RELEASE_LIBS.local (start with generated RELEASE file)
    cp -f $RELEASE_PATH configure/RELEASE_LIBS.local
    cat >> configure/RELEASE_LIBS.local <<EOF
INSTALL_LOCATION_APP=$SUPPORT/areadetector
-include \$(AREA_DETECTOR)/configure/RELEASE_LIBS.local.\$(EPICS_HOST_ARCH)
EOF
    
    cat configure/RELEASE_LIBS.local
    
    # RELEASE.local
    cat > configure/RELEASE.local <<EOF
ADSUPPORT=$PWD/ADSupport
ADCORE=$PWD/ADCore
ADSIMDETECTOR=$PWD/ADSimDetector
-include \$(AREA_DETECTOR)/configure/RELEASE.local.\$(EPICS_HOST_ARCH)
EOF

    cat configure/RELEASE.local

    # RELEASE_PRODS.local
    echo 'include $(TOP)/configure/RELEASE_LIBS.local' > configure/RELEASE_PRODS.local
    cat $RELEASE_PATH >> configure/RELEASE_PRODS.local
    echo '-include $(TOP)/configure/RELEASE_PRODS.local.$(EPICS_HOST_ARCH)' >> configure/RELEASE_PRODS.local

    cat configure/RELEASE_PRODS.local

    # CONFIG_SITE.arch.Common
    cat > configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common <<EOF
WITH_BOOST=NO
BOOST_EXTERNAL=NO
WITH_HDF5=YES
HDF5_EXTERNAL=NO
XML2_EXTERNAL=NO
WITH_NETCDF=YES
NETCDF_EXTERNAL=NO
WITH_NEXUS=YES
NEXUS_EXTERNAL=NO
WITH_TIFF=YES
TIFF_EXTERNAL=NO
WITH_JPEG=YES
JPEG_EXTERNAL=NO
WITH_SZIP=YES
SZIP_EXTERNAL=NO
WITH_ZLIB=YES
ZLIB_EXTERNAL=NO
HOST_OPT=NO
WITH_PVA=NO
EOF

    # Install ADSupport
    if [ ! -d ADSupport/configure ]; then
        git clone --depth=1 --branch=master https://github.com/areaDetector/ADSupport.git
    fi

    # RELEASE.arch.Common
    echo "EPICS_BASE=$EPICS_BASE" > ADSupport/configure/RELEASE.$EPICS_HOST_ARCH.Common

    # Copy the same config site file generated above for ADSupport
    cp configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common ADSupport/configure
    make -sj -C ADSupport
}

# areadetector
install_from_github_archive \
    "https://github.com/areaDetector/areaDetector/archive/R${AREADETECTOR}.tar.gz" \
    "areadetector" "$SUPPORT/areadetector" "$SUPPORT/areadetector" \
    fix_areadetector
