#!/bin/bash

set -eux

cd $PYTORCH_DIR
mkdir -p install

pip install cmake ninja
pip install -r requirements.txt

USE_CUDA=0 USE_DISTRIBUTED=0 BUILD_TEST=0 python setup.py develop

cmake -D CMAKE_INSTALL_PREFIX=build/install -P build/cmake_install.cmake

cd ..
tar --create --xz --file "$ARCHIVE_FILE" -C pytorch/build/install .
