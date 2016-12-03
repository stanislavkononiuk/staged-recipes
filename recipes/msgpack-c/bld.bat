mkdir build
cd build

IF "%ARCH%"=="32" (
    SET EXTRA_COMPILE_FLAGS="/wd4267"
) ELSE (
    SET EXTRA_COMPILE_FLAGS=""
)

cmake ^
    -G "%CMAKE_GENERATOR%" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_CXX_FLAGS='"/D_VARIADIC_MAX=10 /EHsc %EXTRA_COMPILE_FLAGS%"' ^
    -DCMAKE_C_FLAGS="%COMPILE_FLAGS%" ^
    -DBoost_INCLUDE_DIRS=%LIBRARY_PREFIX%\include ^
    -DMSGPACK_BOOST_DIR=%LIBRARY_PREFIX%\include ^
    -DMSGPACK_BOOST=YES ^
    -DCMAKE_BUILD_TYPE=Release ^
    ..

cmake --build . --config Release
cmake --build . --config Release --target install
