#!/usr/bin/env bash

set -e

git submodule update --init --recursive

SOURCE_DIR=static-lib
BUILD_DIR=build/static-lib
OUTPUT_DIR=outputs/static-lib
ONNXRUNTIME_SOURCE_DIR=onnxruntime

case $(uname -s) in
Darwin) CPU_COUNT=$(sysctl -n hw.physicalcpu) ;;
Linux) CPU_COUNT=$(grep ^cpu\\scores /proc/cpuinfo | uniq | awk '{print $4}') ;;
*) CPU_COUNT=$NUMBER_OF_PROCESSORS ;;
esac

cmake \
    -S $SOURCE_DIR \
    -B $BUILD_DIR \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_CONFIGURATION_TYPES=Release \
    -D CMAKE_INSTALL_PREFIX=$OUTPUT_DIR \
    -D ONNXRUNTIME_SOURCE_DIR=$(realpath $ONNXRUNTIME_SOURCE_DIR)
cmake --build $BUILD_DIR --config Release --parallel $CPU_COUNT
cmake --install $BUILD_DIR --config Release

cmake \
    -S $SOURCE_DIR/tests \
    -B $BUILD_DIR/tests \
    -D ONNXRUNTIME_SOURCE_DIR=$(realpath $ONNXRUNTIME_SOURCE_DIR) \
    -D ONNXRUNTIME_LIB_DIR=$(realpath $OUTPUT_DIR/lib)
cmake --build $BUILD_DIR/tests --clean-first
ctest --test-dir $BUILD_DIR/tests --build-config Debug --verbose --no-tests=error
