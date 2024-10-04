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

PYTORCH_DIR="pytorch-$PYTORCH_REF"

if ! [ -d "$PYTORCH_DIR" ]; then
  echo "Directory not found after unarchiving: $PYTORCH_DIR" >&2
  exit 1
fi

cd "$PYTORCH_DIR"

# Without BUILD_LIBTORCH_WHL, cmake_install.cmake will conatain windows paths
# with backslashes. This is from the BUILD_PYTHON flag:
# see caffe2/CMakeLists.txt (near EOF):
#
# setup.py only has BUILD_LIBTORCH_WHL flag which sets BUILD_PYTHON=0
#
# cmake -D CMAKE_INSTALL_PREFIX=build/install -P build/cmake_install.cmake
#
# That works OK on mac, but of course on windows fails with:
#
#     running build_ext
#     -- Building with NumPy bindings
#     error: can't copy 'build/temp.win-amd64-cpython-312/Release/torch/csrc/_C.cp312-win_amd64.lib': doesn't exist or not a regular file
#
# The `python_sitelib_paths_fix.patch` fixes this.
#

"/c/Program Files/Git/usr/bin/patch" < ../vcmi-libtorch-builds/patches/python_sitelib_paths_fix.patch

. "${CONDA}/Scripts/activate"
conda create -y -n vcmi
conda activate vcmi
conda install -y cmake ninja rust
pip install -r requirements.txt
pip install mkl-static mkl-include

export \
  # BUILD_LIBTORCH_WHL=1 \
  # BUILD_LITE_INTERPRETER=1 \
  BUILD_TEST=0 \
  USE_CUDA=0
  # USE_CUDNN=0 \
  # USE_CUSPARSELT=0 \
  # USE_DISTRIBUTED=0 \
  # USE_GLOO=0 \
  # USE_KINETO=0 \
  # USE_LITE_INTERPRETER_PROFILER=0 \
  # USE_TENSORPIPE=0
  # USE_MPI=0 \
  # USE_MKLDNN=0

python setup.py develop
cmake -D CMAKE_INSTALL_PREFIX=install -P build/cmake_install.cmake

cd ..

TAR_FILE="${OUTPUT_ARCHIVE_FILE%.*}.tar"
7z a -ttar "${TAR_FILE}" "libtorch/*"
7z a -txz "$OUTPUT_ARCHIVE_FILE" "${TAR_FILE}"
