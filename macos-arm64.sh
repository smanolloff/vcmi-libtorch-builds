#!/bin/bash

set -eux

cd $PYTORCH_DIR
mkdir -p install

pip install cmake ninja
pip install -r requirements.txt

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
  USE_TENSORPIPE=0

python setup.py develop
cmake -D CMAKE_INSTALL_PREFIX=install -P build/cmake_install.cmake

cd ..
tar --create --xz --file "$ARCHIVE_FILE" -C $PYTORCH_DIR/install .
