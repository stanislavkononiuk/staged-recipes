#!/bin/bash

#=================================================
#=GA=Settings
#=================================================

export USE_MPI="y"
export USE_MPIF="y"
export USE_MPIF4="y"

export MPI_LOC="$PREFIX" #location of openmpi installation
export CC="gcc"
export FC="gfortran"

#=================================================
#=NWChem=Settings
#=================================================
export NWCHEM_TOP="$SRC_DIR/nwchem-${PKG_VERSION}"

if [[ $ARCH = 64 ]]; then
	export TARGET=LINUX64
	export NWCHEM_TARGET=LINUX64
else
	export TARGET=LINUX
	export NWCHEM_TARGET=LINUX
fi

export NWCHEM_MODULES="all python nwxc"
export NWCHEM_LONG_PATHS=y
export USE_NOFSCHECK=Y

export PYTHONHOME="$PREFIX"
export PYTHONPATH="./:$NWCHEM_TOP/contrib/python/"
export PYTHONVERSION="2.7"
export USE_PYTHONCONFIG=y

export BLASOPT="-lopenblas -lpthread -lrt"
export BLAS_SIZE=4
export USE_64TO32=y

export USE_SCALAPACK=y
export SCALAPACK_SIZE=4
export SCALAPACK="$PREFIX"

cd "$NWCHEM_TOP"/src
make nwchem_config
make 64_to_32
make


mkdir -p "$PREFIX"/share/nwchem/libraryps/
mkdir -p "$PREFIX"/etc

cp -r "$NWCHEM_TOP"/bin/$TARGET/* "$PREFIX"/bin
cp -r "$NWCHEM_TOP"/lib/$TARGET/* "$PREFIX"/lib
# cp -r "$NWCHEM_TOP"/include/$TARGET/* "$PREFIX"/include
cp -r "$NWCHEM_TOP"/src/basis/libraries "$PREFIX"/share/nwchem/
cp -r "$NWCHEM_TOP"/src/data "$PREFIX"/share/nwchem/
cp -r "$NWCHEM_TOP"/src/nwpw/libraryps "$PREFIX"/share/nwchem/

cat > "$PREFIX/etc/default.nwchemrc" << EOF
nwchem_basis_library $PREFIX/share/nwchem/libraries/
nwchem_nwpw_library $PREFIX/share/nwchem/libraryps/
ffield amber
amber_1 $PREFIX/share/nwchem/data/amber_s/
amber_2 $PREFIX/share/nwchem/data/amber_q/
amber_3 $PREFIX/share/nwchem/data/amber_x/
amber_4 $PREFIX/share/nwchem/data/amber_u/
spce $PREFIX/share/nwchem/data/solvents/spce.rst
charmm_s $PREFIX/share/nwchem/data/charmm_s/
charmm_x $PREFIX/share/nwchem/data/charmm_x/
EOF
mkdir -p "$PREFIX/etc/conda/activate.d/" "$PREFIX/etc/conda/deactivate.d/"

cat > "$PREFIX/etc/conda/activate.d/nwchem_env.sh" << "EOF"
if [ ! -f $HOME/.nwchemrc ]; then
    ln -s $CONDA_PREFIX/etc/default.nwchemrc $HOME/.nwchemrc
	touch $HOME/.CONDANWCHEMRC
fi
EOF
cat > "$PREFIX/etc/conda/activate.d/nwchem_env.fish" << "EOF"
    bash $CONDA_PREFIX/etc/conda/activate.d/nwchem_env.sh
EOF

cat > "$PREFIX/etc/conda/deactivate.d/nwchem_env.sh" << "EOF"
if [ -f $HOME/.CONDANWCHEMRC ]; then
    rm $HOME/.CONDANWCHEMRC $HOME/.nwchemrc
fi
EOF
cat > "$PREFIX/etc/conda/deactivate.d/nwchem_env.fish" << "EOF"
    bash $CONDA_PREFIX/etc/conda/deactivate.d/nwchem_env.sh
EOF
