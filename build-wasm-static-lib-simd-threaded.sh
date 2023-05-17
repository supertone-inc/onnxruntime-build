#!/usr/bin/env bash

set -e

LIB_NAME=${LIB_NAME:=onnxruntime_webassembly_simd_threaded}
OUTPUT_DIR=${OUTPUT_DIR:=output/wasm-static-lib-simd-threaded}
BUILD_OPTIONS="--enable_wasm_simd --enable_wasm_threads $BUILD_OPTIONS"

source ./build-wasm-static-lib.sh
