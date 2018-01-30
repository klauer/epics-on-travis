#!/bin/bash
set -e -x

source $TRAVIS_BUILD_DIR/epics-config.sh

echo "Running pyepics simulator program..."
python ${PYEPICS_IOC}/simulator.py &
sleep 1
