#!/bin/bash

set -eux

cd pytorch
python -m venv .venv
. .venv/Scripts/activate
pip install cmake ninja
pip install -r requirements.txt

# build_local *may* be used for mac builds
# (and seems to produce smaller binaries compared to setup.py)

args=(
  -DCMAKE_INSTALL_PREFIX=libtorch  # must be available during build
  -DBUILD_LITE_INTERPRETER=0  # causes errors (undefined symbols)
  -DBUILD_PYTHON=0
  -DBUILD_TEST=0
  -DUSE_CUDA=0
  -DUSE_DISTRIBUTED=0
  -DUSE_LITE_INTERPRETER_PROFILER=0
  -DUSE_KINETO=0
  -DUSE_FBGEMM=0
)

python setup.py develop
cmake -D CMAKE_INSTALL_PREFIX=libtorch -P build/cmake_install.cmake

tar --create --xz --file "../$OUTPUT_ARCHIVE_FILE" -C build_mac libtorch
