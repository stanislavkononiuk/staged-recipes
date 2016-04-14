nmake /f Makefile.win clean all
if errorlevel 1 exit 1

REM Install step
copy windows\libsvm.dll %LIBRARY_LIB%\libsvm.dll
if errorlevel 1 exit 1
xcopy windows\*.exe %LIBRARY_BIN%\
if errorlevel 1 exit 1
copy svm.h %LIBRARY_INC%\svm.h
if errorlevel 1 exit 1
