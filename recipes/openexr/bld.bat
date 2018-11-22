cmake %SRC_DIR% -G "NMake Makefiles" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
    -DOPENEXR_BUILD_PYTHON_LIBS:BOOL=OFF ^
    -DOPENEXR_NAMESPACE_VERSIONING:BOOL=OFF ^
    -DOPENEXR_BUILD_STATIC:BOOL=ON ^
    -DOPENEXR_BUILD_TESTS=ON ^
    -DOPENEXR_BUILD_ILMBASE=OFF ^
    -DILMBASE_INCLUDE_DIR:PATH=%_LIBRARY_PREFIX%/include
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
