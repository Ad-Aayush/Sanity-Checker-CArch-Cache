#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'
# Check if file name is provided
if [ -z "$1" ]; then
    echo "Error: No file specified."
    exit 1
fi

file_name=$1
file_base=$(basename "$file_name")

# Check if file matches the expected naming convention
if echo "$file_base" | grep -Eq "^Lab7_[a-zA-Z]{2}[0-9]{2}BTECH[0-9]{5}\.zip$|^Lab7_[a-zA-Z]{2}[0-9]{2}BTECH[0-9]{5}_[a-zA-Z]{2}[0-9]{2}BTECH[0-9]{5}\.zip$"; then
    echo "File name is correct"
else
    echo "$(RED)Error$(NC): File name does not follow the Lab7_roll1_roll2.zip/Lab7_roll1.zip convention"
fi

# Run the Python script
echo "Running the final submission check on $file_name"
python3 test_public.py "$file_name" "true"
