cmake_minimum_required(VERSION 3.20)
project(onnxruntime-build)

include(gnu-toolchain.cmake)
include(protoc.cmake)

set(ONNX_RUNTIME_VERSION 1.8.1)

set(ONNX_CUSTOM_PROTOC_EXECUTABLE ${protoc_SOURCE_DIR}/bin/protoc)
set(onnxruntime_BUILD_SHARED_LIB ON)
set(onnxruntime_BUILD_UNIT_TESTS OFF)
set(BUILD_PKGCONFIG_FILES OFF)

set(CMAKE_BUILD_TYPE MinSizeRel)
set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/dist/onnxruntime-linux-arm64-${ONNX_RUNTIME_VERSION})
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/tool.cmake)

include(FetchContent)
set(FETCHCONTENT_QUIET OFF)
FetchContent_Declare(
    onnxruntime
    GIT_REPOSITORY  https://github.com/microsoft/onnxruntime.git
    GIT_TAG         v${ONNX_RUNTIME_VERSION}
    GIT_SHALLOW     TRUE
    GIT_PROGRESS    TRUE
    SOURCE_SUBDIR   cmake
)
FetchContent_MakeAvailable(onnxruntime)
