#!/usr/bin/env bash

set -euo pipefail

max_scale=2147483647

while true; do
    if ! choice=$(dialog --clear --title "Math Toolkit" \
        --menu "Select operation:" 15 50 3 \
        1 "Calculate Polynomial Roots" \
        2 "Calculate Pi" \
        3 "Calculate Golden Ratio" 3>&1 1>&2 2>&3); then
        break
    fi

    if ! scale=$(dialog --clear --title "Precision" \
        --inputbox "Enter decimal precision (max: ${max_scale}):" 8 50 3>&1 1>&2 2>&3); then
        continue
    fi

    if [[ ! "${scale}" =~ ^[0-9]+$ ]] || [ "${scale}" -gt "${max_scale}" ]; then
        dialog --title "Error" --msgbox "[ERROR] Precision must be a valid number (0 - ${max_scale})." 8 60
        continue
    fi

    case "${choice}" in
    1)
        if ! a=$(dialog --clear --title "Coefficient" --inputbox "Enter coefficient a (cannot be 0):" 8 50 3>&1 1>&2 2>&3); then continue; fi

        if [[ ! "${a}" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            dialog --title "Error" --msgbox "[ERROR] Coefficient 'a' must be a valid number." 8 50
            continue
        fi

        if [ "$(echo "${a} == 0" | bc -l)" -eq 1 ]; then
            dialog --title "Error" --msgbox "[ERROR] Coefficient 'a' cannot be 0." 8 50
            continue
        fi

        if ! b=$(dialog --clear --title "Coefficient" --inputbox "Enter coefficient b:" 8 50 3>&1 1>&2 2>&3); then continue; fi

        if [[ ! "${b}" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            dialog --title "Error" --msgbox "[ERROR] Coefficient 'b' must be a valid number." 8 50
            continue
        fi

        if ! c=$(dialog --clear --title "Coefficient" --inputbox "Enter coefficient c:" 8 50 3>&1 1>&2 2>&3); then continue; fi

        if [[ ! "${c}" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            dialog --title "Error" --msgbox "[ERROR] Coefficient 'c' must be a valid number." 8 50
            continue
        fi

        delta=$(echo "($b)*($b) - 4*($a)*($c)" | bc -l)
        is_negative=$(echo "${delta} < 0" | bc -l)

        if [ "${is_negative}" -eq 1 ]; then
            result="Delta is negative. No real roots."
        else
            x1=$(echo "scale=${scale}; (-($b) - sqrt(${delta})) / (2*($a))" | bc -l)
            x2=$(echo "scale=${scale}; (-($b) + sqrt(${delta})) / (2*($a))" | bc -l)
            result="Roots:\nx1 = ${x1}\nx2 = ${x2}"
        fi
        ;;
    2)
        val=$(echo "scale=${scale}; 4 * a(1)" | bc -l)
        result="Pi calculated to ${scale} decimal places: ${val}"
        ;;
    3)
        val=$(echo "scale=${scale}; (1 + sqrt(5)) / 2" | bc -l)
        result="Golden Ratio calculated to ${scale} decimal places: ${val}"
        ;;
    esac

    dialog --title "Result" --msgbox "${result}" 12 55
done

clear
