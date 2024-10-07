#!/bin/bash

set -eux

cd $PYTORCH_DIR
pip install cmake ninja
pip install -r requirements.txt
pip install mkl-static mkl-include

export \
  USE_CUDA=0
  USE_DISTRIBUTED=0 \
  BUILD_TEST=0 \
  _GLIBCXX_USE_CXX11_ABI=1

python setup.py develop

cmake -D CMAKE_INSTALL_PREFIX=build/install -P build/cmake_install.cmake

cd ..
tar --create --xz --file "$ARCHIVE_FILE" -C $PYTORCH_DIR/build/install .
