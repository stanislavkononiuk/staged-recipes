if "%CONDA_PY%" == "27" copy %RECIPE_DIR%\\pstdint.h %SRC_DIR%\\src\\stdint.h
mkdir build && cd build
cmake ^
	-G "%CMAKE_GENERATOR%"                   ^
	-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%  ^
	-DBIN_INSTALL_DIR=%LIBRARY_BIN%     ^
	-DLIB_INSTALL_DIR=%LIBRARY_LIB%     ^
	-DINCLUDE_INSTALL_DIR=%LIBRARY_INC% ^
	..

cmake --build . --config Release --target INSTALL
