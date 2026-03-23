#!/usr/bin/env bash

set -euo pipefail

function print_hd() {
    echo "=== Free Disk Space ==="
    df -h
}

function print_ram() {
    echo "=== Free Memory ==="
    free -h
}

function print_cpu() {
    echo "=== CPU Information ==="
    lscpu
}

if [ "$#" -lt 1 ]; then
    echo "[ERROR] Missing arguments." >&2
    echo "Usage: $0 [-hd] [-ram] [-cpu] [-all]" >&2
    exit 1
fi

for arg in "$@"; do
    case "${arg}" in
    -hd)
        print_hd
        ;;
    -ram)
        print_ram
        ;;
    -cpu)
        print_cpu
        ;;
    -all)
        print_hd
        print_ram
        print_cpu
        ;;
    *)
        echo "[ERROR] Unknown argument: ${arg}" >&2
        echo "Available arguments: -hd, -ram, -cpu, -all" >&2
        exit 1
        ;;
    esac
done
