$ErrorActionPreference = 'Stop'
$p = Start-Process cmd `
  -ArgumentList '/c build-mc-trtrtx.cmd > build-mc-trtrtx.log 2>&1' `
  -WorkingDirectory 'C:\work\onnxruntime' `
  -WindowStyle Hidden `
  -PassThru
$p.Id | Out-File -Encoding ascii C:\work\onnxruntime\build-mc.pid
Write-Output ("DETACHED_PID=" + $p.Id)
