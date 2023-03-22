cmake_minimum_required(VERSION 3.24)
project(tests)

enable_testing()

add_subdirectory(${ONNXRUNTIME_SOURCE_DIR}/cmake/external/googletest external/googletest EXCLUDE_FROM_ALL)

add_executable(${PROJECT_NAME}
    ${ONNXRUNTIME_SOURCE_DIR}/onnxruntime/test/wasm/test_main.cc
    ${ONNXRUNTIME_SOURCE_DIR}/onnxruntime/test/wasm/test_inference.cc
)

target_include_directories(${PROJECT_NAME} PRIVATE ${ONNXRUNTIME_SOURCE_DIR}/include/onnxruntime)
target_link_directories(${PROJECT_NAME} PRIVATE ${ONNXRUNTIME_LIB_DIR})
target_link_libraries(${PROJECT_NAME} onnxruntime GTest::gtest)

file(COPY ${ONNXRUNTIME_SOURCE_DIR}/onnxruntime/test/testdata DESTINATION .)

if(UNIX AND NOT APPLE)
    target_link_libraries(${PROJECT_NAME} dl)
endif()

add_test(
    NAME ${PROJECT_NAME}
    COMMAND ${PROJECT_NAME}
)
