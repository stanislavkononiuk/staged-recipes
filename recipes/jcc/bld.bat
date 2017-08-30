:: Paths assume openjdk installed by conda
set JCC_JDK=%JAVA_HOME%

set PATH=%JCC_JDK%\jre\bin\server;%JCC_JDK%;%JCC_JDK%\jre\bin;%PATH%

set JCC_INCLUDES=%JCC_JDK%\include\win32;%JCC_JDK%\include
set JCC_LFLAGS=/DLL;/LIBPATH:%JCC_JDK%\lib;Ws2_32.lib;jvm.lib

:: set

"%PYTHON%" setup.py install --single-version-externally-managed --record record.txt
if errorlevel 1 exit 1

:: ensure that JCC_JDK is set correctly
set ACTIVATE_DIR=%PREFIX%\etc\conda\activate.d
set DEACTIVATE_DIR=%PREFIX%\etc\conda\deactivate.d
mkdir %ACTIVATE_DIR%
mkdir %DEACTIVATE_DIR%

copy %RECIPE_DIR%\scripts\activate.bat %ACTIVATE_DIR%\jcc-activate.bat
if errorlevel 1 exit 1

copy %RECIPE_DIR%\scripts\deactivate.bat %DEACTIVATE_DIR%\jcc-deactivate.bat
if errorlevel 1 exit 1
