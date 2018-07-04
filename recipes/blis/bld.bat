copy "%RECIPE_DIR%\build.sh" .
set PREFIX=%PREFIX:\=/%
set LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%
set SRC_DIR=%SRC_DIR:\=/%
set MSYSTEM=MINGW%ARCH%
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1


set CC=clang
set RANLIB=echo

copy %LIBRARY_LIB%\pthreads.lib %LIBRARY_LIB%\pthread.lib
copy %LIBRARY_LIB%\pthreads.lib %LIBRARY_LIB%\m.lib
copy %BUILD_PREFIX%\Library\llvm-ar.exe %BUILD_PREFIX%\Library\ar.exe
copy %BUILD_PREFIX%\Library\llvm-as.exe %BUILD_PREFIX%\Library\as.exe

bash -lc "./build.sh"
if errorlevel 1 exit 1

del %LIBRARY_LIB%\pthread.lib
del %LIBRARY_LIB%\m.lib
