#!/bin/bash

set -eux

cd $PYTORCH_DIR
mkdir -p install

# pip3 install 'conan<2.0'
#
# cat <<-EOF >conan-profile
# [settings]
# arch=armv8
# build_type=Release
# compiler=clang
# compiler.libcxx=c++_shared
# compiler.version=14
# os=Android
# os.api_level=21
#
# [tool_requires]
# android-ndk/r26d
# EOF
#
# conan profile update settings.arch=armv8 android
# conan install android-ndk/r26d@ --profile:build ./conan-profile
# export ANDROID_HOME=$(find ~/.conan/data/android-ndk/r26d/_/_/package -type d -maxdepth 1 | head -1)
# [ -n "$ANDROID_HOME" ] || { echo "error: failed to find android NDK";  }

curl -L https://dl.google.com/android/repository/android-ndk-r26d-linux.zip -o ndk.zip
unzip ndk.zip
export ANDROID_HOME=... # TODO

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
  ANDROID_NDK=$ANDROID_HOME \
  BUILD_ROOT="$PWD/build_android" \
  BUILD_LITE_INTERPRETER=1

scripts/build_android.sh -DUSE_LITE_INTERPRETER_PROFILER=OFF -DUSE_VULKAN=OFF

cd ..
tar --create --xz --file "$ARCHIVE_FILE" -C $PYTORCH_DIR/build_android/install .
