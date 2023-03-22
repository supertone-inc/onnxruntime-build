#!/usr/bin/env bash

set -e

SOURCE_DIR=static-lib
BUILD_DIR=build/static-lib
OUTPUT_DIR=outputs/static-lib
ONNXRUNTIME_SOURCE_DIR=onnxruntime

case $(uname -s) in
Darwin)
    NUM_PARALLEL_JOBS=$(sysctl -n hw.physicalcpu)
    ;;
Linux)
    NUM_PARALLEL_JOBS=$(grep ^cpu\\scores /proc/cpuinfo | uniq | awk '{print $4}')
    ;;
*)
    NUM_PARALLEL_JOBS=$NUMBER_OF_PROCESSORS
    ;;
esac

git submodule update --init --recursive

cmake \
    -S $SOURCE_DIR \
    -B $BUILD_DIR \
    -D CMAKE_BUILD_TYPE=Release \
    -D ONNXRUNTIME_SOURCE_DIR=$ONNXRUNTIME_SOURCE_DIR
cmake --build $BUILD_DIR --config Release -j $NUM_PARALLEL_JOBS
cmake --install $BUILD_DIR --config Release --prefix $OUTPUT_DIR

cmake \
    -S $SOURCE_DIR/tests \
    -B $BUILD_DIR/tests \
    -D ONNXRUNTIME_SOURCE_DIR=$ONNXRUNTIME_SOURCE_DIR \
    -D ONNXRUNTIME_LIB_DIR=$OUTPUT_DIR/lib
cmake --build $BUILD_DIR/tests --clean-first
ctest --test-dir $BUILD_DIR/tests --verbose --no-tests=error
