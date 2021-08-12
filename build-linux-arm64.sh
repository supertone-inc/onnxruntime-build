#!/bin/bash

# Reference: https://onnxruntime.ai/docs/how-to/build/inferencing#cross-compiling-on-linux

set -e

VERSION=1.8.1
OS=linux
ARCH=arm64
BUILD_DIR=./build/onnxruntime-$OS-$ARCH
INSTALL_DIR=./dist/onnxruntime-$OS-$ARCH-$VERSION

cmake \
    -S . \
    -B $BUILD_DIR \
    -DVERSION=$VERSION \
    -Donnxruntime_BUILD_SHARED_LIB=ON \
    -Donnxruntime_BUILD_UNIT_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=MinSizeRel

cmake --build $BUILD_DIR

cmake --install $BUILD_DIR --prefix $INSTALL_DIR
