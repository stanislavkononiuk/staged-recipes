mkdir build
pushd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release     \
      -DBUILD_TESTING=OFF            \
      -Wno-dev \
      ..

make -j ${CPU_COUNT}
make check
make install
popd
