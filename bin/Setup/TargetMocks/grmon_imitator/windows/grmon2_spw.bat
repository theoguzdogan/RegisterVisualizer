@echo off
setlocal enabledelayedexpansion

:: Read the message from message.txt
for /f "usebackq delims=" %%a in ("..\grmon_outs\grmon2_spw.txt") do set "message=%%a"
echo !message!

:loop
set /p "userInput=grmon2> "

:: Check if userInput starts with "mem"
if "!userInput:~0,3!" == "mem" (
    :: Split userInput into space-separated parts
    for /f "tokens=1,2,*" %%a in ("!userInput!") do (
        set "keyword=%%a"
        set "searchString=%%b"
        
        :: Check if the input has at least three parts
        if "%%c" neq "" (
            set "searchString=!searchString:~0,-1!"
            
            :: Search for lines starting with the search string in the file
            set "memory=..\registers\scoc3.txt"
            
            for /f "tokens=*" %%l in ('findstr /b /c:"!searchString!" "!memory!"') do (
                echo %%l
            )
        )
    )
) else if "!userInput:~0,4!" == "wmem" (
    :: Split the "wmem" input into space-separated parts
    for /f "tokens=1,2,3,*" %%a in ("!userInput!") do (
        set "keyword=%%a"
        set "address=%%b"
        set "newString=%%c"
        
        :: Check if the input has at least three parts
        if "%%d" neq "" (
            set "address=!address:~0,-1!"
            
            :: Update the file using PowerShell to find and modify the line
            set "memory=..\registers\scoc3.txt"
            powershell -command "(Get-Content '""!memory!'"') | ForEach-Object { $_ -replace ('^' + '!address!' + '	'), ('!address!' + '	' + '!newString!') } | Set-Content '""!memory!'"'"
        )
    )
)

goto loop
