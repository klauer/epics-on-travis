#!/bin/bash
set -e -x

source $CI_SCRIPTS/epics-config.sh

echo "Running pyepics simulator program..."
python ${PYEPICS_IOC}/simulator.py &
sleep 1
