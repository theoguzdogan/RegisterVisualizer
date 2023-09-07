#!/bin/bash

# Read the message from message.txt
message=$(<../grmon_outs/grmon3_com.txt)
echo "$message"


while true; do
	echo -n "grmon3>"  # Print "Input: " without a newline character
	# Read input from the user
	read userInput
	
	if [ "$userInput" == "mem 0x040000AC 4" ]; then
		echo " 0x040000AC	48700807		G.."
	elif [ "$userInput" == "mem 0x06000500 4" ]; then
		echo " 0x06000500	00000400		...."
	elif [ "$userInput" == "mem 0x06000508 4" ]; then
		echo " 0x06000508	01002000		.. ."
	elif [ "$userInput" == "mem 0x80000024 4" ]; then
		echo " 0x80000024	00000003		...."
	else
		echo "invalid entry"
	fi
	
done

