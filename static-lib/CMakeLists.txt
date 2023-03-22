cmake_minimum_required(VERSION 3.24)
project(onnxruntime_static_lib)

set(onnxruntime_BUILD_SHARED_LIB ON)

execute_process(COMMAND pwd OUTPUT_VARIABLE CURRENT_WORKING_DIRECTORY)
string(STRIP ${CURRENT_WORKING_DIRECTORY} CURRENT_WORKING_DIRECTORY)

get_filename_component(ONNXRUNTIME_SOURCE_DIR ${ONNXRUNTIME_SOURCE_DIR} REALPATH BASE_DIR ${CURRENT_WORKING_DIRECTORY})
file(STRINGS ${ONNXRUNTIME_SOURCE_DIR}/VERSION_NUMBER ONNXRUNTIME_VERSION)

add_subdirectory(${ONNXRUNTIME_SOURCE_DIR}/cmake onnxruntime EXCLUDE_FROM_ALL)
get_target_property(libraries onnxruntime LINK_LIBRARIES)
list(REMOVE_ITEM libraries
    dl
    Threads::Threads
    absl::inlined_vector
    absl::flat_hash_set
    absl::flat_hash_map
    absl::node_hash_set
    absl::node_hash_map
)

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
