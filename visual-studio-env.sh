#!/bin/bash

function load_msenv() {
  local msenv="$HOME/.msenv_bash"
  if [ ! -f "$msenv" ]; then
    local msenvbatch="__print_ms_env.bat"
    echo "@echo off" > "$msenvbatch"
    echo "call ${VS140COMNTOOLS}..\..\VC\vcvarsall.bat x64" >> "$msenvbatch"
    echo "set" >> "$msenvbatch"
    cmd "/C $msenvbatch" > "$msenv.tmp"
    rm -f "$msenvbatch"

    grep -E '^PATH=' "$msenv.tmp" | \
      sed \
        -e 's/\(.*\)=\(.*\)/export \1="\2"/g' \
        -e 's/\([a-zA-Z]\):[\\\/]/\/\1\//g' \
        -e 's/\\/\//g' \
        -e 's/;\//:\//g' \
      > "$msenv"

    # Don't mess with CL compilation env
    grep -E '^(INCLUDE|LIB|LIBPATH)=' "$msenv.tmp" | \
      sed \
        -e 's/\(.*\)=\(.*\)/export \1="\2"/g' \
      >> "$msenv"
    
    rm "$msenv.tmp"
  fi

  source "$msenv"
}

export -f load_msenv


