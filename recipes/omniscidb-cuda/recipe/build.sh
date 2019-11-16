#!/usr/bin/env bash

set -ex

# Make sure -fPIC is not in CXXFLAGS (that some conda packages may
# add), otherwise omniscidb server will crash when executing generated
# machine code:
export CXXFLAGS="`echo $CXXFLAGS | sed 's/-fPIC//'`"

# Fixes https://github.com/Quansight/pearu-sandbox/issues/7
#       https://github.com/omnisci/omniscidb/issues/374
export CXXFLAGS="$CXXFLAGS -Dsecure_getenv=getenv"

# Fixes `error: expected ')' before 'PRIxPTR'`
export CXXFLAGS="$CXXFLAGS -D__STDC_FORMAT_MACROS"

# resolves `fatal error: boost/regex.hpp: No such file or directory`
echo -e "#!/bin/sh\n$(which nvcc || omniscidb_build_sh_could_not_find_nvcc) -I$PREFIX/include \$@" > $PWD/nvcc
chmod +x $PWD/nvcc
export PATH=$PWD:$PATH

# Remove --as-needed to resolve undefined reference to `__vdso_clock_gettime@GLIBC_PRIVATE'
export LDFLAGS="`echo $LDFLAGS | sed 's/-Wl,--as-needed//'`"

export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX}"
export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DCUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME"

# Required for building on a CUDA enabled system without libcuda.so.1
export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DCMAKE_LIBRARY_PATH=$CUDA_HOME/lib64/stubs"

mkdir -p build
cd build

# TODO: when building on a system with no GPUs, using
# -DENABLE_TESTS=off will save build time

cmake -Wno-dev \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX/opt/omnisci \
    -DCMAKE_BUILD_TYPE=release \
    -DMAPD_DOCS_DOWNLOAD=off \
    -DENABLE_AWS_S3=off \
    -DENABLE_CUDA=on \
    -DENABLE_FOLLY=off \
    -DENABLE_JAVA_REMOTE_DEBUG=off \
    -DENABLE_PROFILER=off \
    -DENABLE_TESTS=on \
    -DPREFER_STATIC_LIBS=off \
    $EXTRA_CMAKE_OPTIONS \
    ..

make -j $CPU_COUNT

# skip tests when libcuda.so is not available
if [ "`ldd bin/initdb | grep "not found" | tr -d '[:space:]'`" == "libcuda.so.1=>notfound" ]; then
    echo "SKIP RUNNING SANITY TESTS: libcuda.so.1 not found"
else
    # Omnisci UDF support uses CLangTool for parsing Load-time UDF C++
    # code to AST. If the C++ code uses C++ std headers, we need to
    # specify the locations of include directories:
    . ${RECIPE_DIR}/get_cxx_include_path.sh
    export CPLUS_INCLUDE_PATH=$(get_cxx_include_path)

    # Running sanity tests requires CUDA enabled system with GPU(s).
    mkdir tmp
    $PREFIX/bin/initdb tmp
    make sanity_tests
    rm -rf tmp
fi

make install

for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
