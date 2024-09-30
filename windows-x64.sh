#!/bin/bash

set -eux

cd $PYTORCH_DIR
mkdir -p install

conda install cmake ninja rust
pip install -r requirements.txt
pip install mkl-static mkl-include

USE_CUDA=0 USE_DISTRIBUTED=0 BUILD_TEST=0 python setup.py develop

cmake -D CMAKE_INSTALL_PREFIX=build/install -P build/cmake_install.cmake

cd ..

if [ "$ARCHIVE_FILE" != "${ARCHIVE_FILE%.*}.txz" ]; then
  echo "Expected ARCHIVE_FILE to end with .txz: $ARCHIVE_FILE" >&2
  exit 1
fi

7z a -ttar "${ARCHIVE_FILE%.*}.tar" "$PYTORCH_DIR/build/install/*"
7z a -txz "$ARCHIVE_FILE" "${ARCHIVE_FILE%.*}.tar"
