set -e

mkdir build
cd build

cmake .. \
    -DCMAKE_PREFIX_PATH="$PREFIX" \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_EXAMPLES=ON \
    -DBUILD_META_EXAMPLES=OFF \
    -DBUNDLE_JSON=OFF \
    -DBUNDLE_NLOPT=OFF \
    -DENABLE_TESTING=OFF \
    -DENABLE_COVERAGE=OFF

make install -j $CPU_COUNT
