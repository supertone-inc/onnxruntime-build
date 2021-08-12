cmake_minimum_required(VERSION 3.20)
project(onnxruntime-build)

include(protoc.cmake)
set(ONNX_CUSTOM_PROTOC_EXECUTABLE ${protoc_SOURCE_DIR}/bin/protoc)

include(gnu-toolchain.cmake)
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/tool.cmake)

include(FetchContent)
set(FETCHCONTENT_QUIET OFF)
FetchContent_Declare(
    onnxruntime
    GIT_REPOSITORY  https://github.com/microsoft/onnxruntime.git
    GIT_TAG         v${VERSION}
    GIT_SHALLOW     TRUE
    GIT_PROGRESS    TRUE
    SOURCE_SUBDIR   cmake
)
FetchContent_MakeAvailable(onnxruntime)
