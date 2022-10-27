mkdir build
cd build
if %errorlevel% neq 0 exit /b %errorlevel%

cmake %SRC_DIR% ^
    -D CMAKE_BUILD_TYPE="Release" ^
    -D CMAKE_INSTALL_PREFIX:PATH="%PREFIX%" ^
    -D CMAKE_INSTALL_LIBDIR=lib ^
    -D HPX_WITH_EXAMPLES=FALSE ^
    -D HPX_WITH_FETCH_ASIO=TRUE ^
    -D HPX_WITH_MALLOC="mimalloc" ^
    -D HPX_WITH_NETWORKING=OFF ^
    -D HPX_WITH_TESTS=FALSE ^
    -D HWLOC_ROOT="%LIBRARY_LIB%" ^
    -D HWLOC_LIBRARY="%LIBRARY_LIB%/hwloc.lib"
if %errorlevel% neq 0 exit /b %errorlevel%

cmake --build . --config Release --parallel %CPU_COUNT%
if %errorlevel% neq 0 exit /b %errorlevel%

cmake --install .
if %errorlevel% neq 0 exit /b %errorlevel%
