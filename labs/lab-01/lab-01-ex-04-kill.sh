#!/usr/bin/env bash

set -euo pipefail

pid_file="endlessScript.pid"

if [ ! -f "${pid_file}" ]; then
    echo "[ERROR] PID file ${pid_file} not found. Is the loop script running?" >&2
    exit 1
fi

target_pid=$(cat "${pid_file}")

echo "[INFO] Found PID: ${target_pid}. Attempting to kill the process..."

if kill "${target_pid}"; then
    echo "[INFO] Process ${target_pid} successfully killed."
    rm -f "${pid_file}"
    echo "[INFO] Cleaned up ${pid_file}."
else
    echo "[ERROR] Failed to kill process ${target_pid}. It might have already exited." >&2
    exit 1
fi
