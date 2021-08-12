#!/bin/bash

# Reference: https://github.com/microsoft/onnxruntime/blob/v1.7.0/BUILD.md#Cross-compiling-on-Linux

set -e

VERSION=1.7.0
OS=linux
ARCH=arm64
BUILD_DIR=./build/onnxruntime-$OS-$ARCH
INSTALL_DIR=./dist/onnxruntime-$OS-$ARCH-$VERSION
PATH="$(pwd)/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/bin:$PATH"

cmake \
    -S . \
    -B $BUILD_DIR \
    -DVERSION=$VERSION \
    -DONNX_CUSTOM_PROTOC_EXECUTABLE="$(pwd)/protoc-3.11.2-linux-x86_64/bin/protoc" \
    -DCMAKE_TOOLCHAIN_FILE="$(pwd)/tool.cmake" \
    -Donnxruntime_BUILD_SHARED_LIB=ON \
    -Donnxruntime_BUILD_UNIT_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=MinSizeRel

cmake --build $BUILD_DIR

cmake --install $BUILD_DIR --prefix $INSTALL_DIR
