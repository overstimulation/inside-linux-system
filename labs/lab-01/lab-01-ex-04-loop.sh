#!/usr/bin/env bash

set -euo pipefail

pid_file="endlessScript.pid"

echo $$ >"${pid_file}"
echo "[INFO] Loop started. Saved PID $$ to ${pid_file}."

while true; do
    echo "[INFO] Loop is running..."
    sleep 1
done
