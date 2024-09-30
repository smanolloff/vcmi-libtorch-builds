#!/bin/bash

set -eux

cd $PYTORCH_DIR
mkdir -p install

pip install cmake ninja
pip install -r requirements.txt

scripts/build_local.sh \
      -DCMAKE_INSTALL_PREFIX="$PYTORCH_DIR/build/install" \
      -DBUILD_LITE_INTERPRETER=ON

cmake -P build/cmake_install.cmake

cd ..
tar --create --xz --file "$ARCHIVE_FILE" -C $PYTORCH_DIR/build/install .
