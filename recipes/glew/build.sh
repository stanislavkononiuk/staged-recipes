#!/bin/bash
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} ./cmake
make -j4
make install
# glew installs to /lib64 in some occasions, but conda only uses /lib and
# also changes the rpath to these locations. If this is the case, move the
# libraries from /lib64 to /lib

if [ -f "${PREFIX}/lib64/libGLEW.so" ]; then
   mv "${PREFIX}/lib64/libGLEW.so" "${PREFIX}/lib/libGLEW.so"
fi

if [ -f "${PREFIX}/lib64/libGLEW.a" ]; then
   mv "${PREFIX}/lib64/libGLEW.a" "${PREFIX}/lib/libGLEW.a"
fi

if [ -f "${PREFIX}/lib64/pkgconfig/glew.pc" ]; then
   mv "${PREFIX}/lib64/pkgconfig/glew.pc" "${PREFIX}/lib/pkgconfig/glew.pc"
fi

if [ -d "${PREFIX}/lib64/cmake/glew/" ]; then
   mv "${PREFIX}/lib64/cmake/glew" "${PREFIX}/lib/cmake/glew"
fi

# Check if the lib64 is empty (cmake might have created it) and if so,
# delete it
if [ "$(ls -A ${PREFIX}/lib64/cmake)" ]; then
	rm -rf "${PREFIX}/lib64/cmake"
fi
if [ "$(ls -A ${PREFIX}/lib64)" ]; then
	rm -rf "${PREFIX}/lib64/"
fi