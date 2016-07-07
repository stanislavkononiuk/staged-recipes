#!/bin/bash

# In prep for Qt5, qmake/moc/rcc have been renamed
# Makefiles expect qmake/moc/rcc, so we copy and delete later
for exe in qmake moc rcc; do
    cp $PREFIX/bin/${exe}-qt4 $PREFIX/bin/${exe}
done

[[ -d build ]] || mkdir build
cd build/

export QWT_POLAR_INSTALL_PREFIX=$PREFIX
export QT_POLAR_INSTALL_PREFIX=$PREFIX

qmake ../qwtpolar.pro

make
make check
make install

# No test suite, but we can build the "examples/"
echo "Building examples to test library install"
mkdir -p examples
cd examples/

qmake ../../examples/examples.pro
make
make check

# Clean up rename/linking of 'moc'
for exe in qmake moc rcc; do
    rm $PREFIX/bin/$exe
done
