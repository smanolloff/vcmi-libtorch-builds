#!/bin/bash

set -eux

cd pytorch
python -m venv .venv
. .venv/bin/activate
pip install cmake ninja
pip install -r requirements.txt

# build_ios.sh *must* be used for ios builds

export BUILD_LITE_INTERPRETER=1

args=(
  -G Ninja  # 'make' not available on macos runners
  -DCMAKE_MAKE_PROGRAM="$(which ninja)"
)

scripts/build_ios.sh  "${args[@]}"

mv build_ios/{install,libtorch}
tar --create --xz --file "../$OUTPUT_ARCHIVE_FILE" -C build_ios libtorch
