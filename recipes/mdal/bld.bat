mkdir build
cd build

cmake -G "Visual Studio 16 2019" ^
	-DCMAKE_BUILD_TYPE=Rel  ^
	-DENABLE_TESTS=OFF ^
	-DNETCDF_PREFIX="%LIBRARY_PREFIX%" ^
	-DHDF5_ROOT="%LIBRARY_PREFIX%" ^
	-DGDAL_DIR="%LIBRARY_PREFIX%" ^
	-DGDAL_LIBRARY="%LIBRARY_PREFIX%\lib\gdal_i.lib" ^
	-DGDAL_INCLUDE_DIR="%LIBRARY_PREFIX%\include" ^
	-DLIBXML2_LIBRARIES="%LIBRARY_PREFIX%\lib\libxml2.lib" ^
	-DLIBXML2_INCLUDE_DIR="%LIBRARY_PREFIX%\include\libxml2" ^
	-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
	-DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
	..

cmake --build . 

copy /B mdal\Debug\*.dll %LIBRARY_BIN%
copy /B tools\Debug\*.exe %LIBRARY_BIN%

dir %LIBRARY_BIN%