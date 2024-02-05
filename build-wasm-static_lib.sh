#!/usr/bin/env bash

set -e

BUILD_DIR=${BUILD_DIR:=build/wasm-static_lib}
OUTPUT_DIR=${OUTPUT_DIR:=output/wasm-static_lib}
ONNXRUNTIME_SOURCE_DIR=${ONNXRUNTIME_SOURCE_DIR:=onnxruntime}
ONNXRUNTIME_VERSION=${ONNXRUNTIME_VERSION:=$(cat ONNXRUNTIME_VERSION)}
EMSDK_DIR=${EMSDK_DIR:=$ONNXRUNTIME_SOURCE_DIR/cmake/external/emsdk}
BUILD_OPTIONS=$BUILD_OPTIONS

cd $(dirname $0)

(
    git submodule update --init --depth=1 $ONNXRUNTIME_SOURCE_DIR
    cd $ONNXRUNTIME_SOURCE_DIR
    if [ $ONNXRUNTIME_VERSION != $(cat VERSION_NUMBER) ]; then
        git fetch origin tag v$ONNXRUNTIME_VERSION
        git checkout v$ONNXRUNTIME_VERSION
    fi
    git submodule update --init --depth=1 --recursive
)

rm -f $BUILD_DIR/Release/libonnxruntime_webassembly.a

$ONNXRUNTIME_SOURCE_DIR/build.sh \
    --build_dir $BUILD_DIR \
    --config Release \
    --build_wasm_static_lib \
    --skip_tests \
    --disable_wasm_exception_catching \
    --disable_rtti \
    --parallel \
    $BUILD_OPTIONS

mkdir -p $OUTPUT_DIR/include
cp $ONNXRUNTIME_SOURCE_DIR/include/onnxruntime/core/session/*.h $OUTPUT_DIR/include

mkdir -p $OUTPUT_DIR/lib
cp $BUILD_DIR/Release/libonnxruntime_webassembly.a $OUTPUT_DIR/lib/libonnxruntime.a

case $(uname -s) in
Darwin | Linux) ;;
*) CMAKE_OPTIONS="-G Ninja" ;;
esac

cmake \
    -S wasm-static_lib/tests \
    -B $BUILD_DIR/tests \
    -D CMAKE_TOOLCHAIN_FILE=$(pwd)/$EMSDK_DIR/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake \
    -D ONNXRUNTIME_SOURCE_DIR=$(pwd)/$ONNXRUNTIME_SOURCE_DIR \
    -D ONNXRUNTIME_LIB_DIR=$(pwd)/$OUTPUT_DIR/lib \
    $CMAKE_OPTIONS
cmake --build $BUILD_DIR/tests
ctest --test-dir $BUILD_DIR/tests --verbose --no-tests=error
