cmake_minimum_required(VERSION 3.28)
project(onnxruntime_static_lib)

# Hide symbols
set(C_HEADER_FILE ${ONNXRUNTIME_SOURCE_DIR}/include/onnxruntime/core/session/onnxruntime_c_api.h)
file(COPY_FILE ${C_HEADER_FILE} ${C_HEADER_FILE}.bak)
file(READ ${C_HEADER_FILE} C_HEADER_CONTENTS)
string(REPLACE "__attribute__((visibility(\"default\")))" "__attribute__((visibility(\"hidden\")))" MODIFIED_C_HEADER_CONTENTS "${C_HEADER_CONTENTS}")
file(WRITE ${C_HEADER_FILE} "${MODIFIED_C_HEADER_CONTENTS}")

# Set MSVC runtime library
set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded)
set(ONNX_USE_MSVC_STATIC_RUNTIME ON)
set(protobuf_MSVC_STATIC_RUNTIME ON)
set(ABSL_MSVC_STATIC_RUNTIME ON)

set(CMAKE_OSX_DEPLOYMENT_TARGET 13.4)

# Set ONNX Runtime options
set(onnxruntime_BUILD_SHARED_LIB OFF)
# Suppress C++23 deprecation warnings
add_compile_definitions(_SILENCE_ALL_CXX23_DEPRECATION_WARNINGS)

# Add ONNX Runtime
add_subdirectory(${ONNXRUNTIME_SOURCE_DIR}/cmake onnxruntime EXCLUDE_FROM_ALL)

# Prepare the library list for bundling
set(BUNDLE_LIBS
    onnxruntime_session
    onnxruntime_optimizer
    onnxruntime_providers
    onnxruntime_util
    onnxruntime_framework
    onnxruntime_graph
    onnxruntime_mlas
    onnxruntime_common
    onnxruntime_flatbuffers
    onnx_test_data_proto
    onnx
    onnx_proto
    libprotobuf-lite
    re2
    absl_base
    absl_throw_delegate
    absl_raw_hash_set
    absl_hash
    absl_city
    absl_low_level_hash
    cpuinfo
)

# Add architecture-specific MLAS libraries for universal builds
if(APPLE AND CMAKE_OSX_ARCHITECTURES)
    list(LENGTH CMAKE_OSX_ARCHITECTURES ARCH_COUNT)
    if(ARCH_COUNT GREATER 1)
        # This is a universal build, add architecture-specific MLAS libraries
        if("arm64" IN_LIST CMAKE_OSX_ARCHITECTURES AND TARGET onnxruntime_mlas_arm64)
            list(APPEND BUNDLE_LIBS onnxruntime_mlas_arm64)
            message(STATUS "Adding onnxruntime_mlas_arm64 to bundle")
        endif()
        if("x86_64" IN_LIST CMAKE_OSX_ARCHITECTURES AND TARGET onnxruntime_mlas_x86_64)
            list(APPEND BUNDLE_LIBS onnxruntime_mlas_x86_64)
            message(STATUS "Adding onnxruntime_mlas_x86_64 to bundle")
        endif()
    endif()
endif()

# Bundle the static library
include(bundle_static_library.cmake)
bundle_static_library(${PROJECT_NAME} ${BUNDLE_LIBS})

# Install the static library
install(
    FILES 
    ${ONNXRUNTIME_SOURCE_DIR}/include/onnxruntime/core/session/onnxruntime_c_api.h
    ${ONNXRUNTIME_SOURCE_DIR}/include/onnxruntime/core/session/onnxruntime_cxx_api.h
    ${ONNXRUNTIME_SOURCE_DIR}/include/onnxruntime/core/session/onnxruntime_float16.h
    ${ONNXRUNTIME_SOURCE_DIR}/include/onnxruntime/core/session/onnxruntime_cxx_inline.h
    TYPE INCLUDE
)
install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${PROJECT_NAME}${CMAKE_STATIC_LIBRARY_SUFFIX}
    RENAME ${CMAKE_STATIC_LIBRARY_PREFIX}onnxruntime${CMAKE_STATIC_LIBRARY_SUFFIX}
    TYPE LIB
)

# Restore the original header file
install(
    CODE "file(RENAME ${C_HEADER_FILE}.bak ${C_HEADER_FILE})"
)
