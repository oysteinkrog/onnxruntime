@echo off
set MSB="C:\Program Files\Microsoft Visual Studio\2022\Community\Msbuild\Current\Bin\amd64\MSBuild.exe"
%MSB% C:\work\onnxruntime\build\Windows\RelWithDebInfo\onnxruntime_providers_nv_tensorrt_rtx.vcxproj /p:Configuration=RelWithDebInfo /p:Platform=x64 /m /v:minimal /nologo
echo MSBUILD_EXIT=%ERRORLEVEL%
