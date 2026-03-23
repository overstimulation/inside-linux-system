#!/usr/bin/env bash

set -euo pipefail

function replace_text() {
    if [ "$#" -ne 2 ]; then
        echo "[ERROR] Usage: replace_text <search_pattern> <replacement_string>" >&2
        echo "Note: This function expects input from stdin." >&2
        return 1
    fi

    sed "s|$1|$2|g"
}

replace_text "$@"
