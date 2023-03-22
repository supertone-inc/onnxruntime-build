cmake_minimum_required(VERSION 3.24)
project(tests)

enable_testing()

execute_process(COMMAND pwd OUTPUT_VARIABLE CURRENT_WORKING_DIRECTORY)
string(STRIP ${CURRENT_WORKING_DIRECTORY} CURRENT_WORKING_DIRECTORY)

get_filename_component(ONNXRUNTIME_SOURCE_DIR ${ONNXRUNTIME_SOURCE_DIR} REALPATH BASE_DIR ${CURRENT_WORKING_DIRECTORY})
get_filename_component(ONNXRUNTIME_LIB_DIR ${ONNXRUNTIME_LIB_DIR} REALPATH BASE_DIR ${CURRENT_WORKING_DIRECTORY})

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
