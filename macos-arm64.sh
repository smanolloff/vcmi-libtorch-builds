#!/bin/bash

set -eux

cd pytorch
pip install cmake ninja
pip install -r requirements.txt

mkdir -p install

scripts/build_local.sh \
      -DCMAKE_INSTALL_PREFIX="install" \
      -DBUILD_LITE_INTERPRETER=ON

cmake -P build/cmake_install.cmake
