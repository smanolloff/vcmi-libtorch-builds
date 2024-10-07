#!/bin/bash

set -eux

tar -zxf $INPUT_ARCHIVE_FILE
cd "pytorch-$PYTORCH_REF"
pip install cmake ninja
pip install -r requirements.txt

BUILD_LITE_INTERPRETER=1 scripts/build_ios.sh

mv build_ios/{install,libtorch}
tar --create --xz --file "../$OUTPUT_ARCHIVE_FILE" -C build_ios libtorch
