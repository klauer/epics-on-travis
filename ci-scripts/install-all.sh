#!/bin/bash
set -e -x

./ci-scripts/install-epics-base.sh
./ci-scripts/install-epics-modules.sh
./ci-scripts/install-epics-areadetector.sh
./ci-scripts/install-epics-iocs.sh
