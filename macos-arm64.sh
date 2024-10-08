#!/bin/bash

set -eux

cd $PYTORCH_DIR
mkdir -p install

pip install cmake ninja
pip install -r requirements.txt

# python setup.py produces larger libs (even with all features turned off)
# => use build_local.sh
# XXX: the -DCMAKE_INSTALL_PREFIX *must* be specified the during build phase

BUILD_ROOT=build_mac scripts/build_local.sh \
  -DCMAKE_INSTALL_PREFIX="libtorch" \
  -DBUILD_LITE_INTERPRETER=1 \
  -DBUILD_PYTHON=0 \
  -DBUILD_TEST=0 \
  -DUSE_CUDA=0 \
  -DUSE_DISTRIBUTED=0 \
  -DUSE_LITE_INTERPRETER_PROFILER=0 \
  -DUSE_KINETO=0

cmake -P build_mac/cmake_install.cmake

tar --create --xz --file "../$OUTPUT_ARCHIVE_FILE" -C build_mac libtorch
