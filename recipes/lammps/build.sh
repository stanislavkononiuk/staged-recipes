#!/bin/bash

args="-DENABLE_ASPHERE=ON -DENABLE_BODY=ON -DENABLE_CLASS2=ON -DENABLE_COLLOID=ON -DENABLE_COMPRESS=OFF -DENABLE_CORESHELL=ON -DENABLE_DIPOLE=ON -DENABLE_GRANULAR=ON -DENABLE_KSPACE=ON -DENABLE_MANYBODY=ON -DENABLE_MC=ON -DENABLE_MEAM=ON -DENABLE_MISC=ON -DENABLE_MOLECULE=ON -DENABLE_PERI=ON -DENABLE_REAX=ON -DENABLE_REPLICA=ON -DENABLE_RIGID=ON -DENABLE_SHOCK=ON -DENABLE_SNAP=ON -DENABLE_SRD=ON -DENABLE_OPT=ON -DENABLE_KIM=OFF -DENABLE_GPU=OFF -DENABLE_KOKKOS=OFF -DENABLE_MPIIO=OFF -DENABLE_MSCG=OFF -DENABLE_VORONOI=OFF -DENABLE_LATTE=OFF -DENABLE_PYTHON=OFF -DENABLE_USER-MEAMC=ON -DENABLE_USER-PHONON=ON -DENABLE_GZIP=ON"

# MPI
cmake ./cmake "$args -DBUILD_MPI=ON"
make
cp lmp $PREFIX/bin/lmp_mpi

# serial 
cmake ./cmake $args
make 
cp lmp $PREFIX/bin/lmp_serial

# Library
cmake ./cmake "$args -DBUILD_SHARED_LIBS=ON"
make
cd ./python
python install.py
cd ..
