#!/bin/bash
set -e -x

if [ ! -z "${CI_TOP}" ]; then
    cd $CI_TOP
fi

pwd
source setup_local_dev_env.sh

if [ "$1" == "" ]; then
    echo "Running pyepics simulator program..."
   
    if [ ! -z "$CONDA_DEFAULT_ENV" ]; then
        source activate ${CONDA_DEFAULT_ENV}
        env
    fi

    cd "${PYEPICS_IOC}" 
    python simulator.py
elif [ "$1" == "procserv" ]; then

    run_on_procserv 19999 "pyepics_simulator" "${PYEPICS_IOC}" \
        "$(which python) simulator.py" "Py:ao1" "/dev/stderr"

    echo "Running pyepics simulator program in procServ..."
    sleep 1
fi
