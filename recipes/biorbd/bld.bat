mkdir build
cd build

cmake ../^
    -G"%CMAKE_GENERATOR%"^
    -DCMAKE_BUILD_TYPE=Release^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%"^
    -DBUILD_SHARED_LIBS=OFF^
  	-DBUILD_EXAMPLE=OFF^
    -DBINDER_PYTHON3=ON^
      -DPython3_EXECUTABLE="%PREFIX%/python.exe"^
   	-DBINDER_MATLAB=OFF^
      -DMatlab_biorbd_INSTALL_DIR="%PREFIX%/MATLAB"


cmake --build ./^
    --config Release^
    --target install
