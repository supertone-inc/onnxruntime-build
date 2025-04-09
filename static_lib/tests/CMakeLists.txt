cmake_minimum_required(VERSION 3.28)
project(tests)

set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded)

add_executable(${PROJECT_NAME} test_inference.cc)

include(FetchContent)
FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/519beb0e52c842729b4b53731d27c0e0c32ab4a2.zip
    FIND_PACKAGE_ARGS NAMES GTest
    URL_HASH SHA1=4b3c37972e4c1bef1185d46f702082f8772ee73f
)
FetchContent_MakeAvailable(googletest)
target_link_libraries(${PROJECT_NAME} GTest::gtest_main)

target_include_directories(${PROJECT_NAME} PRIVATE ${ONNXRUNTIME_INCLUDE_DIR})
target_link_directories(${PROJECT_NAME} PRIVATE ${ONNXRUNTIME_LIB_DIR})
target_link_libraries(${PROJECT_NAME} onnxruntime)

if(APPLE)
    target_link_libraries(${PROJECT_NAME} "-framework Foundation")
elseif(UNIX)
    target_link_libraries(${PROJECT_NAME} dl)
endif()

enable_testing()
add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME} WORKING_DIRECTORY ${ONNXRUNTIME_SOURCE_DIR}/onnxruntime/test)
