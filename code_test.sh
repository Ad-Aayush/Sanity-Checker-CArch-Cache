#!/bin/bash

# Check if file name is provided
if [ -z "$1" ]; then
    echo "Error: No file specified."
    exit 1
fi

file_name=$1
file_base=$(basename "$file_name")

# Run the Python script
echo "Running the code functioning check on $file_name"
python3 test_public.py "$file_name"
