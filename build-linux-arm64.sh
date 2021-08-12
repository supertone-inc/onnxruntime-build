#!/bin/bash

# Reference: https://github.com/microsoft/onnxruntime/blob/v1.6.0/BUILD.md#cross-compiling-on-linux

VERSION=1.6.0
OS=linux
ARCH=arm64
CLONE_DIR=./onnxruntime-$VERSION
BUILD_DIR=./build/onnxruntime-$OS-$ARCH-$VERSION
INSTALL_DIR=./dist/onnxruntime-$OS-$ARCH-$VERSION

export PATH="$(pwd)/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/bin:$PATH"

git clone --branch v$VERSION --single-branch --recursive --shallow-submodules https://github.com/Microsoft/onnxruntime $CLONE_DIR

cmake \
    -S $CLONE_DIR/cmake \
    -B $BUILD_DIR \
    -DONNX_CUSTOM_PROTOC_EXECUTABLE="$(pwd)/protoc-3.11.2-linux-x86_64/bin/protoc" \
    -DCMAKE_TOOLCHAIN_FILE="$(pwd)/tool.cmake" \
    -Donnxruntime_BUILD_SHARED_LIB=ON \
    -Donnxruntime_BUILD_UNIT_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=MinSizeRel

cmake --build $BUILD_DIR

cmake --install $BUILD_DIR --prefix $INSTALL_DIR
