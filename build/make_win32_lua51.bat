mkdir build32 & pushd build32
cmake -DUSING_LUAJIT=OFF -G "Visual Studio 17 2022" -A Win32 ..
popd
cmake --build build32 --config Release
md plugin_lua51\Plugins\x86
copy /Y build32\Release\tolua.dll plugin_lua51\Plugins\x86\tolua.dll
pause