#!/usr/bin/env bash

set -e

SOURCE_DIR=$(pwd)/tests
BUILD_DIR=$SOURCE_DIR/build

CMAKE_OPTIONS="\
    -S $SOURCE_DIR \
    -B $BUILD_DIR \
    -D CMAKE_BUILD_TYPE=Release \
    $TEST_CMAKE_OPTIONS \
"

cmake $CMAKE_OPTIONS
cmake --build ${BUILD_DIR} --config Release --clean-first
ctest --test-dir ${BUILD_DIR} --verbose --no-tests=error
