#!/usr/bin/env bash

set -e

OUTPUT_DIR_NAME=wasm-static-lib-simd
LIB_NAME=onnxruntime_webassembly_simd
BUILD_OPTIONS=--enable_wasm_simd

source ./build-wasm-static-lib.sh
