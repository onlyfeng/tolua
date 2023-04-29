mkdir -p build_lj_osx && cd build_lj_osx
cmake -DUSING_LUAJIT=ON -GXcode ../
cd ..
cmake --build build_lj_osx --config Release
mkdir -p plugin_luajit/Plugins/tolua.bundle/Contents/MacOS/
cp build_lj_osx/Release/tolua.bundle/Contents/MacOS/tolua plugin_luajit/Plugins/tolua.bundle/Contents/MacOS/tolua

