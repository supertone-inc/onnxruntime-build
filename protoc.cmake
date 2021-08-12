include(FetchContent)

set(FETCHCONTENT_QUIET OFF)

set(PROTOC_VERSION 3.16.0)

FetchContent_Declare(
    protoc
    URL https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip
)

FetchContent_MakeAvailable(protoc)
