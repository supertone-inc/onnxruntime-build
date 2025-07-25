#!/usr/bin/env bash

set -e

SOURCE_DIR=${SOURCE_DIR:=static_lib}
BUILD_CONFIG=${BUILD_CONFIG:=Release}
BUILD_DIR=${BUILD_DIR:=build/static_lib}
OUTPUT_DIR=${OUTPUT_DIR:=output/static_lib/$BUILD_CONFIG}
ONNXRUNTIME_SOURCE_DIR=${ONNXRUNTIME_SOURCE_DIR:=onnxruntime}
ONNXRUNTIME_VERSION=${ONNXRUNTIME_VERSION:=$(cat ONNXRUNTIME_VERSION)}
CMAKE_OPTIONS=$CMAKE_OPTIONS

cd $(dirname $0)

(
    git submodule update --init --depth=1 $ONNXRUNTIME_SOURCE_DIR
    cd $ONNXRUNTIME_SOURCE_DIR
    if [ $ONNXRUNTIME_VERSION != $(cat VERSION_NUMBER) ]; then
        git fetch origin tag v$ONNXRUNTIME_VERSION
        git checkout v$ONNXRUNTIME_VERSION
    fi
    git submodule update --init --depth=1 --recursive
)

cmake \
    -S $SOURCE_DIR \
    -B $BUILD_DIR \
    -D CMAKE_BUILD_TYPE=$BUILD_CONFIG \
    -D CMAKE_CONFIGURATION_TYPES=$BUILD_CONFIG \
    -D CMAKE_INSTALL_PREFIX=$OUTPUT_DIR \
    -D ONNXRUNTIME_SOURCE_DIR=$(pwd)/$ONNXRUNTIME_SOURCE_DIR \
    --compile-no-warning-as-error \
    $CMAKE_OPTIONS
cmake \
    --build $BUILD_DIR \
    --config $BUILD_CONFIG \
    -j4
    
cmake --install $BUILD_DIR --config $BUILD_CONFIG

cmake \
    -S $SOURCE_DIR/tests \
    -B $BUILD_DIR/tests \
    -D CMAKE_BUILD_TYPE=$BUILD_CONFIG \
    -D CMAKE_CONFIGURATION_TYPES=$BUILD_CONFIG \
    -D ONNXRUNTIME_SOURCE_DIR=$(pwd)/$ONNXRUNTIME_SOURCE_DIR \
    -D ONNXRUNTIME_INCLUDE_DIR=$(pwd)/$OUTPUT_DIR/include \
    -D ONNXRUNTIME_LIB_DIR=$(pwd)/$OUTPUT_DIR/lib
cmake --build $BUILD_DIR/tests --config $BUILD_CONFIG
ctest --test-dir $BUILD_DIR/tests --build-config $BUILD_CONFIG --verbose --no-tests=error