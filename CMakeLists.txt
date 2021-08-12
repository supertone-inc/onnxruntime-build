cmake_minimum_required(VERSION 3.20)
project(onnxruntime-build)

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
