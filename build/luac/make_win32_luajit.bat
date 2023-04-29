@echo off

call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars32.bat"

echo Swtich to x86 build env
cd %~dp0\..\luajit2\src
call msvcbuild.bat static
cd ..\..

md luac\bin_luajit\32
copy /Y luajit2\src\luajit.exe luac\bin_luajit\32\luajit.exe
xcopy /I /E /Y luajit2\src\jit luac\bin_luajit\32\jit
del /Q luac\bin_luajit\32\jit\.gitignore
pause