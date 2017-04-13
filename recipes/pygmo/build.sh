#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DPAGMO_WITH_EIGEN3=yes \
    -DPAGMO_WITH_NLOPT=yes  \
    -DPAGMO_INSTALL_HEADERS=no \
    -DPAGMO_BUILD_PYGMO=yes \
    ..

make

make install

nohup ipcluster start --daemonize=True;

# Give some time for the cluster to start up.
sleep 20;

# Run the test suite
python -c "import pygmo; pygmo.test.run_test_suite()"
