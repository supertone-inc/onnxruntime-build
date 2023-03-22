cmake_minimum_required(VERSION 3.24)
project(tests)

enable_testing()

execute_process(COMMAND pwd OUTPUT_VARIABLE CURRENT_WORKING_DIRECTORY)
string(STRIP ${CURRENT_WORKING_DIRECTORY} CURRENT_WORKING_DIRECTORY)
get_filename_component(ONNXRUNTIME_DIR ${ONNXRUNTIME_DIR} REALPATH BASE_DIR ${CURRENT_WORKING_DIRECTORY})

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../onnxruntime/cmake/external/googletest external/googletest EXCLUDE_FROM_ALL)

add_executable(${PROJECT_NAME} test_main.cc test_inference.cc)

target_include_directories(${PROJECT_NAME} PRIVATE ${ONNXRUNTIME_DIR}/include)
target_link_directories(${PROJECT_NAME} PRIVATE ${ONNXRUNTIME_DIR}/lib)
target_link_libraries(${PROJECT_NAME} onnxruntime GTest::gtest)

if(WASM)
    set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "\
        -s ALLOW_MEMORY_GROWTH=1 \
        -s \"EXPORTED_RUNTIME_METHODS=['FS']\" \
        --preload-file ${CMAKE_CURRENT_SOURCE_DIR}/testdata@/testdata \
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

    file(COPY testdata DESTINATION .)

    add_test(
        NAME ${PROJECT_NAME}
        COMMAND ${PROJECT_NAME}
    )
endif()
