#!/bin/bash
set -e -x

export EPICS_TMUX_SESSION=IOCs

source $CI_SCRIPTS/epics-config.sh

echo "Starting a new tmux session '${EPICS_TMUX_SESSION}'"
tmux new-session -d -s ${EPICS_TMUX_SESSION} /bin/bash

tmux set remain-on-exit on

echo "Starting the IOCs..."
tmux new-window -n 'pyepics-test_ioc' -c "${CI_TOP}" "run-pyepics-test-ioc.sh"
tmux new-window -n 'motorsim_ioc' -c "${CI_TOP}"  "run-motorsim-ioc.sh"
tmux new-window -n 'adsim_ioc' -c "${CI_TOP}" "run-sim-detector-ioc.sh"
timeout --kill-after=25s 30s $CI_SCRIPTS/ensure-iocs-are-running.sh

echo "Running pyepics simulator program..."
tmux new-window -c "${TRAVIS_BUILD_DIR}" -n 'pyepics_sim' \
    "source setup_local_dev_env.sh; \
    source activate ${CONDA_DEFAULT_ENV}; env; \
    cd "${PYEPICS_IOC}" && python simulator.py"

echo "Done - check tmux session ${EPICS_TMUX_SESSION}"
