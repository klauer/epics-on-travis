#!/bin/bash

source "${CI_SCRIPTS}/epics-config.sh"

bash "${CI_SCRIPTS}/install-epics-base.sh"
if [[ ! -z "${PVA}" ]]; then 
   bash "${CI_SCRIPTS}/install-epics-v4.sh";
fi
bash "${CI_SCRIPTS}/install-epics-modules.sh"
if [[ ! -z "${AREADETECTOR_VER}" ]]; then
   bash "${CI_SCRIPTS}/install-epics-areadetector.sh";
fi
bash "${CI_SCRIPTS}/install-epics-iocs.sh"
