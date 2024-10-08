#!/bin/bash

# XXX: building on windows via a bash script succeeds, but
#      the resulting `cmake` install command fails with syntax error:
#           C:\Miniconda\Lib\site-packages/caffe2
#           Invalid escape sequence \M
#      Also, given the size of the built library is probably huge
#      (see comment in win-x64.build.bat)
#       => better to just download the official pre-compiled libtorch

set -eux

if [ "$INPUT_ARCHIVE_FILE" != "${INPUT_ARCHIVE_FILE%.tar.gz}.tar.gz" ]; then
  echo "Expected INPUT_ARCHIVE_FILE to end with .tar.gz: $INPUT_ARCHIVE_FILE" >&2
  exit 1
fi

if [ "$OUTPUT_ARCHIVE_FILE" != "${OUTPUT_ARCHIVE_FILE%.txz}.txz" ]; then
  echo "Expected OUTPUT_ARCHIVE_FILE to end with .txz: $OUTPUT_ARCHIVE_FILE" >&2
  exit 1
fi

7z x "${INPUT_ARCHIVE_FILE}"
7z x "${INPUT_ARCHIVE_FILE%.gz}"
cd "pytorch-$PYTORCH_REF"

# XXX: cmake_install.cmake is generated with paths on windows => apply patch
"/c/Program Files/Git/usr/bin/patch" -d caffe2 < ../patches/python_sitelib_paths_fix.patch

. "${CONDA}/Scripts/activate"

# XXX: conda create+activate causes distutils errors during install => skip
# conda create -y -n vcmi
# conda activate vcmi

conda install -y cmake ninja rust
pip install -r requirements.txt

# MKL is intel-specific
# pip install mkl-static mkl-include

# build_local *must not* be used for windows builds

# XXX: BUILD_LITE_INTERPRETER=1 causes "unresolved external symbol" errors

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

python setup.py develop
cmake -D CMAKE_INSTALL_PREFIX=libtorch -P build/cmake_install.cmake

TAR_FILE="${OUTPUT_ARCHIVE_FILE%.*}.tar"
7z a -ttar "${TAR_FILE}" "libtorch"
7z a -txz "$OUTPUT_ARCHIVE_FILE" "${TAR_FILE}"
mv "$OUTPUT_ARCHIVE_FILE" ..

