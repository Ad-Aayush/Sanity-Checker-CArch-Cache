#!/bin/bash

# Check if file name is provided
if [ -z "$1" ]; then
    echo "Error: No file specified."
    exit 1
fi

file_name=$1
file_base=$(basename "$file_name")

# Check if file matches the expected naming convention
if echo "$file_base" | grep -Eq "^Lab4_[a-zA-Z]{2}[0-9]{2}BTECH[0-9]{5}\.zip$|^Lab4_[a-zA-Z]{2}[0-9]{2}BTECH[0-9]{5}_[a-zA-Z]{2}[0-9]{2}BTECH[0-9]{5}\.zip$"; then
    echo "File name is correct"
else
    echo "Error: File name does not follow the Lab4_roll1_roll2.zip convention"
    exit 1
fi

# Run the Python script
echo "Running the code functioning check on $file_name"
python3 test_public.py "$file_name"
