#!/bin/bash
set -e -x

# fix rpc/rpc.h related issues
export C_INCLUDE_PATH=/usr/include/tirpc/

./ci-scripts/install-epics-base.sh
./ci-scripts/install-epics-modules.sh
./ci-scripts/install-epics-areadetector.sh
./ci-scripts/install-epics-iocs.sh
