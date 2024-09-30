#!/bin/bash

set -eux

cd $PYTORCH_DIR
mkdir -p install

pip install cmake ninja
pip install -r requirements.txt

BUILD_LITE_INTERPRETER=1 scripts/build_ios.sh

cd ..
tar --create --xz --file "$ARCHIVE_FILE" -C pytorch/build_ios/install .
