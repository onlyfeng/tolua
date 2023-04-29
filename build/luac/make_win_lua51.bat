mkdir build64_51 & pushd build64_51
cmake -G "Visual Studio 17 2022" -A x64 ..
popd
cmake --build build64_51 --config Release
md bin_lua51\64
copy /Y build64_51\Release\lua.exe bin_lua51\64\lua.exe
copy /Y build64_51\Release\luac.exe bin_lua51\64\luac.exe

mkdir build32_51 & pushd build32_51
cmake -G "Visual Studio 17 2022" -A Win32 ..
popd
cmake --build build32_51 --config Release
md bin_lua51\32
copy /Y build32_51\Release\lua.exe bin_lua51\32\lua.exe
copy /Y build32_51\Release\luac.exe bin_lua51\32\luac.exe

pause