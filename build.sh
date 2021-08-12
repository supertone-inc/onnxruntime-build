#!/bin/bash

# Reference: https://onnxruntime.ai/docs/how-to/build/inferencing#cross-compiling-on-linux

set -e

BUILD_DIR=./build

cmake -S . -B $BUILD_DIR
cmake --build $BUILD_DIR
cmake --install $BUILD_DIR
