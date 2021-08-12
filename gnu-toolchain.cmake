include(FetchContent)

set(FETCHCONTENT_QUIET OFF)

FetchContent_Declare(
    gnu-toolchain
    URL https://developer.arm.com/-/media/Files/downloads/gnu-a/10.3-2021.07/binrel/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu.tar.xz
)

FetchContent_MakeAvailable(gnu-toolchain)

set(ENV{PATH} ${gnu-toolchain_SOURCE_DIR}/bin:$ENV{PATH})
