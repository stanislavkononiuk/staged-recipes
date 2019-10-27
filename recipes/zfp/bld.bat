setlocal EnableDelayedExpansion

:: Make a build folder and change to it.
mkdir build
cd build

:: Configure using the CMakeFiles
cmake -GNinja -DBUILD_ZFPY=ON -DZFP_WITH_OPENMP=OFF -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ..
if errorlevel 1 exit 1

:: Build and Install
cmake --build . --target install --config Release
if errorlevel 1 exit 1

:: Run tests
ctest
bin/testzfp
