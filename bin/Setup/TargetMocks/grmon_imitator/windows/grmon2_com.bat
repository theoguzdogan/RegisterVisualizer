@echo off

:: Read the message from message.txt
set /p message=<..\grmon_outs\grmon2_com.txt
echo %message%

:input_loop
set /p userInput=grmon2> 

if "%userInput%"=="mem 0x040000AC 4" (
    echo 0x040000AC	48700807		G..
) elseif "%userInput%"=="mem 0x06000500 4" (
    echo 0x06000500	00000400		....
) elseif "%userInput%"=="mem 0x06000508 4" (
    echo 0x06000508	01002000		.. .
) elseif "%userInput%"=="mem 0x80000024 4" (
    echo 0x80000024	00000003		....
) else (
    echo invalid entry
)

goto input_loop
