#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./fixbank.sh filename.csv"
    exit 1
fi

for file in "$@"; do
    echo "Processing $file..."
    # Using Python's robust cp932 decoder with 'ignore' for stray bytes
    python3 -c "import sys; data = open(sys.argv[1], 'rb').read(); print(data.decode('cp932', errors='ignore'))" "$file" > "UTF8_$file"

    if [ $? -eq 0 ]; then
        echo "✅ Created UTF8_$file"
    else
        echo "❌ Failed to convert $file"
    fi
done

