import os
import time

# Read the message from message.txt
with open('../../grmon_outs/grmon3_com.txt', 'r') as file:
    message = file.read()
print(message)
time.sleep(3)

while True:
    userInput = input("grmon3>")  # Print "Input: " without a newline character
    
    if userInput.startswith("mem"):
        # Split the input into space-separated parts
        inputParts = userInput.split()
        
        # Check if the input has at least three parts
        if len(inputParts) >= 3:
            keyword = inputParts[0]
            searchString = inputParts[1]
            
            # Search for lines starting with the search string in the file
            memory = "../../registers/scoc3.txt"
            with open(memory, 'r') as file:
                lines = file.readlines()
                result = [line for line in lines if line.startswith(searchString)]
            
            if result:
                print(''.join(result))
    
    elif userInput.startswith("wmem"):
        # Split the "wmem" input into space-separated parts
        inputParts = userInput.split()
        
        # Check if the input has at least three parts
        if len(inputParts) >= 3:
            keyword = inputParts[0]
            address = inputParts[1]
            newString = inputParts[2].replace("0x", "")
            
            # Update the file by finding and modifying the line
            memory = "../../registers/scoc3.txt"
            with open(memory, 'r') as file:
                lines = file.readlines()
            
            with open(memory, 'w') as file:
                isFound = False
                for line in lines:
                    if line.startswith(address):
                        isFound = True
                        file.write(f"{address}\t{newString}\t....\n")
                    else:
                        file.write(line)
                if not isFound:
                    file.write(f"{address}\t{newString}\t....\n")
