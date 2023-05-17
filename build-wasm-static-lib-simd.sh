#!/usr/bin/env bash

set -e

LIB_NAME=${LIB_NAME:=onnxruntime_webassembly_simd}
OUTPUT_DIR=${OUTPUT_DIR:=output/wasm-static-lib-simd}
BUILD_OPTIONS="--enable_wasm_simd $BUILD_OPTIONS"

source ./build-wasm-static-lib.sh
