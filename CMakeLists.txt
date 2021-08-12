cmake_minimum_required(VERSION 3.20)
project(onnxruntime-build)

include(FetchContent)
set(FETCHCONTENT_QUIET OFF)

set(PROTOC_VERSION 3.16.0)
FetchContent_Declare(
    protoc
    URL https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip
)
FetchContent_MakeAvailable(protoc)
set(ONNX_CUSTOM_PROTOC_EXECUTABLE ${protoc_SOURCE_DIR}/bin/protoc)

FetchContent_Declare(
    gnu-toolchain
    URL https://developer.arm.com/-/media/Files/downloads/gnu-a/10.3-2021.07/binrel/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu.tar.xz
)
FetchContent_MakeAvailable(gnu-toolchain)
set(ENV{PATH} ${gnu-toolchain_SOURCE_DIR}/bin:$ENV{PATH})
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/tool.cmake)

FetchContent_Declare(
    onnxruntime
    GIT_REPOSITORY  https://github.com/microsoft/onnxruntime.git
    GIT_TAG         v${VERSION}
    GIT_SHALLOW     TRUE
    GIT_PROGRESS    TRUE
    SOURCE_SUBDIR   cmake
)
FetchContent_MakeAvailable(onnxruntime)
