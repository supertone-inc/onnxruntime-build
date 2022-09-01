#!/usr/bin/env bash

set -e

BUILD_DIR=./build/emscripten-wasm32
INCLUDE_DIR=$BUILD_DIR/include
LIB_DIR=$BUILD_DIR/lib

OS=$(uname -s)

if [ "$OS" = "Darwin" ]; then
    DIR_OS="MacOS"
else
    DIR_OS="Linux"
fi

rm -f ./onnxruntime/build/$DIR_OS/Release/libonnxruntime_webassembly.a

./onnxruntime/cmake/external/emsdk/emsdk install latest
./onnxruntime/cmake/external/emsdk/emsdk activate latest
source ./onnxruntime/cmake/external/emsdk/emsdk_env.sh

./onnxruntime/build.sh \
    --config Release \
    --build_wasm_static_lib \
    --skip_tests \
    --disable_wasm_exception_catching \
    --disable_rtti \
    --parallel \
    --enable_wasm_threads

mkdir -p $INCLUDE_DIR
mkdir -p $LIB_DIR

cp ./onnxruntime/include/onnxruntime/core/session/onnxruntime_c_api.h $INCLUDE_DIR
cp ./onnxruntime/include/onnxruntime/core/session/onnxruntime_cxx_api.h $INCLUDE_DIR
cp ./onnxruntime/include/onnxruntime/core/session/onnxruntime_cxx_inline.h $INCLUDE_DIR
cp ./onnxruntime/build/$DIR_OS/Release/libonnxruntime_webassembly.a $LIB_DIR/libonnxruntime_webassembly_threaded.a
