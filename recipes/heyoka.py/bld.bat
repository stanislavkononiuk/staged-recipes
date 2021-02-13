mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_C_COMPILER=clang-cl ^
    -DCMAKE_CXX_COMPILER=clang-cl ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DHEYOKA_PY_ENABLE_IPO=yes ^
    -DBoost_NO_BOOST_CMAKE=ON ^
    ..

cmake --build . -- -v

cmake --build . --target install
