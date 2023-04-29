cd "$( dirname "${BASH_SOURCE[0]}" )"
LIPO="xcrun -sdk iphoneos lipo"
STRIP="xcrun -sdk iphoneos strip"

IXCODE=`xcode-select -print-path`
ISDK=$IXCODE/Platforms/iPhoneOS.platform/Developer
ISDKVER=iPhoneOS.sdk
ISDKP=$IXCODE/usr/bin/

export MACOSX_DEPLOYMENT_TARGET='10.4'

if [ ! -e $ISDKP/ar ]; then 
  sudo cp /usr/bin/ar $ISDKP
fi

if [ ! -e $ISDKP/ranlib ]; then
  sudo cp /usr/bin/ranlib $ISDKP
fi

if [ ! -e $ISDKP/strip ]; then
  sudo cp /usr/bin/strip $ISDKP
fi

cd luajit2

XCODEVER=`xcodebuild -version|head -n 1|sed 's/Xcode \([0-9]*\).*/\1/g'`
ISOLD_XCODEVER=`echo "$XCODEVER < 10" | bc`
if [ $ISOLD_XCODEVER -eq 1 ]
then
    make clean
    ISDKF="-arch armv7 -isysroot $ISDK/SDKs/$ISDKVER -miphoneos-version-min=7.0"
    make HOST_CC="gcc -m32 -std=c99" TARGET_FLAGS="$ISDKF" TARGET=armv7 TARGET_SYS=iOS LUAJIT_A=libtoluav7.a
    
    
    make clean
    ISDKF="-arch armv7s -isysroot $ISDK/SDKs/$ISDKVER -miphoneos-version-min=7.0"
    make HOST_CC="gcc -m32 -std=c99" TARGET_FLAGS="$ISDKF" TARGET=armv7s TARGET_SYS=iOS LUAJIT_A=libtoluav7s.a
fi

make clean
ISDKF="-arch arm64 -isysroot $ISDK/SDKs/$ISDKVER -miphoneos-version-min=7.0"
make HOST_CC="gcc -std=c99" TARGET_FLAGS="$ISDKF" TARGET=arm64 TARGET_SYS=iOS LUAJIT_A=libtolua64.a


cd src
if [ $ISOLD_XCODEVER -eq 1 ]
then
    lipo libtoluav7.a -create libtoluav7s.a libtolua64.a -output libluajit.a
else
    mv libtolua64.a libluajit.a
fi
cd ../..

mkdir -p build_lj_ios && cd build_lj_ios
cmake -DUSING_LUAJIT=ON -DCMAKE_TOOLCHAIN_FILE=../cmake/ios.toolchain.cmake -DPLATFORM=OS64  -GXcode ../
cd ..
cmake --build build_lj_ios --config Release

mkdir -p plugin_luajit/Plugins/iOS/
libtool -static -o plugin_luajit/Plugins/iOS/libtolua.a build_lj_ios/Release-iphoneos/libtolua.a luajit2/src/libluajit.a
