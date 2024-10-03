#!/bin/bash

# XXX: building on windows via a bash script succeeds, but
#      the resulting `cmake` install command fails with syntax error:
#           C:\Miniconda\Lib\site-packages/caffe2
#           Invalid escape sequence \M
#      Also, given the size of the built library is probably huge
#      (see comment in win-x64.build.bat)
#       => better to just download the official pre-compiled libtorch

set -eux

curl -sL -o libtorch.zip https://download.pytorch.org/libtorch/cpu/libtorch-win-shared-with-deps-2.4.1%2Bcpu.zip
unzip libtorch.zip
TAR_FILE="${ARCHIVE_FILE%.*}.tar"
7z a -ttar "${TAR_FILE}" "libtorch/*"
7z a -txz "$ARCHIVE_FILE" "${TAR_FILE}"
