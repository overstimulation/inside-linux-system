#!/usr/bin/env bash

set -euo pipefail

# UZASADNIENIE WYBORU:
# Wybrałem okno dialogowe typu inputbox, ponieważ zastąpienie sztywno zakodowanej ścieżki zapisu
# interaktywnym wejściem zwiększa elastyczność i uniwersalność skryptu względem pierwszej wersji.

if ! target_filepath=$(dialog --clear --title "Export System Info" \
    --inputbox "Enter target file path:" 8 50 3>&1 1>&2 2>&3); then
    exit 0
fi

if [ -n "${target_filepath}" ]; then
    if [ -d "${target_filepath}" ]; then
        target_filepath="${target_filepath%/}/ex-01-output.txt"
    fi

    {
        lscpu | grep "Model name:" | tr -s ' '
        echo "Kernel: $(uname -sr)"
        echo "Current user: $(whoami)"
        echo "Home directory: ${HOME}"
    } >"${target_filepath}"

    dialog --title "Success" --msgbox "[INFO] System information successfully exported to: ${target_filepath}" 8 50
else
    dialog --title "Error" --msgbox "[ERROR] No file selected." 8 50
fi

clear
