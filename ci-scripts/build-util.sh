#!/bin/bash

install_from_github_archive() {
    archive_url=$1
    package_name=$2
    build_path=$3
    install_path=$4
    fix_step=$5

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
    archive_url=$1
    package_name=$2
    build_path=$3
    install_path=$4
    branch_name=$5
    fix_step=$6

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
