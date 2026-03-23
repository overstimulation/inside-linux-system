#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -lt 1 ]; then
    echo "[ERROR] Missing arguments." >&2
    echo "Usage: $0 <action> [arguments...]" >&2
    echo "Available actions: create-file, create-dir, delete, copy, move" >&2
    exit 1
fi

action="$1"

case "${action}" in
create-file)
    if [ "$#" -ne 2 ]; then
        echo "[ERROR] Usage: $0 create-file <file_name>" >&2
        exit 1
    fi
    mkdir -p "$(dirname "$2")"
    touch "$2"
    echo "[INFO] Successfully created file: $2"
    ;;
create-dir)
    if [ "$#" -ne 2 ]; then
        echo "[ERROR] Usage: $0 create-dir <directory_path>" >&2
        exit 1
    fi
    mkdir -p "$2"
    echo "[INFO] Successfully created directory path: $2"
    ;;
delete)
    if [ "$#" -ne 2 ]; then
        echo "[ERROR] Usage: $0 delete <target>" >&2
        exit 1
    fi
    rm -rf "$2"
    echo "[INFO] Successfully deleted: $2"
    ;;
copy)
    if [ "$#" -ne 3 ]; then
        echo "[ERROR] Usage: $0 copy <source> <destination>" >&2
        exit 1
    fi
    cp -r "$2" "$3"
    echo "[INFO] Successfully copied $2 to $3"
    ;;
move)
    if [ "$#" -ne 3 ]; then
        echo "[ERROR] Usage: $0 move <source> <destination>" >&2
        exit 1
    fi
    mv "$2" "$3"
    echo "[INFO] Successfully moved $2 to $3"
    ;;
*)
    echo "[ERROR] Unknown action: ${action}" >&2
    echo "Available actions: create-file, create-dir, delete, copy, move" >&2
    exit 1
    ;;
esac
