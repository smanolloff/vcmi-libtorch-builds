#!/bin/bash

set -eux

[ -d "$ARTIFACT_ROOT" ] || { echo "ARTIFACT_ROOT does not exist: $ARTIFACT_ROOT"; exit 1; }

cd pytorch

python -m venv .venv
. .venv/Scripts/activate
pip install cmake ninja
pip install -r requirements.txt

# MKL is intel-specific
# pip install mkl-static mkl-include

export BUILD_TEST=0
export USE_CUDA=0
export USE_DISTRIBUTED=0
export USE_FBGEMM=0  # depends on openmp; also causes asmjit build
export USE_KINETO=0
export USE_MPI=0
export USE_MKL=0  # MKL is intel-specific
export USE_MKLDNN=0
export USE_NUMPY=0
export USE_OPENMP=0  # openmp slows down inference

# XXX: build_local *must not* be used for windows builds => use python setup.py
python setup.py develop

cmake -D CMAKE_INSTALL_PREFIX=libtorch -P build/cmake_install.cmake

mv libtorch "$ARTIFACT_ROOT/libtorch"
