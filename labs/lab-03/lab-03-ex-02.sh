#!/usr/bin/env bash

set -euo pipefail

file_path="StudentsPerformance.csv"
backup_path="${file_path}.bak"

if [ ! -f "${file_path}" ]; then
    echo "[ERROR] File not found: ${file_path}" >&2
    exit 1
fi

if [ ! -f "${backup_path}" ]; then
    cp "${file_path}" "${backup_path}"
    echo "[INFO] Backup successfully created at: ${backup_path}"
else
    cp "${backup_path}" "${file_path}"
    echo "[INFO] Original file successfully restored from: ${backup_path}"
fi

sed -i 's/"female"/"0"/g ; s/"male"/"1"/g' "${file_path}"
echo "[INFO] Successfully replaced 'female' and 'male' with 0 and 1."

sed -i 's/"none"/"0"/g' "${file_path}"
echo "[INFO] Successfully replaced 'none' with 0."

sed -i 's/"group /"/g' "${file_path}"
echo "[INFO] Successfully removed 'group ' prefix."
