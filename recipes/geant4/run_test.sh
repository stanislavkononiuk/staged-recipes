#!/bin/bash
declare -a CMAKE_PLATFORM_FLAGS

cmake ${PREFIX}/share/Geant4-${PKG_VERSION}/examples/basic/B1
make
source ${PREFIX}/bin/geant4.sh
./exampleB1 run2.mac
