#!/usr/bin/env bash

set -euo pipefail

if ! src_dir=$(dialog --clear --title "Source Directory" --dselect "$PWD/" 10 60 3>&1 1>&2 2>&3); then
    clear
    exit 0
fi

if [ ! -d "${src_dir}" ]; then
    dialog --title "Error" --msgbox "[ERROR] Source does not exist: ${src_dir}" 8 50
    clear
    exit 1
fi

file_list=()
for f in "${src_dir}"/*; do
    if [ -f "$f" ]; then
        file_list+=("$(basename "$f")" "" "off")
    fi
done

if [ ${#file_list[@]} -eq 0 ]; then
    dialog --title "Error" --msgbox "[ERROR] No files found in ${src_dir}." 8 50
    clear
    exit 1
fi

if ! selected=$(dialog --clear --title "Select Files" --separate-output \
    --checklist "Choose files to copy:" 15 60 10 "${file_list[@]}" 3>&1 1>&2 2>&3); then
    clear
    exit 0
fi

if [ -z "${selected}" ]; then
    dialog --title "Error" --msgbox "[ERROR] No files selected." 8 50
    clear
    exit 1
fi

if ! dest_dir=$(dialog --clear --title "Destination Directory" --dselect "$PWD/" 10 60 3>&1 1>&2 2>&3); then
    clear
    exit 0
fi

mkdir -p "${dest_dir}"

mapfile -t selected_array <<<"${selected}"
total=${#selected_array[@]}

(
    current=0
    for file in "${selected_array[@]}"; do
        cp "${src_dir}/${file}" "${dest_dir}/"
        current=$((current + 1))
        echo $((current * 100 / total))
        sleep 0.3
    done
) | dialog --clear --title "Copying Files" --gauge "Progress..." 8 50

dialog --title "Success" --msgbox "[INFO] Files successfully copied to ${dest_dir}." 8 50
clear
