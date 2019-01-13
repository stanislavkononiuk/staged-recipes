#!/bin/bash
set -ex

mkdir build-dir
cd build-dir

env

perl -0pi -e 's/(target_link_libraries\([\s]+xrdpfc_print)/\1 \${LIBXML2_LIBRARIES}/smg' ../src/XrdFileCache.cmake
perl -0pi -e 's/(target_link_libraries\([\s]+xrdadler32)/\1 \${LIBXML2_LIBRARIES}/smg' ../src/XrdApps.cmake
perl -0pi -e 's/(target_link_libraries\([\s]+xrdmapc)/\1 \${LIBXML2_LIBRARIES}/smg' ../src/XrdApps.cmake
perl -0pi -e 's/(target_link_libraries\([\s]+xrdfs)/\1 \${LIBXML2_LIBRARIES}/smg' ../src/XrdCl/CMakeLists.txt
perl -0pi -e 's/(target_link_libraries\([\s]+xrdcp)/\1 \${LIBXML2_LIBRARIES}/smg' ../src/XrdCl/CMakeLists.txt


if [ "$(uname)" == "Linux" ]; then
    extra_cmake_args="-DCMAKE_AR=${GCC_AR}"
else
    extra_cmake_args=""
fi

# Set the version number explicitly to prevent xrootd using the latest commit instead
# rm -rf ../.git
# echo "v${PKG_VERSION}" > ../VERSION_INFO
git tag -f "v${PKG_VERSION}"

cmake \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR="${PREFIX}/lib" \
    -DPYTHON_EXECUTABLE="${PYTHON}" \
    -DPYTHON_INCLUDE_DIR="${PREFIX}/include" \
    -DPYTHON_LIBRARY="$PREFIX/lib/libpython${PY_VER}.so" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
    -DCMAKE_CXX_COMPILER="${GXX}" \
    -DCMAKE_C_COMPILER="${GCC}" \
    ${extra_cmake_args} \
    ..

make -j${CPU_COUNT} # VERBOSE=1

make install
