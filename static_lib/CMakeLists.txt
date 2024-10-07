cmake_minimum_required(VERSION 3.26)
project(onnxruntime_static_lib)

# Set default visibility
set(CMAKE_POLICY_DEFAULT_CMP0063 NEW)
set(CMAKE_C_VISIBILITY_PRESET hidden)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)

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

# Set ONNX Runtime options
set(onnxruntime_BUILD_SHARED_LIB ON)

# Suppress C++23 deprecation warnings
add_compile_definitions(_SILENCE_ALL_CXX23_DEPRECATION_WARNINGS)

# Add ONNX Runtime
add_subdirectory(${ONNXRUNTIME_SOURCE_DIR}/cmake onnxruntime EXCLUDE_FROM_ALL)

# Bundle the static library
include(bundle_static_library.cmake)
bundle_static_library(${PROJECT_NAME} onnxruntime)

# Install the static library
install(
    FILES $<TARGET_PROPERTY:onnxruntime,PUBLIC_HEADER>
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
