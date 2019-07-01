#!/usr/bin/env bash

# TODO add anaconda token here

set -ex

# Function to retry functions that sometimes timeout or have flaky failures
retry () {
    $*  || (sleep 1 && $*) || (sleep 2 && $*) || (sleep 4 && $*) || (sleep 8 && $*)
}

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters. Pass cuda version"
    echo "CUDA version should be M.m with no dot, e.g. '9.0' or 'cpu'"
    exit 1
fi
desired_cuda="$1"

export APEX_BUILD_VERSION="master" # TODO: we should add tags to apex, to be able to checkout e.g. "0.1.0"
export APEX_BUILD_NUMBER=1

SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

apex_rootdir="$(pwd)/apex-src"

if [[ ! -d "$apex_rootdir" ]]; then
  rm -rf "$apex_rootdir"
  git clone "https://github.com/nvidia/apex" "$apex_rootdir"
  pushd "$apex_rootdir"
  git checkout $APEX_BUILD_VERSION
  popd
fi

cd "$SOURCE_DIR"

# TODO: set ANADONCA_USER
ANACONDA_USER=nvidia
conda config --set anaconda_upload no

export APEX_PACKAGE_SUFFIX=""
. ./switch_cuda_version.sh $desired_cuda
if [[ "$desired_cuda" == "10.0" ]]; then
  export CONDA_CUDATOOLKIT_CONSTRAINT="    - cudatoolkit >=10.0,<10.1 # [not osx]"
elif [[ "$desired_cuda" == "9.0" ]]; then
  export CONDA_CUDATOOLKIT_CONSTRAINT="    - cudatoolkit >=9.0,<9.1 # [not osx]"
else
  echo "unhandled desired_cuda: $desired_cuda"
    exit 1
fi

time conda build -c pytorch --no-anaconda-upload --python 3.6 apex

set +e
