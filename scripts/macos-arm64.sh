#!/bin/bash

set -eux

tar -zxf $INPUT_ARCHIVE_FILE
cd "pytorch-$PYTORCH_REF"
pip install cmake ninja
pip install -r requirements.txt

# build_local *may* be used for mac builds
# (and seems to produce smaller binaries compared to setup.py)

args=(
  -DCMAKE_INSTALL_PREFIX=libtorch  # must be available during build
  -DBUILD_LITE_INTERPRETER=1
  -DBUILD_PYTHON=0
  -DBUILD_TEST=0
  -DUSE_CUDA=0
  -DUSE_DISTRIBUTED=0
  -DUSE_LITE_INTERPRETER_PROFILER=0
  -DUSE_KINETO=0
)

BUILD_ROOT=build_mac scripts/build_local.sh "${args[@]}"
cmake -P build_mac/cmake_install.cmake

tar --create --xz --file "../$OUTPUT_ARCHIVE_FILE" -C build_mac libtorch
