mkdir build
cd build

cmake .. ^
    %CMAKE_ARGS% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DBUILD_SHARED=ON ^
    -DBUILD_STATIC=OFF ^
    -DBUILD_BINDINGS=OFF ^
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=TRUE ^
    -G "Ninja"

ninja install