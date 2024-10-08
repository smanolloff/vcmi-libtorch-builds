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
pip install mkl-static mkl-include

# XXX: BUILD_LITE_INTERPRETER=1 causes "unresolved external symbol" errors

export \
  BUILD_TEST=0 \
  USE_CUDA=0 \
  USE_CUDNN=0 \
  USE_CUSPARSELT=0 \
  USE_DISTRIBUTED=0 \
  USE_GLOO=0 \
  USE_KINETO=0 \
  USE_TENSORPIPE=0 \
  USE_MPI=0 \
  USE_MKLDNN=0 \
  USE_OPENMP=0 \
  USE_NUMPY=0

python setup.py develop
cmake -D CMAKE_INSTALL_PREFIX=libtorch -P build/cmake_install.cmake

TAR_FILE="${OUTPUT_ARCHIVE_FILE%.*}.tar"
7z a -ttar "${TAR_FILE}" "libtorch"
7z a -txz "$OUTPUT_ARCHIVE_FILE" "${TAR_FILE}"
mv "$OUTPUT_ARCHIVE_FILE" ..

