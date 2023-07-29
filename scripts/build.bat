SET PATH=%PATH%;C:\msys64\mingw64\bin\

mkdir %~dp0..\build\

cmake ^
-DCMAKE_PREFIX_PATH:STRING=C:/msys64/mingw64/lib/cmake/ ^
-DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE ^
-DCMAKE_BUILD_TYPE:STRING=Release ^
-DCMAKE_CXX_COMPILER:FILEPATH=C:/msys64/mingw64/bin/g++.exe ^
-S%~dp0..\ ^
-B%~dp0..\build\ ^
-G "MinGW Makefiles"

set /a coreCount=%NUMBER_OF_PROCESSORS% + 2
cmake ^
--build %~dp0..\build\ ^
--config Release ^
--target all ^
-j %coreCount% --