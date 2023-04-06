#!/usr/bin/env bash

set -e

git submodule update --init --depth=1

SOURCE_DIR=static-lib
BUILD_DIR=build/static-lib
OUTPUT_DIR=output/static-lib
ONNXRUNTIME_SOURCE_DIR=onnxruntime
ONNXRUNTIME_VERSION=${ONNXRUNTIME_VERSION:=$(cat $ONNXRUNTIME_SOURCE_DIR/VERSION_NUMBER)}
CMAKE_OPTIONS=$CMAKE_OPTIONS
CMAKE_BUILD_OPTIONS=$CMAKE_BUILD_OPTIONS
PARALLEL_JOB_COUNT=$PARALLEL_JOB_COUNT

(
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
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_CONFIGURATION_TYPES=Release \
    -D CMAKE_INSTALL_PREFIX=$OUTPUT_DIR \
    -D ONNXRUNTIME_SOURCE_DIR=$(realpath $ONNXRUNTIME_SOURCE_DIR) \
    $CMAKE_OPTIONS
cmake \
    --build $BUILD_DIR \
    --config Release \
    --parallel $PARALLEL_JOB_COUNT \
    $CMAKE_BUILD_OPTIONS
cmake --install $BUILD_DIR --config Release

cmake \
    -S $SOURCE_DIR/tests \
    -B $BUILD_DIR/tests \
    -D ONNXRUNTIME_SOURCE_DIR=$(realpath $ONNXRUNTIME_SOURCE_DIR) \
    -D ONNXRUNTIME_LIB_DIR=$(realpath $OUTPUT_DIR/lib)
cmake --build $BUILD_DIR/tests
ctest --test-dir $BUILD_DIR/tests --build-config Debug --verbose --no-tests=error
