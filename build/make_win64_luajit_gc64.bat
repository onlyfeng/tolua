@echo off
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

echo Swtich to x64 build env
cd %~dp0\luajit2\src
call msvcbuild_mt.bat static
cd ..\..

mkdir build_lj64 & pushd build_lj64
cmake -DUSING_LUAJIT=ON -G "Visual Studio 17 2022" -A x64 ..
IF %ERRORLEVEL% NEQ 0 cmake -DUSING_LUAJIT=ON -G "Visual Studio 17 2022" -A x64 ..
popd
cmake --build build_lj64 --config Release
md plugin_luajit\Plugins\x86_64
copy /Y build_lj64\Release\tolua.dll plugin_luajit\Plugins\x86_64\tolua.dll
pause