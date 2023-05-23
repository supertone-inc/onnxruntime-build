cmake_minimum_required(VERSION 3.24)
project(onnxruntime_static_lib)

set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded)
set(ONNX_USE_MSVC_STATIC_RUNTIME ON)
set(protobuf_MSVC_STATIC_RUNTIME ON)
set(onnxruntime_BUILD_SHARED_LIB ON)

add_subdirectory(${ONNXRUNTIME_SOURCE_DIR}/cmake onnxruntime EXCLUDE_FROM_ALL)
get_target_property(libraries onnxruntime LINK_LIBRARIES)

string(REPLACE ";" "\n" libraries_newline_separated "${libraries}")
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/libraries.txt "${libraries_newline_separated}")

list(REMOVE_ITEM libraries
    dl
    Threads::Threads
    absl::inlined_vector
    absl::flat_hash_set
    absl::flat_hash_map
    absl::node_hash_set
    absl::node_hash_map
    $<$<CONFIG:DEBUG>:Dbghelp>

    # v1.14.1
    rt
    WIL::WIL
    nlohmann_json::nlohmann_json
    Boost::mp11
    safeint_interface
    Microsoft.GSL::GSL
    date_interface
)

string(REPLACE ";" "\n" libraries_newline_separated "${libraries}")
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/libraries_filtered.txt "${libraries_newline_separated}")

include(bundle_static_library.cmake)
bundle_static_library(${PROJECT_NAME} ${libraries})

install(
    FILES
    ${ONNXRUNTIME_SOURCE_DIR}/include/onnxruntime/core/session/onnxruntime_c_api.h
    ${ONNXRUNTIME_SOURCE_DIR}/include/onnxruntime/core/session/onnxruntime_cxx_api.h
    ${ONNXRUNTIME_SOURCE_DIR}/include/onnxruntime/core/session/onnxruntime_cxx_inline.h
    DESTINATION include
)

if(UNIX)
    file(STRINGS ${ONNXRUNTIME_SOURCE_DIR}/VERSION_NUMBER ONNXRUNTIME_VERSION)
    install(
        FILES ${CMAKE_CURRENT_BINARY_DIR}/lib${PROJECT_NAME}.a
        RENAME libonnxruntime.${ONNXRUNTIME_VERSION}.a
        DESTINATION lib
    )
    install(CODE "execute_process( \
        COMMAND ${CMAKE_COMMAND} -E create_symlink \
        libonnxruntime.${ONNXRUNTIME_VERSION}.a \
        ${CMAKE_INSTALL_PREFIX}/lib/libonnxruntime.a \
    )")
else()
    install(
        FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.lib
        RENAME onnxruntime.lib
        DESTINATION lib
    )
endif()
