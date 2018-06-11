mkdir -p build-conda
cd build-conda
rm -rf ./*

export CPATH=${PREFIX}/include
export TBB_LINK=${PREFIX}/lib

if [ "$(uname)" == "Darwin" ]; then
    # prevent cmake from using the conda package clangdev for building
    export CC=/usr/bin/gcc
    export CXX=/usr/bin/g++
fi

cmake ../ \
      -DCMAKE_INSTALL_PREFIX=${SP_DIR} \
      -DPYTHON_EXECUTABLE=${PYTHON} \
      -DENABLE_MPI=off \
      -DENABLE_CUDA=off \
      -DBUILD_TESTING=off \
      -DENABLE_TBB=on \
      -DBUILD_JIT=on \

make install
