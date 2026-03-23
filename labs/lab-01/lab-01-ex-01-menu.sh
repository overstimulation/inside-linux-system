#!/usr/bin/env bash

set -euo pipefail

while true; do
    if ! choice=$(dialog --clear --title "File Manager" \
        --menu "Choose an action:" 15 50 5 \
        1 "Create File" \
        2 "Create Directory" \
        3 "Delete" \
        4 "Copy" \
        5 "Move" 3>&1 1>&2 2>&3); then
        break
    fi

    case "${choice}" in
    1)
        if ! filepath=$(dialog --clear --title "Create File" --inputbox "Enter file path:" 8 50 3>&1 1>&2 2>&3); then
            continue
        fi
        if [ -n "${filepath}" ]; then
            mkdir -p "$(dirname "${filepath}")"
            touch "${filepath}"
            dialog --title "Success" --msgbox "[INFO] Successfully created file: ${filepath}" 8 50
        fi
        ;;
    2)
        if ! dirpath=$(dialog --clear --title "Create Directory" --inputbox "Enter directory path:" 8 50 3>&1 1>&2 2>&3); then
            continue
        fi
        if [ -n "${dirpath}" ]; then
            mkdir -p "${dirpath}"
            dialog --title "Success" --msgbox "[INFO] Successfully created directory path: ${dirpath}" 8 50
        fi
        ;;
    3)
        if ! target=$(dialog --clear --title "Delete" --inputbox "Enter target path to delete:" 8 50 3>&1 1>&2 2>&3); then
            continue
        fi
        if [ -n "${target}" ]; then
            if [ ! -e "${target}" ]; then
                dialog --title "Error" --msgbox "[ERROR] Path does not exist: ${target}" 8 50
            else
                rm -rf "${target}"
                dialog --title "Success" --msgbox "[INFO] Successfully deleted: ${target}" 8 50
            fi
        fi
        ;;
    4)
        if ! source_path=$(dialog --clear --title "Copy (Source)" --inputbox "Enter source path:" 8 50 3>&1 1>&2 2>&3); then
            continue
        fi
        if [ -n "${source_path}" ]; then
            if [ ! -e "${source_path}" ]; then
                dialog --title "Error" --msgbox "[ERROR] Source does not exist: ${source_path}" 8 50
            else
                if ! dest_path=$(dialog --clear --title "Copy (Destination)" --inputbox "Enter destination path:" 8 50 3>&1 1>&2 2>&3); then
                    continue
                fi
                if [ -n "${dest_path}" ]; then
                    cp -r "${source_path}" "${dest_path}"
                    dialog --title "Success" --msgbox "[INFO] Successfully copied ${source_path} to ${dest_path}" 8 50
                fi
            fi
        fi
        ;;
    5)
        if ! source_path=$(dialog --clear --title "Move (Source)" --inputbox "Enter source path:" 8 50 3>&1 1>&2 2>&3); then
            continue
        fi
        if [ -n "${source_path}" ]; then
            if [ ! -e "${source_path}" ]; then
                dialog --title "Error" --msgbox "[ERROR] Source does not exist: ${source_path}" 8 50
            else
                if ! dest_path=$(dialog --clear --title "Move (Destination)" --inputbox "Enter destination path:" 8 50 3>&1 1>&2 2>&3); then
                    continue
                fi
                if [ -n "${dest_path}" ]; then
                    mv "${source_path}" "${dest_path}"
                    dialog --title "Success" --msgbox "[INFO] Successfully moved ${source_path} to ${dest_path}" 8 50
                fi
            fi
        fi
        ;;
    esac
done

clear
