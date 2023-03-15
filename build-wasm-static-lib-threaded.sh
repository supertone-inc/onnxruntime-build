#!/usr/bin/env bash

set -e

OUTPUT_DIR_NAME=wasm-static-lib-threaded
LIB_NAME=onnxruntime_webassembly_threaded
BUILD_OPTIONS=--enable_wasm_threads

source $(pwd)/build-wasm-static-lib.sh
