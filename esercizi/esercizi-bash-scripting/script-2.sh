#!/bin/bash

read -p "Immettere il file con la lista di server e utilizzo di CPU: " file
echo ””
if [[ ! -f "$file" || ! -s "$file" ]]; then
    echo -e "Il file non esiste o è vuoto \v"
    exit 1
fi

while read -r col1 col2 col3; do
    if [[ -z "$col1" || ! "$col2" =~ ^[0-9]+$ || -n "$col3" ]]; then
        echo -e "Il file non è valido \v"
        exit 1
    fi
done < "$file"

declare -A som_cpu
declare -A occ

while read -r server cpu; do
    som_cpu["$server"]=$(( som_cpu["$server"] += cpu ))
    occ["$server"]=$(( occ["$server"] += 1 ))
done < "$file"

echo -e "=== REPORT UTILIZZO MEDIO CPU === \v"

for server in "${!som_cpu[@]}"; do
    media=$(( som_cpu["$server"] / occ["$server"] ))
    echo -e "$server: $media \v"
done
