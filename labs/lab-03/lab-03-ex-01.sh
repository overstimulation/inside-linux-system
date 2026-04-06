#!/usr/bin/env bash

set -euo pipefail

file_path="StudentsPerformance.csv"

if [ ! -f "${file_path}" ]; then
    echo "[ERROR] File not found: ${file_path}" >&2
    exit 1
fi

cleaned_data=$(tr -d '"' <"${file_path}")

echo -e "\n1) Liczba dziewcząt, która uzyskała wynik z matematyki powyżej 60:"
echo "${cleaned_data}" | awk -F',' '
    NR > 1 && $1 == "female" && $6 > 60 { count++ }
    END { print count }
'

echo -e "\n2) Średni wynik chłopców i dziewcząt z czytania:"
echo "${cleaned_data}" | awk -F',' '
    NR > 1 {
        if ($1 == "female") {
            f_sum += $7
            f_count++
        }
        if ($1 == "male") {
            m_sum += $7
            m_count++
        }
    }
    END {
        printf "- Dziewczęta: %.2f\n", f_sum / f_count
        printf "- Chłopcy: %.2f\n", m_sum / m_count
    }
'

echo -e "\n3) Najlepszy i najgorszy wynik (czytanie, pisanie) dla dziewcząt i chłopców:"
echo "${cleaned_data}" | awk -F',' '
    BEGIN {
        f_min_r = 999; f_max_r = -1; f_min_w = 999; f_max_w = -1
        m_min_r = 999; m_max_r = -1; m_min_w = 999; m_max_w = -1
    }
    NR > 1 {
        if ($1 == "female") {
            if ($7 > f_max_r) f_max_r = $7
            if ($7 < f_min_r) f_min_r = $7
            if ($8 > f_max_w) f_max_w = $8
            if ($8 < f_min_w) f_min_w = $8
        }
        if ($1 == "male") {
            if ($7 > m_max_r) m_max_r = $7
            if ($7 < m_min_r) m_min_r = $7
            if ($8 > m_max_w) m_max_w = $8
            if ($8 < m_min_w) m_min_w = $8
        }
    }
    END {
        print "--- Dziewczęta ---"
        print "Czytanie   -> min: " f_min_r ", max: " f_max_r
        print "Pisanie    -> min: " f_min_w ", max: " f_max_w
        print "--- Chłopcy ---"
        print "Czytanie   -> min: " m_min_r ", max: " m_max_r
        print "Pisanie    -> min: " m_min_w ", max: " m_max_w
    }
'

echo -e "\n4) Liczba chłopców, którzy uzyskali z matematyki, pisania lub czytania 100:"
echo "${cleaned_data}" | awk -F',' '
    NR > 1 && $1 == "male" && ($6 == 100 || $7 == 100 || $8 == 100) { count++ }
    END { print count }
'
