#!/usr/bin/env bash

set -e

git submodule update --init --force --depth=1

LIB_NAME=${LIB_NAME:=onnxruntime_webassembly}
BUILD_DIR=build/wasm-static-lib
OUTPUT_DIR=${OUTPUT_DIR:=outputs/wasm-static-lib}
BUILD_OPTIONS="\
    --build_dir $BUILD_DIR \
    --config Release \
    --build_wasm_static_lib \
    --skip_tests \
    --disable_wasm_exception_catching \
    --disable_rtti \
    --parallel \
    $BUILD_OPTIONS \
"
ONNXRUNTIME_SOURCE_DIR=onnxruntime
ONNXRUNTIME_VERSION=${ONNXRUNTIME_VERSION:=$(cat $ONNXRUNTIME_SOURCE_DIR/VERSION_NUMBER)}
EMSDK_DIR=$ONNXRUNTIME_SOURCE_DIR/cmake/external/emsdk

(
    cd $ONNXRUNTIME_SOURCE_DIR

    if [ $ONNXRUNTIME_VERSION != $(cat VERSION_NUMBER) ]; then
        git fetch origin tag v$ONNXRUNTIME_VERSION
        git checkout v$ONNXRUNTIME_VERSION
    fi

    git submodule update --init --force --depth=1 --recursive
)

rm -f $BUILD_DIR/Release/libonnxruntime_webassembly.a

$ONNXRUNTIME_SOURCE_DIR/build.sh $BUILD_OPTIONS

mkdir -p $OUTPUT_DIR/include
cp $ONNXRUNTIME_SOURCE_DIR/include/onnxruntime/core/session/onnxruntime_c_api.h $OUTPUT_DIR/include
cp $ONNXRUNTIME_SOURCE_DIR/include/onnxruntime/core/session/onnxruntime_cxx_api.h $OUTPUT_DIR/include
cp $ONNXRUNTIME_SOURCE_DIR/include/onnxruntime/core/session/onnxruntime_cxx_inline.h $OUTPUT_DIR/include

mkdir -p $OUTPUT_DIR/lib
cp $BUILD_DIR/Release/libonnxruntime_webassembly.a $OUTPUT_DIR/lib/lib$LIB_NAME.$ONNXRUNTIME_VERSION.a
ln -sf lib$LIB_NAME.$ONNXRUNTIME_VERSION.a $OUTPUT_DIR/lib/libonnxruntime.a

case $(uname -s) in
Darwin | Linux) ;;
*) CMAKE_OPTIONS="-G Ninja" ;;
esac

cmake \
    -S wasm-static-lib/tests \
    -B $BUILD_DIR/tests \
    -D CMAKE_TOOLCHAIN_FILE=$(realpath $EMSDK_DIR/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake) \
    -D ONNXRUNTIME_SOURCE_DIR=$(realpath $ONNXRUNTIME_SOURCE_DIR) \
    -D ONNXRUNTIME_LIB_DIR=$(realpath $OUTPUT_DIR/lib) \
    $CMAKE_OPTIONS
cmake --build $BUILD_DIR/tests --clean-first
ctest --test-dir $BUILD_DIR/tests --verbose --no-tests=error
