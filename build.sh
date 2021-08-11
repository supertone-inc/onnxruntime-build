#!/bin/bash

# Reference: https://github.com/microsoft/onnxruntime/blob/v1.6.0/BUILD.md#cross-compiling-on-linux

BUILD_DIR=./build
INSTALL_DIR=./dist

git submodule update --init --recursive

export PATH="$(pwd)/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/bin:$PATH"

cmake \
    -S ./onnxruntime/cmake \
    -B $BUILD_DIR \
    -DONNX_CUSTOM_PROTOC_EXECUTABLE="$(pwd)/protoc-3.11.2-linux-x86_64/bin/protoc" \
    -DCMAKE_TOOLCHAIN_FILE="$(pwd)/tool.cmake" \
    -Donnxruntime_BUILD_SHARED_LIB=ON \
    -Donnxruntime_BUILD_UNIT_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=MinSizeRel

cmake --build $BUILD_DIR

cmake --install $BUILD_DIR --prefix $INSTALL_DIR
