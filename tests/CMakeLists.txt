cmake_minimum_required(VERSION 3.24)
project(tests)

enable_testing()

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../onnxruntime/cmake/external/googletest external/googletest EXCLUDE_FROM_ALL)

add_executable(${PROJECT_NAME} test_main.cc test_inference.cc)

target_include_directories(${PROJECT_NAME} PRIVATE ${ONNXRUNTIME_DIR}/include)
target_link_directories(${PROJECT_NAME} PRIVATE ${ONNXRUNTIME_DIR}/lib)
target_link_libraries(${PROJECT_NAME} PRIVATE onnxruntime GTest::gtest)

if(WASM)
    set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "\
        -s ALLOW_MEMORY_GROWTH=1 \
        -s \"EXPORTED_RUNTIME_METHODS=['FS']\" \
        --preload-file ${CMAKE_CURRENT_SOURCE_DIR}/testdata@/testdata \
        -s EXIT_RUNTIME=1 \
    ")

    find_program(NODE_EXECUTABLE node required)

    if(NOT NODE_EXECUTABLE)
        message(FATAL_ERROR "Node is required for a test")
    endif()

    add_test(
        NAME ${PROJECT_NAME}
        COMMAND ${NODE_EXECUTABLE} ${PROJECT_NAME}.js
    )
else()
    add_test(
        NAME ${PROJECT_NAME}
        COMMAND ${PROJECT_NAME}
    )
endif()
