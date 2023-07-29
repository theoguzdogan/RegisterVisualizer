SET PATH=%PATH%;C:\msys64\mingw64\bin\

cmake --build ./build --config Debug --target clean

rm -rf %~dp0..\build\
rm -rf %~dp0..\.cache\
rm -rf %~dp0..\bin\RegisterVisualizer.exe