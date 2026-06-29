@echo off
:: MC custom ORT build (STRIPPED): CUDA 12.8 + classic TensorRT 10.9 + TensorRT-RTX 1.4.0.76 + DirectML
:: Same EP set as build-mc-trtrtx.cmd, but with the transformer/LLM attention kernels that
:: Motion Catalyst never loads turned OFF. MC runs CNN pose/detection only (TRT-RTX, DML, CUDA
:: fallback); it does not use flash-attention, CUTLASS memory-efficient attention, or the FP8 KV
:: cache. Disabling them drops the flash_attention + cutlass_fmha object libraries from the
:: cuda provider build, saving roughly 3 hours of nvcc time per clean build.
::
:: Gotcha (why this is a separate recipe, not an incremental flag flip): these options feed
:: ORT_PROVIDER_FLAGS, which cmake applies as target_compile_definitions to EVERY cuda target
:: (cmake/CMakeLists.txt). Flipping them changes the compile-command hash of the MoE/cuda_llm
:: objects too, so toggling them on an existing build forces a full MoE recompile (~3.5h). Use
:: this recipe for a CLEAN build; do not flip these flags on a build produced by the full recipe.
::
:: NOTE: the MoE/cuda_llm GEMM kernels (the single largest build cost) have no clean on/off
:: switch in upstream cmake and are left enabled here. Removing them would need invasive source
:: gating (exclude kernels AND their contrib-op registration) and risks breaking a contrib op.
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
    onnxruntime_USE_FLASH_ATTENTION=OFF ^
    onnxruntime_USE_MEMORY_EFFICIENT_ATTENTION=OFF ^
    onnxruntime_USE_FP8_KV_CACHE=OFF ^
    onnxruntime_BUILD_UNIT_TESTS=OFF
echo BUILD_EXIT=%ERRORLEVEL%
:: onnxruntime_BUILD_UNIT_TESTS=OFF: --skip_tests only skips RUNNING ctest; the gtest target
:: onnxruntime_provider_test still builds and its nv_vulkan_test.cc references CUDA-13-only CIG
:: symbols (cudaDevAttrVulkanCigSupported, CIG_DATA_TYPE_NV_BLOB) absent in CUDA 12.8, breaking
:: the build. MC validates EPs via its own benchmarks/e2e, so ORT's gtest suite is not needed.
