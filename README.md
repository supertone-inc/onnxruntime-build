# ONNX Runtime Custom Build

This project is to build custom [ONNX Runtime](https://onnxruntime.ai) libraries which are not provided in [the official releases](https://github.com/microsoft/onnxruntime/releases).

Currently supports static library builds only with the default options.

## Building Libraries

### Prerequisites

- [Requirements for building ONNX Runtime for inferencing](https://onnxruntime.ai/docs/build/inferencing.html#prerequisites) (for native build)
- [Requirements for building ONNX Runtime for Web](https://onnxruntime.ai/docs/build/inferencing.html#prerequisites) (for Wasm build)
- Bash
  - On Windows, you can use Git Bash provided by [Git for Windows](https://git-scm.com/download/win).
- `realpath`
  - On macOS under 13, it can be installed via `brew install coreutils`.

### Build Scripts

Build for native:

```sh
./build-static-lib.sh
```

Build for Wasm:

```sh
./build-wasm-static-lib.sh
./build-wasm-static-lib-simd.sh # with SIMD support
./build-wasm-static-lib-threaded.sh # with multi-thread support
./build-wasm-static-lib-simd-threaded.sh # with SIMD and multi-thread support
```
