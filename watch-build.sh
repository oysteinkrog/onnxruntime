#!/bin/bash
# Tolerant ORT build watcher. Exits 0 on BUILD_EXIT (build done), exits 3 on a
# genuine hang (no compiler process alive AND log flat for many polls). The heavy
# MoE/flash-attention CUDA kernels legitimately take 10-40 min each single-threaded,
# so a flat log alone is NOT a stall — only a flat log WITH no live cicc/nvcc/cl is.
LOG=/c/work/onnxruntime/build-mc-trtrtx.log
prev_size=0
flat_dead=0
for i in $(seq 1 360); do   # 360 * 90s = up to 9h
  if grep -aq "BUILD_EXIT" "$LOG" 2>/dev/null; then
    echo "DONE $(grep -a BUILD_EXIT "$LOG" | tail -1)"
    ls -la /c/work/onnxruntime/build/Windows/RelWithDebInfo/RelWithDebInfo/onnxruntime.dll 2>/dev/null
    exit 0
  fi
  size=$(stat -c %s "$LOG" 2>/dev/null || echo 0)
  alive=$(cmd.exe /c "wmic process where (name='cicc.exe' or name='nvcc.exe' or name='cl.exe' or name='ptxas.exe' or name='link.exe' or name='cudafe++.exe') get ProcessId" 2>/dev/null | grep -cE "[0-9]")
  if [ "$size" = "$prev_size" ] && [ "$alive" -le 1 ]; then
    flat_dead=$((flat_dead+1))
  else
    flat_dead=0
  fi
  prev_size=$size
  if [ "$flat_dead" -ge 5 ]; then
    echo "STALL: log flat ($size) and no compiler alive for 5 polls"
    tail -3 "$LOG"
    exit 3
  fi
  sleep 90
done
echo "TIMEOUT after 9h"
exit 4
