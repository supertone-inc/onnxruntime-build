#!/usr/bin/env bash

set -e

SOURCE_DIR=${SOURCE_DIR:=static_lib}
BUILD_DIR=${BUILD_DIR:=build/static_lib}
OUTPUT_DIR=${OUTPUT_DIR:=output/static_lib}
ONNXRUNTIME_SOURCE_DIR=${ONNXRUNTIME_SOURCE_DIR:=onnxruntime}
ONNXRUNTIME_VERSION=${ONNXRUNTIME_VERSION:=$(cat ONNXRUNTIME_VERSION)}
CMAKE_OPTIONS=$CMAKE_OPTIONS

cd $(dirname $0)

# Update and build ONNX Runtime
(
    git submodule update --init --depth=1 $ONNXRUNTIME_SOURCE_DIR
    cd $ONNXRUNTIME_SOURCE_DIR
    if [ $ONNXRUNTIME_VERSION != $(cat VERSION_NUMBER) ]; then
        git fetch origin tag v$ONNXRUNTIME_VERSION
        git checkout v$ONNXRUNTIME_VERSION
    fi
    git submodule update --init --depth=1 --recursive
)

./onnxruntime/build.sh --config Release --parallel --minimal_build --skip_tests --cmake_extra_defines CMAKE_INSTALL_PREFIX=$OUTPUT_DIR $CMAKE_OPTIONS

# Bundle static libraries
ONNXRUNTIME_BUILD_DIR=$(pwd)/onnxruntime/build/Release
cmake \
    -S $SOURCE_DIR \
    -B $BUILD_DIR \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=$OUTPUT_DIR \
    -D ONNXRUNTIME_SOURCE_DIR=$(pwd)/$ONNXRUNTIME_SOURCE_DIR \
    -D ONNXRUNTIME_BUILD_DIR=$ONNXRUNTIME_BUILD_DIR

cmake --install $BUILD_DIR --config Release

# cmake \
#     -S $SOURCE_DIR/tests \
#     -B $BUILD_DIR/tests \
#     -D ONNXRUNTIME_SOURCE_DIR=$(pwd)/$ONNXRUNTIME_SOURCE_DIR \
#     -D ONNXRUNTIME_INCLUDE_DIR=$(pwd)/$OUTPUT_DIR/include \
#     -D ONNXRUNTIME_LIB_DIR=$(pwd)/$OUTPUT_DIR/lib
# cmake --build $BUILD_DIR/tests
# ctest --test-dir $BUILD_DIR/tests --build-config Debug --verbose --no-tests=error
