
mkdir build
cd build

cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D EXIV2_BUILD_SAMPLES=OFF \
      ..

make -j$CPU_COUNT
make install
