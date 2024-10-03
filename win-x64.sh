#!/bin/bash

# XXX: building on windows via a bash script succeeds, but
#      the resulting `cmake` install command fails with syntax error:
#           C:\Miniconda\Lib\site-packages/caffe2
#           Invalid escape sequence \M
#      Also, given the size of the built library is probably huge
#      (see comment in win-x64.build.bat)
#       => better to just download the official pre-compiled libtorch

set -eux

cd $PYTORCH_DIR
mkdir -p install

. ${CONDA}/Scripts/activate
conda install -y cmake ninja rust
pip install -r requirements.txt
pip install mkl-static mkl-include

export \
  BUILD_LIBTORCH_WHL=1 \
  BUILD_LITE_INTERPRETER=1 \
  BUILD_TEST=0 \
  USE_CUDA=0 \
  USE_CUDNN=0 \
  USE_CUSPARSELT=0 \
  USE_DISTRIBUTED=0 \
  USE_GLOO=0 \
  USE_KINETO=0 \
  USE_LITE_INTERPRETER_PROFILER=0 \
  USE_TENSORPIPE=0
  # USE_MPI=0 \
  # USE_MKLDNN=0

python setup.py develop
cmake -D CMAKE_INSTALL_PREFIX=install -P build/cmake_install.cmake

cd ..

if [ "$ARCHIVE_FILE" != "${ARCHIVE_FILE%.*}.txz" ]; then
  echo "Expected ARCHIVE_FILE to end with .txz: $ARCHIVE_FILE" >&2
  exit 1
fi

TAR_FILE="${ARCHIVE_FILE%.*}.tar"
7z a -ttar "${TAR_FILE}" "libtorch/*"
7z a -txz "$ARCHIVE_FILE" "${TAR_FILE}"
