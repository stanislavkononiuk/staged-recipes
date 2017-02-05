if [ $PY3K == 1 ]; then
  CMAKE_FLAG="-DWITH_PYTHON3=ON" WITH_PYTHON3=ON PY3=ON PSF=3 PYTHONVERSION=35
else
  PYTHONVERSION=27 PSF="" CMAKE_FLAG="" TESTCOMMIT=ON
fi

if [ "$(uname)" == "Linux" ]
then
    export CXXFLAGS="${CXXFLAGS} -DBOOST_MATH_DISABLE_FLOAT128"
fi

mkdir build
pushd build

cmake $CMAKE_FLAG \
  -DCMAKE_C_COMPILER=gcc \
  -DCMAKE_CXX_COMPILER=g++ \
  -DWITH_ECOS=ON \
  -DOLD_LLVM=OFF \
  -DWITH_CLANG=OFF \
  -DWITH_SELFCONTAINED=OFF \
  -DWITH_WORHP=OFF \
  -DWITH_SLICOT=ON \
  -DWITH_PYTHON=ON \
  -DWITH_LAPACK=ON \
  -DWITH_BLASFEO=OFF \
  -DWITH_JSON=ON \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX}\
  -DPYTHON_PREFIX=${SP_DIR} \
  ..

make VERBOSE=1
make install
