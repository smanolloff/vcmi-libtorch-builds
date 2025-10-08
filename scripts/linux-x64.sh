#!/bin/bash

set -eux

[ -d "$ARTIFACT_ROOT" ] || { echo "ARTIFACT_ROOT does not exist: $ARTIFACT_ROOT"; exit 1; }

cd pytorch
# python -m venv .venv
# . .venv/bin/activate
# pip install cmake ninja
# pip install -r requirements.txt

# # MKL is intel-specific
# # pip install mkl-static mkl-include

# # build_local *may* be used for linux builds
# # (and seems to produce smaller binaries compared to setup.py)

# args=(
#   -DCMAKE_INSTALL_PREFIX=libtorch  # must be available during build
#   -D_GLIBCXX_USE_CXX11_ABI=1
#   -DBUILD_LITE_INTERPRETER=0  # causes errors (undefined symbols)
#   -DBUILD_PYTHON=0
#   -DBUILD_TEST=0
#   -DUSE_CUDA=0  # no gpu needed
#   -DUSE_DISTRIBUTED=0
#   -DUSE_KINETO=0
#   -DUSE_MKL=0  # MKL is intel-specific
#   -DUSE_MKLDNN=0  # MKL is intel-specific
#   -DUSE_NUMPY=0  # has libgfortran dependency
#   -DUSE_OPENMP=0  # openmp slows down inference
# )

# BUILD_ROOT=build_linux scripts/build_local.sh "${args[@]}"
# cmake -P build_linux/cmake_install.cmake

mkdir -p build_linux/libtorch
echo "test" > build_linux/libtorch/testfile.txt

mv build_linux/libtorch "$ARTIFACT_ROOT/libtorch"
