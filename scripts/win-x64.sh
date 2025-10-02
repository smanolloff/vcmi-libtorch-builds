#!/bin/bash

set -eux

# 7z produces .txz archives
if [ "$OUTPUT_ARCHIVE_FILE" != "${OUTPUT_ARCHIVE_FILE%.txz}.txz" ]; then
  echo "Expected OUTPUT_ARCHIVE_FILE to end with .txz: $OUTPUT_ARCHIVE_FILE" >&2
  exit 1
fi

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

TAR_FILE="${OUTPUT_ARCHIVE_FILE%.*}.tar"
7z a -ttar "${TAR_FILE}" "libtorch"
7z a -txz "$OUTPUT_ARCHIVE_FILE" "${TAR_FILE}"
mv "$OUTPUT_ARCHIVE_FILE" ..
