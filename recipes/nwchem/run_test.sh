#!/bin/bash -f

if [[ "$mpi" == "openmpi" ]]; then
    export OMPI_MCA_plm_rsh_agent=sh
fi

export NWCHEM_TOP=$SRC_DIR
export NWCHEM_EXECUTABLE=$PREFIX/bin/nwchem
export NWCHEM_TARGET=""
export MPIRUN_PATH=$PREFIX/bin/mpirun 
export NWCHEM_BASIS_LIBRARY=$PREFIX/share/nwchem/libraries/

cd $NWCHEM_TOP/QA
./doafewqmtests.mpi 2
