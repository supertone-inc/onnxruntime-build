#!/usr/bin/env bash

set -e

OUTPUT_DIR_NAME=static-lib
BUILD_DIR=build
OUTPUT_DIR=$(pwd)/outputs/$OUTPUT_DIR_NAME

case $(uname -s) in
Darwin)
    OS="MacOS"
    NUM_PARALLEL_JOBS=$(sysctl -n hw.physicalcpu)
    ;;
Linux)
    OS="Linux"
    NUM_PARALLEL_JOBS=$(grep ^cpu\\scores /proc/cpuinfo | uniq |  awk '{print $4}')
    ;;
*)
    OS="Windows"
    NUM_PARALLEL_JOBS=$NUMBER_OF_PROCESSORS
    ;;
esac

git submodule update --init --recursive

cmake -S . -B $BUILD_DIR -D CMAKE_BUILD_TYPE=Release
cmake --build $BUILD_DIR --config Release -j $NUM_PARALLEL_JOBS
cmake --install $BUILD_DIR --config Release --prefix $OUTPUT_DIR

TEST_CMAKE_OPTIONS="\
    -D ONNXRUNTIME_DIR=$OUTPUT_DIR \
    -U WASM \
    -U CMAKE_TOOLCHAIN_FILE \
"
source ./test.sh
