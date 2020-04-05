#!/bin/bash

REL_SP_DIR=$(python -c "import os;print(os.path.relpath(os.getenv('SP_DIR'), os.getenv('PREFIX')))")
sed -i.bak "s@set(PYTHON_SITE_PATH.*@set(PYTHON_SITE_PATH $REL_SP_DIR)@g" CMakeLists.txt

mkdir build
cd build

cmake \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DENABLE_SYSTEM_JSONCPP=ON \
  -DENABLE_MATHEMATICA=OFF \
  ..

make -j${CPU_COUNT}
make install

mkdir -p $PREFIX/share/cadabra2
ln -s $SP_DIR $PREFIX/share/cadabra2/python

ctest --output-on-failure -E modules -j${CPU_COUNT}
