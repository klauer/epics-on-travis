#!/bin/bash
set -e -x

export EPICS_TMUX_SESSION=IOCs

source $CI_SCRIPTS/epics-config.sh
tmux kill-session -t ${EPICS_TMUX_SESSION} || true

echo "Starting a new tmux session '${EPICS_TMUX_SESSION}'"
tmux new-session -d -s ${EPICS_TMUX_SESSION} /bin/bash

tmux set remain-on-exit on

echo "Starting the pyepics test IOC..."
tmux new-window -n 'pyepics-test_ioc' -c "${TRAVIS_BUILD_DIR}" \
    "source setup_local_dev_env.sh; \
    cd "${PYEPICS_IOC}/iocBoot/iocTestioc" && \
    ${PYEPICS_IOC}/bin/${EPICS_HOST_ARCH}/testioc ./st.cmd"

echo "Starting the motorsim IOC..."
tmux new-window -n 'motorsim_ioc' -c "${TRAVIS_BUILD_DIR}"  \
    "source setup_local_dev_env.sh; \
    cd "${MOTORSIM_IOC}/iocBoot/ioclocalhost" && \
    ${MOTORSIM_IOC}/bin/${EPICS_HOST_ARCH}/mtrSim ./st.cmd"

echo "Starting the ADSim IOC..."
tmux new-window -n 'adsim_ioc' -c "${TRAVIS_BUILD_DIR}"  \
    "source setup_local_dev_env.sh; \
    cd "${ADSIM_IOC}/iocBoot/iocSimDetector" && \
    ${ADSIM_IOC}/bin/${EPICS_HOST_ARCH}/simDetectorApp ./st.cmd"

# -- check that all IOCs have started --
until caget Py:ao1
do
  echo "Waiting for pyepics test IOC to start..."
  sleep 0.5
done

until caget sim:mtr1
do
  echo "Waiting for motorsim IOC to start..."
  sleep 0.5
done

until caget 13SIM1:HDF1:PluginType_RBV
do
  echo "Waiting for ADSim IOC to start..."
  sleep 0.5
done

echo "All IOCs are running in tmux!"

echo "Running pyepics simulator program..."
tmux new-window -c "${TRAVIS_BUILD_DIR}" -n 'pyepics_sim' \
    "source setup_local_dev_env.sh; \
    source activate ${CONDA_DEFAULT_ENV}; env; \
    cd "${PYEPICS_IOC}" && python simulator.py"

echo "Done - check tmux session ${EPICS_TMUX_SESSION}"
