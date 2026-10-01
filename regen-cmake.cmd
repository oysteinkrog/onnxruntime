@echo off
cd /d C:\work\onnxruntime\build\Windows\RelWithDebInfo
"C:\Program Files\CMake\bin\cmake.exe" .
echo CMAKE_EXIT=%ERRORLEVEL%
