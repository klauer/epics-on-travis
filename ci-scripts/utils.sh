#!/bin/bash

update_release() {
    local package_name=$1
    local install_path=$2
   
    if [ -f "$install_path/configure/RELEASE" ]; then
        # TODO warn if files differ
        echo "Updating RELEASE of $package_name"
        cmp -s $RELEASE_PATH $install_path/configure/RELEASE || \
            echo "WARNING: RELEASE files differ; this may break builds"
        cp -f $RELEASE_PATH $install_path/configure/RELEASE
    fi
}


download_and_extract() {
    url=$1
    destination=$2
    curl -L "$url" | tar -C $destination -xvz --strip-components=1
}

install_from_github_archive() {
    local archive_url=$1
    local package_name=$2
    local build_path=$3
    local install_path=$4
    local fix_step=$5

    if [ ! -e "$install_path/built" ]; then
        echo "Download $package_name"
        install -d $build_path
        download_and_extract "$archive_url" "$build_path"
        cp $RELEASE_PATH $build_path/configure/RELEASE
        if [ ! -z "$fix_step" ]; then
            pushd $build_path
            $fix_step;
            popd
        fi
        echo "Build $package_name"
        if [[ "$install_path" == "$build_path" ]]; then
            make -C "$build_path"
        else
            make -C "$build_path" INSTALL_LOCATION="$install_path"
        fi
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


run_on_procserv() {
    port=$1
    name=$2
    path=$3
    executable_string=$4
    test_pv=$5
    echo_in_foreground=$6
    
    procServ --name "$name" --port $port --ignore "^D^C" --coresize 0 --chdir "$path" --holdoff 1 $executable_string

    if [[ ! -z "${test_pv}" ]]; then
        until caget ${test_pv}
        do
            echo "Waiting for ${IOC_NAME} to start..."
            sleep 1.0
        done
    fi
}
