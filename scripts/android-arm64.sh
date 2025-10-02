#!/bin/bash

set -eux

# https://github.com/actions/runner-images/blob/main/images/macos/macos-15-arm64-Readme.md
EXPECTED_ANDROID_NDK="/Users/runner/Library/Android/sdk/ndk/27.3.13750724"

if [ "$ANDROID_NDK" != "$EXPECTED_ANDROID_NDK" ]; then
  echo "Unexpected android home: have: $ANDROID_NDK, want: $EXPECTED_ANDROID_NDK" >&2
  exit 1
fi

cd pytorch
python -m venv .venv
. .venv/bin/activate
pip install cmake ninja
pip install -r requirements.txt

# build_android.sh *must* be used for android builds

mkdir -p "android/pytorch_android/src/main/jniLibs"
mkdir -p "android/pytorch_android/src/main/cpp/libtorch_include"

export \
  PYTORCH_ANDROID_DIR="$PWD/android" \
  GRADLE_PATH="$PWD/android/gradlew" \
  LIB_DIR="$PWD/android/pytorch_android/src/main/jniLibs" \
  INCLUDE_DIR="$PWD/android/pytorch_android/src/main/cpp/libtorch_include" \
  ANDROID_BUILD_ROOT="$PWD/build_android" \
  ANDROID_ABI=arm64-v8a \
  BUILD_ROOT="$PWD/build_android" \
  BUILD_LITE_INTERPRETER=1

scripts/build_android.sh -DUSE_LITE_INTERPRETER_PROFILER=OFF -DUSE_VULKAN=OFF

mv build_android/{install,libtorch}
tar --create --xz --file "../$OUTPUT_ARCHIVE_FILE" -C build_android libtorch
