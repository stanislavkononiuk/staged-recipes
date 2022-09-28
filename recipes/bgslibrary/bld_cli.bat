SET "CMAKE_GENERATOR_PLATFORM="
set "CMAKE_GENERATOR_TOOLSET="
cmake CMakeLists.txt -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
cmake --build . --config Release --parallel %CPU_COUNT%

MKDIR %LIBRARY_BIN%
COPY bgslibrary.exe %LIBRARY_BIN%
