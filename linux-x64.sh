#!/bin/bash

set -eux

tar -zxf $INPUT_ARCHIVE_FILE
cd "pytorch-$PYTORCH_REF"
pip install cmake ninja
pip install -r requirements.txt
pip install mkl-static mkl-include

export \
  BUILD_LIBTORCH_WHL=1 \
  BUILD_TEST=0 \
  USE_CUDA=0 \
  USE_CUDNN=0 \
  USE_CUSPARSELT=0 \
  USE_DISTRIBUTED=0 \
  USE_GLOO=0 \
  USE_KINETO=0 \
  USE_LITE_INTERPRETER_PROFILER=0 \
  USE_TENSORPIPE=0 \
  _GLIBCXX_USE_CXX11_ABI=1

python setup.py develop
cmake -D CMAKE_INSTALL_PREFIX=install/libtorch -P build/cmake_install.cmake

tar --create --xz --file "../$OUTPUT_ARCHIVE_FILE" -C install libtorch
