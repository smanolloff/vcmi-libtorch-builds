#!/bin/bash

set -eux

tar -zxf $INPUT_ARCHIVE_FILE
cd "pytorch-$PYTORCH_REF"
pip install cmake ninja
pip install -r requirements.txt
pip install mkl-static mkl-include

BUILD_ROOT=build_linux scripts/build_local.sh \
  -DCMAKE_INSTALL_PREFIX="libtorch" \
  -D_GLIBCXX_USE_CXX11_ABI=1 \
  -DBUILD_PYTHON=0 \
  -DBUILD_TEST=0 \
  -DUSE_CUDA=0 \
  -DUSE_DISTRIBUTED=0 \
  -DUSE_KINETO=0 \
  -DUSE_MKLDNN=0 \
  -DUSE_NUMPY=0 \
  -DUSE_OPENMP=0

cmake -P build_linux/cmake_install.cmake

tar --create --xz --file "../$OUTPUT_ARCHIVE_FILE" -C build_linux libtorch
