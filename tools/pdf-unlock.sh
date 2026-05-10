#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: $0 <password> <file.pdf> [file2.pdf ...]"
    exit 1
fi

PASSWORD="$1"
shift

for file in "$@"; do
    if [ ! -f "$file" ]; then
        echo "Fichier non trouvé: $file"
        continue
    fi

    output="${file%.pdf}_unlocked.pdf"

    if qpdf --decrypt --password="$PASSWORD" "$file" "$output" 2>/dev/null; then
        echo "OK: $output"
    else
        echo "Erreur: $file (mauvais mot de passe ou fichier non protégé)"
    fi
done
