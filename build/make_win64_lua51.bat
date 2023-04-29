mkdir build64 & pushd build64
cmake -DUSING_LUAJIT=OFF -G "Visual Studio 17 2022" -A x64 ..
popd
cmake --build build64 --config Release
md plugin_lua51\Plugins\x86_64
copy /Y build64\Release\tolua.dll plugin_lua51\Plugins\x86_64\tolua.dll
pause