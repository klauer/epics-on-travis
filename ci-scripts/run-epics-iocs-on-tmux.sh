#!/bin/bash
set -e -x

export EPICS_TMUX_SESSION=IOCs

source $CI_SCRIPTS/epics-config.sh

echo "Starting a new tmux session '${EPICS_TMUX_SESSION}'"
tmux new-session -d -s ${EPICS_TMUX_SESSION} /bin/bash

tmux set remain-on-exit on

echo "Starting the pyepics test IOC..."
tmux new-window -n 'pyepics-test_ioc' -c "${CI_SCRIPTS}" \
    "run-pyepics-test-ioc.sh"

echo "Starting the motorsim IOC..."
tmux new-window -n 'motorsim_ioc' -c "${CI_TOP}"  \
    "source setup_local_dev_env.sh; \
    cd "${MOTORSIM_IOC}/iocBoot/ioclocalhost" && \
    ${MOTORSIM_IOC}/bin/${EPICS_HOST_ARCH}/mtrSim ./st.cmd"

echo "Starting the ADSim IOC..."
tmux new-window -n 'adsim_ioc' -c "${CI_TOP}"  \
    "source setup_local_dev_env.sh; \
    cd "${ADSIM_IOC}/iocBoot/iocSimDetector" && \
    ${ADSIM_IOC}/bin/${EPICS_HOST_ARCH}/simDetectorApp ./st.cmd"

timeout --kill-after=25s 30s $CI_SCRIPTS/ensure-iocs-are-running.sh

echo "All IOCs are running in tmux!"

echo "Running pyepics simulator program..."
tmux new-window -c "${TRAVIS_BUILD_DIR}" -n 'pyepics_sim' \
    "source setup_local_dev_env.sh; \
    source activate ${CONDA_DEFAULT_ENV}; env; \
    cd "${PYEPICS_IOC}" && python simulator.py"

echo "Done - check tmux session ${EPICS_TMUX_SESSION}"
