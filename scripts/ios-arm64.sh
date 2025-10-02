#!/bin/bash

set -eux

cd pytorch
python -m venv .venv
. .venv/bin/activate
pip install cmake
pip install -r requirements.txt

export BUILD_LITE_INTERPRETER=1

args=(
  -DCMAKE_MAKE_PROGRAM="$(which make)"    # prevents 'No rule to make target `install''
)

# build_ios.sh *must* be used for ios builds
scripts/build_ios.sh "${args[@]}"

mv build_ios/{install,libtorch}
tar --create --xz --file "../$OUTPUT_ARCHIVE_FILE" -C build_ios libtorch
