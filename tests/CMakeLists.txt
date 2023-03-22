cmake_minimum_required(VERSION 3.24)
project(tests)

enable_testing()

execute_process(COMMAND pwd OUTPUT_VARIABLE CURRENT_WORKING_DIRECTORY)
string(STRIP ${CURRENT_WORKING_DIRECTORY} CURRENT_WORKING_DIRECTORY)

get_filename_component(ONNXRUNTIME_ROOT ${ONNXRUNTIME_ROOT} REALPATH BASE_DIR ${CURRENT_WORKING_DIRECTORY})
get_filename_component(ONNXRUNTIME_LIB_DIR ${ONNXRUNTIME_LIB_DIR} REALPATH BASE_DIR ${CURRENT_WORKING_DIRECTORY})

add_subdirectory(${ONNXRUNTIME_ROOT}/cmake/external/googletest external/googletest EXCLUDE_FROM_ALL)

add_executable(${PROJECT_NAME}
    ${ONNXRUNTIME_ROOT}/onnxruntime/test/wasm/test_main.cc
    ${ONNXRUNTIME_ROOT}/onnxruntime/test/wasm/test_inference.cc
)

target_include_directories(${PROJECT_NAME} PRIVATE ${ONNXRUNTIME_ROOT}/include/onnxruntime)
target_link_directories(${PROJECT_NAME} PRIVATE ${ONNXRUNTIME_LIB_DIR})
target_link_libraries(${PROJECT_NAME} onnxruntime GTest::gtest)

file(COPY ${ONNXRUNTIME_ROOT}/onnxruntime/test/testdata DESTINATION .)

if(WASM)
    set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "\
        -s ALLOW_MEMORY_GROWTH=1 \
        -s \"EXPORTED_RUNTIME_METHODS=['FS']\" \
        --preload-file ${CMAKE_CURRENT_BINARY_DIR}/testdata@/testdata \
        -s EXIT_RUNTIME=1 \
    ")

    find_program(NODE_EXECUTABLE node REQUIRED)

    if(NOT NODE_EXECUTABLE)
        message(FATAL_ERROR "Node is required for a test")
    endif()

    add_test(
        NAME ${PROJECT_NAME}
        COMMAND ${NODE_EXECUTABLE} ${PROJECT_NAME}.js
    )
else()
    if(UNIX AND NOT APPLE)
        target_link_libraries(${PROJECT_NAME} dl)
    endif()

    add_test(
        NAME ${PROJECT_NAME}
        COMMAND ${PROJECT_NAME}
    )
endif()
