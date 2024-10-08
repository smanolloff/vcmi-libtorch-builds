#!/bin/bash

set -eux

# https://github.com/actions/runner-images/blob/e7648fd6a7ca5dc796f218a01ce92d0b8d068203/images/macos/macos-13-Readme.md
EXPECTED_ANDROID_NDK="/Users/runner/Library/Android/sdk/ndk/26.3.11579264"

if [ "$ANDROID_NDK" != "$EXPECTED_ANDROID_NDK" ]; then
  echo "Unexpected android home: have: $ANDROID_NDK, want: $EXPECTED_ANDROID_NDK" >&2
  exit 1
fi

tar -zxf $INPUT_ARCHIVE_FILE
cd "pytorch-$PYTORCH_REF"
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
