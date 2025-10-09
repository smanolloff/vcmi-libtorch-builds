#!/bin/bash

set -eux

[ -d "$ARTIFACT_ROOT" ] || { echo "ARTIFACT_ROOT does not exist: $ARTIFACT_ROOT"; exit 1; }

cd pytorch
python -m venv .venv
. .venv/bin/activate
pip install 'cmake<4' ninja
pip install -r requirements.txt

# build_android.sh *must* be used for android builds

mkdir -p "android/pytorch_android/src/main/jniLibs"
mkdir -p "android/pytorch_android/src/main/cpp/libtorch_include"

export PYTORCH_ANDROID_DIR="$PWD/android"
export GRADLE_PATH="$PWD/android/gradlew"
export LIB_DIR="$PWD/android/pytorch_android/src/main/jniLibs"
export INCLUDE_DIR="$PWD/android/pytorch_android/src/main/cpp/libtorch_include"
export ANDROID_BUILD_ROOT="$PWD/build_android"
export ANDROID_ABI=x86_64
export BUILD_ROOT="$PWD/build_android"
export BUILD_LITE_INTERPRETER=1

args=(
  -DUSE_LITE_INTERPRETER_PROFILER=OFF
  -DUSE_VULKAN=OFF
)

scripts/build_android.sh "${args[@]}"

mv build_android/install "$ARTIFACT_ROOT/libtorch"
