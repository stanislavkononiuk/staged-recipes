call %LIBRARY_BIN%\run_auto_tools_clang_conda_build.bat
if errorlevel 1 exit 1

del %LIBRARY_LIB%\libzimg.a
