rem
rem XXX: building libtorch from source produces a huge binary
rem      (2.5G), regardless of CMAKE_BUILD_TYPE=Release
rem      => better to just download the official pre-compiled libtorch
rem

mkdir install
%CONDA%\condabin\activate.bat
conda create -y -n vcmi
conda activate simo
conda install -y cmake ninja rust
pip install -r requirements.txt
pip install mkl-static mkl-include

rem fix from https://github.com/pytorch/pytorch/pull/136489 (not yet merged)
pip uninstall setuptools
pip install setuptools==72.1.0

set USE_CUDA=0
set USE_CUDNN=0
set USE_CUSPARSELT=0
rem set USE_KINETO=0
set BUILD_TEST=0
set USE_DISTRIBUTED=0
set USE_TENSORPIPE=0
set USE_GLOO=0
rem set USE_MPI=0
rem set USE_MKLDNN=0
set BUILD_LITE_INTERPRETER=1

call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x64
python setup.py develop

rem debug
dir build
dir torch
dir lib

cmake -D CMAKE_INSTALL_PREFIX=build\install -P build\cmake_install.cmake

cd ..

rem replace .txz with .tar

if not "%ARCHIVE_FILE:~-4%" == ".txz" (
  echo Expected ARCHIVE_FILE to end with .txz: %ARCHIVE_FILE% >&2
  exit /b 1
)

set TAR_FILE="%ARCHIVE_FILE:~0,-4%.tar"
7z a -ttar "%TAR_FILE%" "%PYTORCH_DIR%\build\install\*"
7z a -txz "%ARCHIVE_FILE%" "%TAR_FILE%"
