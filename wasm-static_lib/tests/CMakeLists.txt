cmake_minimum_required(VERSION 3.26)
project(tests)

add_executable(${PROJECT_NAME}
    ${ONNXRUNTIME_SOURCE_DIR}/onnxruntime/test/wasm/test_main.cc
    ${ONNXRUNTIME_SOURCE_DIR}/onnxruntime/test/wasm/test_inference.cc
)

set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "\
    -s ALLOW_MEMORY_GROWTH=1 \
    -s \"EXPORTED_RUNTIME_METHODS=['FS']\" \
    --preload-file ${ONNXRUNTIME_SOURCE_DIR}/onnxruntime/test/testdata@/testdata \
    -s EXIT_RUNTIME=1 \
")

include(FetchContent)
FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/519beb0e52c842729b4b53731d27c0e0c32ab4a2.zip
    FIND_PACKAGE_ARGS NAMES GTest
    URL_HASH SHA1=4b3c37972e4c1bef1185d46f702082f8772ee73f
)
FetchContent_MakeAvailable(googletest)
target_link_libraries(${PROJECT_NAME} GTest::gtest)

target_include_directories(${PROJECT_NAME} PRIVATE ${ONNXRUNTIME_SOURCE_DIR}/include/onnxruntime)
target_link_directories(${PROJECT_NAME} PRIVATE ${ONNXRUNTIME_LIB_DIR})
target_link_libraries(${PROJECT_NAME} onnxruntime)

enable_testing()
add_test(NAME ${PROJECT_NAME} COMMAND node ${PROJECT_NAME}.js)
