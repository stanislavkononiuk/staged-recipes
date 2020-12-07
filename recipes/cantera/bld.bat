@ECHO off

echo ****************************
echo BUILD STARTED
echo ****************************

REM IF %ARCH% EQU 64 (
REM    CALL "%VS141COMNTOOLS%"\..\..\VC\bin\amd64\vcvars64.bat
REM ) ELSE (
REM    CALL "%VS150COMNTOOLS%"\..\..\VC\bin\vcvars32.bat
REM )

:: Have to use CALL to prevent the script from exiting after calling SCons
CALL scons clean
IF ERRORLEVEL 1 EXIT 1

DEL /F cantera.conf

COPY "%RECIPE_DIR%\..\.ci_support\cantera_base.conf" cantera.conf
ECHO msvc_version='14.1' >> cantera.conf

:: Set the number of CPUs to use in building
SET /A CPU_USE=%CPU_COUNT% / 2
IF %CPU_USE% EQU 0 SET CPU_USE=1

SET "ESC_PREFIX=%PREFIX:\=/%"
ECHO prefix="%ESC_PREFIX%" >> cantera.conf
ECHO boost_inc_dir="%ESC_PREFIX%/Library/include" >> cantera.conf

CALL scons build -j%CPU_USE%
IF ERRORLEVEL 1 EXIT 1

echo ****************************
echo BUILD COMPLETED SUCCESSFULLY
echo ****************************
