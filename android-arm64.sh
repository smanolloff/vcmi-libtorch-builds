#!/bin/bash

set -eux

cd $PYTORCH_DIR
mkdir -p install

# https://github.com/actions/runner-images/blob/e7648fd6a7ca5dc796f218a01ce92d0b8d068203/images/macos/macos-13-Readme.md
EXPECTED_ANDROID_NDK="/Users/runner/Library/Android/sdk/ndk/26.3.11579264"

if [ "$ANDROID_NDK" != "$EXPECTED_ANDROID_NDK" ]; then
  echo "Unexpected android home: have: $ANDROID_NDK, want: $EXPECTED_ANDROID_NDK" >&2
  exit 1
fi

pip install cmake ninja
pip install -r requirements.txt

rm -rf "android/pytorch_android/src/main/jniLibs"
mkdir -p "android/pytorch_android/src/main/jniLibs"
rm -rf "android/pytorch_android/src/main/cpp/libtorch_include"
mkdir -p "android/pytorch_android/src/main/cpp/libtorch_include"

export \
  PYTORCH_DIR="$PWD" \
  PYTORCH_ANDROID_DIR="$PWD/android" \
  GRADLE_PATH="$PWD/android/gradlew" \
  LIB_DIR="$PWD/android/pytorch_android/src/main/jniLibs" \
  INCLUDE_DIR="$PWD/android/pytorch_android/src/main/cpp/libtorch_include" \
  ANDROID_BUILD_ROOT="$PWD/build_android" \
  ANDROID_ABI=arm64-v8a \
  BUILD_ROOT="$PWD/build_android" \
  BUILD_LITE_INTERPRETER=1

scripts/build_android.sh -DUSE_LITE_INTERPRETER_PROFILER=OFF -DUSE_VULKAN=OFF

cd ..
tar --create --xz --file "$ARCHIVE_FILE" -C $PYTORCH_DIR/build_android/install .
