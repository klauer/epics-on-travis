#!/bin/bash
set -e -x

source $CI_SCRIPTS/epics-config.sh

if [ "$1" == "" ]; then
    echo "Running pyepics simulator program in the background..."
    python ${PYEPICS_IOC}/simulator.py &
    sleep 1
elif [ "$1" == "procserv" ]; then
    run_on_procserv 19999 "pyepics_simulator" "${PYEPICS_IOC}" \
        "$(which python) simulator.py" ""

    echo "Running pyepics simulator program in procServ..."
    sleep 1
fi
