#!/bin/bash

set -eux

cd pytorch
python -m venv .venv
. .venv/bin/activate
pip install cmake #ninja
pip install -r requirements.txt

# build_ios.sh *must* be used for ios builds

args=(
  -G Xcode  # 'make' not available on macos runners
)

BUILD_LITE_INTERPRETER=1 scripts/build_ios.sh  "${args[@]}"

mv build_ios/{install,libtorch}
tar --create --xz --file "../$OUTPUT_ARCHIVE_FILE" -C build_ios libtorch
