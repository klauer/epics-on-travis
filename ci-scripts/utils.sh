#!/bin/bash

install_from_github_archive() {
    local archive_url=$1
    local package_name=$2
    local build_path=$3
    local install_path=$4
    local fix_step=$5

    if [ ! -e "$install_path/built" ]; then
        echo "Download $package_name"
        install -d $build_path
        curl -L "${archive_url}" | tar -C $build_path -xvz --strip-components=1
        cp $RELEASE_PATH $build_path/configure/RELEASE
        if [ ! -z "$fix_step" ]; then
            $fix_step;
        fi
        echo "Build $package_name"
        make -C "$build_path" INSTALL_LOCATION=$install_path
        touch $install_path/built
    else
        echo "Using cached $package_name"
    fi
    
}

install_from_git() {
    local git_url=$1
    local package_name=$2
    local build_path=$3
    local install_path=$4
    local branch_name=$5
    local fix_step=$6

    if [ ! -e "$install_path/built" ]; then
        echo "Cloning $package_name from git (branch $branch_name)"
        install -d $build_path
        git clone --depth 5 --branch ${branch_name} ${git_url} ${build_path}
        cp $RELEASE_PATH $build_path/configure/RELEASE
        if [ ! -z "$fix_step" ]; then
            $fix_step;
        fi
        make -C "$build_path" INSTALL_LOCATION=$install_path
        touch $install_path/built
    else
        echo "Using cached $package_name"
    fi
    
}

function run_ioc() {
    set +x
    local PIPE_PATH="$1"
    local IOC_NAME="$2"
    local IOC_PATH="$3"
    local IOC_COMMAND="$4"
    local TEST_PV="$5"

    echo ""
    echo ""
    echo ""
    echo "Executing IOC ${IOC_NAME}"
    echo "-------------------------"
    echo "pipe       ${PIPE_PATH}"
    echo "path       ${IOC_PATH}"
    echo "command    ${IOC_COMMAND}"
    echo "test_pv    ${TEST_PV}"
    echo ""
    echo ""
    set -x

    PID=0

    until caget ${TEST_PV}
    do
      if [[ -p "$PIPE_PATH" ]]; then
          echo "Retrying ${IOC_NAME} IOC"
          rm -f $PIPE_PATH
          if [ $PID -eq 0 ]; then
              echo "Failed to launch ${IOC_NAME}!"
              exit 1
          else
              kill -9 $PID || /bin/true
          fi
      fi

      mkfifo $PIPE_PATH
      sleep 10000 > $PIPE_PATH &

      cd "${IOC_PATH}" && ${IOC_COMMAND} < $PIPE_PATH &
      export PID=$!
      echo "${IOC_NAME} PID is $PID"
      echo help > $PIPE_PATH

      echo "Waiting for ${IOC_NAME} to start..."
      sleep 5.0
    done
}
