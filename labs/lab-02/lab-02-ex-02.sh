#!/usr/bin/env bash

set -euo pipefail

if ! form_data=$(dialog --clear --title "Form" \
    --form "Enter your details:" 15 50 6 \
    "First Name:" 1 1 "" 1 15 30 0 \
    "Last Name:" 2 1 "" 2 15 30 0 \
    "Email Address:" 3 1 "" 3 15 30 0 \
    "Login:" 4 1 "" 4 15 30 0 \
    "Password:" 5 1 "" 5 15 30 0 \
    "Hobby:" 6 1 "" 6 15 30 0 \
    3>&1 1>&2 2>&3); then
    clear
    exit 0
fi

if ! target_filepath=$(dialog --clear --title "Save Location" \
    --inputbox "Enter target file path to append data:" 8 50 3>&1 1>&2 2>&3); then
    clear
    exit 0
fi

if [ -n "${target_filepath}" ]; then
    if [ -d "${target_filepath}" ]; then
        target_filepath="${target_filepath%/}/ex-02-output.txt"
    fi

    echo "${form_data}" >>"${target_filepath}"

    dialog --title "Success" --msgbox "[INFO] Data successfully appended to:\n${target_filepath}" 8 50
else
    dialog --title "Error" --msgbox "[ERROR] No file selected." 8 50
fi

clear
