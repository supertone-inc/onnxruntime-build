#!/usr/bin/env bash

set -e

LIB_NAME=onnxruntime_webassembly_simd_threaded
OUTPUT_DIR=outputs/wasm-static-lib-simd-threaded
BUILD_OPTIONS="--enable_wasm_simd --enable_wasm_threads"

source ./build-wasm-static-lib.sh
