#!/bin/bash

# Read the message from message.txt
message=$(<../grmon_outs/grmon2_com.txt)
echo "$message"


while true; do
	stdbuf -o0 echo -n "grmon2>"  # Print "Input: " without a newline character
    # Read input from the user
    read userInput

    if [[ $userInput == "mem"* ]]; then
        # Split the input into space-separated parts
        read -a inputParts <<< "$userInput"
        
        # Check if the input has at least three parts
        if [ "${#inputParts[@]}" -ge 3 ]; then
            keyword="${inputParts[0]}"
            searchString="${inputParts[1]}"
            clearString=$(tr -d '\n' <<< "$searchString")
            
            # Search for lines starting with the search string in the file
            memory="../registers/scoc3.txt"
            result=$(grep "^$clearString" "$memory")

            if [ -n "$result" ]; then
                echo "$result"
            fi
        fi
    elif [[ $userInput == "wmem"* ]]; then
        # Split the "wmem" input into space-separated parts
        read -a inputParts <<< "$userInput"
        
        # Check if the input has at least three parts
        if [ "${#inputParts[@]}" -ge 3 ]; then
            keyword="${inputParts[0]}"
            address="${inputParts[1]}"
            newString="${inputParts[2]}"
            
            # Update the file using awk to find and modify the line
            memory="../registers/scoc3.txt"
            awk -v address="$address" -v newString="$newString" '
                BEGIN { FS = OFS = "\t" }
                $1 == address { $2 = newString; }
                { print; }
            ' "$memory" > "$memory.tmp" && mv "$memory.tmp" "$memory"
        fi
    fi
done
