#!/usr/bin/env bash

set -e

git submodule update --init --depth=1

SOURCE_DIR=static-lib
BUILD_DIR=build/static-lib
OUTPUT_DIR=outputs/static-lib
ONNXRUNTIME_SOURCE_DIR=onnxruntime
ONNXRUNTIME_VERSION=${ONNXRUNTIME_VERSION:=$(cat $ONNXRUNTIME_SOURCE_DIR/VERSION_NUMBER)}

(
    cd $ONNXRUNTIME_SOURCE_DIR

    if [ $ONNXRUNTIME_VERSION != $(cat VERSION_NUMBER) ]; then
        git fetch origin tag v$ONNXRUNTIME_VERSION
        git checkout v$ONNXRUNTIME_VERSION
    fi

    git submodule update --init --depth=1 --recursive
)

case $(uname -s) in
Darwin)
    CPU_COUNT=$(sysctl -n hw.physicalcpu)
    CMAKE_BUILD_OPTIONS="--parallel $CPU_COUNT"
    ;;
Linux)
    CPU_COUNT=$(grep ^cpu\\scores /proc/cpuinfo | uniq | awk '{print $4}')
    CMAKE_BUILD_OPTIONS="--parallel $CPU_COUNT"
    ;;
*)
    CPU_COUNT=$NUMBER_OF_PROCESSORS
    CMAKE_BUILD_OPTIONS="-- /maxcpucount:$CPU_COUNT /nodeReuse:False"
    ;;
esac

cmake \
    -S $SOURCE_DIR \
    -B $BUILD_DIR \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_CONFIGURATION_TYPES=Release \
    -D CMAKE_INSTALL_PREFIX=$OUTPUT_DIR \
    -D ONNXRUNTIME_SOURCE_DIR=$(realpath $ONNXRUNTIME_SOURCE_DIR)
cmake --build $BUILD_DIR --config Release $CMAKE_BUILD_OPTIONS
cmake --install $BUILD_DIR --config Release

cmake \
    -S $SOURCE_DIR/tests \
    -B $BUILD_DIR/tests \
    -D ONNXRUNTIME_SOURCE_DIR=$(realpath $ONNXRUNTIME_SOURCE_DIR) \
    -D ONNXRUNTIME_LIB_DIR=$(realpath $OUTPUT_DIR/lib)
cmake --build $BUILD_DIR/tests
ctest --test-dir $BUILD_DIR/tests --build-config Debug --verbose --no-tests=error
