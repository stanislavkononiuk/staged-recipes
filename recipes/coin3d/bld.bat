mkdir build
cd build

cmake .. -G "Ninja" ^
    -DCMAKE_PREFIX_PATH:FILEPATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX:FILEPATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_BUILD_TYPE="Release" ^
	-DCOIN_LINK_LIBSIMAGE="dynamic"

if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1
