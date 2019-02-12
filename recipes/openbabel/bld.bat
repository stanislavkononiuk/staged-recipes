cmake ^
      -G "%CMAKE_GENERATOR%" ^
      -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -DWITH_INCHI=ON ^
      -DPYTHON_EXECUTABLE=%PYTHON% ^
      -DPYTHON_BINDINGS=ON ^
      -DRUN_SWIG=ON ^
      -DCMAKE_BUILD_TYPE=Release ^
      .

cmake --build . --target install --config Release

:: Where should BABEL_DATADIR go?
xcopy %PREFIX%\bin\data %PREFIX%\share\openbabel /e /c
rmdir /s /q %PREFIX%\bin\data
