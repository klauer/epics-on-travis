#!/bin/bash
set -e -x

export EPICS_TMUX_SESSION=IOCs

source $CI_SCRIPTS/epics-config.sh
tmux kill-session -t ${EPICS_TMUX_SESSION} || true

echo "Starting a new tmux session '${EPICS_TMUX_SESSION}'"
tmux new-session -d -s ${EPICS_TMUX_SESSION} /bin/bash

echo "Starting the IOCs..."
tmux new-window -n 'pyepics-test_ioc' -c "${CI_TOP}" "ci-scripts/run-pyepics-test-ioc.sh" && tmux set remain-on-exit on
tmux new-window -n 'motorsim_ioc' -c "${CI_TOP}"  "ci-scripts/run-motorsim-ioc.sh" && tmux set remain-on-exit on
tmux new-window -n 'adsim_ioc' -c "${CI_TOP}" "ci-scripts/run-sim-detector-ioc.sh" && tmux set remain-on-exit on

timeout 30s $CI_SCRIPTS/ensure-iocs-are-running.sh

echo "Running pyepics simulator program..."
tmux new-window -n 'pyepics-simulator' -c "${CI_TOP}" "ci-scripts/run-pyepics-simulator.sh" && tmux set remain-on-exit on

echo "Done - check tmux session ${EPICS_TMUX_SESSION}"
