#!/usr/bin/env bash

set -e

OUTPUT_DIR_NAME=wasm-static-lib-simd-threaded
LIB_NAME=onnxruntime_webassembly_simd_threaded
BUILD_OPTIONS="--enable_wasm_simd --enable_wasm_threads"

source ./build-wasm-static-lib.sh
