#!/bin/bash

set -x

function load_msenv() {
  local msenv="$HOME/.msenv_bash"
  if [ ! -f "$msenv" ]; then
    local msenvbatch="__print_ms_env.bat"
    echo "@echo off" > "$msenvbatch"
    echo "call ${VS140COMNTOOLS}..\..\VC\vcvarsall.bat x64" >> "$msenvbatch"
    echo "set" >> "$msenvbatch"
    cmd "/C $msenvbatch" > "$msenv.tmp"
    rm -f "$msenvbatch"

    grep -E '^PATH=' "$msenv.tmp" | \
      sed \
        -e 's/\(.*\)=\(.*\)/export \1="\2"/g' \
        -e 's/\([a-zA-Z]\):[\\\/]/\/\1\//g' \
        -e 's/\\/\//g' \
        -e 's/;\//:\//g' \
      > "$msenv"

    # Don't mess with CL compilation env
    grep -E '^(INCLUDE|LIB|LIBPATH)=' "$msenv.tmp" | \
      sed \
        -e 's/\(.*\)=\(.*\)/export \1="\2"/g' \
      >> "$msenv"
    
    rm "$msenv.tmp"
  fi

  source "$msenv"
}

export -f load_msenv


export CI_TOP=$PWD
export CI_SCRIPTS=$CI_TOP/ci-scripts

env
cpan -i ExtUtils::Command

which g++ || /bin/true
which gcc || /bin/true
which make

env |grep _VER

source "${CI_SCRIPTS}/epics-config.sh"

bash "${CI_SCRIPTS}/install-epics-base.sh"
# if [[ ! -z "${PVA}" ]]; then
#    bash "${CI_SCRIPTS}/install-epics-v4.sh";
# fi
# bash "${CI_SCRIPTS}/install-epics-modules.sh"
# if [[ ! -z "${AREADETECTOR_VER}" ]]; then
#    bash "${CI_SCRIPTS}/install-epics-areadetector.sh";
# fi
# bash "${CI_SCRIPTS}/install-epics-iocs.sh"

export GIT_TAG=$(git describe --tag)
export VERSION_TAG=${BASE_VER}_pva${PVA}_areadetector${AREADETECTOR_VER}_motor${MOTOR_VER}
export FILE_TO_UPLOAD="${HOME}/epics-ci-${EPICS_HOST_ARCH}-${GIT_TAG}_${VERSION_TAG}.tar.bz2"
echo $FILE_TO_UPLOAD

# Reduce the deployed package size a bit:
rm -rf $SNCSEQ_PATH/lib    $SNCSEQ_PATH/bin
rm -rf $AUTOSAVE_PATH/lib  $AUTOSAVE_PATH/bin
rm -rf $SSCAN_PATH/lib     $SSCAN_PATH/bin
rm -rf $BUSY_PATH/lib      $BUSY_PATH/bin
rm -rf $ASYN_PATH/lib      $ASYN_PATH/bin
rm -rf $CALC_PATH/lib      $CALC_PATH/bin
rm -rf $MOTOR_PATH/lib     $MOTOR_PATH/bin
# find $AREA_DETECTOR_PATH -type f -name "*.a" -delete
# find $AREA_DETECTOR_PATH -type f -name "*.so" -delete
# find $AREA_DETECTOR_PATH -type f -name "*.dylib" -delete
# tar cfj ${FILE_TO_UPLOAD} ${EPICS_ROOT} --exclude=${EPICS_ROOT}/modules
