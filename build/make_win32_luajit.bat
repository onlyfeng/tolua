@echo off

call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars32.bat"

echo Swtich to x86 build env
cd %~dp0\luajit2\src
call msvcbuild_mt.bat static
cd ..\..

mkdir build_lj32 & pushd build_lj32
cmake -DUSING_LUAJIT=ON -G "Visual Studio 17 2022" -A Win32 ..
IF %ERRORLEVEL% NEQ 0 cmake -DUSING_LUAJIT=ON -G "Visual Studio 17 2022" -A Win32 ..
popd
cmake --build build_lj32 --config Release
md plugin_luajit\Plugins\x86
copy /Y build_lj32\Release\tolua.dll plugin_luajit\Plugins\x86\tolua.dll
pause