#!/usr/bin/env bash

set -e

LIB_NAME=onnxruntime_webassembly_simd
OUTPUT_DIR=output/wasm-static-lib-simd
BUILD_OPTIONS=--enable_wasm_simd

source ./build-wasm-static-lib.sh
