set -xe
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=ON ..
make -j
make test
make install
