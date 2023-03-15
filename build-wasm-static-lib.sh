#!/usr/bin/env bash

set -e

OUTPUT_DIR_NAME=${OUTPUT_DIR_NAME:=wasm-sataic-lib}
LIB_NAME=${LIB_NAME:=onnxruntime_webassembly}
BUILD_OPTIONS="\
    --config Release \
    --build_wasm_static_lib \
    --skip_tests \
    --disable_wasm_exception_catching \
    --disable_rtti \
    --parallel \
    $BUILD_OPTIONS \
"

OUTPUT_DIR=$(pwd)/outputs/$OUTPUT_DIR_NAME
INCLUDE_DIR=$OUTPUT_DIR/include
LIB_DIR=$OUTPUT_DIR/lib

ONNXRUNTIME_SOURCE_DIR=$(pwd)/onnxruntime
EMSDK_DIR=$ONNXRUNTIME_SOURCE_DIR/cmake/external/emsdk

case $(uname -s) in
Darwin)
    OS="MacOS"
    ;;
*)
    OS="Linux"
    ;;
esac

$EMSDK_DIR/emsdk install latest
$EMSDK_DIR/emsdk activate latest
source $EMSDK_DIR/emsdk_env.sh

rm -f $ONNXRUNTIME_SOURCE_DIR/build/$OS/Release/libonnxruntime_webassembly.a

$ONNXRUNTIME_SOURCE_DIR/build.sh $BUILD_OPTIONS

mkdir -p $INCLUDE_DIR
cp $ONNXRUNTIME_SOURCE_DIR/include/onnxruntime/core/session/onnxruntime_c_api.h $INCLUDE_DIR
cp $ONNXRUNTIME_SOURCE_DIR/include/onnxruntime/core/session/onnxruntime_cxx_api.h $INCLUDE_DIR
cp $ONNXRUNTIME_SOURCE_DIR/include/onnxruntime/core/session/onnxruntime_cxx_inline.h $INCLUDE_DIR

mkdir -p $LIB_DIR
cp $ONNXRUNTIME_SOURCE_DIR/build/$OS/Release/libonnxruntime_webassembly.a $LIB_DIR/lib$LIB_NAME.a
ln -sf lib$LIB_NAME.a $LIB_DIR/libonnxruntime.a
