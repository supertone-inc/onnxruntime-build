cmake_minimum_required(VERSION 3.28)
project(onnxruntime_static_lib)

message(STATUS "ONNXRUNTIME_SOURCE_DIR: ${ONNXRUNTIME_SOURCE_DIR}")
message(STATUS "ONNXRUNTIME_BUILD_DIR: ${ONNXRUNTIME_BUILD_DIR}")

# Bundle static libraries
include(bundle_static_library.cmake)
bundle_static_library(${PROJECT_NAME} onnxruntime)

# Install the bundled static library
install(
    FILES ${ONNXRUNTIME_BUILD_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${PROJECT_NAME}${CMAKE_STATIC_LIBRARY_SUFFIX}
    RENAME ${CMAKE_STATIC_LIBRARY_PREFIX}onnxruntime${CMAKE_STATIC_LIBRARY_SUFFIX}
    TYPE LIB
)

# Install headers
install(
    FILES ${ONNXRUNTIME_SOURCE_DIR}/include/onnxruntime/core/session/onnxruntime_c_api.h
    DESTINATION ${CMAKE_INSTALL_PREFIX}/include
)
