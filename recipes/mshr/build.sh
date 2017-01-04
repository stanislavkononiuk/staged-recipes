INCLUDE_PATH="$PREFIX/include"
LIBRARY_PATH="$PREFIX/lib"

export LDFLAGS="-Wl,-rpath,$LIBRARY_PATH $LDFLAGS"


mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_INCLUDE_PATH="$INCLUDE_PATH" \
  -DCMAKE_LIBRARY_PATH="$LIBRARY_PATH" \
  -DENABLE_TESTS=1 \
  -DMSHR_ENABLE_VTK=0 \
  ..

make -j${CPU_COUNT}
make install
