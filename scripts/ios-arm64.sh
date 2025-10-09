#!/bin/bash

set -eux

[ -d "$ARTIFACT_ROOT" ] || { echo "ARTIFACT_ROOT does not exist: $ARTIFACT_ROOT"; exit 1; }

cd pytorch
python -m venv .venv
. .venv/bin/activate
pip install 'cmake<4'
pip install -r requirements.txt

export BUILD_LITE_INTERPRETER=1

# As per VCMI's CMakeLists
export IOS_DEPLOYMENT_TARGET=12.0

args=(
  -DCMAKE_MAKE_PROGRAM="$(which make)"    # prevents 'No rule to make target `install''
)

# build_ios.sh *must* be used for ios builds
scripts/build_ios.sh "${args[@]}"

mv build_ios/install "$ARTIFACT_ROOT/libtorch"
