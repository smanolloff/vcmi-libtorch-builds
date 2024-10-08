#!/bin/bash

set -eux

tar -zxf $INPUT_ARCHIVE_FILE
cd "pytorch-$PYTORCH_REF"
pip install cmake ninja
pip install -r requirements.txt

# MKL is intel-specific
# pip install mkl-static mkl-include

# build_local *may* be used for linux builds
# (and seems to produce smaller binaries compared to setup.py)

args=(
  -DCMAKE_INSTALL_PREFIX=libtorch  # must be available during build
  -D_GLIBCXX_USE_CXX11_ABI=1
  -DBUILD_LITE_INTERPRETER=0  # causes errors if built (undefined symbols)
  -DBUILD_PYTHON=0
  -DBUILD_TEST=0
  -DUSE_CUDA=0  # no gpu needed
  -DUSE_DISTRIBUTED=0
  -DUSE_KINETO=0
  -DUSE_MKL=0  # MKL is intel-specific
  -DUSE_MKLDNN=0  # MKL is intel-specific
  -DUSE_NUMPY=0  # has libgfortran dependency
  -DUSE_OPENMP=0  # openmp slows down inference
)

BUILD_ROOT=build_linux scripts/build_local.sh "${args[@]}"
cmake -P build_linux/cmake_install.cmake

tar --create --xz --file "../$OUTPUT_ARCHIVE_FILE" -C build_linux libtorch
