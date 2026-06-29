@echo off
:: MC custom ORT build: CUDA 12.8 + classic TensorRT 10.9 + TensorRT-RTX 1.4.0.76 + DirectML
:: Reproduces the 1.26-dev-trtrtx EP set on the v1.27.0 + DML-mutex-fix branch.
setlocal
cd /d C:\work\onnxruntime
call build.bat ^
  --config RelWithDebInfo ^
  --parallel 2 ^
  --nvcc_threads 1 ^
  --build_shared_lib ^
  --skip_tests ^
  --skip_submodule_sync ^
  --cmake_generator "Visual Studio 17 2022" ^
  --use_dml ^
  --use_cuda ^
  --cuda_home "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8" ^
  --cudnn_home "C:\work\sdk\CUDNN\v9.8" ^
  --use_tensorrt ^
  --tensorrt_home "C:\work\sdk\TensorRT\TensorRT-10.9.0.34" ^
  --use_nv_tensorrt_rtx ^
  --tensorrt_rtx_home "C:\work\sdk\TensorRT-RTX\TensorRT-RTX-1.4.0.76" ^
  --cmake_extra_defines ^
    onnxruntime_BUILD_UNIT_TESTS=OFF
echo BUILD_EXIT=%ERRORLEVEL%
:: NOTE: onnxruntime_BUILD_UNIT_TESTS=OFF is required, not just --skip_tests. --skip_tests
:: only skips RUNNING ctest; the gtest target onnxruntime_provider_test still builds and its
:: nv_vulkan_test.cc references CUDA-13-only CIG symbols (cudaDevAttrVulkanCigSupported,
:: CIG_DATA_TYPE_NV_BLOB) that CUDA 12.8 lacks, breaking the build. MC validates EPs via its
:: own benchmarks/e2e, so ORT's gtest suite is not needed here.
