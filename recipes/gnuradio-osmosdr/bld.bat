setlocal EnableDelayedExpansion
@echo on

:: define NOMINMAX since gnuradio headers expect min/max to be functions not macros
set "CFLAGS=%CFLAGS% -DNOMINMAX"
set "CXXFLAGS=%CXXFLAGS% -DNOMINMAX"

:: Make a build folder and change to it
mkdir build
cd build

:: configure
:: enable components explicitly so we get build error when unsatisfied
cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DPYTHON_EXECUTABLE:PATH="%PYTHON%" ^
    -DBoost_NO_BOOST_CMAKE=ON ^
    -DGR_PYTHON_DIR:PATH="%SP_DIR%" ^
    -DMPIR_LIBRARY="%LIBRARY_LIB%\mpir.lib" ^
    -DMPIRXX_LIBRARY="%LIBRARY_LIB%\mpir.lib" ^
    -DENABLE_AIRSPY=OFF ^
    -DENABLE_AIRSPYHF=OFF ^
    -DENABLE_BLADERF=OFF ^
    -DENABLE_DOXYGEN=OFF ^
    -DENABLE_FILE=ON ^
    -DENABLE_FREESRP=OFF ^
    -DENABLE_HACKRF=OFF ^
    -DENABLE_IQBALANCE=OFF ^
    -DENABLE_MIRI=OFF ^
    -DENABLE_NONFREE=OFF ^
    -DENABLE_OSMOSDR=OFF ^
    -DENABLE_PYTHON=ON ^
    -DENABLE_REDPITAYA=OFF ^
    -DENABLE_RFSPACE=OFF ^
    -DENABLE_RTL=OFF ^
    -DENABLE_RTL_TCP=OFF ^
    -DENABLE_SOAPY=ON ^
    -DENABLE_UHD=OFF ^
    ..
if errorlevel 1 exit 1

:: build
cmake --build . --config Release -- -j%CPU_COUNT%
if errorlevel 1 exit 1

:: install
cmake --build . --config Release --target install
if errorlevel 1 exit 1
