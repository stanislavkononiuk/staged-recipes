setlocal EnableDelayedExpansion

mkdir build
cd build

:: Configure
cmake -G "NMake Makefiles" ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      -DCMAKE_LIBRARY_PATH:PATH="%LIBRARY_PREFIX%;%LIBRARY_PREFIX%/bin" ^
      ..
if errorlevel 1 exit 1

:: Build
nmake
if errorlevel 1 exit 1

:: Install
nmake install
