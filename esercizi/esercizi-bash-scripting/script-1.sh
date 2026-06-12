#!/usr/bin/env bash

while true; do
    read -p "Inserire il file da controllare: " file
    if [ -f "$file" ] && [ -s "$file" ]; then
        risultato=$(sort "$file" | uniq -dc | sort -k1 -k2 -nr | head -n 3)
        echo "I tre indirizzi IP più frequenti sono: "
        echo "$risultato"
        exit 0
    else
        echo  "Inserire un file valido"
    fi
done 