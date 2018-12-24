@ECHO ON

SETLOCAL ENABLEDELAYEDEXPANSION

:: Copy the vs20xx solution files which
:: were created by converting the .dsw files
xcopy /s %RECIPE_DIR%\vs%VS_YEAR% %SRC_DIR%\

SET XML_PARSER=expat

SET BUILD_MODE=Release

IF "%ARCH%"=="32" (
    SET PLATFORM=Win32
) ELSE (
    SET PLATFORM=x64
)

:: Nasty hack to force the newer MSBuild from .NET is still used for the older
:: Visual Studio build. Without this an older MSBuild will be picked up by accident on
:: AppVeyor after running `vcvars32.bat`, which fails to process our solution files.
::
:: ref: https://github.com/conda-forge/staged-recipes/pull/194#issuecomment-203577297
:: ref: https://github.com/conda-forge/libsodium-feedstock/commit/b411740e0f439d5a5d257f74f74945f86585684a#diff-d04c86b6bb20341f5f7c53165501a393R12
:: ref: https://stackoverflow.com/q/2709279
::
:: Also there is some bug using MSBuild from .NET to build with VS 2008 64-bit, which
:: we workaround as well.
::
:: ref: https://social.msdn.microsoft.com/Forums/vstudio/en-US/19bb86ab-258a-40a9-b9fc-3bf36cac46bc/team-build-error-msb4018-the-quotresolvevcprojectoutputquot-task-failed-unexpectedly?forum=tfsbuild
if %VS_MAJOR% == 9 (
    set "PATH=C:\Windows\Microsoft.NET\Framework\v4.0.30319;%PATH%"
    set VC_PROJECT_ENGINE_NOT_USING_REGISTRY_FOR_INIT=1
)

:: This is required for picking up expat headers and lib
IF "%VS_YEAR%"=="2008" (
    SET ENVOPT="/p:VCBuildUseEnvironment=true"
) ELSE (
    SET ENVOPT="/p:UseEnv=true"
)

:: APR creates 32 bit builds in the "Debug" and "Release" directories
:: but 64 bit builds in the "x64\Debug" or "x64\Release" directories.
SET SHARED_LIBDIR=%BUILD_MODE%
IF %PLATFORM% == x64 SET SHARED_LIBDIR=x64\%SHARED_LIBDIR%

SET STATIC_LIBDIR=LibR
IF %PLATFORM% == x64 SET STATIC_LIBDIR=x64\%STATIC_LIBDIR%

MKDIR %LIBRARY_PREFIX%\LibR

:: The target 'aprutil' depends on apr and apr-iconv
:: so everything we need is built.
msbuild apr-util\aprutil.sln ^
        /p:Configuration=%BUILD_MODE% ^
        /p:Platform=%PLATFORM% ^
        %ENVOPT% ^
        /t:libaprutil

IF ERRORLEVEL 1 (ECHO Failed to build APR shared library & EXIT /b 1)

msbuild apr-util\aprutil.sln ^
        /p:Configuration=%BUILD_MODE% ^
        /p:Platform=%PLATFORM% ^
        %ENVOPT% ^
        /t:aprutil

IF ERRORLEVEL 1 (ECHO Failed to build APR static library & EXIT /b 1)

for %%i in (apr apr-util apr-iconv) do (
  SET PROJ_DIR=%%i
  SET PROJ_LIB=!PROJ_DIR:-=!

  copy !PROJ_DIR!\%SHARED_LIBDIR%\lib!PROJ_LIB!-1.dll %LIBRARY_BIN%\
  copy !PROJ_DIR!\%SHARED_LIBDIR%\lib!PROJ_LIB!-1.lib %LIBRARY_LIB%\
  IF EXIST !PROJ_DIR!\%SHARED_LIBDIR%\lib!PROJ_LIB!-1.pdb copy !PROJ_DIR!\%SHARED_LIBDIR%\lib!PROJ_LIB!-1.pdb %LIBRARY_BIN%\

  copy !PROJ_DIR!\%STATIC_LIBDIR%\!PROJ_LIB!-1.lib %LIBRARY_PREFIX%\LibR\
  IF EXIST !PROJ_DIR!\%STATIC_LIBDIR%\!PROJ_LIB!-1.pdb copy !PROJ_DIR!\%STATIC_LIBDIR%\!PROJ_LIB!-1.pdb %LIBRARY_PREFIX%\LibR\

  xcopy !PROJ_DIR!\include\*.h %LIBRARY_INC%\
)

IF NOT EXIST %LIBRARY_BIN%\iconv MKDIR %LIBRARY_BIN%\iconv
copy apr-iconv\%SHARED_LIBDIR%\iconv\*.so %LIBRARY_BIN%\iconv
copy apr-iconv\%SHARED_LIBDIR%\iconv\*.pdb %LIBRARY_BIN%\iconv

mkdir %LIBRARY_INC%\arch\win32

copy apr\include\arch\apr_private_common.h %LIBRARY_INC%\arch\
xcopy apr\include\arch\win32\*.h %LIBRARY_INC%\arch\win32\
