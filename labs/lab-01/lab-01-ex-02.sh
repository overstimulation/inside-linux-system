#!/usr/bin/env bash

set -euo pipefail

output_file="ex-02-output.txt"

{
    lscpu | grep "Model name:" | tr -s ' '
    echo "Kernel: $(uname -sr)"
    echo "Current user: $(whoami)"
    echo "Home directory: ${HOME}"
} >"${output_file}"

echo "[INFO] System information successfully exported to: ${output_file}"
