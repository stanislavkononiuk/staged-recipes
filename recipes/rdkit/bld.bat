rem surely there's a better way than this
if "%PY_VER%"=="2.7" (
	set PYTHON_LIBRARY=python27.lib
) else if  "%PY_VER%"=="3.4" (
	set PYTHON_LIBRARY=python34.lib
) else if  "%PY_VER%"=="3.5" (
	set PYTHON_LIBRARY=python35.lib
) else if  "%PY_VER%"=="3.6" (
	set PYTHON_LIBRARY=python36.lib
) else (
	echo "Unexpected version of python"
	exit 1
)

cmake ^
    -G "NMake Makefiles JOM" ^
    -D RDK_INSTALL_INTREE=OFF ^
    -D RDK_BUILD_INCHI_SUPPORT=ON ^
    -D RDK_BUILD_AVALON_SUPPORT=ON ^
    -D RDK_USE_FLEXBISON=OFF ^
    -D Python_ADDITIONAL_VERSIONS=${PY_VER} ^
    -D PYTHON_EXECUTABLE:PATH="%PYTHON%" ^
    -D PYTHON_INCLUDE_DIR:PATH="%PREFIX%\include" ^
    -D PYTHON_LIBRARY="%PREFIX%\libs\%PYTHON_LIBRARY%" ^
    -D PYTHON_INSTDIR:PATH="%SP_DIR%" ^
    -D BOOST_ROOT:PATH="%LIBRARY_PREFIX%" -D Boost_NO_SYSTEM_PATHS=ON ^
    -D CMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -D CMAKE_BUILD_TYPE=Release ^
    .
if errorlevel 1 exit 1


jom -j%CPU_COUNT%
if errorlevel 1 exit 1

jom install
if errorlevel 1 exit 1

