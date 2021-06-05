echo ON

mkdir build

cmake -G "NMake Makefiles" -H. -Bbuild ^
    -DPython_FIND_STRATEGY="LOCATION" ^
    -DPython_ROOT_DIR="%PREFIX%" ^
    -DPYCLINGODL_ENABLE="require" ^
    -DPYCLINGODL_INSTALL_DIR="%SP_DIR%" %
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCLINGODL_MANAGE_RPATH=Off ^
    -DCMAKE_BUILD_TYPE=Release

if errorlevel 1 exit 1

cmake --build build
if errorlevel 1 exit 1

cmake --build build --target install
if errorlevel 1 exit 1
