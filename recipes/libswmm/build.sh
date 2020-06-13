cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX CMakeLists.txt
cmake --build . --config Release
# cmake --install $SRC_DIR -v
mkdir -p $PREFIX/bin $PREFIX/lib
install $SRC_DIR/bin/run-swmm $PREFIX/bin
install $SRC_DIR/lib/libswmm5.so $PREFIX/lib
install $SRC_DIR/lib/libswmm-output.so $PREFIX/lib
